import 'dart:io';
import 'package:chatapp/core/database/cache/cache_helper.dart';

const String localeKey = "APP_LOCALE";

abstract class LocaleService {
  void changeLocale(String langCode);
  String getCurrentLang();
  String getDeiceLang();
}

class LocaleServiceImpl implements LocaleService {
  final CacheHelper _cacheHelper;

  const LocaleServiceImpl(this._cacheHelper);

  @override
  void changeLocale(String langCode) {
    try {
      _cacheHelper.save(localeKey, langCode);
    } catch (e) {
      print(e);
    }
  }

  @override
  String getCurrentLang() {
    try {
      final lang = _cacheHelper.readData(localeKey);
      if (lang != null) {
        return lang;
      } else {
        return getDeiceLang();
      }
    } catch (e) {
      return getDeiceLang();
    }
  }

  @override
  String getDeiceLang() {
    try {
      final String deviceLocale = Platform.localeName.split('_')[0];
      return deviceLocale;
    } catch (e) {
      return "en";
    }
  }
}
