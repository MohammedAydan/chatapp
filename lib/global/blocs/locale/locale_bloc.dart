import 'package:chatapp/core/services/locale_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'locale_event.dart';
part 'locale_state.dart';

class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  final LocaleService localeService;

  LocaleBloc({required this.localeService}) : super(LocaleInitial()) {
    on<LoadLocaleEvent>(_loadLocalHandler);
    on<ChangeLocaleEvent>(_changeLocalHandler);
  }

  void _loadLocalHandler(LoadLocaleEvent event, Emitter emit) {
    emit(LocaleLoadedState(locale: Locale(localeService.getCurrentLang())));
  }

  void _changeLocalHandler(ChangeLocaleEvent event, Emitter emit) {
    localeService.changeLocale(event.locale.languageCode);
    emit(LocaleLoadedState(locale: event.locale));
  }
}
