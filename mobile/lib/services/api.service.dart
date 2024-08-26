import 'package:dio/dio.dart';
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
    return Daily.fromJson(response.data);
  }
}
