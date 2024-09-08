import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:toucant/models/settings.model.dart';
import 'package:toucant/provider/settings.provider.dart';

class SettingsService extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    readSettings();
    return state;
  }

  void saveSettings() {
    final prefs = ref.read(sharedPrefsProvider);
    prefs.setString('appSettings', jsonEncode(state.toJson()));
    ref.notifyListeners();
  }

  void readSettings() {
    final prefs = ref.read(sharedPrefsProvider);
    Map<String, dynamic> appSettings = jsonDecode(prefs.getString('appSettings') ?? '{}');
    if (appSettings.isEmpty) {
      state = defaultSettings;
      return;
    }
    try {
      state = AppSettings.fromJson(appSettings);
    } on Exception catch (e) {
      debugPrint('Error reading settings: $e');
      prefs.remove('appSettings');
      state = defaultSettings;
    }
  }
}

final AppSettings defaultSettings = AppSettings(
  themeSetting: ThemeMode.system,
  notifyOnNewContent: true,
);
