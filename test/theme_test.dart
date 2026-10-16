import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:untitled/di/di.dart';
import 'package:untitled/main.dart';
import 'package:untitled/pages/home/bloc/home_bloc.dart';
import 'package:untitled/pages/home/home_page.dart';
import 'package:untitled/pages/profile_page.dart';
import 'package:untitled/theme/app_theme.dart';
import 'package:untitled/theme/theme_cubit.dart';

import 'test_di.dart';

Brightness brightnessOf(WidgetTester tester, Finder finder) =>
    Theme.of(tester.element(finder)).brightness;

void main() {
  setUp(setUpTestDependencies);
  tearDown(() => getIt.reset());

  test('ThemeCubit toggles between light and dark', () {
    final cubit = getIt<ThemeCubit>();
    expect(cubit.state, ThemeMode.light);
    cubit.toggleTheme();
    expect(cubit.state, ThemeMode.dark);
    cubit.toggleTheme();
    expect(cubit.state, ThemeMode.light);
    cubit.setDark(true);
    expect(cubit.state, ThemeMode.dark);
    cubit.close();
  });

  test('custom themes differ in required properties', () {
    final l = AppTheme.light, d = AppTheme.dark;
    expect(l.brightness, Brightness.light);
    expect(d.brightness, Brightness.dark);
    expect(l.scaffoldBackgroundColor, isNot(d.scaffoldBackgroundColor));
    expect(l.appBarTheme.backgroundColor, isNot(d.appBarTheme.backgroundColor));
    expect(l.textTheme.bodyMedium?.color, isNot(d.textTheme.bodyMedium?.color));
    expect(l.cardTheme.color, isNot(d.cardTheme.color));
    expect(l.iconTheme.color, isNot(d.iconTheme.color));
    expect(
      l.elevatedButtonTheme.style?.backgroundColor?.resolve({}),
      isNot(d.elevatedButtonTheme.style?.backgroundColor?.resolve({})),
    );
  });

  testWidgets('AppBar button switches the whole app theme', (tester) async {
    await tester.pumpWidget(
      MyApp(
        home: BlocProvider(
          create: (_) => getIt<HomeBloc>()..add(const LoadProtocolsEvent()),
          child: const HomePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(brightnessOf(tester, find.byType(HomePage)), Brightness.light);

    await tester.tap(find.byIcon(Icons.dark_mode));
    await tester.pumpAndSettle();
    expect(brightnessOf(tester, find.byType(HomePage)), Brightness.dark);
    expect(find.byIcon(Icons.light_mode), findsOneWidget);
  });

  testWidgets('Profile switch enables dark theme', (tester) async {
    tester.view.physicalSize = const Size(1080, 2600);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MyApp(home: ProfilePage()));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(brightnessOf(tester, find.byType(ProfilePage)), Brightness.dark);
  });
}
