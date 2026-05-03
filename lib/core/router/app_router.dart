import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../di/service_locator.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/auth/auth_state.dart';

import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/subscription/add_subscription_screen.dart';
import '../../presentation/screens/analytics/analytics_screen.dart';

class AppRouter {
  AppRouter._();

  static const String loginPath = '/login';
  static const String registerPath = '/register';
  static const String homePath = '/';
  static const String analyticsPath = '/analytics';
  static const String addSubscriptionPath = '/add-subscription';

  static final GoRouter router = GoRouter(
    initialLocation: homePath,
    refreshListenable: _RouterRefreshStream(sl<AuthBloc>().stream),
    redirect: (context, state) {
      final authState = context.read<AuthBloc>().state;
      final bool loggedIn = authState is Authenticated;
      final bool loggingIn = state.matchedLocation == loginPath ||
          state.matchedLocation == registerPath;

      if (!loggedIn && !loggingIn) return loginPath;
      if (loggedIn && loggingIn) return homePath;
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
        path: analyticsPath,
        builder: (context, state) => const AnalyticsScreen(),
      ),
      GoRoute(
        path: addSubscriptionPath,
        builder: (context, state) => const AddSubscriptionScreen(),
      ),
    ],
  );
}

// Хелпер для прослушивания стрима Bloc в GoRouter
class _RouterRefreshStream extends ChangeNotifier {
  _RouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
