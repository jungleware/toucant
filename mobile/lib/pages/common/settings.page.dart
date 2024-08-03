import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:toucant/providers/test.provider.dart';

@RoutePage()
class SettingsPage extends HookConsumerWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var res = ref.watch(testTestProvider);
    return res.when(
      data: (data) => Text(data.toString()),
      error: (msg, stk) => Text("Error"),
      loading: () => Text("Ld"),
    );
  }
}
