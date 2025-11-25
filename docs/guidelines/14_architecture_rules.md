# Architecture Rules - Clean Architecture Principles

**Purpose:** Enforce Clean Architecture boundaries and SOLID principles
**Pattern:** Maintain clear separation of concerns across layers

## Layer Hierarchy

```
┌─────────────────────────────────────┐
│       Presentation Layer            │  ← UI, BLoCs, Pages, Widgets
│  (features/{feature}/presentation)  │
└─────────────────────────────────────┘
              ↓ depends on
┌─────────────────────────────────────┐
│         Domain Layer                │  ← Business Logic, Entities, Use Cases
│   (features/{feature}/domain)       │  ← Repository Interfaces
└─────────────────────────────────────┘
              ↑ implements
┌─────────────────────────────────────┐
│          Data Layer                 │  ← Models, Data Sources, API calls
│    (features/{feature}/data)        │  ← Repository Implementations
└─────────────────────────────────────┘
```

## Critical Architectural Rules

### Rule 1: Dependency Direction

**Dependencies must always point inward (toward domain).**

```
✅ CORRECT Flow:
Presentation → Domain ← Data
    ↓           ↑        ↓
  BLoC     Repository  API
           Interface

❌ WRONG:
Domain → Data (Domain imports from Data)
Domain → Presentation (Domain imports from Presentation)
```

### Rule 2: Domain Independence

**Domain layer MUST NOT depend on any other layer.**

```dart
✅ CORRECT:
// domain/entities/parent.dart
class Parent {
  final String id;
  final String name;
  // NO imports from data or presentation
}

// domain/repositories/auth_repository.dart
import 'package:your_app/features/auth/domain/entities/parent.dart';  // ✅ Same layer

❌ WRONG:
// domain/repositories/auth_repository.dart
import 'package:your_app/features/auth/data/models/parent_model.dart';  // ❌ Depends on data layer
import 'package:your_app/features/auth/presentation/bloc/auth_bloc.dart';  // ❌ Depends on presentation
```

### Rule 3: Interface-Based Dependencies

**Depend on abstractions, not concretions.**

```dart
✅ CORRECT:
// BLoC depends on abstract repository
class AuthBloc {
  final AuthRepository _repository;  // ✅ Interface

  AuthBloc({required AuthRepository repository}) : _repository = repository;
}

❌ WRONG:
// BLoC depends on concrete implementation
class AuthBloc {
  final AuthRepositoryImpl _repository;  // ❌ Concrete class

  AuthBloc({required AuthRepositoryImpl repository}) : _repository = repository;
}
```

### Rule 4: Entity vs Model Separation

**Entities in domain, Models in data.**

```dart
✅ CORRECT:
// domain/entities/parent.dart
class Parent {
  final String id;
  final String name;
  // Pure data only
}

// data/models/parent_model.dart
class ParentModel extends Parent {
  const ParentModel({required super.id, required super.name});

  // Serialization logic
  factory ParentModel.fromMap(Map<String, dynamic> map) {...}
  Map<String, dynamic> toMap() {...}
}

❌ WRONG:
// domain/entities/parent.dart
class Parent {
  final String id;

  factory Parent.fromMap(Map<String, dynamic> map) {...}  // ❌ Serialization in entity
}
```

## SOLID Principles in Clean Architecture

### Single Responsibility Principle (SRP)

**Each class should have one reason to change.**

```dart
✅ CORRECT:
// Each use case handles ONE operation
class LoginWithEmail {
  Future<Either<Failure, Parent>> call(LoginWithEmailParams params) async {
    return await repository.login(email: params.email, password: params.password);
  }
}

class RegisterParent {
  Future<Either<Failure, Parent>> call(RegisterParentParams params) async {
    return await repository.register(name: params.name, email: params.email, password: params.password);
  }
}

❌ WRONG:
// One use case handling multiple operations
class AuthUseCase {
  Future<Either<Failure, Parent>> login(...) async {...}
  Future<Either<Failure, Parent>> register(...) async {...}
  Future<Either<Failure, void>> logout() async {...}
  Future<Either<Failure, Parent>> resetPassword(...) async {...}
  // Too many responsibilities!
}
```

