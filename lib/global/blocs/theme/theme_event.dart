part of 'theme_bloc.dart';

sealed class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

class GetThemeModeEvent extends ThemeEvent {}

class SetThemeModeEvent extends ThemeEvent {
  final ThemeMode themeMode;

  const SetThemeModeEvent({required this.themeMode});

  @override
  List<Object> get props => [themeMode];
}
