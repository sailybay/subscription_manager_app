import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SharedPreferences _prefs;
  final _controller = StreamController<UserEntity?>();

  AuthRepositoryImpl(this._prefs) {
    _init();
  }

  void _init() {
    final email = _prefs.getString('user_email');
    if (email != null) {
      _controller.add(UserEntity(id: '1', email: email));
    } else {
      _controller.add(null);
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges => _controller.stream;

  @override
  Future<UserEntity?> getCurrentUser() async {
    final email = _prefs.getString('user_email');
    if (email != null) return UserEntity(id: '1', email: email);
    return null;
  }

  @override
  Future<UserEntity?> login(String email, String password) async {
    // Имитация задержки сети
    await Future.delayed(const Duration(seconds: 1));
    await _prefs.setString('user_email', email);
    final user = UserEntity(id: '1', email: email);
    _controller.add(user);
    return user;
  }

  @override
  Future<UserEntity?> register(String email, String password) async {
    return login(email, password);
  }

  @override
  Future<void> logout() async {
    await _prefs.remove('user_email');
    _controller.add(null);
  }
}