### Open/Closed Principle (OCP)

**Open for extension, closed for modification.**

```dart
✅ CORRECT:
// Base failure class - closed for modification
abstract class Failure {
  final String message;
  const Failure([this.message = 'An error occurred']);
}

// Extend with new failure types - open for extension
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error']);
}

class CustomFailure extends Failure {
  const CustomFailure([super.message]);
}

// No need to modify base class when adding new failures
```

### Liskov Substitution Principle (LSP)

**Derived classes must be substitutable for their base classes.**

```dart
✅ CORRECT:
// ParentModel can be used anywhere Parent is expected
abstract interface class AuthRepository {
  Future<Either<Failure, Parent>> login({...});  // Returns Parent
}

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<Either<Failure, ParentModel>> login({...}) async {
    final parentModel = await _remoteDataSource.login(...);
    return right(parentModel);  // ParentModel is substitutable for Parent
  }
}

// Usage
final Either<Failure, Parent> result = await repository.login(...);
// Works because ParentModel extends Parent
```

### Interface Segregation Principle (ISP)

**Clients should not depend on interfaces they don't use.**

```dart
✅ CORRECT:
// Separate interfaces for different responsibilities
abstract interface class AuthRemoteDataSource {
  Future<ParentModel> login({required String email, required String password});
  Future<ParentModel> register({required String name, required String email, required String password});
}

abstract interface class AuthLocalDataSource {
  Future<ParentModel> getCachedParent();
  Future<void> cacheParent(ParentModel parent);
  Future<void> clearCache();
}

❌ WRONG:
// One interface with all methods (some clients don't need all)
abstract interface class AuthDataSource {
  Future<ParentModel> login({...});
  Future<ParentModel> register({...});
  Future<ParentModel> getCachedParent();
  Future<void> cacheParent(ParentModel parent);
  Future<void> clearCache();
  // Remote data source doesn't need cache methods
  // Local data source doesn't need API methods
}
```

### Dependency Inversion Principle (DIP)

**Depend on abstractions, not concretions.**

```dart
✅ CORRECT:
// High-level module (BLoC) depends on abstraction (Repository interface)
class AuthBloc {
  final AuthRepository _repository;  // ✅ Abstraction

  AuthBloc({required AuthRepository repository}) : _repository = repository;
}

// Low-level module (Implementation) implements abstraction
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;  // ✅ Also abstraction
  final AuthLocalDataSource _localDataSource;    // ✅ Also abstraction

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;
}

❌ WRONG:
// High-level module depends on concrete implementation
class AuthBloc {
  final AuthRepositoryImpl _repository;  // ❌ Concrete class
  final HttpService _httpService;        // ❌ Direct dependency on low-level module

  AuthBloc({required AuthRepositoryImpl repository, required HttpService httpService});
}
```

## Layer-Specific Rules

### Presentation Layer Rules

1. **Depend only on Domain**
```dart
✅ CORRECT:
import 'package:your_app/features/auth/domain/entities/parent.dart';
import 'package:your_app/features/auth/domain/usecases/login_with_email.dart';

❌ WRONG:
import 'package:your_app/features/auth/data/models/parent_model.dart';
import 'package:your_app/features/auth/data/repositories/auth_repository_impl.dart';
```

2. **BLoCs handle operations, Cubits handle state**
```dart
✅ CORRECT:
// Feature BLoC - operations
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginWithEmail _loginUseCase;
  final AuthCubit _authCubit;  // Updates global state
}

// Global Cubit - state tracking
class AuthCubit extends Cubit<AuthState> {
  void login(Parent parent) => emit(AuthLoggedIn(parent));
}

❌ WRONG:
// Cubit handling operations
class AuthCubit extends Cubit<AuthState> {
  final LoginWithEmail _loginUseCase;

  Future<void> login(String email, String password) async {
    // Complex business logic in cubit
  }
}
```

