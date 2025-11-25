import 'package:fpdart/fpdart.dart';
import 'package:test/test.dart';
import 'package:clean_modular_architecture/clean_modular_architecture.dart';

/// Test implementation of UseCase
class TestUseCase implements UseCase<String, TestParams> {
  final Either<Failure, String> Function(TestParams) handler;

  TestUseCase(this.handler);

  @override
  Future<Either<Failure, String>> call(TestParams params) async {
    return handler(params);
  }
}

class TestParams {
  final String value;
  const TestParams(this.value);
}

/// Test implementation of SyncUseCase
class TestSyncUseCase implements SyncUseCase<int, String> {
  final Either<Failure, int> Function(String) handler;

  TestSyncUseCase(this.handler);

  @override
  Either<Failure, int> call(String params) {
    return handler(params);
  }
}

void main() {
  group('UseCase', () {
    test('should return Right on success', () async {
      final useCase = TestUseCase(
        (params) => Right('Result: ${params.value}'),
      );

      final result = await useCase(const TestParams('test'));

      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Should not be a failure'),
        (value) => expect(value, equals('Result: test')),
      );
    });

    test('should return Left on failure', () async {
      final useCase = TestUseCase(
        (params) => const Left(ServerFailure('Test error')),
      );

      final result = await useCase(const TestParams('test'));

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure.message, equals('Test error')),
        (value) => fail('Should not be a success'),
      );
    });
  });

  group('SyncUseCase', () {
    test('should return Right on success', () {
      final useCase = TestSyncUseCase(
        (params) => Right(params.length),
      );

      final result = useCase('hello');

      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Should not be a failure'),
        (value) => expect(value, equals(5)),
      );
    });

    test('should return Left on failure', () {
      final useCase = TestSyncUseCase(
        (params) => const Left(ValidationFailure('Invalid input')),
      );

      final result = useCase('');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (value) => fail('Should not be a success'),
      );
    });
  });

  group('NoParams', () {
    test('should have const constructor', () {
      const params1 = NoParams();
      const params2 = NoParams();

      expect(identical(params1, params2), isTrue);
    });
  });
}
