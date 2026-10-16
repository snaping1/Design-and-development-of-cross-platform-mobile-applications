import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../di/di.dart';
import '../main.dart';
import '../theme/theme_cubit.dart';
import '../widgets/app_button.dart';
import '../widgets/text_field.dart';

// Для автономного запуска экрана: правая кнопка мыши → Run 'profile_page.dart'
void main() {
  configureDependencies();
  runApp(const MyApp(home: ProfilePage()));
}

class ProfilePage extends StatefulWidget {
  // Обработчик кнопки «Назад»; по умолчанию — возврат по стеку
  final VoidCallback? onBack;

  const ProfilePage({super.key, this.onBack});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController(text: 'Тагин Никита');
  final _emailController = TextEditingController(text: 'nikita@mail.ru');
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Данные профиля сохранены')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Material(
                        color: colors.onSurface,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap:
                              widget.onBack ??
                              () => Navigator.of(context).maybePop(),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              color: colors.surface,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Text(
                      'Профиль',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Смена фото профиля')),
                      );
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.person,
                            size: 90,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        Icon(
                          Icons.photo_camera_outlined,
                          size: 36,
                          color: colors.onSurface.withValues(alpha: 0.6),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 8),
                // Настройка темы приложения
                BlocBuilder<ThemeCubit, ThemeMode>(
                  builder: (context, themeMode) => SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: Icon(
                      themeMode == ThemeMode.dark
                          ? Icons.dark_mode
                          : Icons.light_mode,
                    ),
                    title: const Text('Тёмная тема'),
                    value: themeMode == ThemeMode.dark,
                    onChanged: context.read<ThemeCubit>().setDark,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: AppButton(text: 'Сохранить', onPressed: _submit),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
