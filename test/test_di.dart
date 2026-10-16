import 'package:drift/native.dart';
import 'package:untitled/data/protocol_database.dart';
import 'package:untitled/di/di.dart';

/// DI-контейнер для тестов: те же регистрации, но БД Drift в памяти
Future<void> setUpTestDependencies() async {
  await getIt.reset();
  configureDependencies();
  getIt.allowReassignment = true;
  getIt.registerLazySingleton<AppDatabase>(
    () => AppDatabase.forTesting(NativeDatabase.memory()),
    dispose: (db) => db.close(),
  );
  getIt.allowReassignment = false;
}
