import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:toucant/constants/strings.dart';
import 'package:toucant/extensions/build_context_extensions.dart';
import 'package:toucant/provider/notifications.provider.dart';
import 'package:toucant/provider/package_info.provider.dart';
import 'package:toucant/provider/settings.provider.dart';
import 'package:toucant/provider/theme.provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SettingsPage extends HookConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appSettings = ref.watch(appSettingsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.common_settings,
          semanticsLabel: context.l10n.common_settings,
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8.0),
          Expanded(
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Text(
                    context.l10n.settings_group_appearance,
                    style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.primary),
                    semanticsLabel: context.l10n.settings_group_appearance,
                  ),
                ),
                const SizedBox(height: 8.0),
                Semantics(
                  label: context.l10n.semantics_current_app_theme(_buildDropdownLabel(context, ref.read(themeProvider))),
                  child: ListTile(
                    title: ExcludeSemantics(child: Text(context.l10n.settings_theme_title)),
                    trailing: Semantics(
                      button: true,
                      child: DropdownButton<ThemeMode>(
                        value: appSettings.themeSetting,
                        onChanged: (ThemeMode? value) {
                          appSettings.themeSetting = value!;
                          ref.read(appSettingsProvider.notifier).saveSettings();
                        },
                        items: const [
                          DropdownMenuItem(
                            value: ThemeMode.system,
                            child: Text('System'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.light,
                            child: Text('Light'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.dark,
                            child: Text('Dark'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Text(
                    context.l10n.settings_group_notifications,
                    style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.primary),
                    semanticsLabel: context.l10n.settings_group_notifications,
                  ),
                ),
                const SizedBox(height: 8.0),
                Semantics(
                  button: true,
                  value: appSettings.notifyOnNewContent.toString(),
                  child: ListTile(
                    title: ExcludeSemantics(child: Text("${context.l10n.settings_notify_on_new_content_title} ${Emojis.animals_parrot}")),
                    subtitle: Text(context.l10n.settings_notify_on_new_content_description),
                    trailing: Switch(
                      value: appSettings.notifyOnNewContent,
                      onChanged: (bool value) {
                        appSettings.notifyOnNewContent = value;
                        ref.read(appSettingsProvider.notifier).saveSettings();
                        if (appSettings.notifyOnNewContent) {
                          ref.read(notificationServiceProvider).createScheduledNotifications(context);
                        } else {
                          ref.read(notificationServiceProvider).removeScheduledNotifications();
                        }
                      },
                    ),
                  ),
                ),
                const Divider(),
                const AppSettingsFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _buildDropdownLabel(BuildContext context, ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.system:
        return context.l10n.settings_theme_system;
      case ThemeMode.light:
        return context.l10n.settings_theme_light;
      case ThemeMode.dark:
        return context.l10n.settings_theme_dark;
    }
  }
}

class AppSettingsFooter extends ConsumerWidget {
  const AppSettingsFooter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appInfo = ref.read(packageInfoProvider);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Semantics(
              button: true,
              enabled: true,
              label: context.l10n.common_privacy_policy,
              child: TextButton(
                onPressed: () => launchUrlString(kPrivacyPolicyUrl),
                child: Text(context.l10n.common_privacy_policy),
              ),
            ),
            const Text(' • '),
            Semantics(
              button: true,
              enabled: true,
              label: 'GitHub',
              child: TextButton(
                onPressed: () => launchUrlString(kGitHubUrl),
                child: const Text('GitHub'),
              ),
            ),
            const Text(' • '),
            Semantics(
              button: true,
              enabled: true,
              label: context.l10n.common_open_source_licenses,
              child: TextButton(
                onPressed: () => showLicensePage(
                  context: context,
                  applicationIcon: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      'assets/toucant_splash.png',
                      width: 50,
                      semanticLabel: context.l10n.semantics_app_icon,
                    ),
                  ),
                  applicationName: 'TouCant',
                  applicationVersion: 'v${appInfo.value!.version} (${appInfo.value!.buildNumber})',
                ),
                child: Text(
                  context.l10n.common_open_source_licenses,
                  semanticsLabel: context.l10n.common_open_source_licenses,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        Text(
          'v${appInfo.value!.version} (${appInfo.value!.buildNumber})',
          style: context.textTheme.bodySmall,
          semanticsLabel: context.l10n.semantics_current_app_version(
            'v${appInfo.value!.version} (${appInfo.value!.buildNumber})',
          ),
        ),
      ],
    );
  }
}
