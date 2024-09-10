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
  }) : possibleAnswers = type == DailyType.quiz ? [answer!, ...wrongs!] : null;

  factory Content.fromJson(Map<String, Object?> json, DailyType type) {
    return Content(
      locale: Locale(json['lang'] as String),
      type: type,
      text: json['text'] as String,
      answer: json['answer'] as String?,
      wrongs: json['wrong'] != null ? List<String>.from(json['wrong'] as List) : null,
    );
  }

  @override
  String toString() {
    return 'Content(locale: $locale, type: $type, text: $text, answer: $answer, wrongs: $wrongs, possibleAnswers: $possibleAnswers)';
  }
}
