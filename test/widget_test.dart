import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:untitled/di/di.dart';
import 'package:untitled/main.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled/pages/home/bloc/home_bloc.dart';
import 'package:untitled/pages/home/home_page.dart';

import 'test_di.dart';

void phoneSize(WidgetTester tester, {double width = 1080}) {
  tester.view.physicalSize = Size(width, 2340);
  tester.view.devicePixelRatio = 2.75;
  addTearDown(tester.view.reset);
}

/// Запуск приложения и ожидание перехода с экрана заставки
Future<void> startApp(WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  expect(find.text('СЕТЕВЫЕ ПРОТОКОЛЫ'), findsOneWidget);
  await tester.pump(const Duration(seconds: 4));
  await tester.pumpAndSettle();
  expect(find.text('Войти'), findsOneWidget);
}

/// Прокрутка основного экрана до карточки пункта
Future<void> scrollToCard(WidgetTester tester, String name) async {
  final card = find.widgetWithText(ListTile, name);
  await tester.scrollUntilVisible(
    card,
    150,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(setUpTestDependencies);
  tearDown(() => getIt.reset());

  testWidgets('Login form validation and navigation', (tester) async {
    phoneSize(tester);
    await startApp(tester);

    // Пустая форма — ошибки валидации
    await tester.tap(find.text('Войти'));
    await tester.pump();
    expect(find.text('Поле не может быть пустым'), findsNWidgets(2));

    // Некорректные email и пароль
    await tester.enterText(find.byType(TextFormField).at(0), 'nikita@mail');
    await tester.enterText(find.byType(TextFormField).at(1), 'abc123');
    await tester.tap(find.text('Войти'));
    await tester.pump();
    expect(find.textContaining('корректный email'), findsOneWidget);
    expect(find.textContaining('Не менее 6 символов'), findsOneWidget);

    // Корректные данные — переход на основной экран
    await tester.enterText(find.byType(TextFormField).at(0), 'nikita@mail.ru');
    await tester.enterText(find.byType(TextFormField).at(1), 'abc_123');
    await tester.tap(find.text('Войти'));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);

    // Переход на экран детализации и возврат
    await scrollToCard(tester, 'TCP/IP');
    await tester.tap(find.widgetWithText(ListTile, 'TCP/IP'));
    await tester.pumpAndSettle();
    expect(find.textContaining('тройное'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ListTile, 'TCP/IP'), findsOneWidget);

    // Вкладка «Профиль» и возврат на «Главную»
    await tester.tap(find.text('Профиль').last);
    await tester.pumpAndSettle();
    expect(find.text('Сохранить'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ListTile, 'TCP/IP'), findsOneWidget);

    // С экрана детализации — сразу во вкладку «Профиль»
    await scrollToCard(tester, 'DNS');
    await tester.tap(find.widgetWithText(ListTile, 'DNS'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Профиль').last);
    await tester.pumpAndSettle();
    expect(find.text('Сохранить'), findsOneWidget);
  });

  testWidgets('Register: validation and return to login', (tester) async {
    phoneSize(tester);
    await startApp(tester);
    await tester.tap(find.text('Зарегистрируйтесь'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Никита123');
    await tester.enterText(fields.at(1), 'nikita@mail.ru');
    await tester.enterText(fields.at(2), 'abc_123');
    await tester.enterText(fields.at(3), 'abc_124');
    await tester.tap(find.text('Зарегистрироваться'));
    await tester.pump();
    expect(
      find.text('Имя должно содержать только буквы и пробелы'),
      findsOneWidget,
    );
    expect(find.text('Пароли не совпадают'), findsOneWidget);

    await tester.enterText(fields.at(0), 'Тагин Никита');
    await tester.enterText(fields.at(3), 'abc_123');
    await tester.tap(find.text('Зарегистрироваться'));
    await tester.pumpAndSettle();
    expect(find.text('Войти'), findsOneWidget);
  });

  testWidgets('Next moves focus to the next field', (tester) async {
    phoneSize(tester);
    await startApp(tester);
    await tester.tap(find.text('Зарегистрируйтесь'));
    await tester.pumpAndSettle();

    final fields = find.byType(EditableText);
    bool hasFocus(int i) =>
        tester.widget<EditableText>(fields.at(i)).focusNode.hasFocus;

    await tester.tap(fields.at(0));
    await tester.pump();
    for (var i = 0; i < 3; i++) {
      expect(hasFocus(i), isTrue, reason: 'поле $i');
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pump();
    }
    expect(hasFocus(3), isTrue, reason: 'поле «Повторите пароль»');
  });

  testWidgets('Wide screen shows cards in 2 columns', (tester) async {
    tester.view.physicalSize = const Size(2000, 1400);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MyApp(
        home: BlocProvider(
          create: (_) => getIt<HomeBloc>()..add(const LoadProtocolsEvent()),
          child: const HomePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    Offset cardOf(String text) => tester.getTopLeft(
      find.ancestor(of: find.text(text).last, matching: find.byType(Card)),
    );
    final http = cardOf('HTTP/HTTPS');
    final tcp = cardOf('TCP/IP');
    expect(http.dy, tcp.dy); // карточки в одной строке
    expect(tcp.dx, greaterThan(http.dx));
  });
}
