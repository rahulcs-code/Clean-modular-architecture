# Use Case Pattern - Single Responsibility Business Operations

**Location:** `lib/features/{feature}/domain/use_cases/` or `usecases/`
**Layer:** Domain
**Purpose:** Encapsulate single business operations

## Core Principle

**One use case = One business operation**

Each use case should do exactly one thing and do it well.

## Base UseCase Interface

```dart
// lib/core/use_case/use_case.dart

import 'package:fpdart/fpdart.dart';
import 'package:your_app/core/errors/failures.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {
  const NoParams();
}
```

## ✅ CORRECT Use Case Implementation

```dart
// lib/features/auth/domain/use_cases/login_with_email.dart

import 'package:fpdart/fpdart.dart';
import 'package:your_app/core/errors/failures.dart';
import 'package:your_app/core/use_case/use_case.dart';
import 'package:your_app/features/auth/domain/entities/parent.dart';
import 'package:your_app/features/auth/domain/repositories/auth_repository.dart';

class LoginWithEmail implements UseCase<Parent, LoginWithEmailParams> {
  final AuthRepository repository;

  const LoginWithEmail(this.repository);

  @override
  Future<Either<Failure, Parent>> call(LoginWithEmailParams params) async {
    return await repository.login(
      email: params.email,
      password: params.password,
    );
  }
}

class LoginWithEmailParams {
  final String email;
  final String password;

  const LoginWithEmailParams({
    required this.email,
    required this.password,
  });
}
```

**Key Points:**
- Implements `UseCase<ReturnType, ParamsType>`
- Single responsibility (login with email)
- Depends on repository interface (not implementation)
- Returns `Either<Failure, Entity>`
- Has corresponding params class

## Use Case with No Parameters

```dart
// lib/features/auth/domain/use_cases/get_cached_parent.dart

import 'package:fpdart/fpdart.dart';
import 'package:your_app/core/errors/failures.dart';
import 'package:your_app/core/use_case/use_case.dart';
import 'package:your_app/features/auth/domain/entities/parent.dart';
import 'package:your_app/features/auth/domain/repositories/auth_repository.dart';

class GetCachedParent implements UseCase<Parent, NoParams> {
  final AuthRepository repository;

  const GetCachedParent(this.repository);

  @override
  Future<Either<Failure, Parent>> call(NoParams params) async {
    return await repository.getCachedParent();
  }
}

// Usage:
final result = await getCachedParent(NoParams());
```

## Use Case with Complex Parameters

```dart
// lib/features/auth/domain/use_cases/register_parent.dart

import 'package:fpdart/fpdart.dart';
import 'package:your_app/core/errors/failures.dart';
import 'package:your_app/core/use_case/use_case.dart';
import 'package:your_app/features/auth/domain/entities/parent.dart';
import 'package:your_app/features/auth/domain/repositories/auth_repository.dart';

class RegisterParent implements UseCase<Parent, RegisterParentParams> {
  final AuthRepository repository;

  const RegisterParent(this.repository);

  @override
  Future<Either<Failure, Parent>> call(RegisterParentParams params) async {
    return await repository.register(
      name: params.name,
      email: params.email,
      password: params.password,
      phoneNumber: params.phoneNumber,
      address: params.address,
    );
  }
}

class RegisterParentParams {
  final String name;
  final String email;
  final String password;
  final String? phoneNumber;
  final String? address;

  const RegisterParentParams({
    required this.name,
    required this.email,
    required this.password,
    this.phoneNumber,
    this.address,
  });
}
```

## Use Case with Business Logic

Sometimes use cases contain business logic before calling repository:

```dart
// lib/features/order/domain/use_cases/place_order.dart

import 'package:fpdart/fpdart.dart';
import 'package:your_app/core/errors/failures.dart';
import 'package:your_app/core/use_case/use_case.dart';
import 'package:your_app/features/order/domain/entities/order.dart';
import 'package:your_app/features/order/domain/repositories/order_repository.dart';

class PlaceOrder implements UseCase<Order, PlaceOrderParams> {
  final OrderRepository repository;

  const PlaceOrder(this.repository);

  @override
  Future<Either<Failure, Order>> call(PlaceOrderParams params) async {
    // ✅ Business logic in use case
    if (params.items.isEmpty) {
      return left(ValidationFailure('Order must contain at least one item'));
    }

    // Calculate total before placing order
    final total = params.items.fold<double>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );

    // Minimum order validation
    if (total < 10.0) {
      return left(ValidationFailure('Minimum order amount is \$10'));
    }

    return await repository.placeOrder(
      items: params.items,
      deliveryAddress: params.deliveryAddress,
      total: total,
    );
  }
}

class PlaceOrderParams {
  final List<OrderItem> items;
  final String deliveryAddress;

  const PlaceOrderParams({
    required this.items,
    required this.deliveryAddress,
  });
}
```

