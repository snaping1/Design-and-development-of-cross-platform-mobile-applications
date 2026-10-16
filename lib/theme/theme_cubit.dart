import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// Cubit хранит текущий режим темы приложения в виде ThemeMode
@injectable
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light);

  bool get isDark => state == ThemeMode.dark;

  /// Переключить тему
  void toggleTheme() =>
      emit(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);

  /// Установить тему явно (переключатель в профиле)
  void setDark(bool dark) => emit(dark ? ThemeMode.dark : ThemeMode.light);
}
