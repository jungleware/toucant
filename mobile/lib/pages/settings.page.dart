import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:toucant/extensions/build_context_extensions.dart';
import 'package:toucant/provider/package_info.provider.dart';

class SettingsPage extends HookConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.common_settings),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(context.l10n.common_settings_version),
            subtitle: Text(ref.watch(packageInfoProvider).value?.version ?? ''),
          ),
        ],
      ),
    );
  }
}
