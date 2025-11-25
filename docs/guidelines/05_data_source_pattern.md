# Data Source Pattern - Mandatory Error Handling

**Location:** `lib/features/{feature}/data/datasources/`
**Layer:** Data
**Purpose:** Handle external data operations (API, Database, Cache)

## ⚠️ MANDATORY PATTERN

All data source methods MUST follow this exact structure. This is **non-negotiable**.

## Required Pattern Structure

```dart
@override
Future<ModelType> methodName({
  required params,
}) async {
  try {
    // 1. Perform the operation
    final response = await _httpService.post(endpoint, body: {...});

    // 2. Check for errors
    if (response.hasError && response.error != null) {
      throw response.error!;
    }

    // 3. Validate response data
    if (response.data == null) {
      throw const ServerException('No data received');
    }

    // 4. Convert and return
    return ModelType.fromMap(response.data);
  } catch (e, s) {
    // 5. Log stack trace (MANDATORY)
    Log.custom(Level.error, s.toString());

    // 6. Rethrow known exceptions
    if (e is AppException) {
      rethrow;
    }

    // 7. Wrap unknown exceptions
    throw ServerException(e.toString());
  }
}
```

## Data Source Types

### 1. Remote Data Source (API)

```dart
// lib/features/auth/data/datasources/auth_remote_data_source.dart

import 'package:your_app/core/errors/exceptions.dart';
import 'package:your_app/core/services/http_service.dart';
import 'package:your_app/core/utils/log.dart';
import 'package:your_app/core/services/api/endpoints.dart';
import 'package:your_app/features/auth/data/models/parent_model.dart';
import 'package:logger/logger.dart';

abstract interface class AuthRemoteDataSource {
  Future<ParentModel> login({
    required String email,
    required String password,
  });

  Future<ParentModel> register({
    required String name,
    required String email,
    required String password,
  });

  Future<void> logout({required String token});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final HttpService _httpService;

  const AuthRemoteDataSourceImpl({required HttpService httpService})
      : _httpService = httpService;

  @override
  Future<ParentModel> login({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Make API call
      final response = await _httpService.post(
        Endpoints.login,
        body: {
          'email': email,
          'password': password,
        },
      );

      // 2. Check for HTTP errors
      if (response.hasError && response.error != null) {
        throw response.error!;
      }

      // 3. Validate response data
      if (response.data == null) {
        throw const ServerException('Login failed: No data received');
      }

      // 4. Deserialize and return model
      return ParentModel.fromMap(response.data as Map<String, dynamic>);
    } catch (e, s) {
      // 5. MANDATORY: Log complete stack trace
      Log.custom(Level.error, s.toString());

      // 6. Rethrow known exceptions (AuthException, NetworkException, etc.)
      if (e is AppException) {
        rethrow;
      }

      // 7. Wrap unknown exceptions
      throw ServerException('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<ParentModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _httpService.post(
        Endpoints.register,
        body: {
          'name': name,
          'email': email,
          'password': password,
        },
      );

      if (response.hasError && response.error != null) {
        throw response.error!;
      }

      if (response.data == null) {
        throw const ServerException('Registration failed: No data received');
      }

      return ParentModel.fromMap(response.data as Map<String, dynamic>);
    } catch (e, s) {
      Log.custom(Level.error, s.toString());

      if (e is AppException) {
        rethrow;
      }

      throw ServerException('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<void> logout({required String token}) async {
    try {
      final response = await _httpService.post(
        Endpoints.logout,
        body: {'token': token},
      );

      if (response.hasError && response.error != null) {
        throw response.error!;
      }

      // Void return - no data to deserialize
    } catch (e, s) {
      Log.custom(Level.error, s.toString());

      if (e is AppException) {
        rethrow;
      }

      throw ServerException('Logout failed: ${e.toString()}');
    }
  }
}
```

### 2. Local Data Source (Cache/Database)

