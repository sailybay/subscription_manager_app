import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// Импорты экранов будут добавлены по мере их создания
// import '../../presentation/screens/auth/login_screen.dart';
// import '../../presentation/screens/home/home_screen.dart';

class AppRouter {
  AppRouter._();

  static const String loginPath = '/login';
  static const String registerPath = '/register';
  static const String homePath = '/';
  static const String analyticsPath = '/analytics';
  static const String addSubscriptionPath = '/add-subscription';

  static final GoRouter router = GoRouter(
    initialLocation: loginPath, // Начинаем с логина для теста
    routes: [
      GoRoute(
        path: loginPath,
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Login Screen'))),
      ),
      GoRoute(
        path: registerPath,
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Register Screen'))),
      ),
      GoRoute(
        path: homePath,
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Home Screen'))),
      ),
      GoRoute(
        path: analyticsPath,
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Analytics Screen'))),
      ),
      GoRoute(
        path: addSubscriptionPath,
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Add Subscription'))),
      ),
    ],
  );
}
