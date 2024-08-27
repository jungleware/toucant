import 'dart:ui';

class Content {
  /// The locale of the content.
  final Locale locale;

  /// The text of the content.
  final String text;

  /// The answer of the content. Only available for quizzes.
  final String? answer;

  /// The wrong answers of the content. Only available for quizzes.
  final List<String>? wrongs;

  Content({
    required this.locale,
    required this.text,
    this.answer,
    this.wrongs,
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      locale: Locale(json['lang']),
      text: json['text'],
      answer: json['answer'],
      wrongs: json['wrong'],
    );
  }

  @override
  String toString() {
    return 'Content(locale: $locale, text: $text, answer: $answer, wrongs: $wrongs)';
  }
}
