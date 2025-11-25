/// Base class for all exceptions in the data layer.
///
/// Exceptions are thrown by data sources and caught by repositories.
/// Repositories then convert exceptions to [Failure] types.
///
/// ## Usage
///
/// ```dart
/// // In data source
/// Future<UserModel> login(String email, String password) async {
///   try {
///     final response = await httpService.post('/login', body: {...});
///     return UserModel.fromMap(response.data);
///   } catch (e, s) {
///     Log.error('Login failed', e, s);
///     if (e is AppException) rethrow;
///     throw ServerException('Login failed: ${e.toString()}');
///   }
/// }
///
/// // In repository
/// Future<Either<Failure, User>> login(...) async {
///   try {
///     final user = await remoteDataSource.login(email, password);
///     return Right(user);
///   } on AuthException catch (e) {
///     return Left(AuthFailure(e.message));
///   } on ServerException catch (e) {
///     return Left(ServerFailure(e.message));
///   }
/// }
/// ```
///
/// ## Guidelines
///
/// - Exceptions belong in the data layer (core/errors/exceptions.dart)
/// - Always capture and log stack traces in data sources
/// - Rethrow known exceptions, wrap unknown ones
/// - Each exception type should have a corresponding failure type
///
/// See: docs/guidelines/05_data_source_pattern.md
abstract class AppException implements Exception {
  /// Human-readable error message.
  final String message;

  /// Optional error code for programmatic handling.
  final String? code;

  /// Stack trace captured when the exception was created.
  final StackTrace? stackTrace;

  /// Creates an [AppException] with the given [message], [code], and [stackTrace].
  const AppException([
    this.message = 'An error occurred',
    this.code,
    this.stackTrace,
  ]);

  @override
  String toString() => '$runtimeType: $message${code != null ? ' ($code)' : ''}';
}

/// Exception for server-side errors.
///
/// Throw when the server returns an error response or communication fails.
class ServerException extends AppException {
  /// HTTP status code if available.
  final int? statusCode;

  /// Creates a [ServerException] with the given [message] and optional [statusCode].
  const ServerException([
    super.message = 'Server error',
    this.statusCode,
    super.code,
    super.stackTrace,
  ]);
}

/// Exception for network connectivity issues.
///
/// Throw when the device cannot reach the server.
class NetworkException extends AppException {
  /// Creates a [NetworkException] with the given [message].
  const NetworkException([
    super.message = 'Network error',
    super.code,
    super.stackTrace,
  ]);
}

/// Exception for local cache/storage operations.
///
/// Throw when reading from or writing to local storage fails.
class CacheException extends AppException {
  /// Creates a [CacheException] with the given [message].
  const CacheException([
    super.message = 'Cache error',
    super.code,
    super.stackTrace,
  ]);
}

/// Exception for authentication-related errors.
///
/// Throw when authentication fails (invalid credentials, expired tokens, etc.).
class AuthException extends AppException {
  /// Creates an [AuthException] with the given [message].
  const AuthException([
    super.message = 'Authentication error',
    super.code,
    super.stackTrace,
  ]);
}

/// Exception for input validation errors.
///
/// Throw when input doesn't meet validation requirements.
class ValidationException extends AppException {
  /// Map of field names to error messages.
  final Map<String, List<String>>? errors;

  /// Creates a [ValidationException] with the given [message] and optional [errors].
  const ValidationException([
    super.message = 'Validation error',
    this.errors,
    super.code,
    super.stackTrace,
  ]);
}

/// Exception for permission-related errors.
///
/// Throw when the user lacks permission to perform an action.
class PermissionException extends AppException {
  /// Creates a [PermissionException] with the given [message].
  const PermissionException([
    super.message = 'Permission denied',
    super.code,
    super.stackTrace,
  ]);
}

/// Exception for not found errors.
///
/// Throw when a requested resource doesn't exist.
class NotFoundException extends AppException {
  /// Creates a [NotFoundException] with the given [message].
  const NotFoundException([
    super.message = 'Resource not found',
    super.code,
    super.stackTrace,
  ]);
}

/// Exception for timeout errors.
///
/// Throw when an operation takes too long to complete.
class TimeoutException extends AppException {
  /// Creates a [TimeoutException] with the given [message].
  const TimeoutException([
    super.message = 'Operation timed out',
    super.code,
    super.stackTrace,
  ]);
}
