import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:timezone/data/latest.dart';
import 'package:toucant/constants/locales.dart';
import 'package:toucant/extensions/build_context_extensions.dart';
import 'package:toucant/routing/app_navigation_observer.dart';
import 'package:toucant/routing/router.dart';
import 'package:toucant/utils/toucant_app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initApp();

  runApp(
    ProviderScope(child: const TouCantApp()),
  );
}

Future<void> initApp() async {
  await EasyLocalization.ensureInitialized();

  if (kReleaseMode && Platform.isAndroid) {
    try {
      await FlutterDisplayMode.setHighRefreshRate();
      debugPrint('High refresh rate set');
    } catch (e) {
      debugPrint('Error setting high refresh rate: $e');
    }
  }

  var errorLogger = Logger("ToucantErrorLogger");

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    errorLogger.severe(
      'FlutterError - Catch all',
      "${details.toString()}\nException: ${details.exception}\nLibrary: ${details.library}\nContext: ${details.context}",
      details.stack,
    );
  };

  PlatformDispatcher.instance.onError = (error, stackTrace) {
    errorLogger.severe('PlatformDispatcher - Catch all', error, stackTrace);
    return true;
  };

  initializeTimeZones();
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return EasyLocalization(
      supportedLocales: toucantLocales.values.toList(),
      path: translationsPath,
      useFallbackTranslations: true,
      fallbackLocale: toucantLocales.values.first,
      child: const TouCantApp(),
    );
  }
}

class TouCantApp extends ConsumerStatefulWidget {
  const TouCantApp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TouCantAppState();
}

class _TouCantAppState extends ConsumerState<TouCantApp> with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // do something
    }
  }

  Future<void> _initApp() async {
    WidgetsBinding.instance.addObserver(this);

    // Draw the app from edge to edge
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // Sets the navigation bar color
    SystemUiOverlayStyle overlayStyle = const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
    );

    if (Platform.isAndroid) {
      // Android 8 does not support transparent app bars
      final info = await DeviceInfoPlugin().androidInfo;
      if (info.version.sdkInt <= 26) {
        overlayStyle = context.isDarkTheme ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light;
      }
    }
    SystemChrome.setSystemUIOverlayStyle(overlayStyle);
  }

  @override
  void initState() {
    super.initState();
    _initApp().then((_) => debugPrint('App initialized'));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'TouCant',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      theme: toucantLightTheme,
      darkTheme: toucantDarkTheme,
      routeInformationParser: router.defaultRouteParser(),
      routerDelegate: router.delegate(
        navigatorObservers: () => [AppNavigationObserver()],
      ),
      routeInformationProvider: router.routeInfoProvider(),
    );
  }
}
