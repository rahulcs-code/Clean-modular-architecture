# Repository Pattern - Interface vs Implementation

**Interface Location:** `lib/features/{feature}/domain/repositories/`
**Implementation Location:** `lib/features/{feature}/data/repositories/`
**Purpose:** Abstract data operations and define domain/data layer boundary

## ⚠️ CRITICAL: Return Type Rules

This is the **MOST CONFUSING** pattern for AI agents. Read carefully.

### The Golden Rule

```
Repository Interface (Domain)  → Returns Entity
Repository Implementation (Data) → Returns Model (which extends Entity)
```

**Why this works:** Since `Model extends Entity`, returning a Model where an Entity is expected is valid through polymorphism.

## Repository Pattern Overview

```
Domain Layer                     Data Layer
┌─────────────────────┐         ┌──────────────────────────┐
│ Repository          │         │ RepositoryImpl           │
│ Interface           │◄────────│ Implementation           │
│                     │         │                          │
│ Returns: Entity     │         │ Returns: Model           │
│                     │         │         ↓                │
│                     │         │    (extends Entity)      │
└─────────────────────┘         └──────────────────────────┘
         ↑                                   ↑
         │                                   │
   Use Cases                          Data Sources
   (Domain)                           (Models only)
```

## ✅ CORRECT Repository Pattern

### Step 1: Define Entity (Domain)

```dart
// lib/features/auth/domain/entities/parent.dart
class Parent {
  final String id;
  final String name;
  final String email;
  final String? token;
  final bool isVerified;

  const Parent({
    required this.id,
    required this.name,
    required this.email,
    this.token,
    required this.isVerified,
  });
}
```

### Step 2: Create Model (Data)

```dart
// lib/features/auth/data/models/parent_model.dart
import 'package:your_app/features/auth/domain/entities/parent.dart';

class ParentModel extends Parent {
  const ParentModel({
    required super.id,
    required super.name,
    required super.email,
    super.token,
    required super.isVerified,
  });

  factory ParentModel.fromMap(Map<String, dynamic> map) {
    return ParentModel(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      token: map['token'] as String?,
      isVerified: map['is_verified'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'token': token,
      'is_verified': isVerified,
    };
  }
}
```

### Step 3: Define Repository Interface (Domain)

```dart
// lib/features/auth/domain/repositories/auth_repository.dart

/// ✅ CORRECT: Interface returns Entity types
abstract interface class AuthRepository {
  /// Authenticate parent with email and password
  ///
  /// Returns authenticated [Parent] entity with tokens on success.
  /// Returns [AuthFailure] on invalid credentials or [NetworkFailure] on network issues.
  Future<Either<Failure, Parent>> login({
    required String email,
    required String password,
  });

  /// Get cached parent from local storage
  ///
  /// Returns [Parent] if cached, [CacheFailure] if not found.
  Future<Either<Failure, Parent>> getCachedParent();

  /// Logout current parent
  ///
  /// Clears all cached data and returns success or [CacheFailure].
  Future<Either<Failure, void>> logout();

  /// Register new parent account
  ///
  /// Returns newly created [Parent] on success.
  Future<Either<Failure, Parent>> register({
    required String name,
    required String email,
    required String password,
  });
}
```

**Key Points:**
- Uses `abstract interface class` (Dart 3+)
- Returns `Future<Either<Failure, Parent>>` (Entity type)
- Documents what entity is returned
- Documents what failures can occur
- No implementation details

### Step 4: Implement Repository (Data)

