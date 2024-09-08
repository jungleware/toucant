import 'package:flutter/material.dart';

class AppSettings {
  ThemeMode themeSetting;
  bool notifyOnNewContent;

  AppSettings({
    required this.themeSetting,
    required this.notifyOnNewContent,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeSetting: ThemeMode.values.firstWhere((element) => element.toString() == json['themeSetting']),
      notifyOnNewContent: json['notifyOnNewContent'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeSetting': themeSetting.toString(),
      'notifyOnNewContent': notifyOnNewContent,
    };
  }
}
