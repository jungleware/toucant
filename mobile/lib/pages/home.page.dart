import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_confetti/flutter_confetti.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:toucant/extensions/build_context_extensions.dart';
import 'package:toucant/models/daily.model.dart';
import 'package:toucant/provider/daily.provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Daily> daily = ref.watch(getDailyProvider);

    final userAnswer = useState<String?>(null);
    // Shuffles the answers when the daily changes
    useEffect(
      () {
        daily.whenData((data) {
          if (data.type == DailyType.QUIZ) {
            data.content.possibleAnswers?.shuffle();
          }
        });
        return null;
      },
      [daily],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.app_name),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.push('/settings');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              daily.when(
                data: (data) {
                  if (data.type == DailyType.QUOTE) return _buildQuote(context, data);
                  if (data.type == DailyType.QUIZ) {
                    return _buildQuiz(
                      context,
                      data,
                      (answer) {
                        userAnswer.value = answer;
                        if (data.content.answer == answer) {
                          Confetti.launch(
                            context,
                            particleBuilder: (index) => Square(),
                            options: const ConfettiOptions(
                              particleCount: 250,
                              y: 0.7,
                              spread: 100,
                              scalar: 4,
                              gravity: 5,
                              startVelocity: 80,
                            ),
                          );
                        }
                      },
                      userAnswer.value,
                    );
                  }
                  return const Center(child: Text('Unknown daily type'));
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Center(
                  child: Text(
                    error.toString() + '\n' + stackTrace.toString(),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    context.l10n.common_no_responsibility,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuote(BuildContext context, Daily daily) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            daily.content.text,
            textAlign: TextAlign.center,
            style: context.textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          SelectableText.rich(
            TextSpan(
              text: context.l10n.common_open_source_website,
              style: context.textTheme.bodySmall?.copyWith(color: Colors.blue),
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  if (!await canLaunchUrlString(daily.source)) return;
                  launchUrl(Uri.parse(daily.source));
                },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuiz(BuildContext context, Daily daily, Function(String) onAnswer, String? userAnswer) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            daily.content.text,
            textAlign: TextAlign.center,
            style: context.textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          OverflowBar(
            children: _buildButtons(context, daily, onAnswer, userAnswer),
            spacing: 16,
          ),
          const SizedBox(height: 16),
          SelectableText.rich(
            TextSpan(
              text: context.l10n.common_open_source_website,
              style: context.textTheme.bodySmall?.copyWith(color: Colors.blue),
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  if (!await canLaunchUrlString(daily.source)) return;
                  launchUrl(Uri.parse(daily.source));
                },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildButtons(BuildContext context, Daily daily, Function(String) onAnswer, String? userAnswer) {
    return daily.content.possibleAnswers!.map((answer) {
      return ElevatedButton(
        onPressed: () => onAnswer(answer),
        child: Text(answer),
        style: ElevatedButton.styleFrom(
          backgroundColor: _buildButtonColor(context, daily, answer, userAnswer),
          foregroundColor: Colors.white,
        ),
      );
    }).toList();
  }

  Color? _buildButtonColor(BuildContext context, Daily daily, String answer, String? userAnswer) {
    if (userAnswer == answer) {
      // If the users answer is correct, return the primary color
      if (daily.content.answer == answer) return context.themeData.colorScheme.primaryContainer;
      return context.themeData.colorScheme.errorContainer;
    }
    return null;
  }
}