```dart
// lib/features/auth/data/repositories/auth_repository_impl.dart

import 'package:fpdart/fpdart.dart';
import 'package:your_app/core/errors/failures.dart';
import 'package:your_app/core/errors/exceptions.dart';
import 'package:your_app/core/utils/log.dart';
import 'package:your_app/features/auth/domain/entities/parent.dart';
import 'package:your_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:your_app/features/auth/data/models/parent_model.dart';
import 'package:your_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:your_app/features/auth/data/datasources/auth_local_data_source.dart';

/// ✅ CORRECT: Implementation returns Model types
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  const AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  /// ✅ CORRECT: Returns ParentModel (which extends Parent)
  @override
  Future<Either<Failure, ParentModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      // Data source returns ParentModel
      final parentModel = await _remoteDataSource.login(
        email: email,
        password: password,
      );

      // Cache the model
      await _localDataSource.cacheParent(parentModel);

      Log.info('Login successful for: $email');

      // Return model (satisfies Parent return type due to inheritance)
      return right(parentModel);
    } on AuthException catch (e) {
      Log.warning('Auth error during login: ${e.message}');
      return left(AuthFailure(e.message));
    } on ValidationException catch (e) {
      Log.warning('Validation error during login: ${e.message}');
      return left(ValidationFailure(e.message, e.errors));
    } on NetworkException catch (e) {
      Log.warning('Network error during login: ${e.message}');
      return left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      Log.warning('Server error during login: ${e.message}');
      return left(ServerFailure(e.message));
    } on CacheException catch (e) {
      Log.error('Cache error during login', e, StackTrace.current);
      return left(CacheFailure(e.message));
    } catch (e, s) {
      Log.error('Unexpected error during login', e, s);
      return left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, ParentModel>> getCachedParent() async {
    try {
      final parentModel = await _localDataSource.getParent();

      if (parentModel == null) {
        return left(CacheFailure('No cached parent found'));
      }

      return right(parentModel);
    } on CacheException catch (e) {
      Log.warning('Cache error: ${e.message}');
      return left(CacheFailure(e.message));
    } catch (e, s) {
      Log.error('Unexpected error getting cached parent', e, s);
      return left(CacheFailure('Failed to retrieve cached parent'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _localDataSource.clearParent();
      Log.info('Logout successful');
      return right(null);
    } on CacheException catch (e) {
      Log.error('Cache error during logout', e, StackTrace.current);
      return left(CacheFailure(e.message));
    } catch (e, s) {
      Log.error('Unexpected error during logout', e, s);
      return left(CacheFailure('Failed to logout'));
    }
  }

  @override
  Future<Either<Failure, ParentModel>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final parentModel = await _remoteDataSource.register(
        name: name,
        email: email,
        password: password,
      );

      await _localDataSource.cacheParent(parentModel);

      Log.info('Registration successful for: $email');

      return right(parentModel);
    } on AuthException catch (e) {
      Log.warning('Auth error during registration: ${e.message}');
      return left(AuthFailure(e.message));
    } on ValidationException catch (e) {
      Log.warning('Validation error during registration: ${e.message}');
      return left(ValidationFailure(e.message, e.errors));
    } on NetworkException catch (e) {
      Log.warning('Network error during registration: ${e.message}');
      return left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      Log.warning('Server error during registration: ${e.message}');
      return left(ServerFailure(e.message));
    } catch (e, s) {
      Log.error('Unexpected error during registration', e, s);
      return left(ServerFailure('An unexpected error occurred'));
    }
  }
}
```

**Key Points:**
- Implements the repository interface
- Returns `ParentModel` (not `Parent`)
- ParentModel satisfies Parent return type through inheritance
- Handles exceptions and converts to failures
- Uses comprehensive logging
- Coordinates between remote and local data sources

## Why This Pattern Works

### Type Hierarchy

```
Parent (Entity)
    ↑
    │ extends
    │
ParentModel (Model)
```

Since `ParentModel extends Parent`, Dart's type system allows:

```dart
// Interface expects Parent
Future<Either<Failure, Parent>> login();

// Implementation returns ParentModel
Future<Either<Failure, ParentModel>> login() {
  final parentModel = ParentModel(...);
  return right(parentModel);  // ✅ Valid: ParentModel is a Parent
}
```

### Liskov Substitution Principle

The implementation satisfies the interface contract because:
- ParentModel can be used anywhere Parent is expected
- All Parent properties are available in ParentModel
- Domain layer receives what it expects (Parent)
- Data layer works with what it needs (ParentModel)

## ❌ Common Mistakes

### Mistake 1: Interface Returns Model

```dart
// ❌ WRONG: Domain layer should not know about models
abstract interface class AuthRepository {
  Future<Either<Failure, ParentModel>> login({  // ❌ Model in domain
    required String email,
    required String password,
  });
}
```

**Why wrong:** The domain layer should not depend on the data layer. Models are data layer concepts.

**Fix:**
```dart
// ✅ CORRECT: Domain layer uses entities
abstract interface class AuthRepository {
  Future<Either<Failure, Parent>> login({  // ✅ Entity
    required String email,
    required String password,
  });
}
```

### Mistake 2: Implementation Returns Entity

```dart
// ❌ WRONG: Trying to return entity when working with models
class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<Either<Failure, Parent>> login({
    required String email,
    required String password,
  }) async {
    final parentModel = await _remoteDataSource.login(...);

    // ❌ Trying to convert model to entity (unnecessary)
    final parent = Parent(
      id: parentModel.id,
      name: parentModel.name,
      email: parentModel.email,
      token: parentModel.token,
      isVerified: parentModel.isVerified,
    );

    return right(parent);
  }
}
```

**Why wrong:** Unnecessary conversion. ParentModel IS a Parent (through inheritance).

**Fix:**
```dart
// ✅ CORRECT: Return model directly
class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<Either<Failure, ParentModel>> login({  // Returns Model
    required String email,
    required String password,
  }) async {
    final parentModel = await _remoteDataSource.login(...);
    return right(parentModel);  // ✅ Model satisfies Entity return type
  }
}
```

### Mistake 3: Not Handling All Exceptions

