# Error Handling - Exceptions and Failures

**Location:** `lib/core/errors/`
**Purpose:** Consistent error handling across all layers

## Core Principle

**Data layer throws Exceptions, Domain layer uses Failures, wrapped in Either type.**

## Error Flow

```
Data Source
    ↓ throws Exception
Repository Implementation
    ↓ catches Exception, converts to Failure
    ↓ returns Either<Failure, Success>
Use Case
    ↓ returns Either<Failure, Success>
BLoC/Cubit
    ↓ handles Left (failure) or Right (success)
UI
```

## Exception Classes (Data Layer)

### Base Exception

```dart
// lib/core/errors/exceptions.dart

abstract class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}
```

### Specific Exceptions

```dart
/// Thrown when server returns an error response
class ServerException extends AppException {
  const ServerException([String message = 'Server error occurred']) : super(message);
}

/// Thrown when network connection fails
class NetworkException extends AppException {
  const NetworkException([String message = 'Network connection failed']) : super(message);
}

/// Thrown when authentication fails
class AuthException extends AppException {
  const AuthException([String message = 'Authentication failed']) : super(message);
}

/// Thrown when validation fails
class ValidationException extends AppException {
  final Map<String, String>? errors;

  const ValidationException(
    String message, [
    this.errors,
  ]) : super(message);
}

/// Thrown when cache operation fails
class CacheException extends AppException {
  const CacheException([String message = 'Cache operation failed']) : super(message);
}
```

## Failure Classes (Domain Layer)

### Base Failure

```dart
// lib/core/errors/failures.dart

abstract class Failure {
  final String message;
  const Failure([this.message = 'An unexpected error occurred']);

  @override
  String toString() => message;
}
```

### Specific Failures

```dart
/// Represents server-related failures
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred']);
}

/// Represents network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Please check your internet connection']);
}

/// Represents authentication failures
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed']);
}

/// Represents validation failures
class ValidationFailure extends Failure {
  final Map<String, String>? errors;

  const ValidationFailure(
    String message, [
    this.errors,
  ]) : super(message);
}

/// Represents cache/storage failures
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local storage error']);
}
```

## Using Either Type

### In Data Sources (Throw Exceptions)

```dart
// Data sources throw exceptions
@override
Future<ParentModel> login({
  required String email,
  required String password,
}) async {
  try {
    final response = await _httpService.post(
      Endpoints.login,
      body: {'email': email, 'password': password},
    );

    if (response.hasError && response.error != null) {
      throw response.error!;  // Throw exception
    }

    return ParentModel.fromMap(response.data);
  } catch (e, s) {
    Log.custom(Level.error, s.toString());

    if (e is AppException) rethrow;
    throw ServerException('Login failed: ${e.toString()}');
  }
}
```

### In Repositories (Convert to Either)

```dart
// Repositories catch exceptions and return Either
@override
Future<Either<Failure, ParentModel>> login({
  required String email,
  required String password,
}) async {
  try {
    final parentModel = await _remoteDataSource.login(
      email: email,
      password: password,
    );

    await _localDataSource.cacheParent(parentModel);

    return right(parentModel);  // Success
  } on AuthException catch (e) {
    return left(AuthFailure(e.message));  // Convert to failure
  } on ValidationException catch (e) {
    return left(ValidationFailure(e.message, e.errors));
  } on NetworkException catch (e) {
    return left(NetworkFailure(e.message));
  } on ServerException catch (e) {
    return left(ServerFailure(e.message));
  } catch (e, s) {
    Log.error('Unexpected error during login', e, s);
    return left(ServerFailure('An unexpected error occurred'));
  }
}
```

### In Use Cases (Pass Through)

```dart
// Use cases just return the Either from repository
@override
Future<Either<Failure, Parent>> call(LoginWithEmailParams params) async {
  return await repository.login(
    email: params.email,
    password: params.password,
  );  // Returns Either<Failure, Parent>
}
```

### In BLoC (Handle Left/Right)

```dart
// BLoC handles the Either
Future<void> _onLoginRequested(
  AuthLoginRequested event,
  Emitter<AuthState> emit,
) async {
  emit(AuthLoading());

  final result = await _loginWithEmail(
    LoginWithEmailParams(
      email: event.email,
      password: event.password,
    ),
  );

  result.fold(
    (failure) => emit(AuthFailure(failure.message)),  // Handle failure
    (parent) {
      _authCubit.login(parent);
      emit(AuthSuccess(parent));  // Handle success
    },
  );
}
```

## Exception to Failure Mapping

| Exception | Failure | Use Case |
|-----------|---------|----------|
| ServerException | ServerFailure | API errors, 500s |
| NetworkException | NetworkFailure | No connection, timeout |
| AuthException | AuthFailure | 401, 403, invalid credentials |
| ValidationException | ValidationFailure | Invalid input, form errors |
| CacheException | CacheFailure | Local storage errors |

