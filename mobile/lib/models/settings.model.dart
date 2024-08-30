import 'package:flutter/material.dart';

class AppSettings {
  ThemeMode themeSetting;

  AppSettings({
    required this.themeSetting,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeSetting: ThemeMode.values.firstWhere((element) => element.toString() == json['themeSetting']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeSetting': themeSetting.toString(),
    };
  }
}
