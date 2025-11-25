import 'package:fpdart/fpdart.dart';
import 'failure.dart';

/// Base class for all use cases in the domain layer.
///
/// Use cases represent single business operations and follow the Single
/// Responsibility Principle. Each use case should do one thing only.
///
/// ## Usage
///
/// ```dart
/// class LoginWithEmail implements UseCase<User, LoginParams> {
///   final AuthRepository repository;
///
///   const LoginWithEmail(this.repository);
///
///   @override
///   Future<Either<Failure, User>> call(LoginParams params) async {
///     return await repository.login(
///       email: params.email,
///       password: params.password,
///     );
///   }
/// }
///
/// class LoginParams {
///   final String email;
///   final String password;
///
///   const LoginParams({required this.email, required this.password});
/// }
/// ```
///
/// ## Guidelines
///
/// - Use cases should depend on repository interfaces, not implementations
/// - Return `Either<Failure, SuccessType>` for error handling
/// - Use [NoParams] when no parameters are needed
/// - Name use cases with action verbs: `LoginWithEmail`, `GetCachedUser`, `RegisterParent`
///
/// See: docs/guidelines/04_use_case_pattern.md
abstract class UseCase<SuccessType, Params> {
  /// Execute the use case.
  ///
  /// Returns [Either] with [Failure] on the left side for errors,
  /// or the success [SuccessType] on the right side.
  Future<Either<Failure, SuccessType>> call(Params params);
}

/// Base class for synchronous use cases.
///
/// Use this when the operation doesn't require async execution.
///
/// ```dart
/// class ValidateEmail implements SyncUseCase<bool, String> {
///   @override
///   Either<Failure, bool> call(String email) {
///     if (email.contains('@')) {
///       return const Right(true);
///     }
///     return const Left(ValidationFailure('Invalid email format'));
///   }
/// }
/// ```
abstract class SyncUseCase<SuccessType, Params> {
  /// Execute the use case synchronously.
  Either<Failure, SuccessType> call(Params params);
}

/// Base class for use cases that return a stream.
///
/// Use this for reactive operations that emit multiple values over time.
///
/// ```dart
/// class WatchUserProfile implements StreamUseCase<User, String> {
///   final UserRepository repository;
///
///   const WatchUserProfile(this.repository);
///
///   @override
///   Stream<Either<Failure, User>> call(String userId) {
///     return repository.watchUser(userId);
///   }
/// }
/// ```
abstract class StreamUseCase<SuccessType, Params> {
  /// Execute the use case and return a stream.
  Stream<Either<Failure, SuccessType>> call(Params params);
}
