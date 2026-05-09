import 'package:flutter/material.dart';

String weatherCodeDescription(int code) {
  switch (code) {
    case 0:
      return 'Cielo despejado';
    case 1:
      return 'Mayormente despejado';
    case 2:
      return 'Parcialmente nublado';
    case 3:
      return 'Nublado';
    case 45:
    case 48:
      return 'Niebla';
    case 51:
    case 53:
    case 55:
      return 'Llovizna';
    case 56:
    case 57:
      return 'Llovizna helada';
    case 61:
    case 63:
    case 65:
      return 'Lluvia';
    case 66:
    case 67:
      return 'Lluvia helada';
    case 71:
    case 73:
    case 75:
      return 'Nieve';
    case 77:
      return 'Granos de nieve';
    case 80:
    case 81:
    case 82:
      return 'Chubascos';
    case 85:
    case 86:
      return 'Chubascos de nieve';
    case 95:
      return 'Tormenta';
    case 96:
    case 99:
      return 'Tormenta con granizo';
    default:
      return 'Condición desconocida';
  }
}

IconData weatherCodeIcon(int code) {
  switch (code) {
    case 0:
      return Icons.wb_sunny;
    case 1:
    case 2:
      return Icons.wb_cloudy;
    case 3:
      return Icons.cloud;
    case 45:
    case 48:
      return Icons.foggy;
    case 51:
    case 53:
    case 55:
    case 56:
    case 57:
      return Icons.grain;
    case 61:
    case 63:
    case 65:
    case 66:
    case 67:
    case 80:
    case 81:
    case 82:
      return Icons.water_drop;
    case 71:
    case 73:
    case 75:
    case 77:
    case 85:
    case 86:
      return Icons.ac_unit;
    case 95:
    case 96:
    case 99:
      return Icons.thunderstorm;
    default:
      return Icons.help_outline;
  }
}

double celsiusToFahrenheit(double celsius) {
  return (celsius * 9 / 5) + 32;
}

String formatTemperature(double celsius, bool useFahrenheit) {
  final value = useFahrenheit ? celsiusToFahrenheit(celsius) : celsius;
  final unit = useFahrenheit ? '°F' : '°C';
  return '${value.toStringAsFixed(1)} $unit';
}