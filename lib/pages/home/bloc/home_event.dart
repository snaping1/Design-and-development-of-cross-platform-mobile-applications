part of 'home_bloc.dart';

/// Базовый класс событий основного экрана
@immutable
sealed class HomeEvent {
  const HomeEvent();
}

/// Событие: загрузить список протоколов
final class LoadProtocolsEvent extends HomeEvent {
  const LoadProtocolsEvent();
}
