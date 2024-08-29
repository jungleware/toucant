import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:toucant/extensions/build_context_extensions.dart';

class ClickableText extends StatelessWidget {
  const ClickableText({super.key, required this.text, required this.onTap});

  final String text;

  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return SelectableText.rich(
      TextSpan(
        text: text,
        style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.primary),
        recognizer: TapGestureRecognizer()..onTap = () => onTap(),
      ),
    );
  }
}
