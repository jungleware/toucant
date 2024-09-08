import 'package:flutter/material.dart';

class AppSettings {
  ThemeMode themeSetting;
  bool notifyOnNewContent;

  AppSettings({
    this.themeSetting = ThemeMode.system,
    this.notifyOnNewContent = true,
  });

  factory AppSettings.fromJson(Map<String, Object?> json) {
    return AppSettings(
      themeSetting: ThemeMode.values.firstWhere(
        (element) => element.toString() == json['themeSetting'],
        orElse: () => ThemeMode.system,
      ),
      notifyOnNewContent: (json['notifyOnNewContent'] ?? true) as bool,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'themeSetting': themeSetting.toString(),
      'notifyOnNewContent': notifyOnNewContent,
    };
  }
}
