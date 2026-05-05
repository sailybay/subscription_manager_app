import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Централизованное определение темы приложения.
/// Используется современный Dark Mode с фиолетовыми акцентами и «стеклянными» элементами.
class AppTheme {
  AppTheme._();

  // --- Базовая палитра ---
  static const Color primaryColor = Color(0xFF6C63FF); // Яркий фиолетовый
  static const Color primaryDark = Color(0xFF3D35B5);
  static const Color accentColor = Color(0xFF03DAC6); // Бирюзовый акцент

  // --- Фон и поверхности ---
  static const Color backgroundColor = Color(0xFF0F0E17); // Глубокий темный
  static const Color surfaceColor = Color(0xFF1C1B2E); // Карточки и панели
  static const Color cardColor = Color(0xFF252436); // Элементы списка

  // --- Текст ---
  static const Color textPrimary = Color(0xFFF5F5F5); // Основной белый
  static const Color textSecondary = Color(0xFFAAABBA); // Вторичный серый
  static const Color textHint = Color(0xFF6B6B7B); // Подсказки

  // --- Семантика ---
  static const Color errorColor = Color(0xFFFF4C6A);
  static const Color successColor = Color(0xFF4CAF50);

  // --- Градиенты ---
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [backgroundColor, Color(0xFF1C1B2E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // --- Базовая палитра (Light) ---
  static const Color primaryColorLight = Color(0xFF6C63FF);
  static const Color backgroundLight = Color(0xFFF8F9FE);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF1A1A2E);
  static const Color textSecondaryLight = Color(0xFF6E6E82);

  /// Конфигурация светлой темы
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryColorLight,
        secondary: Color(0xFF00BFA5),
        surface: surfaceLight,
        error: errorColor,
        onPrimary: Colors.white,
        onSurface: textPrimaryLight,
      ),
      scaffoldBackgroundColor: backgroundLight,

      // Типографика
      textTheme: GoogleFonts.interTextTheme(const TextTheme(
        displayLarge: TextStyle(
            fontSize: 32, fontWeight: FontWeight.bold, color: textPrimaryLight),
        headlineMedium: TextStyle(
            fontSize: 20, fontWeight: FontWeight.w600, color: textPrimaryLight),
        titleMedium: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w500, color: textPrimaryLight),
        bodyMedium: TextStyle(fontSize: 14, color: textSecondaryLight),
      )),

      // AppBar стиль
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: textPrimaryLight),
        iconTheme: IconThemeData(color: textPrimaryLight),
      ),

      // Карточки
      cardTheme: CardThemeData(
        color: surfaceLight,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Поля ввода (Inputs)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColorLight, width: 2),
        ),
        contentPadding: const EdgeInsets.all(20),
      ),

      // Кнопки
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColorLight,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// Конфигурация темной темы
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
        surface: surfaceColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSurface: textPrimary,
      ),
      scaffoldBackgroundColor: backgroundColor,

      // Типографика
      textTheme: GoogleFonts.interTextTheme(const TextTheme(
        displayLarge: TextStyle(
            fontSize: 32, fontWeight: FontWeight.bold, color: textPrimary),
        headlineMedium: TextStyle(
            fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
        titleMedium: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w500, color: textPrimary),
        bodyMedium: TextStyle(fontSize: 14, color: textSecondary),
      )),

      // AppBar стиль
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: textPrimary),
      ),

      // Карточки
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Поля ввода (Inputs)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2A2A40)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.all(20),
      ),

      // Кнопки
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// Утилита для быстрого получения стиля поля ввода
  static InputDecoration inputDecoration(String label) {
    return InputDecoration(
      hintText: label,
      hintStyle: const TextStyle(color: textHint),
    );
  }
}
