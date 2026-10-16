import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:untitled/data/protocols_repository.dart';
import 'package:untitled/di/di.dart';
import 'package:untitled/main.dart';
import 'package:untitled/models/protocol.dart';
import 'package:untitled/pages/home/bloc/home_bloc.dart';
import 'package:untitled/pages/home/home_page.dart';

import 'test_di.dart';

/// Репозиторий, который можно заставить падать
class FlakyRepository implements ProtocolsRepository {
  final ProtocolsRepository inner;
  bool fail;
  FlakyRepository(this.inner, {this.fail = true});

  @override
  Future<List<Protocol>> fetchAll() =>
      fail ? Future.error(Exception('fail')) : inner.fetchAll();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Высокий экран телефона, чтобы карточки помещались без прокрутки
void tallPhone(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 4400);
  tester.view.devicePixelRatio = 2.75;
  addTearDown(tester.view.reset);
}

Widget homeWith(HomeBloc bloc) => MyApp(
  home: BlocProvider(create: (_) => bloc, child: const HomePage()),
);

void main() {
  setUp(setUpTestDependencies);
  tearDown(() => getIt.reset());

  test('initial state is HomeInitial', () {
    final bloc = getIt<HomeBloc>();
    expect(bloc.state, isA<HomeInitial>());
    bloc.close();
  });

  test('DI creates a new HomeBloc each time (factory)', () {
    final a = getIt<HomeBloc>();
    final b = getIt<HomeBloc>();
    expect(identical(a, b), isFalse);
    a.close();
    b.close();
  });

  test('LoadProtocolsEvent: loading -> loaded from database', () async {
    final bloc = getIt<HomeBloc>();
    final states = bloc.stream.take(2).toList();
    bloc.add(const LoadProtocolsEvent());
    final result = await states;
    expect(result[0], isA<HomeLoading>());
    expect(result[1], isA<HomeLoaded>());
    expect((result[1] as HomeLoaded).protocols, hasLength(5));
    await bloc.close();
  });

  test('LoadProtocolsEvent: loading -> error', () async {
    final bloc = HomeBloc(FlakyRepository(getIt<ProtocolsRepository>()));
    final states = bloc.stream.take(2).toList();
    bloc.add(const LoadProtocolsEvent());
    final result = await states;
    expect(result[0], isA<HomeLoading>());
    expect(result[1], isA<HomeError>());
    await bloc.close();
  });

  testWidgets('HomePage shows error and retries', (tester) async {
    tallPhone(tester);
    final repo = FlakyRepository(getIt<ProtocolsRepository>());
    await tester.pumpWidget(
      homeWith(HomeBloc(repo)..add(const LoadProtocolsEvent())),
    );
    await tester.pumpAndSettle();
    expect(find.text('Не удалось загрузить данные'), findsOneWidget);

    repo.fail = false;
    await tester.tap(find.text('Повторить'));
    await tester.pumpAndSettle();
    expect(find.text('Не удалось загрузить данные'), findsNothing);
    expect(find.widgetWithText(ListTile, 'HTTP/HTTPS'), findsOneWidget);
  });

  testWidgets('HomePage initial state is empty, refresh loads', (tester) async {
    tallPhone(tester);
    await tester.pumpWidget(homeWith(getIt<HomeBloc>()));
    expect(find.byType(ListTile), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Повторить'), findsNothing);

    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ListTile, 'HTTP/HTTPS'), findsOneWidget);
  });
}
