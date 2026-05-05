import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final SharedPreferences _prefs;

  ThemeBloc(this._prefs)
      : super(ThemeState(
          (_prefs.getBool(SessionKeys.isDarkMode) ?? true)
              ? ThemeMode.dark
              : ThemeMode.light,
        )) {
    on<ThemeChanged>((event, emit) async {
      await _prefs.setBool(SessionKeys.isDarkMode, event.isDark);
      emit(ThemeState(event.isDark ? ThemeMode.dark : ThemeMode.light));
    });
  }
}
