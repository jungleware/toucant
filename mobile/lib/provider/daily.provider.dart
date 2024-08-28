import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:toucant/models/daily.model.dart';
import 'package:toucant/services/api.service.dart';

final apiServiceProvider = Provider((ref) => ApiService());

final getDailyProvider = FutureProvider.autoDispose<Daily>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  return apiService.getDaily();
});
