import 'package:flutter/material.dart';
import 'package:flutter_confetti/flutter_confetti.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:toucant/extensions/build_context_extensions.dart';
import 'package:toucant/models/daily.model.dart';
import 'package:toucant/provider/daily.provider.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Daily> daily = ref.watch(getDailyProvider);

    final userAnswer = useState<String?>(null);

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
          child: daily.when(
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
                          particleCount: 200,
                          y: 0.7,
                          spread: 100,
                          startVelocity: 15,
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
                error.toString(),
                textAlign: TextAlign.center,
              ),
            ),
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
          Text(daily.content.text, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildQuiz(BuildContext context, Daily daily, Function(String) onAnswer, String? userAnswer) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(daily.content.text, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          OverflowBar(
            children: _buildButtons(context, daily, onAnswer, userAnswer),
            spacing: 16,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildButtons(BuildContext context, Daily daily, Function(String) onAnswer, String? userAnswer) {
    return daily.possibleAnswers.map((answer) {
      return ElevatedButton(
        onPressed: () => onAnswer(answer),
        child: Text(answer),
        style: ElevatedButton.styleFrom(
          backgroundColor: _buildButtonColor(context, daily, answer, userAnswer),
        ),
      );
    }).toList();
  }

  Color? _buildButtonColor(BuildContext context, Daily daily, String answer, String? userAnswer) {
    if (userAnswer == answer) {
      if (daily.content.answer == answer) return context.themeData.colorScheme.primaryContainer;
      return context.themeData.colorScheme.errorContainer;
    }
    return null;
  }
}
