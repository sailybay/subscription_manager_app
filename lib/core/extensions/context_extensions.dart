import 'package:flutter/material.dart';

extension ContextExt on BuildContext {
  // Тема
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => theme.colorScheme;
  TextTheme get text => theme.textTheme;

  // Размеры экрана
  double get width => MediaQuery.of(this).size.width;
  double get height => MediaQuery.of(this).size.height;

  // Шрифт (удобные алиасы)
  TextStyle? get displayLarge => text.displayLarge;
  TextStyle? get headlineMedium => text.headlineMedium;
  TextStyle? get titleMedium => text.titleMedium;
  TextStyle? get bodyMedium => text.bodyMedium;

  // Навигация (короткий доступ)
  void pop<T>([T? result]) => Navigator.of(this).pop(result);
}
