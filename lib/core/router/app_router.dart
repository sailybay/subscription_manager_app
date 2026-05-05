import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../di/service_locator.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/auth/auth_state.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/subscription/add_subscription_screen.dart';
import '../../presentation/screens/analytics/analytics_screen.dart';
import '../../domain/entities/subscription.dart';

class AppRouter {
  AppRouter._();

  // Убираем splashPath, так как файла не существует. Стартовым сделаем логин.
  static const String loginPath = '/login';
  static const String registerPath = '/register';
  static const String homePath = '/home';
  static const String addSubscriptionPath = '/subscription/add';
  static const String analyticsPath = '/analytics';

  static final GoRouter router = GoRouter(
    initialLocation: loginPath,
    refreshListenable: _RouterRefreshStream(sl<AuthBloc>().stream),
    redirect: (context, state) {
      final authState = sl<AuthBloc>().state;

      // Проверяем, находимся ли мы на страницах входа/регистрации
      final bool isLoggingIn = state.matchedLocation == loginPath ||
          state.matchedLocation == registerPath;

      // Если состояние еще начальное или идет загрузка — остаемся (или ждем)
      if (authState is AuthInitial || authState is AuthLoading) {
        return null; // GoRouter просто подождет следующего события
      }

      // Если НЕ авторизован и НЕ на странице логина — принудительно на логин
      if (authState is! Authenticated) {
        return isLoggingIn ? null : loginPath;
      }

      // Если АВТОРИЗОВАН и на странице логина — идем домой
      if (isLoggingIn) {
        return homePath;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: loginPath,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: registerPath,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: homePath,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: addSubscriptionPath,
        builder: (context, state) => AddSubscriptionScreen(
          subscription:
              state.extra is Subscription ? state.extra as Subscription : null,
        ),
      ),
      GoRoute(
        path: analyticsPath,
        builder: (context, state) => const AnalyticsScreen(),
      ),
    ],
  );
}

class _RouterRefreshStream extends ChangeNotifier {
  _RouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
