import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as p;
import '../../domain/entities/subscription.dart';
import '../utils/app_utils.dart';

/// Сервис экспорта данных.
/// Содержит всю логику работы с файловой системой и шарингом.
/// Экраны вызывают методы этого сервиса и не знают деталей реализации.
class ExportService {
  ExportService._();

  /// Экспортирует список подписок в CSV и открывает меню «Поделиться».
  /// Возвращает [ExportResult] с результатом операции.
  static Future<ExportResult> exportSubscriptionsCsv(
      List<Subscription> subscriptions) async {
    if (subscriptions.isEmpty) {
      return ExportResult.empty();
    }

    try {
      final csv = AppUtils.generateSubscriptionCsv(subscriptions);

      Directory directory;
      if (Platform.isWindows) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getTemporaryDirectory();
      }

      final fileName =
          'subscriptions_export_${DateTime.now().millisecondsSinceEpoch}.csv';
      final filePath = p.join(directory.path, fileName);

      await File(filePath).writeAsString(csv);
      debugPrint('[ExportService] File saved to: $filePath');

      try {
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(filePath)],
            subject: 'Экспорт подписок',
          ),
        );
        return ExportResult.success(filePath);
      } catch (_) {
        // Если плагин шаринга недоступен — файл уже сохранён на диске
        return ExportResult.savedOnly(fileName);
      }
    } catch (e) {
      debugPrint('[ExportService] Export error: $e');
      return ExportResult.failure(e.toString());
    }
  }
}

/// Результат операции экспорта.
sealed class ExportResult {
  const ExportResult();

  factory ExportResult.success(String path) = ExportSuccess;
  factory ExportResult.savedOnly(String fileName) = ExportSavedOnly;
  factory ExportResult.empty() = ExportEmpty;
  factory ExportResult.failure(String error) = ExportFailure;
}

class ExportSuccess extends ExportResult {
  final String filePath;
  const ExportSuccess(this.filePath);
}

class ExportSavedOnly extends ExportResult {
  final String fileName;
  const ExportSavedOnly(this.fileName);
}

class ExportEmpty extends ExportResult {
  const ExportEmpty();
}

class ExportFailure extends ExportResult {
  final String error;
  const ExportFailure(this.error);
}