```dart
// lib/features/auth/data/datasources/auth_local_data_source.dart

import 'package:your_app/core/errors/exceptions.dart';
import 'package:your_app/core/services/storage/local_storage.dart';
import 'package:your_app/core/utils/log.dart';
import 'package:your_app/features/auth/data/models/parent_model.dart';
import 'package:logger/logger.dart';

abstract interface class AuthLocalDataSource {
  Future<void> cacheParent(ParentModel parent);
  Future<ParentModel?> getParent();
  Future<void> clearParent();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String _parentKey = 'cached_parent';

  @override
  Future<void> cacheParent(ParentModel parent) async {
    try {
      // 1. Serialize model
      final jsonString = parent.toJson();

      // 2. Store in local storage
      await LocalStorage.writeString(_parentKey, jsonString);

      Log.info('Parent cached successfully');
    } catch (e, s) {
      // 3. Log stack trace (MANDATORY)
      Log.custom(Level.error, s.toString());

      // 4. Wrap in CacheException
      throw CacheException('Failed to cache parent: ${e.toString()}');
    }
  }

  @override
  Future<ParentModel?> getParent() async {
    try {
      // 1. Read from storage
      final jsonString = await LocalStorage.readString(_parentKey);

      // 2. Return null if not found
      if (jsonString == null) {
        return null;
      }

      // 3. Deserialize and return
      return ParentModel.fromJson(jsonString);
    } catch (e, s) {
      Log.custom(Level.error, s.toString());

      throw CacheException('Failed to retrieve cached parent: ${e.toString()}');
    }
  }

  @override
  Future<void> clearParent() async {
    try {
      await LocalStorage.delete(_parentKey);
      Log.info('Parent cache cleared');
    } catch (e, s) {
      Log.custom(Level.error, s.toString());

      throw CacheException('Failed to clear parent cache: ${e.toString()}');
    }
  }
}
```

## Why This Pattern is Mandatory

### 1. Stack Trace Logging

```dart
catch (e, s) {  // ✅ MUST capture stack trace
  Log.custom(Level.error, s.toString());  // ✅ MUST log it
  // ...
}
```

**Why:**
- Provides complete error context
- Shows exact call chain
- Essential for debugging production issues
- Required parameter `s` forces capturing stack trace

### 2. Specific Exception Rethrowing

```dart
if (e is AppException) {
  rethrow;  // ✅ Preserve exception type
}
```

**Why:**
- Preserves specific exception types (AuthException, NetworkException, etc.)
- Allows repository to handle different exceptions appropriately
- Maintains error context and messages

### 3. Unknown Exception Wrapping

```dart
throw ServerException(e.toString());  // ✅ Wrap unknown exceptions
```

**Why:**
- Standardizes all exceptions to AppException hierarchy
- Prevents unexpected exception types reaching domain layer
- Provides consistent error handling interface

## ❌ Common Mistakes

### Mistake 1: Generic Catch Without Stack Trace

```dart
// ❌ WRONG: No stack trace parameter
@override
Future<ParentModel> login({...}) async {
  try {
    final response = await _httpService.post(...);
    return ParentModel.fromMap(response.data);
  } catch (e) {  // ❌ Missing stack trace
    throw ServerException(e.toString());
  }
}
```

**Fix:**
```dart
// ✅ CORRECT: Capture and log stack trace
@override
Future<ParentModel> login({...}) async {
  try {
    final response = await _httpService.post(...);
    return ParentModel.fromMap(response.data);
  } catch (e, s) {  // ✅ Capture stack trace
    Log.custom(Level.error, s.toString());  // ✅ Log it
    if (e is AppException) rethrow;
    throw ServerException(e.toString());
  }
}
```

### Mistake 2: Not Rethrowing Known Exceptions

```dart
// ❌ WRONG: Wrapping all exceptions
@override
Future<ParentModel> login({...}) async {
  try {
    final response = await _httpService.post(...);
    return ParentModel.fromMap(response.data);
  } catch (e, s) {
    Log.custom(Level.error, s.toString());
    // ❌ Always wrapping, loses specific exception types
    throw ServerException(e.toString());
  }
}
```

**Fix:**
```dart
// ✅ CORRECT: Rethrow known exceptions
@override
Future<ParentModel> login({...}) async {
  try {
    final response = await _httpService.post(...);
    return ParentModel.fromMap(response.data);
  } catch (e, s) {
    Log.custom(Level.error, s.toString());

    // ✅ Rethrow known exceptions with their specific types
    if (e is AppException) {
      rethrow;
    }

    // ✅ Only wrap truly unknown exceptions
    throw ServerException(e.toString());
  }
}
```

### Mistake 3: No Response Validation

