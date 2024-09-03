import 'package:dio/dio.dart';
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

    useEffect(() {
      /// Shuffle the possible answers if the daily is not refreshing, to prevent shuffling twice
      daily.whenData((data) {
        if (data.type == DailyType.quiz && !daily.isRefreshing) {
          data.content.possibleAnswers!.shuffle();
        }
      });
      return null;
      // ignore: require_trailing_commas
    }, [daily]);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.app_name,
          semanticsLabel: context.l10n.app_name,
        ),
        leading: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Image.asset(
            'assets/toucant_splash.png',
            semanticLabel: context.l10n.semantics_app_icon,
          ),
        ),
        centerTitle: true,
        actions: [
          Semantics(
            button: true,
            label: context.l10n.common_settings,
            child: IconButton(
              icon: const Icon(Icons.settings),
              tooltip: context.l10n.common_settings,
              onPressed: () {
                context.push('/settings');
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: RefreshIndicator(
            onRefresh: () {
              userAnswer.value = null;
              return ref.refresh(getDailyProvider.future);
            },
            child: CustomScrollView(
              scrollBehavior: const MaterialScrollBehavior().copyWith(scrollbars: false, overscroll: false),
              slivers: [
                SliverFillRemaining(
                  child: Stack(
                    children: [
                      daily.when(
                        data: (data) {
                          if (data.type == DailyType.quote) return _buildQuote(context, daily: data);
                          if (data.type == DailyType.quiz) {
                            return _buildQuiz(
                              context,
                              daily: data,
                              onAnswer: (answer) {
                                userAnswer.value = answer;
                                if (data.content.answer == answer) {
                                  Confetti.launch(
                                    context,
                                    particleBuilder: (index) => Square(),
                                    options: const ConfettiOptions(
                                      particleCount: 250,
                                      y: 1.3,
                                      spread: 50,
                                      scalar: 2,
                                      gravity: 5,
                                      startVelocity: 130,
                                      ticks: 100,
                                    ),
                                  );
                                }
                              },
                              userAnswer: userAnswer.value,
                            );
                          }
                          return Center(
                            child: Text(
                              context.l10n.error_unknown_daily_type,
                              semanticsLabel: context.l10n.error_unknown_daily_type,
                            ),
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (error, stackTrace) {
                          if (error is DioException && error.type == DioExceptionType.connectionError) {
                            return Center(
                              child: Text(
                                context.l10n.error_no_internet,
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          return Center(
                            child: Text(
                              context.l10n.error_no_internet,
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            context.l10n.common_no_responsibility,
                            style: context.textTheme.bodySmall!.copyWith(color: context.textTheme.bodySmall!.color!.withOpacity(0.5)),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuote(BuildContext context, {required Daily daily}) {
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
          TextButton(
            onPressed: () => _launchSource(context, daily.source),
            child: Text(
              context.l10n.common_open_source_website,
              semanticsLabel: context.l10n.common_open_source_website,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuiz(BuildContext context, {required Daily daily, required Function(String) onAnswer, String? userAnswer}) {
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
            spacing: 16,
            children: _buildButtons(context, daily, onAnswer, userAnswer),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => _launchSource(context, daily.source),
            child: Text(
              context.l10n.common_open_source_website,
              semanticsLabel: context.l10n.common_open_source_website,
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
        style: ElevatedButton.styleFrom(
          backgroundColor: _buildButtonColor(context, daily, answer, userAnswer),
        ),
        child: Text(answer),
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

  Future<void> _launchSource(BuildContext context, String source) async {
    if (!await canLaunchUrlString(source)) return;
    launchUrl(Uri.parse(source));
  }
}