## Use Case with Multiple Repository Calls

```dart
// lib/features/profile/domain/use_cases/update_profile_with_image.dart

import 'package:fpdart/fpdart.dart';
import 'package:your_app/core/errors/failures.dart';
import 'package:your_app/core/use_case/use_case.dart';
import 'package:your_app/features/profile/domain/entities/parent.dart';
import 'package:your_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:your_app/features/storage/domain/repositories/storage_repository.dart';

class UpdateProfileWithImage implements UseCase<Parent, UpdateProfileWithImageParams> {
  final ProfileRepository profileRepository;
  final StorageRepository storageRepository;

  const UpdateProfileWithImage({
    required this.profileRepository,
    required this.storageRepository,
  });

  @override
  Future<Either<Failure, Parent>> call(UpdateProfileWithImageParams params) async {
    // 1. Upload image first if provided
    String? imageUrl;
    if (params.imagePath != null) {
      final uploadResult = await storageRepository.uploadImage(params.imagePath!);

      // Return failure if upload fails
      if (uploadResult.isLeft()) {
        return uploadResult.map((url) => throw Exception());  // Won't be called
      }

      imageUrl = uploadResult.getRight().toNullable();
    }

    // 2. Update profile with image URL
    return await profileRepository.updateProfile(
      name: params.name,
      phoneNumber: params.phoneNumber,
      imageUrl: imageUrl,
    );
  }
}

class UpdateProfileWithImageParams {
  final String name;
  final String? phoneNumber;
  final String? imagePath;

  const UpdateProfileWithImageParams({
    required this.name,
    this.phoneNumber,
    this.imagePath,
  });
}
```

## Use Case Naming Convention

```
{Verb}{Entity}[{Context}]

GetCachedParent
LoginWithEmail
LoginWithPhone
RegisterParent
PlaceOrder
UpdateProfile
DeleteAccount
FetchOrders
SearchProducts
CancelOrder
```

**Pattern:**
- Start with action verb (Get, Login, Register, Place, Update, Delete, Fetch, Search, Cancel)
- Follow with entity being acted upon
- Add context if multiple use cases for same entity

## How Use Cases Are Called

### In BLoC

```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginWithEmail _loginWithEmail;
  final GetCachedParent _getCachedParent;
  final RegisterParent _registerParent;

  AuthBloc({
    required LoginWithEmail loginWithEmail,
    required GetCachedParent getCachedParent,
    required RegisterParent registerParent,
  })  : _loginWithEmail = loginWithEmail,
        _getCachedParent = getCachedParent,
        _registerParent = registerParent,
        super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthCheckCached>(_onCheckCached);
    on<AuthRegisterRequested>(_onRegisterRequested);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    // ✅ Call use case with params
    final result = await _loginWithEmail(
      LoginWithEmailParams(
        email: event.email,
        password: event.password,
      ),
    );

    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (parent) => emit(AuthSuccess(parent)),
    );
  }

  Future<void> _onCheckCached(
    AuthCheckCached event,
    Emitter<AuthState> emit,
  ) async {
    // ✅ Call use case with NoParams
    final result = await _getCachedParent(NoParams());

    result.fold(
      (failure) => emit(AuthInitial()),
      (parent) => emit(AuthSuccess(parent)),
    );
  }
}
```

## ❌ Common Mistakes

### Mistake 1: Multiple Responsibilities

```dart
// ❌ WRONG: Use case doing too many things
class AuthenticateAndSyncData implements UseCase<Parent, LoginParams> {
  final AuthRepository authRepository;
  final SyncRepository syncRepository;

  @override
  Future<Either<Failure, Parent>> call(LoginParams params) async {
    final authResult = await authRepository.login(...);

    if (authResult.isRight()) {
      await syncRepository.syncUserData();  // ❌ Different responsibility
      await syncRepository.syncSettings();   // ❌ Different responsibility
    }

    return authResult;
  }
}
```

