import 'package:toucant/entities/store.entity.dart';

enum AppSettingsEnum<T> {
  themeMode<String>(StoreKey.themeMode, defaultValue: "system"),
  ;

  const AppSettingsEnum(this.storeKey, {required this.defaultValue});

  final StoreKey<T> storeKey;
  final T defaultValue;
}
