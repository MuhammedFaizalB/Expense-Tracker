import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { system, light, dark }

extension AppThemeModeX on AppThemeMode {
  ThemeMode get toFlutterThemeMode => switch (this) {
    AppThemeMode.system => ThemeMode.system,
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
  };
}

const _prefsKey = 'app_theme_mode';

class ThemeCubit extends Cubit<AppThemeMode> {
  final SharedPreferences _prefs;

  ThemeCubit(this._prefs) : super(_load(_prefs));

  static AppThemeMode _load(SharedPreferences prefs) {
    final stored = prefs.getString(_prefsKey);
    return AppThemeMode.values.firstWhere(
      (m) => m.name == stored,
      orElse: () => AppThemeMode.system,
    );
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    emit(mode);
    await _prefs.setString(_prefsKey, mode.name);
  }
}
