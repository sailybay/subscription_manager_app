import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// --- Таблица Подписок ---
class SubscriptionTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get price => real()();
  TextColumn get category => text()();
  DateTimeColumn get nextBillingDate => dateTime()();
}

// --- Таблица Пользователей (Новая) ---
class UserTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get email =>
      text().withLength(min: 3, max: 50).customConstraint('UNIQUE')();
  TextColumn get password => text().withLength(min: 4, max: 20)();
}

@DriftDatabase(tables: [SubscriptionTable, UserTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2; // Увеличиваем версию, так как добавили таблицу

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(userTable);
          }
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'subscription_manager.db'));
    return NativeDatabase(file);
  });
}
