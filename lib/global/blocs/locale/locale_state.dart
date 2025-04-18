part of 'locale_bloc.dart';

sealed class LocaleState extends Equatable {
  const LocaleState();

  @override
  List<Object> get props => [];
}

final class LocaleInitial extends LocaleState {}

final class LocaleLoadedState extends LocaleState {
  final Locale locale;

  const LocaleLoadedState({required this.locale});
  
  @override
  List<Object> get props => [locale];
}
