import 'package:flutter/foundation.dart';
import 'package:toucant/models/content.model.dart';

@immutable
class Daily {
  /// Whether the daily is a quote or a quiz.
  final DailyType type;

  /// The keywords of the daily.
  final List<String> keywords;

  /// The source of the daily.
  final String source;

  /// The content of the daily.
  final Content content;

  Daily({
    required this.type,
    required this.keywords,
    required this.source,
    required this.content,
  });

  factory Daily.fromJson(Map<String, dynamic> json) {
    return Daily(
      type: json['type'] == 'quote' ? DailyType.QUOTE : DailyType.QUIZ,
      keywords: List<String>.from(json['keywords']),
      source: json['source'],
      content: Content.fromJson(json['content']),
    );
  }
}

enum DailyType { QUOTE, QUIZ }
