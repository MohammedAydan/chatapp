import 'package:chatapp/core/database/cache/cache_helper.dart';
import 'package:flutter/material.dart';

const String themeModeKey = "THEME_MODE";

abstract class ThemeService {
  void changeThemeModel(ThemeMode themeMode);
  ThemeMode getCurrentThemeMode();
}

class ThemeServiceImpl implements ThemeService {
  final CacheHelper _cacheHelper;

  ThemeServiceImpl(this._cacheHelper);

  @override
  void changeThemeModel(ThemeMode themeMode) async {
    try {
      await _cacheHelper.save(themeModeKey, themeMode.name);
    } catch (e) {
      // error save value
      debugPrint(e.toString());
    }
  }

  @override
  ThemeMode getCurrentThemeMode() {
    final String? themeMode = _cacheHelper.readData(themeModeKey);
    if (themeMode == null || themeMode.isEmpty) {
      return ThemeMode.system;
    }

    if (themeMode == ThemeMode.dark.name) {
      return ThemeMode.dark;
    } else if (themeMode == ThemeMode.light.name) {
      return ThemeMode.light;
    } else {
      return ThemeMode.system;
    }
  }
}
