import 'package:get_it/get_it.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/subscription_repository_impl.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../../presentation/blocs/subscription/subscription_bloc.dart';
import '../services/notification_service.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator() async {
  // Database
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // Services
  final notificationService = NotificationService();
  await notificationService.init();
  sl.registerSingleton<NotificationService>(notificationService);

  // Repositories
  sl.registerLazySingleton<SubscriptionRepository>(
    () => SubscriptionRepositoryImpl(sl<AppDatabase>()),
  );

  // Blocs
  sl.registerLazySingleton<SubscriptionBloc>(
    () => SubscriptionBloc(
        sl<SubscriptionRepository>(), sl<NotificationService>()),
  );
}
