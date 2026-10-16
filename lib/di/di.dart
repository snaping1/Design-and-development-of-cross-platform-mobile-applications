import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'di.config.dart';

/// DI-контейнер приложения
final getIt = GetIt.instance;

/// Регистрируем все зависимости (код регистрации генерирует injectable)
@InjectableInit()
void configureDependencies() => getIt.init();
