import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/service_locator.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/auth/auth_event.dart';
import 'presentation/blocs/subscription/subscription_bloc.dart';
import 'presentation/blocs/subscription/subscription_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Установка ориентации
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Инициализация внедрения зависимостей (включая БД и Notifications)
  await initServiceLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<AuthBloc>()..add(AuthCheckRequested()),
        ),
        BlocProvider(
          create: (context) =>
              sl<SubscriptionBloc>()..add(SubscriptionSubscriptionRequested()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Subscription Manager',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
