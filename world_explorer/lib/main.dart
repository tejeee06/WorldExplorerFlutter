import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'screens/favorites_screen.dart';
import 'screens/search_screen.dart';
import 'services/preferences_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES');

  runApp(const WorldExplorerApp());
}

class WorldExplorerApp extends StatefulWidget {
  const WorldExplorerApp({super.key});

  @override
  State<WorldExplorerApp> createState() => _WorldExplorerAppState();
}

class _WorldExplorerAppState extends State<WorldExplorerApp> {
  final PreferencesService _preferencesService = PreferencesService();

  bool _darkMode = false;
  bool _useFahrenheit = false;
  bool _loadingPreferences = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final darkMode = await _preferencesService.getDarkMode();
    final fahrenheit = await _preferencesService.getFahrenheit();

    setState(() {
      _darkMode = darkMode;
      _useFahrenheit = fahrenheit;
      _loadingPreferences = false;
    });
  }

  Future<void> _setDarkMode(bool value) async {
    await _preferencesService.setDarkMode(value);
    setState(() => _darkMode = value);
  }

  Future<void> _setFahrenheit(bool value) async {
    await _preferencesService.setFahrenheit(value);
    setState(() => _useFahrenheit = value);
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingPreferences) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      title: 'WorldExplorer',
      debugShowCheckedModeBanner: false,
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.dark,
      ),
      home: HomeShell(
        darkMode: _darkMode,
        useFahrenheit: _useFahrenheit,
        onDarkModeChanged: _setDarkMode,
        onFahrenheitChanged: _setFahrenheit,
      ),
    );
  }
}

class HomeShell extends StatefulWidget {
  final bool darkMode;
  final bool useFahrenheit;
  final ValueChanged<bool> onDarkModeChanged;
  final ValueChanged<bool> onFahrenheitChanged;

  const HomeShell({
    super.key,
    required this.darkMode,
    required this.useFahrenheit,
    required this.onDarkModeChanged,
    required this.onFahrenheitChanged,
  });

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      SearchScreen(useFahrenheit: widget.useFahrenheit),
      FavoritesScreen(useFahrenheit: widget.useFahrenheit),
      SettingsScreen(
        darkMode: widget.darkMode,
        useFahrenheit: widget.useFahrenheit,
        onDarkModeChanged: widget.onDarkModeChanged,
        onFahrenheitChanged: widget.onFahrenheitChanged,
      ),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Buscar',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  final bool darkMode;
  final bool useFahrenheit;
  final ValueChanged<bool> onDarkModeChanged;
  final ValueChanged<bool> onFahrenheitChanged;

  const SettingsScreen({
    super.key,
    required this.darkMode,
    required this.useFahrenheit,
    required this.onDarkModeChanged,
    required this.onFahrenheitChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: SwitchListTile(
              title: const Text('Modo oscuro'),
              subtitle: const Text('Guarda la preferencia entre ejecuciones'),
              value: darkMode,
              onChanged: onDarkModeChanged,
              secondary: const Icon(Icons.dark_mode),
            ),
          ),
          Card(
            child: SwitchListTile(
              title: const Text('Mostrar temperaturas en Fahrenheit'),
              subtitle: Text(
                useFahrenheit
                    ? 'Unidad actual: Fahrenheit'
                    : 'Unidad actual: Celsius',
              ),
              value: useFahrenheit,
              onChanged: onFahrenheitChanged,
              secondary: const Icon(Icons.thermostat),
            ),
          ),
        ],
      ),
    );
  }
}
