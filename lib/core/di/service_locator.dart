import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/subscription_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../presentation/blocs/subscription/subscription_bloc.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../services/notification_service.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator() async {
  // External
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  // Database
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // Services
  final notificationService = NotificationService();
  await notificationService.init();
  sl.registerSingleton<NotificationService>(notificationService);

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl<SharedPreferences>()));
  sl.registerLazySingleton<SubscriptionRepository>(
    () => SubscriptionRepositoryImpl(sl<AppDatabase>()),
  );

  // Blocs
  sl.registerLazySingleton<AuthBloc>(() => AuthBloc(sl<AuthRepository>()));
  sl.registerLazySingleton<SubscriptionBloc>(
    () => SubscriptionBloc(
        sl<SubscriptionRepository>(), sl<NotificationService>()),
  );
}
