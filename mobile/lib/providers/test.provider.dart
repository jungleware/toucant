import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'test.provider.g.dart';

@riverpod
class TestTest extends _$TestTest {
  // Initial value for the provider
  @override
  Future<int> build() async {
    return 0;
  }

  // Function to increment the value of the provider
  Future<void> increment() async {
    state = const AsyncLoading();
    await Future.delayed(const Duration(seconds: 1));
    final count = state.valueOrNull ?? 0;
    state = AsyncData(count + 1);
  }

  // Function to decrement the value of the provider
  Future<void> decrement() async {
    state = const AsyncLoading();
    await Future.delayed(const Duration(seconds: 1));
    final count = state.valueOrNull ?? 0;
    state = AsyncData(count - 1);
  }

  Future<bool> emulateProgress() async {
    state = const AsyncLoading();
    for (var i = 0; i < 10; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      state = AsyncData<int>(i);
    }
    state = const AsyncData(10);
    return true;
  }
}
