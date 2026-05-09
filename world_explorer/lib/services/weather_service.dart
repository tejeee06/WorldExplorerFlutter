import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/weather.dart';
import 'api_exception.dart';

class WeatherService {
  final http.Client _client;

  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  Future<Weather> getWeatherByCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.https(
      'api.open-meteo.com',
      '/v1/forecast',
      {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'current_weather': 'true',
        'daily': 'temperature_2m_max,temperature_2m_min,weathercode',
        'timezone': 'auto',
      },
    );

    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          ApiErrorType.server,
          'Open-Meteo ha devuelto un error ${response.statusCode}.',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw const ApiException(
          ApiErrorType.malformedResponse,
          'Error del servidor. Prueba más tarde.',
        );
      }

      return Weather.fromJson(decoded);
    } on SocketException {
      throw const ApiException(
        ApiErrorType.noInternet,
        'No hay conexión a Internet. Revisa tu conexión y reintenta.',
      );
    } on TimeoutException {
      throw const ApiException(
        ApiErrorType.timeout,
        'La petición ha tardado demasiado. Prueba de nuevo.',
      );
    } on FormatException {
      throw const ApiException(
        ApiErrorType.malformedResponse,
        'Error del servidor. Prueba más tarde.',
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException(
        ApiErrorType.unknown,
        'Ha ocurrido un error inesperado.',
      );
    }
  }
}