import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Enum para los modos de tema
enum AppThemeMode { light, dark, system }

// Notificador para el tema
class ThemeNotifier extends StateNotifier<AppThemeMode> {
  ThemeNotifier() : super(AppThemeMode.system) {
    _loadTheme();
  }

  static const String _themeKey = 'theme_mode';

  // Cargar tema guardado
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeString = prefs.getString(_themeKey);
      
      if (themeString != null) {
        switch (themeString) {
          case 'light':
            state = AppThemeMode.light;
            break;
          case 'dark':
            state = AppThemeMode.dark;
            break;
          case 'system':
          default:
            state = AppThemeMode.system;
            break;
        }
      }
    } catch (e) {
      // En caso de error, usar tema del sistema
      state = AppThemeMode.system;
    }
  }

  // Cambiar tema
  Future<void> setTheme(AppThemeMode themeMode) async {
    state = themeMode;
    await _saveTheme(themeMode);
  }

  // Guardar tema
  Future<void> _saveTheme(AppThemeMode themeMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String themeString;
      
      switch (themeMode) {
        case AppThemeMode.light:
          themeString = 'light';
          break;
        case AppThemeMode.dark:
          themeString = 'dark';
          break;
        case AppThemeMode.system:
        default:
          themeString = 'system';
          break;
      }
      
      await prefs.setString(_themeKey, themeString);
    } catch (e) {
      // Manejar error silenciosamente
      print('Error al guardar tema: $e');
    }
  }

  // Alternar entre claro y oscuro
  Future<void> toggleTheme() async {
    switch (state) {
      case AppThemeMode.light:
        await setTheme(AppThemeMode.dark);
        break;
      case AppThemeMode.dark:
        await setTheme(AppThemeMode.light);
        break;
      case AppThemeMode.system:
        // Si está en sistema, cambiar a claro
        await setTheme(AppThemeMode.light);
        break;
    }
  }

  // Obtener descripción del tema actual
  String get themeDescription {
    switch (state) {
      case AppThemeMode.light:
        return 'Claro';
      case AppThemeMode.dark:
        return 'Oscuro';
      case AppThemeMode.system:
        return 'Sistema';
    }
  }

  // Obtener icono del tema actual
  IconData get themeIcon {
    switch (state) {
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
      case AppThemeMode.system:
        return Icons.brightness_auto;
    }
  }
}

// Provider del tema
final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeMode>((ref) {
  return ThemeNotifier();
});

// Provider para determinar si debe usar tema oscuro
final isDarkModeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(themeProvider);
  
  switch (themeMode) {
    case AppThemeMode.light:
      return false;
    case AppThemeMode.dark:
      return true;
    case AppThemeMode.system:
      // Usar tema del sistema
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
  }
});
