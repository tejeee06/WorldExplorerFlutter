import 'package:flutter/material.dart';

import '../models/country.dart';
import '../services/api_exception.dart';
import '../services/countries_service.dart';
import '../services/preferences_service.dart';
import '../widgets/error_panel.dart';
import 'detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final bool useFahrenheit;

  const SearchScreen({
    super.key,
    required this.useFahrenheit,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final CountriesService _countriesService = CountriesService();
  final PreferencesService _preferencesService = PreferencesService();

  bool _loading = false;
  String? _errorMessage;
  List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final history = await _preferencesService.getHistory();
    setState(() => _history = history);
  }

  Future<void> _clearHistory() async {
    await _preferencesService.clearHistory();
    setState(() => _history = []);
  }

  Future<void> _search([String? forcedQuery]) async {
    final query = (forcedQuery ?? _controller.text).trim();

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final Country country = await _countriesService.searchCountryByName(query);

      final newHistory = await _preferencesService.addSearchToHistory(country.commonName);

      if (!mounted) return;

      setState(() => _history = newHistory);

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetailScreen(
            countryName: country.commonName,
            initialCountry: country,
            useFahrenheit: widget.useFahrenheit,
          ),
        ),
      );
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

  @override
  Widget build(BuildContext context) {
    final canSearch = !_loading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('WorldExplorer'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Busca un país',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Escribe el nombre en inglés. Ejemplos: Spain, France, Japan, Brazil.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            textInputAction: TextInputAction.search,
            enabled: canSearch,
            onSubmitted: (_) => _search(),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Nombre del país',
              prefixIcon: Icon(Icons.public),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: canSearch ? () => _search() : null,
            icon: const Icon(Icons.search),
            label: const Text('Buscar'),
          ),
          if (_loading) ...[
            const SizedBox(height: 24),
            const Center(child: CircularProgressIndicator()),
          ],
          if (_errorMessage != null) ...[
            const SizedBox(height: 24),
            ErrorPanel(
              message: _errorMessage!,
              onRetry: () => _search(),
            ),
          ],
          if (_history.isNotEmpty) ...[
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Últimas búsquedas',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton.icon(
                  onPressed: _clearHistory,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Borrar'),
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _history
                  .map(
                    (item) => ActionChip(
                      avatar: const Icon(Icons.history),
                      label: Text(item),
                      onPressed: () => _search(item),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}