**Why wrong:** Use case is doing authentication AND data sync. These are separate operations.

**Fix:**
```dart
// ✅ CORRECT: Separate use cases
class LoginWithEmail implements UseCase<Parent, LoginParams> {
  @override
  Future<Either<Failure, Parent>> call(LoginParams params) async {
    return await repository.login(...);
  }
}

class SyncUserData implements UseCase<void, SyncParams> {
  @override
  Future<Either<Failure, void>> call(SyncParams params) async {
    return await repository.syncUserData();
  }
}

// BLoC coordinates multiple use cases
Future<void> _onLogin(event, emit) async {
  final loginResult = await _loginUseCase(params);

  if (loginResult.isRight()) {
    await _syncUserDataUseCase(SyncParams());  // Separate call
  }
}
```

### Mistake 2: Direct Data Source Access

```dart
// ❌ WRONG: Use case calling data source directly
class LoginWithEmail implements UseCase<Parent, LoginParams> {
  final AuthRemoteDataSource dataSource;  // ❌ Should be repository

  @override
  Future<Either<Failure, Parent>> call(LoginParams params) async {
    try {
      final parent = await dataSource.login(...);  // ❌ Direct data source access
      return right(parent);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
```

**Why wrong:** Use cases should depend on repository interfaces, not data sources. Repositories handle data source coordination and exception handling.

**Fix:**
```dart
// ✅ CORRECT: Use case depends on repository
class LoginWithEmail implements UseCase<Parent, LoginParams> {
  final AuthRepository repository;  // ✅ Repository interface

  @override
  Future<Either<Failure, Parent>> call(LoginParams params) async {
    return await repository.login(...);  // ✅ Repository handles details
  }
}
```

### Mistake 3: No Params Class

```dart
// ❌ WRONG: Using Map or multiple parameters
class LoginWithEmail implements UseCase<Parent, Map<String, String>> {
  @override
  Future<Either<Failure, Parent>> call(Map<String, String> params) async {
    return await repository.login(
      email: params['email']!,  // ❌ Unsafe
      password: params['password']!,  // ❌ Unsafe
    );
  }
}
```

**Why wrong:** Type safety is lost, no IDE support, prone to errors.

**Fix:**
```dart
// ✅ CORRECT: Dedicated params class
class LoginWithEmailParams {
  final String email;
  final String password;

  const LoginWithEmailParams({
    required this.email,
    required this.password,
  });
}

class LoginWithEmail implements UseCase<Parent, LoginWithEmailParams> {
  @override
  Future<Either<Failure, Parent>> call(LoginWithEmailParams params) async {
    return await repository.login(
      email: params.email,  // ✅ Type-safe
      password: params.password,  // ✅ Type-safe
    );
  }
}
```

## Use Case Checklist

- [ ] Implements `UseCase<ReturnType, ParamsType>`
- [ ] Single responsibility (one business operation)
- [ ] Depends on repository interface (not implementation)
- [ ] Returns `Future<Either<Failure, Entity>>`
- [ ] Has params class (or uses NoParams)
- [ ] Params class has const constructor
- [ ] Named with verb + entity pattern
- [ ] Located in `domain/use_cases/`
- [ ] No direct data source dependencies
- [ ] Contains business logic only (if any)

## When to Create a Use Case

Create a use case for:
- Every repository method called by BLoC
- Operations with business logic/validation
- Operations coordinating multiple repositories
- Any distinct business operation

Don't create use cases for:
- Simple property access
- UI-only operations
- Widget-specific logic

## Use Case File Organization

```
lib/features/auth/domain/use_cases/
├── login_with_email.dart
├── login_with_phone.dart
├── register_parent.dart
├── get_cached_parent.dart
├── logout.dart
├── reset_password.dart
└── verify_email.dart

Each file contains:
- Use case class
- Params class (if needed)
```

## Related Guidelines

- [03_repository_pattern.md](03_repository_pattern.md) - What use cases depend on
- [06_bloc_cubit_pattern.md](06_bloc_cubit_pattern.md) - How BLoCs call use cases
- [09_error_handling.md](09_error_handling.md) - Either type and failure handling

## Summary

**Use Cases:**
- Encapsulate single business operations
- Depend on repository interfaces
- Return Either<Failure, Entity>
- Have typed params classes
- Are called by BLoCs
- Contain business logic when needed
- Follow single responsibility principle
