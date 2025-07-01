import 'package:flutter/material.dart';

class AppTheme {
  // Colores principales médicos
//   static const Color primaryBlue = Color(0xFF2E86AB);      // Azul teal profesional
//   static const Color primaryGreen = Color(0xFF52C41A);     // Verde salud
  
  // colores de BG Med
  static const Color primaryBlue = Color(0xFF008080);      // Azul teal profesional
  static const Color primaryGreen = Color(0xFF7E84F2);     // lilac salud
  static const Color accentRed = Color(0xFFE53E3E);        // Rojo emergencia
  static const Color accentOrange = Color(0xFFFD7F28);     // Naranja alerta
  static const Color neutralGray = Color(0xFF718096);      // Gris profesional
  static const Color backgroundLight = Color(0xFFF7FAFC);  // Fondo claro
  static const Color cardWhite = Color(0xFFFFFFFF);        // Blanco puro
  static const Color textDark = Color(0xFF2D3748);         // Texto oscuro
  static const Color textLight = Color(0xFF718096);        // Texto claro



  // Gradientes médicos
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, Color(0xFF4299E1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emergencyGradient = LinearGradient(
    colors: [accentRed, Color(0xFFFC8181)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [primaryGreen, Color(0xFF68D391)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Tema principal
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.light,
        primary: primaryBlue,
        secondary: primaryGreen,
        error: accentRed,
        background: backgroundLight,
        surface: cardWhite,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onError: Colors.white,
        onBackground: textDark,
        onSurface: textDark,
      ),
      
      // AppBar personalizado
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: cardWhite,
        foregroundColor: textDark,
        titleTextStyle: const TextStyle(
          color: textDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: textDark),
      ),
      
      // Cards personalizadas
      cardTheme: CardTheme(
        elevation: 3,
        shadowColor: primaryBlue.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: cardWhite,
      ),
      
      // Botones elevados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: primaryBlue.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 14,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Botones de texto
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryBlue,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Campos de entrada
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: neutralGray.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: neutralGray.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentRed, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentRed, width: 2),
        ),
        filled: true,
        fillColor: backgroundLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: const TextStyle(color: neutralGray),
        hintStyle: TextStyle(color: neutralGray.withOpacity(0.7)),
      ),
      
      // FAB personalizado
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // BottomNavigationBar personalizado
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cardWhite,
        selectedItemColor: primaryBlue,
        unselectedItemColor: neutralGray,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
      
      // TabBar personalizado
      tabBarTheme: TabBarTheme(
        labelColor: primaryBlue,
        unselectedLabelColor: neutralGray,
        indicator: UnderlineTabIndicator(
          borderSide: const BorderSide(color: primaryBlue, width: 3),
          insets: const EdgeInsets.symmetric(horizontal: 20),
        ),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
      
      // Scaffold personalizado
      scaffoldBackgroundColor: backgroundLight,
      
      // Divider personalizado
      dividerTheme: DividerThemeData(
        color: neutralGray.withOpacity(0.2),
        thickness: 1,
      ),
    );
  }

  // Colores específicos para tipos de datos médicos
  static const Map<String, Color> medicalColors = {
    'emergency': accentRed,
    'warning': accentOrange,
    'success': primaryGreen,
    'info': primaryBlue,
    'neutral': neutralGray,
  };

  // Método para obtener color por estado médico
  static Color getColorByStatus(String status) {
    return medicalColors[status.toLowerCase()] ?? neutralGray;
  }
} 