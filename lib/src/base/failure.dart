/// Base class for all failures in the domain layer.
///
/// Failures represent expected errors that are handled gracefully.
/// They are returned from repositories wrapped in `Either<Failure, Success>`.
///
/// ## Usage
///
/// ```dart
/// Future<Either<Failure, User>> login({
///   required String email,
///   required String password,
/// }) async {
///   try {
///     final user = await remoteDataSource.login(email, password);
///     return Right(user);
///   } on AuthException catch (e) {
///     return Left(AuthFailure(e.message));
///   } on NetworkException catch (e) {
///     return Left(NetworkFailure(e.message));
///   }
/// }
/// ```
///
/// ## Guidelines
///
/// - Failures belong in the domain layer (core/errors/failures.dart)
/// - Each failure type should have a corresponding exception type
/// - Messages should be user-friendly, not technical
/// - Use specific failure types, not generic ones
///
/// See: docs/guidelines/09_error_handling.md
abstract class Failure {
  /// Human-readable error message.
  final String message;

  /// Optional error code for programmatic handling.
  final String? code;

  /// Creates a [Failure] with the given [message] and optional [code].
  const Failure([this.message = 'An unexpected error occurred', this.code]);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          code == other.code;

  @override
  int get hashCode => message.hashCode ^ code.hashCode;

  @override
  String toString() => '$runtimeType: $message${code != null ? ' ($code)' : ''}';
}

/// Failure for server-side errors.
///
/// Use when the server returns an error response (5xx status codes)
/// or when server communication fails unexpectedly.
class ServerFailure extends Failure {
  /// HTTP status code if available.
  final int? statusCode;

  /// Creates a [ServerFailure] with the given [message] and optional [statusCode].
  const ServerFailure([
    super.message = 'Server error occurred. Please try again later.',
    this.statusCode,
  ]);
}

/// Failure for network connectivity issues.
///
/// Use when the device cannot reach the server due to network issues.
class NetworkFailure extends Failure {
  /// Creates a [NetworkFailure] with the given [message].
  const NetworkFailure([
    super.message = 'Network error. Please check your internet connection.',
  ]);
}

/// Failure for local cache/storage operations.
///
/// Use when reading from or writing to local storage fails.
class CacheFailure extends Failure {
  /// Creates a [CacheFailure] with the given [message].
  const CacheFailure([
    super.message = 'Local storage error occurred.',
  ]);
}

/// Failure for authentication-related errors.
///
/// Use when authentication fails (invalid credentials, expired tokens, etc.).
class AuthFailure extends Failure {
  /// Creates an [AuthFailure] with the given [message].
  const AuthFailure([
    super.message = 'Authentication failed. Please login again.',
  ]);
}

/// Failure for input validation errors.
///
/// Use when user input doesn't meet validation requirements.
class ValidationFailure extends Failure {
  /// Map of field names to error messages.
  final Map<String, List<String>>? errors;

  /// Creates a [ValidationFailure] with the given [message] and optional [errors].
  const ValidationFailure([
    super.message = 'Validation failed. Please check your input.',
    this.errors,
  ]);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is ValidationFailure &&
          _mapsEqual(errors, other.errors);

  @override
  int get hashCode => super.hashCode ^ errors.hashCode;

  bool _mapsEqual(
    Map<String, List<String>>? a,
    Map<String, List<String>>? b,
  ) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key)) return false;
      final aList = a[key]!;
      final bList = b[key]!;
      if (aList.length != bList.length) return false;
      for (var i = 0; i < aList.length; i++) {
        if (aList[i] != bList[i]) return false;
      }
    }
    return true;
  }
}

/// Failure for permission-related errors.
///
/// Use when the user lacks permission to perform an action.
class PermissionFailure extends Failure {
  /// Creates a [PermissionFailure] with the given [message].
  const PermissionFailure([
    super.message = 'Permission denied.',
  ]);
}

/// Failure for not found errors.
///
/// Use when a requested resource doesn't exist.
class NotFoundFailure extends Failure {
  /// Creates a [NotFoundFailure] with the given [message].
  const NotFoundFailure([
    super.message = 'The requested resource was not found.',
  ]);
}

/// Failure for timeout errors.
///
/// Use when an operation takes too long to complete.
class TimeoutFailure extends Failure {
  /// Creates a [TimeoutFailure] with the given [message].
  const TimeoutFailure([
    super.message = 'The operation timed out. Please try again.',
  ]);
}
