import 'package:flutter_test/flutter_test.dart';
import 'package:untitled/data/protocols_repository.dart';
import 'package:untitled/models/protocol.dart';
import 'package:untitled/di/di.dart';

import 'test_di.dart';

void main() {
  late ProtocolsRepository repository;

  setUp(() async {
    await setUpTestDependencies();
    repository = getIt<ProtocolsRepository>();
  });

  tearDown(() => getIt.reset());

  test('DI returns singletons for database and repository', () {
    expect(identical(getIt<ProtocolsRepository>(), repository), isTrue);
  });

  test('database is seeded on create', () async {
    final all = await repository.fetchAll();
    expect(all.map((p) => p.name), [
      'HTTP/HTTPS',
      'TCP/IP',
      'UDP',
      'FTP',
      'DNS',
    ]);
    expect(all.first.imagePath, 'assets/images/protocol1_http.png');
  });

  test('CRUD operations', () async {
    final id = await repository.add(
      name: 'SMTP',
      description: 'Передача электронной почты',
      details: 'SMTP — протокол отправки почты.',
      imagePath: 'assets/images/protocol1_http.png',
      iconName: 'language',
    );
    var smtp = await repository.fetchById(id);
    expect(smtp?.name, 'SMTP');
    expect(await repository.fetchAll(), hasLength(6));

    final updated = await repository.update(
      Protocol(
        id: id,
        name: 'SMTP',
        description: 'Simple Mail Transfer Protocol',
        details: smtp!.details,
        imagePath: smtp.imagePath,
        iconName: smtp.iconName,
      ),
    );
    expect(updated, isTrue);
    smtp = await repository.fetchById(id);
    expect(smtp?.description, 'Simple Mail Transfer Protocol');

    expect(await repository.delete(id), isTrue);
    expect(await repository.fetchById(id), isNull);
    expect(await repository.fetchAll(), hasLength(5));
  });
}
