import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:toucant/provider/settings.provider.dart';

final themeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(appSettingsProvider).themeSetting;
});
