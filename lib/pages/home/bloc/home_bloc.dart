import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../data/protocols_repository.dart';
import '../../../models/protocol.dart';

part 'home_event.dart';
part 'home_state.dart';

/// BLoC основного экрана: преобразует события в состояния.
/// Регистрируется в DI как factory — новый экземпляр для каждого экрана
@injectable
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  // Репозиторий внедряется через конструктор из DI-контейнера
  final ProtocolsRepository _repository;

  // Начальное состояние при создании блока — ничего не загружено
  HomeBloc(this._repository) : super(const HomeInitial()) {
    // Регистрируется обработчик для события LoadProtocolsEvent
    on<LoadProtocolsEvent>(_onLoadProtocols);
  }

  Future<void> _onLoadProtocols(
    LoadProtocolsEvent event,
    Emitter<HomeState> emit,
  ) async {
    // Меняем состояние на индикатор загрузки
    emit(const HomeLoading());
    try {
      // Получаем данные из БД через репозиторий
      final protocols = await _repository.fetchAll();
      // Возвращаем новое состояние со списком протоколов
      emit(HomeLoaded(protocols));
    } catch (e) {
      debugPrint('Ошибка загрузки протоколов: $e');
      emit(const HomeError('Не удалось загрузить данные'));
    }
  }
}
