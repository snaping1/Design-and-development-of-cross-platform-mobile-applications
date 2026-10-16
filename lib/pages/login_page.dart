import 'package:flutter/material.dart';

import '../di/di.dart';
import '../main.dart';
import '../routes.dart';
import '../theme/theme_toggle_action.dart';
import '../widgets/app_button.dart';
import '../widgets/text_field.dart';

// Для автономного запуска экрана: правая кнопка мыши → Run 'login_page.dart'
void main() {
  configureDependencies();
  runApp(const MyApp(home: LoginPage()));
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Вход выполнен: ${_emailController.text}')),
      );
      // Успешная авторизация — основной экран с заменой текущего
      Navigator.pushReplacementNamed(context, Routes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Переключатель темы (экран без AppBar)
            const Align(
              alignment: Alignment.topRight,
              child: ThemeToggleAction(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 32),
                      const Text(
                        'Добро пожаловать!\n'
                        'Войдите в свой аккаунт\n'
                        'Или создайте новый',
                        style: TextStyle(fontSize: 22, height: 1.3),
                      ),
                      const SizedBox(height: 48),
                      CustomTextFormField(
                        inputType: InputFieldType.email,
                        hintText: 'Email',
                        prefixIcon: const Icon(Icons.mail_outline),
                        controller: _emailController,
                      ),
                      const SizedBox(height: 16),
                      CustomTextFormField(
                        inputType: InputFieldType.password,
                        hintText: 'Пароль',
                        prefixIcon: const Icon(Icons.shield),
                        controller: _passwordController,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Инструкция по восстановлению отправлена на email',
                                ),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context)
                                .colorScheme
                                .onSurface,
                          ),
                          child: const Text(
                            'Забыли пароль?',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Center(
                        child: AppButton(text: 'Войти', onPressed: _submit),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Wrap(
                alignment: WrapAlignment.center,
                children: [
                  const Text('Нет аккаунта? '),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, Routes.register),
                    child: const Text(
                      'Зарегистрируйтесь',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
