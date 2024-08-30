import 'dart:io';
import 'dart:ui';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:toucant/constants/locales.dart';

final localeProvider = StateProvider<Locale>((ref) {
  String languageCode = Platform.localeName.split('_').first.trim();
  String countryCode = Platform.localeName.split('_').last.trim();

  if (toucantLocales.containsKey(languageCode)) {
    return Locale(languageCode, countryCode);
  }

  return const Locale('en', 'US');
});
