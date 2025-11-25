import 'package:test/test.dart';
import 'package:clean_modular_architecture/clean_modular_architecture.dart';

void main() {
  group('Exception', () {
    group('ServerException', () {
      test('should have default message', () {
        const exception = ServerException();
        expect(exception.message, contains('Server'));
      });

      test('should accept custom message and status code', () {
        const exception = ServerException('Internal error', 500);
        expect(exception.message, equals('Internal error'));
        expect(exception.statusCode, equals(500));
      });

      test('should implement Exception', () {
        const exception = ServerException();
        expect(exception, isA<Exception>());
      });

      test('should have toString representation', () {
        const exception = ServerException('Test');
        expect(exception.toString(), contains('ServerException'));
        expect(exception.toString(), contains('Test'));
      });
    });

    group('NetworkException', () {
      test('should have default message', () {
        const exception = NetworkException();
        expect(exception.message, contains('Network'));
      });
    });

    group('CacheException', () {
      test('should have default message', () {
        const exception = CacheException();
        expect(exception.message.isNotEmpty, isTrue);
      });
    });

    group('AuthException', () {
      test('should have default message', () {
        const exception = AuthException();
        expect(exception.message.isNotEmpty, isTrue);
      });
    });

    group('ValidationException', () {
      test('should have default message', () {
        const exception = ValidationException();
        expect(exception.message.isNotEmpty, isTrue);
      });

      test('should accept field errors', () {
        const exception = ValidationException(
          'Validation error',
          {'password': ['Too short', 'Needs uppercase']},
        );
        expect(exception.errors, isNotNull);
        expect(exception.errors!['password'], hasLength(2));
      });
    });

    group('PermissionException', () {
      test('should have default message', () {
        const exception = PermissionException();
        expect(exception.message.isNotEmpty, isTrue);
      });
    });

    group('NotFoundException', () {
      test('should have default message', () {
        const exception = NotFoundException();
        expect(exception.message.isNotEmpty, isTrue);
      });
    });

    group('TimeoutException', () {
      test('should have default message', () {
        const exception = TimeoutException();
        expect(exception.message.isNotEmpty, isTrue);
      });
    });
  });
}