3. **Pages should be dumb**
```dart
✅ CORRECT:
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          Navigator.pushNamed(context, '/home');
        }
      },
      builder: (context, state) => const LoginForm(),
    );
  }
}

❌ WRONG:
class LoginPage extends StatelessWidget {
  Future<void> _performLogin() async {
    // Business logic in page
    final result = await http.post(...);
    // Direct API calls
  }
}
```

### Domain Layer Rules

1. **No external dependencies**
```dart
✅ CORRECT:
// domain/entities/parent.dart
class Parent {
  final String id;
  final String name;
  // Only Dart core types
}

❌ WRONG:
// domain/entities/parent.dart
import 'package:http/http.dart';  // ❌ External package
import 'package:flutter/material.dart';  // ❌ Framework dependency

class Parent {
  final String id;
  Color get statusColor => ...;  // ❌ UI logic in domain
}
```

2. **Business logic only**
```dart
✅ CORRECT:
// domain/usecases/login_with_email.dart
class LoginWithEmail {
  final AuthRepository repository;

  Future<Either<Failure, Parent>> call(LoginWithEmailParams params) async {
    // Pure business logic
    return await repository.login(email: params.email, password: params.password);
  }
}

❌ WRONG:
// domain/usecases/login_with_email.dart
class LoginWithEmail {
  Future<Either<Failure, Parent>> call(LoginWithEmailParams params) async {
    final response = await http.post(...);  // ❌ Direct API call
    final jsonData = json.decode(response.body);  // ❌ Serialization logic
  }
}
```

3. **Define contracts, not implementations**
```dart
✅ CORRECT:
// domain/repositories/auth_repository.dart
abstract interface class AuthRepository {
  Future<Either<Failure, Parent>> login({required String email, required String password});
  // Just contract definition
}

❌ WRONG:
// domain/repositories/auth_repository.dart
class AuthRepository {
  Future<Either<Failure, Parent>> login({required String email, required String password}) async {
    // Implementation in domain
    final response = await http.post(...);
  }
}
```

### Data Layer Rules

1. **Implement domain interfaces**
```dart
✅ CORRECT:
// data/repositories/auth_repository_impl.dart
class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<Either<Failure, ParentModel>> login({...}) async {
    // Implementation
  }
}

❌ WRONG:
// data/repositories/auth_repository_impl.dart
class AuthRepositoryImpl {  // ❌ Doesn't implement interface
  Future<Either<Failure, ParentModel>> login({...}) async {
    // Implementation
  }
}
```

2. **Models extend entities**
```dart
✅ CORRECT:
class ParentModel extends Parent {
  const ParentModel({required super.id, required super.name});

  factory ParentModel.fromMap(Map<String, dynamic> map) {...}
}

❌ WRONG:
class ParentModel {  // ❌ Doesn't extend entity
  final String id;
  final String name;

  factory ParentModel.fromMap(Map<String, dynamic> map) {...}
}
```

3. **Data sources throw exceptions**
```dart
✅ CORRECT:
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<ParentModel> login({...}) async {
    try {
      final response = await _httpService.post(...);
      return ParentModel.fromMap(response.data);
    } catch (e) {
      throw ServerException('Login failed');  // ✅ Throws exception
    }
  }
}

❌ WRONG:
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<Either<Failure, ParentModel>> login({...}) async {  // ❌ Returns Either
    // Either belongs in repository, not data source
  }
}
```

## Testing Architecture

### Unit Tests

**Test each layer independently:**

```dart
// Domain layer test
void main() {
  group('LoginWithEmail', () {
    test('should return Parent when login succeeds', () async {
      // Arrange
      final mockRepository = MockAuthRepository();
      final useCase = LoginWithEmail(mockRepository);

      // Act
      final result = await useCase(LoginWithEmailParams(email: 'test@test.com', password: 'password'));

      // Assert
      expect(result.isRight(), true);
    });
  });
}

// Data layer test
void main() {
  group('AuthRepositoryImpl', () {
    test('should return ParentModel when remote call succeeds', () async {
      // Arrange
      final mockRemoteDataSource = MockAuthRemoteDataSource();
      final repository = AuthRepositoryImpl(remoteDataSource: mockRemoteDataSource);

      // Act
      final result = await repository.login(email: 'test@test.com', password: 'password');

      // Assert
      expect(result.isRight(), true);
    });
  });
}
```

