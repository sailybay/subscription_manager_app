import 'package:flutter/material.dart';
import '../../domain/entities/subscription.dart';
import '../constants/app_constants.dart';

/// Вспомогательный класс для аналитических вычислений.
/// Содержит только чистую логику без зависимости от UI-фреймворка,
/// за исключением цветов которые являются частью presentation-слоя.
class AnalyticsHelper {
  AnalyticsHelper._();

  // ─── Цветовая палитра категорий ──────────────────────────────────────────
  // Вынесена сюда как presentation-константа, а не в тело виджета.
  static const List<Color> categoryColors = [
    Colors.blueAccent,
    Colors.greenAccent,
    Colors.redAccent,
    Colors.purpleAccent,
    Colors.orangeAccent,
    Colors.tealAccent,
    Colors.pinkAccent,
  ];

  /// Возвращает цвет для категории по её названию.
  static Color getCategoryColor(String category) {
    final index = AppConstants.categories.indexOf(category);
    if (index == -1) return Colors.grey;
    return categoryColors[index % categoryColors.length];
  }

  /// Агрегирует подписки по категориям: { 'Видео': 1239.0, 'Музыка': 169.0 }
  static Map<String, double> calculateCategoryData(
      List<Subscription> subscriptions) {
    final Map<String, double> data = {};
    for (var sub in subscriptions) {
      data[sub.category] = (data[sub.category] ?? 0) + sub.price;
    }
    return data;
  }

  /// Возвращает название самой дорогой категории или null если список пуст.
  static String? getTopCategory(Map<String, double> categoryData) {
    if (categoryData.isEmpty) return null;
    return categoryData.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Вычисляет разницу трат в процентах относительно предыдущего месяца.
  /// Возвращает [diffAmount, diffPercent].
  static (double amount, double percent) calculateMonthlyDiff(
      double current, double previous) {
    final diff = current - previous;
    final percent = previous > 0 ? (diff / previous * 100).abs() : 0.0;
    return (diff, percent);
  }

  /// Форматирует строку тренда: "+12.5% к пр. мес."
  static String formatTrendLabel(double diffAmount, double diffPercent) {
    final sign = diffAmount >= 0 ? '+' : '-';
    return '$sign${diffPercent.toStringAsFixed(1)}% к пр. мес.';
  }
}
