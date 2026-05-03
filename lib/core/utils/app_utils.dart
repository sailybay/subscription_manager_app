import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class AppUtils {
  AppUtils._();

  // --- Форматирование валюты ---
  static String formatCurrency(double amount, {String symbol = '₽'}) {
    final formatter = NumberFormat.currency(
      locale: 'ru_RU',
      symbol: symbol,
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  // --- Форматирование даты ---
  static String formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }

  static String formatFullDate(DateTime date) {
    return DateFormat('d MMMM yyyy', 'ru_RU').format(date);
  }

  // --- Валидация ---
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Введите email';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Некорректный email';
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Введите пароль';
    if (value.length < 6) return 'Пароль должен быть не менее 6 символов';
    return null;
  }

  // --- UI Helpers ---
  static void showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
