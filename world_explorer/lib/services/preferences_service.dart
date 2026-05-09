import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const _favoritesKey = 'favorites';
  static const _historyKey = 'search_history';
  static const _darkModeKey = 'dark_mode';
  static const _fahrenheitKey = 'fahrenheit';

  Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoritesKey) ?? [];
  }

  Future<bool> isFavorite(String countryName) async {
    final favorites = await getFavorites();
    return favorites.contains(countryName);
  }

  Future<List<String>> toggleFavorite(String countryName) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoritesKey) ?? [];

    if (favorites.contains(countryName)) {
      favorites.remove(countryName);
    } else {
      favorites.add(countryName);
      favorites.sort();
    }

    await prefs.setStringList(_favoritesKey, favorites);
    return favorites;
  }

  Future<List<String>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_historyKey) ?? [];
  }

  Future<List<String>> addSearchToHistory(String countryName) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_historyKey) ?? [];

    history.removeWhere(
      (item) => item.toLowerCase() == countryName.toLowerCase(),
    );

    history.insert(0, countryName);

    final limitedHistory = history.take(5).toList();
    await prefs.setStringList(_historyKey, limitedHistory);
    return limitedHistory;
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }

  Future<bool> getFahrenheit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_fahrenheitKey) ?? false;
  }

  Future<void> setFahrenheit(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_fahrenheitKey, value);
  }
}