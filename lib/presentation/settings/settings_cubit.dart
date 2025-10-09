import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import '../../core/utils/storage_service.dart';

class SettingsState {
  final ThemeMode themeMode;
  SettingsState({required this.themeMode});
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(SettingsState(themeMode: ThemeMode.light)) {
    _load();
  }

  Future<void> _load() async {
    final mode = await StorageService.loadThemeMode();
    emit(SettingsState(themeMode: mode));
  }

  Future<void> toggleTheme() async {
    final newMode = state.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    emit(SettingsState(themeMode: newMode));
    await StorageService.saveThemeMode(newMode);
  }
}
