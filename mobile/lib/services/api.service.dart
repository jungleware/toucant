import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:toucant/constants/locales.dart';
import 'package:toucant/models/daily.model.dart';

class ApiService {
  final _dio = Dio(
    BaseOptions(
      baseUrl: 'https://apps.jungleware.dev/toucant/api',
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
    if (response.statusCode != 200) {
      throw Exception('Failed to load daily');
    }

    Map<String, dynamic> data = response.data;

    // Get only the daily for the current locale (or fallback to first entry in )
    String currentLocale = Intl.getCurrentLocale().split("_").first;
    if (!toucantLocales.values.any((e) => e.languageCode == currentLocale)) {
      currentLocale = toucantLocales.values.first.languageCode;
    }
    final Map<String, dynamic> content = data['content'].firstWhere((element) => element['lang'] == currentLocale);

    data.remove('content');
    return Daily.fromJson({
      ...data,
      'content': content,
    });
  }
}
