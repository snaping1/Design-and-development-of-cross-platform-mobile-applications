import 'package:flutter/material.dart';

import '../di/di.dart';
import '../main.dart';
import '../routes.dart';
import '../theme/theme_toggle_action.dart';
import '../widgets/app_button.dart';
import '../widgets/text_field.dart';

// Для автономного запуска экрана: правая кнопка мыши → Run 'register_page.dart'
void main() {
  configureDependencies();
  runApp(const MyApp(home: RegisterPage()));
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Пользователь ${_nameController.text} зарегистрирован. '
            'Войдите в аккаунт',
          ),
        ),
      );
      _backToLogin();
    }
  }

  // Возврат на экран авторизации
  void _backToLogin() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, Routes.login);
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
                      const SizedBox(height: 12),
                      const Text(
                        'Регистрация',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 32),
                      CustomTextFormField(
                        inputType: InputFieldType.name,
                        hintText: 'ФИО',
                        prefixIcon: const Icon(Icons.person_outline),
                        controller: _nameController,
                      ),
                      const SizedBox(height: 16),
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
                      ),
                      const SizedBox(height: 16),
                      CustomTextFormField(
                        inputType: InputFieldType.confirmPassword,
                        hintText: 'Повторите пароль',
                        prefixIcon: const Icon(Icons.shield),
                        controller: _confirmController,
                        passwordController: _passwordController,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: 40),
                      Center(
                        child: AppButton(
                          text: 'Зарегистрироваться',
                          onPressed: _submit,
                        ),
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
                  const Text('Уже есть аккаунт? '),
                  GestureDetector(
                    onTap: _backToLogin,
                    child: const Text(
                      'Войдите',
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
