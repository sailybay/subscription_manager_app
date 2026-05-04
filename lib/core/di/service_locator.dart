import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/subscription_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/subscription/subscription_bloc.dart';

final sl = GetIt.instance; // sl - service locator

Future<void> init() async {
  // --- External ---
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // --- Database ---
  sl.registerLazySingleton(() => AppDatabase());

  // --- Repositories ---
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<SubscriptionRepository>(
    () => SubscriptionRepositoryImpl(sl()),
  );

  // --- Blocs ---
  sl.registerLazySingleton(
    () => AuthBloc(sl()),
  );
  sl.registerLazySingleton(
    () => SubscriptionBloc(sl()),
  );
}
