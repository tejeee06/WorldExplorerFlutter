import 'package:flutter/material.dart';

import '../services/preferences_service.dart';
import 'detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final bool useFahrenheit;

  const FavoritesScreen({
    super.key,
    required this.useFahrenheit,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final PreferencesService _preferencesService = PreferencesService();

  List<String> _favorites = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favorites = await _preferencesService.getFavorites();

    if (!mounted) return;

    setState(() {
      _favorites = favorites;
      _loading = false;
    });
  }

  Future<void> _removeFavorite(String countryName) async {
    final favorites = await _preferencesService.toggleFavorite(countryName);
    setState(() => _favorites = favorites);
  }

  Future<void> _openFavorite(String countryName) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailScreen(
          countryName: countryName,
          useFahrenheit: widget.useFahrenheit,
        ),
      ),
    );

    _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Todavía no tienes favoritos. Busca un país y pulsa el corazón.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _favorites.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final countryName = _favorites[index];

                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.favorite),
                        title: Text(countryName),
                        subtitle: const Text('Tocar para ver información actualizada'),
                        onTap: () => _openFavorite(countryName),
                        trailing: IconButton(
                          tooltip: 'Eliminar favorito',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _removeFavorite(countryName),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}