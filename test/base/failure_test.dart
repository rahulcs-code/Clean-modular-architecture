import 'package:test/test.dart';
import 'package:clean_modular_architecture/clean_modular_architecture.dart';

void main() {
  group('Failure', () {
    group('ServerFailure', () {
      test('should have default message', () {
        const failure = ServerFailure();
        expect(failure.message, contains('Server'));
      });

      test('should accept custom message', () {
        const failure = ServerFailure('Custom server error');
        expect(failure.message, equals('Custom server error'));
      });

      test('should have toString representation', () {
        const failure = ServerFailure('Test');
        expect(failure.toString(), contains('ServerFailure'));
        expect(failure.toString(), contains('Test'));
      });
    });

    group('NetworkFailure', () {
      test('should have default message', () {
        const failure = NetworkFailure();
        expect(failure.message, contains('Network'));
      });

      test('should accept custom message', () {
        const failure = NetworkFailure('No internet');
        expect(failure.message, equals('No internet'));
      });
    });

    group('CacheFailure', () {
      test('should have default message', () {
        const failure = CacheFailure();
        expect(failure.message.isNotEmpty, isTrue);
      });
    });

    group('AuthFailure', () {
      test('should have default message', () {
        const failure = AuthFailure();
        expect(failure.message.isNotEmpty, isTrue);
      });
    });

    group('ValidationFailure', () {
      test('should have default message', () {
        const failure = ValidationFailure();
        expect(failure.message.isNotEmpty, isTrue);
      });

      test('should accept field errors', () {
        const failure = ValidationFailure(
          'Validation failed',
          {'email': ['Invalid email']},
        );
        expect(failure.errors, isNotNull);
        expect(failure.errors!['email'], contains('Invalid email'));
      });
    });

    group('PermissionFailure', () {
      test('should have default message', () {
        const failure = PermissionFailure();
        expect(failure.message.isNotEmpty, isTrue);
      });
    });

    group('NotFoundFailure', () {
      test('should have default message', () {
        const failure = NotFoundFailure();
        expect(failure.message.isNotEmpty, isTrue);
      });
    });

    group('TimeoutFailure', () {
      test('should have default message', () {
        const failure = TimeoutFailure();
        expect(failure.message.isNotEmpty, isTrue);
      });
    });
  });
}
