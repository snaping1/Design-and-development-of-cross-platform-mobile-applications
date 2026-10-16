import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

import 'protocols_seed.dart';

part 'protocol_database.g.dart';

/// Таблица сетевых протоколов.
/// Класс записи называется ProtocolRow, чтобы не конфликтовать с моделью Protocol
@DataClassName('ProtocolRow')
class Protocols extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get description => text()();
  TextColumn get details => text()();
  // Путь к изображению в assets
  TextColumn get imagePath => text()();
  // Имя иконки (см. protocolIcons в models/protocol.dart)
  TextColumn get iconName => text()();
}

/// Drift-база приложения (в DI — единственный экземпляр)
@lazySingleton
@DriftDatabase(tables: [Protocols])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Для тестов: база с переданным подключением (например, в памяти)
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  /// Стратегия миграций и первичное заполнение
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      // Создаём все таблицы
      await m.createAll();
      // Первоначальное заполнение (раньше — коллекция List<Protocol>)
      await batch((batch) {
        batch.insertAll(protocols, protocolsSeed);
      });
    },
    onUpgrade: (m, from, to) async {
      // Здесь описываются изменения схемы при увеличении schemaVersion
    },
  );

  /// Закрытие базы при удалении из DI-контейнера
  @disposeMethod
  Future<void> dispose() => close();
}

/// Открытие соединения с файлом БД в системной папке приложения
QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'protocols_drift',
    native: const DriftNativeOptions(
      databaseDirectory: getApplicationSupportDirectory,
    ),
  );
}
