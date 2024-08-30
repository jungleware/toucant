import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:toucant/constants/strings.dart';
import 'package:toucant/extensions/build_context_extensions.dart';
import 'package:toucant/provider/package_info.provider.dart';
import 'package:toucant/provider/settings.provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SettingsPage extends HookConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appSettings = ref.watch(appSettingsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.common_settings),
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
                  ),
                ),
                const SizedBox(height: 8.0),
                ListTile(
                  title: Text(context.l10n.settings_theme_title),
                  trailing: DropdownButton<ThemeMode>(
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
                const Divider(),
                const AppSettingsFooter(),
              ],
            ),
          ),
        ],
      ),
    );
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
            TextButton(
              onPressed: () => launchUrlString(kPrivacyPolicyUrl),
              child: Text(context.l10n.common_privacy_policy),
            ),
            const Text(' • '),
            TextButton(
              onPressed: () => launchUrlString(kGitHubUrl),
              child: const Text('GitHub'),
            ),
            const Text(' • '),
            TextButton(
              onPressed: () => showLicensePage(
                context: context,
                applicationIcon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    'assets/toucant_splash.png',
                    width: 50,
                  ),
                ),
                applicationName: 'TouCant',
                applicationVersion: 'v${appInfo.value!.version} (${appInfo.value!.buildNumber})',
              ),
              child: Text(context.l10n.common_open_source_licenses),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        Text(
          'v${appInfo.value!.version} (${appInfo.value!.buildNumber})',
          style: context.textTheme.bodySmall,
        ),
      ],
    );
  }
}
