import 'package:test/test.dart';

import 'package:clean_modular_architecture/clean_modular_architecture.dart';

void main() {
  group('Clean Modular Architecture Package', () {
    test('exports UseCase base class', () {
      // Verify the package exports are accessible
      expect(NoParams, isNotNull);
    });

    test('NoParams equality works correctly', () {
      const params1 = NoParams();
      const params2 = NoParams();
      expect(params1 == params2, isTrue);
    });

    test('Failure base class is accessible', () {
      const failure = ServerFailure();
      expect(failure.message, 'Server error occurred. Please try again later.');
    });
  });
}
