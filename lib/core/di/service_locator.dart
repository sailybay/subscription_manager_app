import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/database/app_database.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../../data/repositories/subscription_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../presentation/blocs/subscription/subscription_bloc.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../services/notification_service.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator() async {
  // --- External ---
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  // --- Database ---
  sl.registerSingleton<AppDatabase>(AppDatabase());

  // --- Services ---
  final notificationService = NotificationService();
  await notificationService.init();
  sl.registerLazySingleton<NotificationService>(() => notificationService);

  // --- Repositories ---
  sl.registerLazySingleton<SubscriptionRepository>(
    () => SubscriptionRepositoryImpl(sl<AppDatabase>()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<SharedPreferences>(), sl<AppDatabase>()),
  );

  // --- Blocs ---
  sl.registerLazySingleton(() => AuthBloc(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SubscriptionBloc(
      sl<SubscriptionRepository>(), sl<NotificationService>()));
}
