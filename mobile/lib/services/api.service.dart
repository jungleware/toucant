import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
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
    final Map<String, dynamic> data = response.data;

    // Get only the daily for the current locale
    final String currentLocale = Intl.getCurrentLocale();

    data['content'].firstWhere((element) => element['lang'] == currentLocale);

    return Daily.fromJson(response.data);
  }
}