## Error Message Best Practices

### User-Facing Messages

```dart
// ✅ CORRECT: User-friendly messages
const AuthFailure('Invalid email or password');
const NetworkFailure('Please check your internet connection');
const ServerFailure('Something went wrong. Please try again');
const ValidationFailure('Please fix the errors below');

// ❌ WRONG: Technical messages to users
const AuthFailure('401 Unauthorized');
const NetworkFailure('SocketException: Failed host lookup');
const ServerFailure('NullPointerException at line 42');
```

### Logging Technical Details

```dart
try {
  // operation
} on AuthException catch (e) {
  Log.warning('Auth error: ${e.message}');  // Log technical details
  return left(AuthFailure('Invalid credentials'));  // User-friendly message
}
```

## Validation Failure with Field Errors

```dart
// Exception with field-specific errors
class ValidationException extends AppException {
  final Map<String, String>? errors;

  const ValidationException(String message, [this.errors]) : super(message);
}

// Throwing validation exception
if (email.isEmpty) {
  throw ValidationException(
    'Validation failed',
    {'email': 'Email is required'},
  );
}

// Converting to failure
on ValidationException catch (e) {
  return left(ValidationFailure(e.message, e.errors));
}

// Displaying in UI
if (state is AuthFailure && state.errors != null) {
  final emailError = state.errors!['email'];
  // Show error under email field
}
```

## HTTP Status Code Mapping

```dart
// In HttpService or API client
if (response.statusCode >= 200 && response.statusCode < 300) {
  return ApiResponse.success(response.data);
}

switch (response.statusCode) {
  case 400:
    throw ValidationException('Invalid request');
  case 401:
    throw AuthException('Unauthorized');
  case 403:
    throw AuthException('Forbidden');
  case 404:
    throw ServerException('Resource not found');
  case 500:
  case 502:
  case 503:
    throw ServerException('Server error');
  default:
    throw ServerException('Unexpected error: ${response.statusCode}');
}
```

## Retrying Failed Operations

```dart
// In repository or use case
Future<Either<Failure, T>> withRetry<T>({
  required Future<T> Function() operation,
  int maxAttempts = 3,
}) async {
  int attempt = 0;

  while (attempt < maxAttempts) {
    try {
      final result = await operation();
      return right(result);
    } on NetworkException catch (e) {
      attempt++;
      if (attempt >= maxAttempts) {
        return left(NetworkFailure(e.message));
      }
      await Future.delayed(Duration(seconds: attempt));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  return left(ServerFailure('Max retry attempts reached'));
}

// Usage
return await withRetry(
  operation: () => _remoteDataSource.login(email, password),
);
```

## Displaying Errors in UI

### SnackBar for General Errors

```dart
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.red,
        ),
      );
    }
  },
  child: ...,
)
```

### Form Field Errors

```dart
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    String? emailError;

    if (state is AuthFailure && state is ValidationFailure) {
      emailError = (state as ValidationFailure).errors?['email'];
    }

    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Email',
        errorText: emailError,
      ),
    );
  },
)
```

### Error Widget

```dart
if (state is AuthFailure) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 60, color: Colors.red),
        const SizedBox(height: 16),
        Text(
          state.message,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => context.read<AuthBloc>().add(RetryLogin()),
          child: const Text('Retry'),
        ),
      ],
    ),
  );
}
```

## Checklist

- [ ] Exception classes in `core/errors/exceptions.dart`
- [ ] Failure classes in `core/errors/failures.dart`
- [ ] Data sources throw exceptions
- [ ] Repositories catch and convert to failures
- [ ] Repositories return `Either<Failure, Success>`
- [ ] Use cases return `Either<Failure, Success>`
- [ ] BLoCs use `fold()` to handle either case
- [ ] User-friendly failure messages
- [ ] Technical details logged, not shown to users
- [ ] Field-specific errors for validation
- [ ] Appropriate HTTP status code mapping

## Related Guidelines

- [03_repository_pattern.md](03_repository_pattern.md) - Exception to failure conversion
- [05_data_source_pattern.md](05_data_source_pattern.md) - Throwing exceptions
- [04_use_case_pattern.md](04_use_case_pattern.md) - Either return types

## Summary

**Error Flow:**
1. Data Source: Throws `Exception` (ServerException, NetworkException, etc.)
2. Repository: Catches `Exception`, returns `Either<Failure, Success>`
3. Use Case: Returns `Either<Failure, Success>`
4. BLoC: Handles with `fold()` - Left (failure) or Right (success)
5. UI: Displays user-friendly error messages

**Key Points:**
- Exceptions = Data layer (technical errors)
- Failures = Domain layer (business errors)
- Either = Functional error handling
- User-friendly messages in failures
- Technical details in logs only
