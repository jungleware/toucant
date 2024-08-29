import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:toucant/constants/strings.dart';
import 'package:toucant/extensions/build_context_extensions.dart';
import 'package:toucant/models/setting.model.dart';
import 'package:toucant/provider/package_info.provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SettingsPage extends HookConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Setting> settings = useMemoized(() {
      return [
        Setting(
          name: context.l10n.settings_theme_title,
          group: context.l10n.settings_group_appearance,
          icon: const Icon(Icons.color_lens),
          value: context.l10n.settings_theme_system,
          onTap: () {},
        ),
      ];
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.common_settings),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8.0),
          Expanded(
            child: GroupedListView<Setting, String>(
              elements: settings,
              groupBy: (element) => element.group,
              itemBuilder: (context, element) {
                return ListTile(
                  title: Text(element.name),
                  subtitle: Text(element.value.toString()),
                  leading: element.icon,
                  onTap: () => element.onTap(),
                );
              },
              groupSeparatorBuilder: (value) {
                return Padding(
                  padding: const EdgeInsets.only(left: 12.0, top: 8.0, bottom: 8.0),
                  child: Text(
                    value,
                    style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.primary),
                  ),
                );
              },
              footer: const AppSettingsFooter(),
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
