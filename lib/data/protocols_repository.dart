import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../models/protocol.dart';
import 'protocol_database.dart';

/// Репозиторий протоколов: операции с данными без деталей хранения
abstract class ProtocolsRepository {
  /// Все протоколы
  Future<List<Protocol>> fetchAll();

  /// Протокол по id (null, если не найден)
  Future<Protocol?> fetchById(int id);

  /// Добавление, возвращает id новой записи
  Future<int> add({
    required String name,
    required String description,
    required String details,
    required String imagePath,
    required String iconName,
  });

  /// Обновление, возвращает true, если запись изменена
  Future<bool> update(Protocol protocol);

  /// Удаление, возвращает true, если запись удалена
  Future<bool> delete(int id);
}

/// Реализация репозитория на базе Drift.
/// Преобразует записи ProtocolRow из БД в модель приложения Protocol
@LazySingleton(as: ProtocolsRepository)
class DriftProtocolsRepository implements ProtocolsRepository {
  final AppDatabase _db;

  DriftProtocolsRepository(this._db);

  Protocol _toModel(ProtocolRow row) => Protocol(
    id: row.id,
    name: row.name,
    description: row.description,
    details: row.details,
    imagePath: row.imagePath,
    iconName: row.iconName,
  );

  @override
  Future<List<Protocol>> fetchAll() async {
    final rows = await (_db.select(
      _db.protocols,
    )..orderBy([(t) => OrderingTerm.asc(t.id)])).get();
    return rows.map(_toModel).toList();
  }

  @override
  Future<Protocol?> fetchById(int id) async {
    final row = await (_db.select(
      _db.protocols,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  @override
  Future<int> add({
    required String name,
    required String description,
    required String details,
    required String imagePath,
    required String iconName,
  }) {
    return _db
        .into(_db.protocols)
        .insert(
          ProtocolsCompanion.insert(
            name: name,
            description: description,
            details: details,
            imagePath: imagePath,
            iconName: iconName,
          ),
        );
  }

  @override
  Future<bool> update(Protocol protocol) async {
    final count =
        await (_db.update(
          _db.protocols,
        )..where((t) => t.id.equals(protocol.id))).write(
          ProtocolsCompanion(
            name: Value(protocol.name),
            description: Value(protocol.description),
            details: Value(protocol.details),
            imagePath: Value(protocol.imagePath),
            iconName: Value(protocol.iconName),
          ),
        );
    return count > 0;
  }

  @override
  Future<bool> delete(int id) async {
    final count = await (_db.delete(
      _db.protocols,
    )..where((t) => t.id.equals(id))).go();
    return count > 0;
  }
}
