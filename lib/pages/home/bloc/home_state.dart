part of 'home_bloc.dart';

/// Базовый класс состояний основного экрана
@immutable
sealed class HomeState {
  const HomeState();
}

/// Ничего не загружено (начальное состояние)
final class HomeInitial extends HomeState {
  const HomeInitial();
}

/// Идёт загрузка
final class HomeLoading extends HomeState {
  const HomeLoading();
}

/// Успешная загрузка: получен список протоколов
final class HomeLoaded extends HomeState {
  final List<Protocol> protocols;
  const HomeLoaded(this.protocols);
}

/// Ошибка при загрузке
final class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);
}
