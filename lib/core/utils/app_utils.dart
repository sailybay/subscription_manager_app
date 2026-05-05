import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class AppUtils {
  AppUtils._();

  /// Форматирование валюты с учетом переданного символа. По умолчанию рубль.
  static String formatCurrency(double amount, {String symbol = '₽'}) {
    final formatter = NumberFormat.currency(
      locale: 'ru_RU', // Можно в будущем вынести в настройки приложения
      symbol: symbol,
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  /// Компактная дата: 01.01.2024
  static String formatDate(DateTime date) =>
      DateFormat('dd.MM.yyyy').format(date);

  /// Полная дата: 1 января 2024
  static String formatFullDate(DateTime date) =>
      DateFormat('d MMMM yyyy', 'ru_RU').format(date);

  /// Валидация Email с проверкой на null и пустую строку
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Введите email';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Некорректный email';
    return null;
  }

  /// Валидация пароля
  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) return 'Введите пароль';
    if (value.length < 6) return 'Пароль должен быть не менее 6 символов';
    return null;
  }

  /// Универсальный SnackBar
  static void showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    if (!context.mounted) {
      return;
    }
    // Проверка на "живой" контекст (предотвращает баги)

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.blueAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Генерация CSV из списка подписок
  static String generateSubscriptionCsv(List<dynamic> subs) {
    if (subs.isEmpty) return '';
    final buffer = StringBuffer();
    // Заголовки
    buffer.writeln('ID,Name,Price,Category,NextBillingDate');
    // Данные
    for (var sub in subs) {
      buffer.writeln(
          '${sub.id},${sub.name},${sub.price},${sub.category},${sub.nextBillingDate}');
    }
    return buffer.toString();
  }
}
