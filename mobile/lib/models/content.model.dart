import 'dart:ui';

import 'package:toucant/models/daily.model.dart';

class Content {
  /// The locale of the content.
  final Locale locale;

  /// The type of the daily.
  final DailyType type;

  /// The text of the content.
  final String text;

  /// The answer of the content. Only available for quizzes.
  final String? answer;

  /// The wrong answers of the content. Only available for quizzes.
  final List<String>? wrongs;

  /// The possible answers of the content. Only available for quizzes.
  final List<String>? possibleAnswers;

  Content({
    required this.locale,
    required this.type,
    required this.text,
    this.answer,
    this.wrongs,
  }) : possibleAnswers = type == DailyType.QUIZ ? [answer!, ...wrongs!] : null;

  factory Content.fromJson(Map<String, dynamic> json, DailyType type) {
    return Content(
      locale: Locale(json['lang']),
      type: type,
      text: json['text'],
      answer: json['answer'],
      wrongs: json['wrong']?.cast<String>(),
    );
  }

  @override
  String toString() {
    return 'Content(locale: $locale, type: $type, text: $text, answer: $answer, wrongs: $wrongs, possibleAnswers: $possibleAnswers)';
  }
}