```dart
// ❌ WRONG: Incomplete exception handling
class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<Either<Failure, ParentModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final parentModel = await _remoteDataSource.login(...);
      return right(parentModel);
    } catch (e) {  // ❌ Catching all exceptions generically
      return left(Failure('Error occurred'));
    }
  }
}
```

**Why wrong:** Different exceptions should be handled differently to provide specific feedback.

**Fix:**
```dart
// ✅ CORRECT: Handle each exception type specifically
class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<Either<Failure, ParentModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final parentModel = await _remoteDataSource.login(...);
      return right(parentModel);
    } on AuthException catch (e) {
      return left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return left(ServerFailure(e.message));
    } catch (e, s) {
      Log.error('Unexpected error', e, s);
      return left(ServerFailure('An unexpected error occurred'));
    }
  }
}
```

## Repository Responsibilities

### 1. Coordinate Data Sources

```dart
class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<Either<Failure, ParentModel>> login({...}) async {
    // 1. Fetch from remote
    final parentModel = await _remoteDataSource.login(...);

    // 2. Cache locally
    await _localDataSource.cacheParent(parentModel);

    // 3. Return result
    return right(parentModel);
  }

  @override
  Future<Either<Failure, ParentModel>> getCachedParent() async {
    // Try local first
    final cached = await _localDataSource.getParent();

    if (cached != null) {
      return right(cached);
    }

    // Fallback to remote if needed
    return left(CacheFailure('No cached data'));
  }
}
```

### 2. Exception to Failure Conversion

```dart
// Data sources throw exceptions
throw AuthException('Invalid credentials');

// Repository catches and converts to failures
try {
  final model = await _remoteDataSource.login(...);
  return right(model);
} on AuthException catch (e) {
  return left(AuthFailure(e.message));  // Converts to Failure
}
```

### 3. Business Logic Coordination

```dart
class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<Either<Failure, ParentModel>> login({...}) async {
    try {
      // 1. Authenticate
      final parentModel = await _remoteDataSource.login(...);

      // 2. Set auth token for future requests
      if (parentModel.token != null) {
        _httpService.setAuthToken(parentModel.token!);
      }

      // 3. Cache user data
      await _localDataSource.cacheParent(parentModel);

      // 4. Log analytics
      Log.info('Login successful for: ${parentModel.email}');

      return right(parentModel);
    } catch (e) {
      // Handle exceptions...
    }
  }
}
```

## Repository Naming Convention

```
Interface: {Feature}Repository
Implementation: {Feature}RepositoryImpl

AuthRepository → AuthRepositoryImpl
OrderRepository → OrderRepositoryImpl
ProductRepository → ProductRepositoryImpl
```

## Repository Checklist

Before marking repository code as complete:

**Interface (Domain):**
- [ ] Located in `domain/repositories/`
- [ ] Uses `abstract interface class`
- [ ] Returns Entity types
- [ ] Methods return `Future<Either<Failure, Entity>>`
- [ ] Well documented with dartdoc comments
- [ ] No implementation details
- [ ] No data layer dependencies

**Implementation (Data):**
- [ ] Located in `data/repositories/`
- [ ] Implements domain repository interface
- [ ] Returns Model types (matching entities)
- [ ] Injects required data sources
- [ ] Handles all specific exception types
- [ ] Converts exceptions to failures
- [ ] Uses comprehensive logging
- [ ] Coordinates between data sources
- [ ] Returns Either<Failure, Success>

## Type Flow Example

```
1. Use Case calls:
   Future<Either<Failure, Parent>> result = repository.login(...)

2. Repository (interface) declares:
   Future<Either<Failure, Parent>> login(...)

3. Repository (implementation) returns:
   Future<Either<Failure, ParentModel>> login(...) {
     return right(parentModel);  // ParentModel extends Parent
   }

4. Use Case receives:
   Parent parent = result.fold(...)  // Actually a ParentModel

5. BLoC receives:
   AuthSuccess(parent: parent)  // Thinks it's Parent, actually ParentModel

6. This is CORRECT and intentional!
   - Domain layer works with abstractions (Entity)
   - Data layer works with implementations (Model)
   - Type system ensures compatibility
```

## Related Guidelines

- [01_entity_rules.md](01_entity_rules.md) - Entity definition rules
- [02_model_rules.md](02_model_rules.md) - Model extends entity
- [04_use_case_pattern.md](04_use_case_pattern.md) - How use cases call repositories
- [05_data_source_pattern.md](05_data_source_pattern.md) - What repositories coordinate

## Summary

**Repository Pattern Type Rules:**

```
Domain Interface    → Returns Entity
Data Implementation → Returns Model (extends Entity)
Data Sources        → Return Model
Use Cases           → Receive Entity (actually Model)
BLoC                → Uses Entity (actually Model)
```

**This works because Model extends Entity. Trust the type system!**
