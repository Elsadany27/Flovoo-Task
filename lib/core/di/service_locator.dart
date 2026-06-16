import 'package:get_it/get_it.dart';

import '../services/chat_storage_service.dart';
import '../services/hive_service.dart';
import '../services/session_service.dart';
import '../services/theme_service.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  await HiveService.instance.init();

  getIt
    ..registerLazySingleton<HiveService>(() => HiveService.instance)
    ..registerLazySingleton<SessionService>(SessionService.new)
    ..registerLazySingleton<ChatStorageService>(ChatStorageService.new)
    ..registerLazySingleton<ThemeService>(ThemeService.new);

  await getIt<ThemeService>().load();
}
