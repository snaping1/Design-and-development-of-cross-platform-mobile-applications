import 'package:flutter/material.dart';

enum InputFieldType { name, email, password, confirmPassword }

class CustomTextFormField extends StatefulWidget {
  final InputFieldType inputType;
  final String hintText;
  final Widget prefixIcon;
  final TextEditingController controller;
  // Контроллер поля «Пароль» — нужен для проверки поля «Повторите пароль»
  final TextEditingController? passwordController;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  const CustomTextFormField({
    super.key,
    required this.inputType,
    required this.hintText,
    required this.prefixIcon,
    required this.controller,
    this.passwordController,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextFormField> {
  bool _hidePassword = true;

  bool get _isPassword =>
      widget.inputType == InputFieldType.password ||
      widget.inputType == InputFieldType.confirmPassword;

  String? _validator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Поле не может быть пустым';
    }

    switch (widget.inputType) {
      case InputFieldType.name:
        final reg = RegExp(r'^[A-Za-zА-Яа-яЁё\s]+$'); // только буквы и пробелы
        if (!reg.hasMatch(value)) {
          return 'Имя должно содержать только буквы и пробелы';
        }
        return null;

      case InputFieldType.email:
        // текст до @, текст после @, точка в домене
        final reg = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');
        if (!reg.hasMatch(value.trim())) {
          return 'Введите корректный email (например, example@mail.ru)';
        }
        return null;

      case InputFieldType.password:
        // не менее 6 символов, буквы, цифры и символы + _ -
        final reg = RegExp(
          r'^(?=.*[A-Za-zА-Яа-яЁё])(?=.*\d)(?=.*[+_\-])[A-Za-zА-Яа-яЁё\d+_\-]{6,}$',
        );
        if (!reg.hasMatch(value)) {
          return 'Не менее 6 символов: буквы, цифры и символы (+, _, -)';
        }
        return null;

      case InputFieldType.confirmPassword:
        if (value != widget.passwordController?.text) {
          return 'Пароли не совпадают';
        }
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Цвета берутся из текущей темы (светлой или тёмной)
    final colors = Theme.of(context).colorScheme;
    final border = OutlineInputBorder(
      borderSide: BorderSide(color: colors.onSurface, width: 1.5),
      borderRadius: BorderRadius.circular(16),
    );
    final errorBorder = border.copyWith(
      borderSide: BorderSide(color: colors.error, width: 1.5),
    );

    return TextFormField(
      controller: widget.controller,
      obscureText: _isPassword && _hidePassword,
      keyboardType: widget.inputType == InputFieldType.email
          ? TextInputType.emailAddress
          : _isPassword
          ? TextInputType.visiblePassword
          : TextInputType.name,
      // При TextInputAction.next фокус сам переходит к следующему полю
      // (FocusScope.nextFocus() внутри EditableText)
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
      style: TextStyle(color: colors.onSurface, fontSize: 15),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(color: colors.onSurfaceVariant, fontSize: 14),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        prefixIcon: IconTheme(
          data: IconThemeData(color: colors.onSurface),
          child: widget.prefixIcon,
        ),
        suffixIcon: _isPassword
            // Кнопка не участвует в переходе фокуса между полями
            ? ExcludeFocus(
                child: IconButton(
                  icon: Icon(
                    _hidePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: colors.onSurfaceVariant,
                  ),
                  onPressed: () =>
                      setState(() => _hidePassword = !_hidePassword),
                ),
              )
            : null,
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: colors.onSurface, width: 2),
        ),
        errorBorder: errorBorder,
        focusedErrorBorder: errorBorder,
        errorMaxLines: 2,
      ),
      // После первой проверки ошибки обновляются по мере ввода
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: _validator,
    );
  }
}
