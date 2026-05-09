import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/country.dart';
import 'api_exception.dart';

class CountriesService {
  final http.Client _client;

  CountriesService({http.Client? client}) : _client = client ?? http.Client();

  Future<Country> searchCountryByName(String name) async {
    final cleanName = name.trim();

    if (cleanName.isEmpty) {
      throw const ApiException(
        ApiErrorType.notFound,
        'Escribe el nombre de un país.',
      );
    }

    final uri = Uri.https(
      'restcountries.com',
      '/v3.1/name/$cleanName',
      {'fullText': 'false'},
    );

    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 404) {
        throw ApiException(
          ApiErrorType.notFound,
          'No se ha encontrado el país "$cleanName". Prueba a buscarlo en inglés.',
        );
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          ApiErrorType.server,
          'REST Countries ha devuelto un error ${response.statusCode}.',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! List || decoded.isEmpty || decoded.first is! Map<String, dynamic>) {
        throw const ApiException(
          ApiErrorType.malformedResponse,
          'Error del servidor. Prueba más tarde.',
        );
      }

      return Country.fromJson(decoded.first as Map<String, dynamic>);
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