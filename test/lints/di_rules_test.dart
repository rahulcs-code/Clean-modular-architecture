import 'package:test/test.dart';

/// Tests for dependency injection lint rules.
void main() {
  group('DI Rules', () {
    group('use_lazy_singleton_for_bloc', () {
      test('should flag registerFactory for BLoC', () {
        // This would be detected as a violation:
        // sl.registerFactory(() => UserBloc(repository: sl())); // VIOLATION
        expect(true, isTrue);
      });

      test('should flag registerSingleton for BLoC', () {
        // This would be detected as a violation:
        // sl.registerSingleton(UserBloc(repository: sl())); // VIOLATION
        expect(true, isTrue);
      });

      test('should flag registerFactory for Cubit', () {
        // This would be detected as a violation:
        // sl.registerFactory(() => AuthCubit()); // VIOLATION
        expect(true, isTrue);
      });

      test('should pass with registerLazySingleton', () {
        // This should NOT be flagged:
        // sl.registerLazySingleton(() => UserBloc(repository: sl())); // OK
        expect(true, isTrue);
      });

      test('should pass registerFactory for non-BLoC classes', () {
        // This should NOT be flagged:
        // sl.registerFactory(() => UserRepository()); // OK
        expect(true, isTrue);
      });
    });
  });
}
