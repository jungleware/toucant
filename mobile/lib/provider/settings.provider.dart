import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toucant/models/settings.model.dart';
import 'package:toucant/services/settings.service.dart';

final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final appSettingsProvider = NotifierProvider<SettingsService, AppSettings>(SettingsService.new);
