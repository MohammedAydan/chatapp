import 'package:chatapp/core/services/theme_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final ThemeService themeService;
  ThemeBloc({required this.themeService}) : super(ThemeInitial()) {
    on<GetThemeModeEvent>(_getThemeModeHandler);
    on<SetThemeModeEvent>(_setThemeModeHandler);
  }

  void _getThemeModeHandler(GetThemeModeEvent event, Emitter emit) {
    try {
      emit(LoadedThemeModeState(themeMode: themeService.getCurrentThemeMode()));
    } catch (e) {
      // error set theme mode error
    }
  }

  void _setThemeModeHandler(SetThemeModeEvent event, Emitter emit) {
    try {
      themeService.changeThemeModel(event.themeMode);
      emit(LoadedThemeModeState(themeMode: event.themeMode));
    } catch (e) {
      // error set theme mode error
    }
  }
}
