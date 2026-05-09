import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/country.dart';
import '../models/weather.dart';
import '../services/api_exception.dart';
import '../services/countries_service.dart';
import '../services/preferences_service.dart';
import '../services/weather_service.dart';
import '../utils/weather_codes.dart';
import '../widgets/error_panel.dart';

class DetailScreen extends StatefulWidget {
  final String countryName;
  final Country? initialCountry;
  final bool useFahrenheit;

  const DetailScreen({
    super.key,
    required this.countryName,
    this.initialCountry,
    required this.useFahrenheit,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final CountriesService _countriesService = CountriesService();
  final WeatherService _weatherService = WeatherService();
  final PreferencesService _preferencesService = PreferencesService();

  Country? _country;
  Weather? _weather;
  bool _loading = true;
  bool _favorite = false;
  String? _errorMessage;

  final NumberFormat _integerFormat = NumberFormat.decimalPattern('es_ES');
  final NumberFormat _decimalFormat = NumberFormat.decimalPattern('es_ES');

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final country = widget.initialCountry ??
          await _countriesService.searchCountryByName(widget.countryName);

      if (!country.hasCapitalCoordinates) {
        throw const ApiException(
          ApiErrorType.malformedResponse,
          'Este país no tiene coordenadas de capital disponibles.',
        );
      }

      final weather = await _weatherService.getWeatherByCoordinates(
        latitude: country.capitalLatitude!,
        longitude: country.capitalLongitude!,
      );

      final favorite = await _preferencesService.isFavorite(country.commonName);

      if (!mounted) return;

      setState(() {
        _country = country;
        _weather = weather;
        _favorite = favorite;
      });
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (_) {
      setState(() => _errorMessage = 'Ha ocurrido un error inesperado.');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _toggleFavorite() async {
    final country = _country;
    if (country == null) return;

    final favorites = await _preferencesService.toggleFavorite(country.commonName);

    setState(() => _favorite = favorites.contains(country.commonName));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _favorite
              ? '${country.commonName} añadido a favoritos'
              : '${country.commonName} eliminado de favoritos',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _country?.commonName ?? widget.countryName;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (_country != null)
            IconButton(
              tooltip: _favorite ? 'Eliminar de favoritos' : 'Añadir a favoritos',
              onPressed: _toggleFavorite,
              icon: Icon(_favorite ? Icons.favorite : Icons.favorite_border),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: ErrorPanel(
                      message: _errorMessage!,
                      onRetry: _loadAll,
                    ),
                  ),
                )
              : _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final country = _country!;
    final weather = _weather!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _CountryHeader(country: country),
        const SizedBox(height: 16),
        _CountryBasicInfo(
          country: country,
          integerFormat: _integerFormat,
        ),
        const SizedBox(height: 16),
        _CurrentWeatherCard(
          weather: weather,
          useFahrenheit: widget.useFahrenheit,
        ),
        const SizedBox(height: 16),
        _DailyForecastCard(
          forecasts: weather.dailyForecasts,
          useFahrenheit: widget.useFahrenheit,
        ),
        const SizedBox(height: 16),
        _MoreCountryInfo(
          country: country,
          integerFormat: _integerFormat,
          decimalFormat: _decimalFormat,
        ),
      ],
    );
  }
}

class _CountryHeader extends StatelessWidget {
  final Country country;

  const _CountryHeader({required this.country});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          if (country.flagPng.isNotEmpty)
            Image.network(
              country.flagPng,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox(
                height: 180,
                child: Center(child: Icon(Icons.flag, size: 64)),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  country.commonName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  country.officialName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CountryBasicInfo extends StatelessWidget {
  final Country country;
  final NumberFormat integerFormat;

  const _CountryBasicInfo({
    required this.country,
    required this.integerFormat,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.location_city),
            title: const Text('Capital'),
            subtitle: Text(country.capital ?? 'Sin capital disponible'),
          ),
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('Región'),
            subtitle: Text(
              country.subregion == null
                  ? country.region
                  : '${country.region} · ${country.subregion}',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Población'),
            subtitle: Text(integerFormat.format(country.population)),
          ),
        ],
      ),
    );
  }
}

class _CurrentWeatherCard extends StatelessWidget {
  final Weather weather;
  final bool useFahrenheit;

  const _CurrentWeatherCard({
    required this.weather,
    required this.useFahrenheit,
  });

  @override
  Widget build(BuildContext context) {
    final current = weather.current;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  weatherCodeIcon(current.weatherCode),
                  size: 48,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Meteorología actual',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.thermostat),
              title: const Text('Temperatura'),
              subtitle: Text(formatTemperature(current.temperature, useFahrenheit)),
            ),
            ListTile(
              leading: const Icon(Icons.air),
              title: const Text('Viento'),
              subtitle: Text('${current.windSpeed.toStringAsFixed(1)} km/h'),
            ),
            ListTile(
              leading: const Icon(Icons.cloud),
              title: const Text('Condición'),
              subtitle: Text(weatherCodeDescription(current.weatherCode)),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyForecastCard extends StatelessWidget {
  final List<DailyForecast> forecasts;
  final bool useFahrenheit;

  const _DailyForecastCard({
    required this.forecasts,
    required this.useFahrenheit,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.EEEE('es_ES');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Previsión 7 días', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            if (forecasts.isEmpty)
              const Text('No hay previsión disponible.')
            else
              SizedBox(
                height: 150,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: forecasts.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final item = forecasts[index];

                    return Container(
                      width: 145,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _capitalize(dateFormat.format(item.date)),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          Icon(weatherCodeIcon(item.weatherCode), size: 32),
                          const SizedBox(height: 8),
                          Text(
                            'Máx ${formatTemperature(item.maxTemperature, useFahrenheit)}',
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            'Mín ${formatTemperature(item.minTemperature, useFahrenheit)}',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}

class _MoreCountryInfo extends StatelessWidget {
  final Country country;
  final NumberFormat integerFormat;
  final NumberFormat decimalFormat;

  const _MoreCountryInfo({
    required this.country,
    required this.integerFormat,
    required this.decimalFormat,
  });

  @override
  Widget build(BuildContext context) {
    final density = country.populationDensity;

    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.info_outline),
        title: const Text('Más información'),
        childrenPadding: const EdgeInsets.only(bottom: 12),
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Idiomas'),
            subtitle: Text(
              country.languages.isEmpty
                  ? 'No disponibles'
                  : country.languages.values.join(', '),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.payments),
            title: const Text('Monedas'),
            subtitle: Text(
              country.currencies.isEmpty
                  ? 'No disponibles'
                  : country.currencies.map((currency) => currency.formatted).join(', '),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Zonas horarias'),
            subtitle: Text(
              country.timezones.isEmpty ? 'No disponibles' : country.timezones.join(', '),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.public),
            title: const Text('Fronteras'),
            subtitle: Text(
              country.borders.isEmpty ? 'Sin fronteras' : country.borders.join(', '),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.square_foot),
            title: const Text('Área'),
            subtitle: Text('${integerFormat.format(country.area)} km²'),
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Densidad de población'),
            subtitle: Text(
              density == null
                  ? 'No disponible'
                  : '${decimalFormat.format(density)} hab/km²',
            ),
          ),
        ],
      ),
    );
  }
}