```dart
// ❌ WRONG: No null checking
@override
Future<ParentModel> login({...}) async {
  try {
    final response = await _httpService.post(...);

    // ❌ What if response.data is null?
    return ParentModel.fromMap(response.data);
  } catch (e, s) {
    Log.custom(Level.error, s.toString());
    if (e is AppException) rethrow;
    throw ServerException(e.toString());
  }
}
```

**Fix:**
```dart
// ✅ CORRECT: Validate response before using
@override
Future<ParentModel> login({...}) async {
  try {
    final response = await _httpService.post(...);

    // ✅ Check for HTTP errors
    if (response.hasError && response.error != null) {
      throw response.error!;
    }

    // ✅ Validate data exists
    if (response.data == null) {
      throw const ServerException('No data received');
    }

    return ParentModel.fromMap(response.data);
  } catch (e, s) {
    Log.custom(Level.error, s.toString());
    if (e is AppException) rethrow;
    throw ServerException(e.toString());
  }
}
```

## Data Source Naming Convention

```
Interface: {Feature}{Type}DataSource
Implementation: {Feature}{Type}DataSourceImpl

AuthRemoteDataSource → AuthRemoteDataSourceImpl
AuthLocalDataSource → AuthLocalDataSourceImpl
OrderRemoteDataSource → OrderRemoteDataSourceImpl
ProductRemoteDataSource → ProductRemoteDataSourceImpl
```

## Data Source Checklist

Before marking data source code as complete:

- [ ] Interface uses `abstract interface class`
- [ ] All methods have try-catch blocks
- [ ] Stack trace parameter `s` in catch blocks
- [ ] `Log.custom(Level.error, s.toString())` called
- [ ] Known exceptions (AppException) are rethrown
- [ ] Unknown exceptions are wrapped appropriately
- [ ] Response validation before use
- [ ] Returns Model types (never Entity)
- [ ] Appropriate exception types thrown:
  - Remote: ServerException, NetworkException, AuthException
  - Local: CacheException
- [ ] Clear, descriptive error messages

## Exception Types by Data Source

### Remote Data Source
```dart
throw ServerException('...');      // API/server errors
throw NetworkException('...');     // Connection errors
throw AuthException('...');        // Authentication errors
throw ValidationException('...');  // Validation errors
```

### Local Data Source
```dart
throw CacheException('...');       // Storage/cache errors
```

## Response Validation Examples

### JSON Response

```dart
// ✅ Proper validation
final response = await _httpService.post(...);

if (response.hasError && response.error != null) {
  throw response.error!;
}

if (response.data == null) {
  throw const ServerException('No data received');
}

// Additional validation
if (response.data is! Map<String, dynamic>) {
  throw const ServerException('Invalid response format');
}

return ParentModel.fromMap(response.data as Map<String, dynamic>);
```

### List Response

```dart
// ✅ Proper validation for list endpoints
final response = await _httpService.get(...);

if (response.hasError && response.error != null) {
  throw response.error!;
}

if (response.data == null) {
  throw const ServerException('No data received');
}

if (response.data is! List) {
  throw const ServerException('Expected list response');
}

return (response.data as List)
    .map((item) => OrderModel.fromMap(item as Map<String, dynamic>))
    .toList();
```

## Async Operations

All data source methods should be async:

```dart
// ✅ CORRECT
Future<ParentModel> login({...}) async {
  // async operation
}

// ❌ WRONG: Synchronous data source
ParentModel login({...}) {
  // Not async
}
```

## Related Guidelines

- [02_model_rules.md](02_model_rules.md) - What data sources return
- [03_repository_pattern.md](03_repository_pattern.md) - How repositories use data sources
- [09_error_handling.md](09_error_handling.md) - Exception hierarchy

## Summary

**Data Source Pattern Requirements:**

1. ✅ Try-catch with stack trace: `catch (e, s)`
2. ✅ Log stack trace: `Log.custom(Level.error, s.toString())`
3. ✅ Rethrow known exceptions: `if (e is AppException) rethrow;`
4. ✅ Wrap unknown exceptions: `throw ServerException(...)`
5. ✅ Validate responses before use
6. ✅ Return Model types
7. ✅ Use appropriate exception types
8. ✅ All methods async

**This pattern is mandatory for all data sources. No exceptions.**