## Architectural Violations to Avoid

### ❌ Violation 1: Domain Depends on Data

```dart
❌ WRONG:
// domain/usecases/login_with_email.dart
import 'package:your_app/features/auth/data/models/parent_model.dart';

class LoginWithEmail {
  Future<Either<Failure, ParentModel>> call(...) async {
    // Using Model in domain
  }
}
```

**Fix:** Use Entity

```dart
✅ CORRECT:
// domain/usecases/login_with_email.dart
import 'package:your_app/features/auth/domain/entities/parent.dart';

class LoginWithEmail {
  Future<Either<Failure, Parent>> call(...) async {
    // Using Entity in domain
  }
}
```

### ❌ Violation 2: Presentation Bypasses Domain

```dart
❌ WRONG:
class AuthBloc {
  final AuthRepositoryImpl _repository;  // Concrete implementation

  Future<void> _onLoginRequested() async {
    final response = await http.post(...);  // Direct API call
  }
}
```

**Fix:** Use abstractions through domain

```dart
✅ CORRECT:
class AuthBloc {
  final LoginWithEmail _loginUseCase;  // Use case from domain

  Future<void> _onLoginRequested() async {
    final result = await _loginUseCase(params);
  }
}
```

### ❌ Violation 3: God Objects

```dart
❌ WRONG:
class AuthService {
  Future<void> login() {}
  Future<void> register() {}
  Future<void> logout() {}
  Future<void> resetPassword() {}
  Future<void> updateProfile() {}
  Future<void> deleteAccount() {}
  // Too many responsibilities
}
```

**Fix:** Separate into focused classes

```dart
✅ CORRECT:
class LoginWithEmail { /* ... */ }
class RegisterParent { /* ... */ }
class Logout { /* ... */ }
class ResetPassword { /* ... */ }
class UpdateProfile { /* ... */ }
class DeleteAccount { /* ... */ }
```

## Architecture Decision Records (ADR)

### Document major architectural decisions:

```markdown
# ADR 001: Use BLoC for State Management

## Context
Need consistent state management across app

## Decision
Use BLoC pattern with flutter_bloc package

## Consequences
- Predictable state management
- Easy testing
- Separation of business logic from UI
- Learning curve for new developers

## Alternatives Considered
- Provider
- Riverpod
- GetX
```

## Checklist

- [ ] Dependencies point inward (toward domain)
- [ ] Domain layer has no external dependencies
- [ ] All dependencies use interfaces, not concrete classes
- [ ] Entities in domain, Models in data
- [ ] Repository interfaces in domain, implementations in data
- [ ] Use cases have single responsibility
- [ ] BLoCs depend on use cases, not repositories directly
- [ ] Data sources throw exceptions
- [ ] Repositories return Either<Failure, Success>
- [ ] No circular dependencies
- [ ] Each class follows SOLID principles
- [ ] Tests exist for each layer
- [ ] No god objects or classes
- [ ] Clear separation of concerns

## Related Guidelines

- [01_entity_rules.md](01_entity_rules.md) - Entity separation
- [02_model_rules.md](02_model_rules.md) - Model responsibilities
- [03_repository_pattern.md](03_repository_pattern.md) - Repository boundaries
- [06_bloc_cubit_pattern.md](06_bloc_cubit_pattern.md) - State management architecture

## Summary

**Layer Hierarchy:**
```
Presentation → Domain ← Data
(depends on)    ↑    (implements)
```

**Dependency Rules:**
1. Dependencies point inward
2. Domain is independent
3. Use abstractions (interfaces)
4. Entities in domain, Models in data

**SOLID Principles:**
- **S**ingle Responsibility: One class, one purpose
- **O**pen/Closed: Open for extension, closed for modification
- **L**iskov Substitution: Models substitute entities
- **I**nterface Segregation: Focused interfaces
- **D**ependency Inversion: Depend on abstractions

**Key Violations to Avoid:**
- Domain depending on data or presentation
- Bypassing domain layer
- God objects with too many responsibilities
- Concrete dependencies instead of abstractions
