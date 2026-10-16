import 'package:flutter/material.dart';

/// Основная кнопка приложения; цвет фона, текста и форма берутся из темы
/// (elevatedButtonTheme в theme/app_theme.dart)
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const AppButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: onPressed, child: Text(text));
  }
}
