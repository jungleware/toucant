import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:logging/logging.dart';
import 'package:timezone/data/latest.dart';
import 'package:toucant/constants/locales.dart';
import 'package:toucant/extensions/build_context_extensions.dart';
import 'package:toucant/provider/daily.provider.dart';
import 'package:toucant/provider/package_info.provider.dart';
import 'package:toucant/provider/theme.provider.dart';
import 'package:toucant/routing/router.dart';
import 'package:toucant/utils/toucant_app_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initApp();

  runApp(
    const ProviderScope(child: TouCantApp()),
  );
}

Future<void> initApp() async {
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

class TouCantApp extends ConsumerStatefulWidget {
  const TouCantApp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TouCantAppState();
}

class _TouCantAppState extends ConsumerState<TouCantApp> with WidgetsBindingObserver {
  // The update info
  AppUpdateInfo? _updateInfo;

  // The scaffold key to show snack bars
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  // Whether a flexible update is available
  bool _flexibleUpdateAvailable = false;

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
        if (!mounted) return;
        overlayStyle = context.isDarkTheme ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light;
      }
    }
    SystemChrome.setSystemUIOverlayStyle(overlayStyle);

    // Check for updates and perform them if necessary
    await checkForUpdate();

    // Init package info
    ref.read(packageInfoProvider);
  }

  Future<void> checkForUpdate() async {
    await InAppUpdate.checkForUpdate().then(
      (info) => setState(() => _updateInfo = info),
      onError: (e) => debugPrint('Error checking for update: $e'),
    );
  }

  /// Show a snack bar with the given text
  void showSnack(String text) {
    if (_scaffoldKey.currentContext != null) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(SnackBar(content: Text(text)));
    }
  }

  /// Invalidate the daily provider when the locale changes
  /// to fetch the new daily content in the new locale
  @override
  void didChangeLocales(List<Locale>? locales) {
    ref.invalidate(getDailyProvider);
    super.didChangeLocales(locales);
  }

  @override
  void initState() {
    super.initState();
    _initApp().then((_) => debugPrint('App initialized'));
  }

  @override
  Widget build(BuildContext context) {
    var router = ref.watch(appRouterProvider);
    var themeMode = ref.watch(themeProvider);

    if (_updateInfo != null && _updateInfo!.updateAvailability == UpdateAvailability.updateAvailable) {
      return MaterialApp(
        title: 'TouCant',
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: toucantLocales.values.toList(),
        debugShowCheckedModeBanner: false,
        themeMode: themeMode,
        theme: toucantLightTheme,
        darkTheme: toucantDarkTheme,
        home: Builder(
          builder: (context) {
            return Scaffold(
              key: _scaffoldKey,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      context.l10n.common_update_available,
                      style: context.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.common_update_available_description,
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Perform immediate update if allowed

                        if (_updateInfo!.immediateUpdateAllowed) {
                          InAppUpdate.performImmediateUpdate().catchError((e) {
                            debugPrint('Error updating: $e');
                            showSnack(e.toString());
                            return AppUpdateResult.inAppUpdateFailed;
                          });
                        } else if (_updateInfo!.flexibleUpdateAllowed) {
                          if (_flexibleUpdateAvailable) {
                            // If update is already downloaded, complete the update
                            InAppUpdate.completeFlexibleUpdate().catchError((e) {
                              debugPrint('Error updating: $e');
                              showSnack(e.toString());
                            });
                          } else {
                            // Start the flexible update download
                            InAppUpdate.startFlexibleUpdate().then((_) {
                              setState(() => _flexibleUpdateAvailable = true);
                            }).catchError((e) {
                              debugPrint('Error updating: $e');
                              showSnack(e.toString());
                            });
                          }
                        }
                      },
                      child: Text(
                        _flexibleUpdateAvailable ? context.l10n.common_update_install : context.l10n.common_update_now,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }

    return MaterialApp.router(
      title: 'TouCant',
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: toucantLocales.values.toList(),
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: toucantLightTheme,
      darkTheme: toucantDarkTheme,
      routerConfig: router,
    );
  }
}
