import 'dart:async';
import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../database/app_database.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SharedPreferences _prefs;
  final AppDatabase _db;
  final _controller = StreamController<UserEntity?>();

  AuthRepositoryImpl(this._prefs, this._db) {
    _init();
  }

  void _init() {
    final email = _prefs.getString(SessionKeys.currentUserEmail);
    if (email != null) {
      _controller.add(UserEntity(id: 'local', email: email));
    } else {
      _controller.add(null);
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges => _controller.stream;

  @override
  Future<UserEntity?> getCurrentUser() async {
    final email = _prefs.getString(SessionKeys.currentUserEmail);
    if (email != null) return UserEntity(id: 'local', email: email);
    return null;
  }

  @override
  Future<UserEntity?> login(String email, String password) async {
    // Поиск пользователя в БД
    final query = _db.select(_db.userTable)
      ..where((t) => t.email.equals(email));
    final userRow = await query.getSingleOrNull();

    if (userRow == null) {
      throw Exception('Пользователь не найден');
    }

    if (userRow.password != password) {
      throw Exception('Неверный пароль');
    }

    // Сохранение сессии
    await _prefs.setBool(SessionKeys.isLoggedIn, true);
    await _prefs.setString(SessionKeys.currentUserEmail, email);

    final user = UserEntity(id: userRow.id.toString(), email: userRow.email);
    _controller.add(user);
    return user;
  }

  @override
  Future<UserEntity?> register(String email, String password) async {
    try {
      // Проверка, существует ли уже такой email
      final existingQuery = _db.select(_db.userTable)
        ..where((t) => t.email.equals(email));
      final exists = await existingQuery.getSingleOrNull();

      if (exists != null) {
        throw Exception('Этот Email уже занят');
      }

      // Создание пользователя
      final id = await _db.into(_db.userTable).insert(
            UserTableCompanion.insert(
              email: email,
              password: password,
            ),
          );

      return login(email, password);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    await _prefs.remove(SessionKeys.isLoggedIn);
    await _prefs.remove(SessionKeys.currentUserEmail);
    _controller.add(null);
  }
}
