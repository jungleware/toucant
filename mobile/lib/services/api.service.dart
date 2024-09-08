import 'dart:io';

import 'package:dio/dio.dart';
import 'package:toucant/constants/locales.dart';
import 'package:toucant/models/daily.model.dart';

class ApiService {
  final _dio = Dio(
    BaseOptions(
      baseUrl: 'https://toucant.jungleware.dev/api',
      contentType: 'application/json',
      sendTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  /// Get the daily content.
  ///
  /// Throws an exception if the request fails.
  Future<Daily> getDaily() async {
    final response = await _dio.get('/daily');
    if (response.statusCode != 200 || response.data == null) {
      throw Exception('Failed to load daily');
    }

    Map<String, Object?> data = response.data;

    // Get only the daily for the current locale (or fallback to the default - first - entry in toucantLocales)
    String currentLocale = Platform.localeName.split('_').first.trim();
    if (!toucantLocales.values.any((e) => e.languageCode == currentLocale)) {
      currentLocale = toucantLocales.values.first.languageCode.trim();
    }

    // Get the content field
    final List<Map<String, Object?>> jsonContent = List<Map<String, Object?>>.from(data['content'] as List<Object?>);

    // Get a fallback content if the current locale is not available
    final Map<String, Object?> fallbackContent = jsonContent.firstWhere(
      (element) => element['lang'].toString().trim() == toucantLocales.values.first.languageCode.trim(),
      orElse: () => jsonContent.first,
    );

    // Get the content for the current locale
    final Map<String, Object?> content = jsonContent.firstWhere(
      (element) => element['lang'].toString().trim() == currentLocale,
      orElse: () => fallbackContent,
    );

    // Remove the content field from the data and add the content field with the current locale
    data.remove('content');
    return Daily.fromJson({
      // "type": "quiz",
      // "keywords": ["population", "weight"],
      // "content": {
      //   "lang": "en",
      //   "text": "What was the percentage of overweight or obese adults in most EU countries in 2021?",
      //   "answer": "~50%",
      //   "wrong": ["~25%", "~75%"]
      // },
      // "source": "https://de.statista.com/statistik/daten/studie/153908/umfrage/fettleibigkeit-unter-erwachsenen-in-oecd-laendern/"
      ...data,
      'content': content,
      // "type": "quote",
      // "keywords": ["salary", "ceo"],
      // "content": {"lang": "en", "text": "In 2022, it was estimated that the CEO-to-worker compensation ratio was 344.3 in the United States."},
      // "source": "https://www.statista.com/statistics/261463/ceo-to-worker-compensation-ratio-of-top-firms-in-the-us/"
    });
  }
}
