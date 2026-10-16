import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'di/di.dart';
import 'models/protocol.dart';
import 'pages/detail_page.dart';
import 'pages/home/bloc/home_bloc.dart';
import 'pages/home/home_page.dart';
import 'pages/loading_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'routes.dart';
import 'theme/app_theme.dart';
import 'theme/theme_cubit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Регистрация зависимостей в DI-контейнере
  configureDependencies();
  runApp(const MyApp());
}

/// Маршруты приложения (именованные маршруты Navigator)
Route<dynamic>? generateRoute(RouteSettings settings) {
  final Widget page;
  switch (settings.name) {
    case Routes.loading:
      page = const LoadingPage();
    case Routes.login:
      page = const LoginPage();
    case Routes.register:
      page = const RegisterPage();
    case Routes.home:
      // Блок берётся из DI-контейнера, и в него сразу добавляется событие загрузки
      page = BlocProvider(
        create: (_) => getIt<HomeBloc>()..add(const LoadProtocolsEvent()),
        child: const HomePage(),
      );
    case Routes.detail:
      // Выбранный пункт передаётся через arguments
      page = DetailPage(protocol: settings.arguments as Protocol);
    default:
      return null;
  }
  return MaterialPageRoute(builder: (_) => page, settings: settings);
}

class MyApp extends StatelessWidget {
  /// Стартовый экран для автономного запуска отдельной страницы
  final Widget? home;

  const MyApp({super.key, this.home});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Получаем ThemeCubit из DI
      create: (_) => getIt<ThemeCubit>(),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Сетевые протоколы',
            theme: AppTheme.light, // светлая тема
            darkTheme: AppTheme.dark, // тёмная тема
            themeMode: themeMode, // состояние Cubit
            home: home,
            initialRoute: home == null ? Routes.loading : null,
            onGenerateRoute: generateRoute,
          );
        },
      ),
    );
  }
}
