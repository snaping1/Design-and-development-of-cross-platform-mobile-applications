// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:untitled/data/protocol_database.dart' as _i958;
import 'package:untitled/data/protocols_repository.dart' as _i162;
import 'package:untitled/pages/home/bloc/home_bloc.dart' as _i235;
import 'package:untitled/theme/theme_cubit.dart' as _i794;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.factory<_i794.ThemeCubit>(() => _i794.ThemeCubit());
    gh.lazySingleton<_i958.AppDatabase>(
      () => _i958.AppDatabase(),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i162.ProtocolsRepository>(
      () => _i162.DriftProtocolsRepository(gh<_i958.AppDatabase>()),
    );
    gh.factory<_i235.HomeBloc>(
      () => _i235.HomeBloc(gh<_i162.ProtocolsRepository>()),
    );
    return this;
  }
}
