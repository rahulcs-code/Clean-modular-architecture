# Common Mistakes by AI Agents

This document contains real violations by AI coding agents and their fixes.

## Table of Contents

1. [Entity with Logic Violations](#1-entity-with-logic-violations)
2. [Repository Return Type Confusion](#2-repository-return-type-confusion)
3. [Feature BLoC vs Global Cubit Confusion](#3-feature-bloc-vs-global-cubit-confusion)
4. [Dependency Injection Registration Errors](#4-dependency-injection-registration-errors)
5. [MultiBlocProvider Misplacement](#5-multiblocprovider-misplacement)

---

## 1. Entity with Logic Violations

### Mistake: Adding copyWith to Entity

```dart
// ❌ WRONG: copyWith in entity
class Parent {
  final String id;
  final String name;
  final String email;

  const Parent({
    required this.id,
    required this.name,
    required this.email,
  });

  // ❌ VIOLATION: copyWith belongs in Model
  Parent copyWith({
    String? id,
    String? name,
    String? email,
  }) {
    return Parent(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }
}
```

**Fix:**
```dart
// ✅ CORRECT: Pure entity
class Parent {
  final String id;
  final String name;
  final String email;

  const Parent({
    required this.id,
    required this.name,
    required this.email,
  });
}

// ✅ copyWith in Model
class ParentModel extends Parent {
  const ParentModel({
    required super.id,
    required super.name,
    required super.email,
  });

  ParentModel copyWith({
    String? id,
    String? name,
    String? email,
  }) {
    return ParentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }
}
```

### Mistake: Static Constants in Entity

```dart
// ❌ WRONG: Static constants in entity
class Parent {
  final String id;
  final String name;
  final String email;

  // ❌ VIOLATION: Static constants belong in Model
  static const Parent empty = Parent(
    id: '',
    name: '',
    email: '',
  );

  const Parent({
    required this.id,
    required this.name,
    required this.email,
  });
}
```

**Fix:**
```dart
// ✅ CORRECT: Pure entity, no static constants
class Parent {
  final String id;
  final String name;
  final String email;

  const Parent({
    required this.id,
    required this.name,
    required this.email,
  });
}

// ✅ Static constants in Model
class ParentModel extends Parent {
  const ParentModel({
    required super.id,
    required super.name,
    required super.email,
  });

  static const ParentModel empty = ParentModel(
    id: '',
    name: '',
    email: '',
  );
}
```

### Mistake: Serialization in Entity

```dart
// ❌ WRONG: Serialization in entity
class Parent {
  final String id;
  final String name;
  final String email;

  const Parent({
    required this.id,
    required this.name,
    required this.email,
  });

  // ❌ VIOLATION: Serialization belongs in Model
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }

  factory Parent.fromJson(Map<String, dynamic> json) {
    return Parent(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
}
```

**Fix:**
```dart
// ✅ CORRECT: Pure entity
class Parent {
  final String id;
  final String name;
  final String email;

  const Parent({
    required this.id,
    required this.name,
    required this.email,
  });
}

// ✅ Serialization in Model
class ParentModel extends Parent {
  const ParentModel({
    required super.id,
    required super.name,
    required super.email,
  });

  factory ParentModel.fromMap(Map<String, dynamic> map) {
    return ParentModel(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}
```

---

## 2. Repository Return Type Confusion

### THE CORRECT PATTERN (User's Example)

This is the EXACT pattern that should be followed:

```dart
// ✅ CORRECT: Repository Interface (Domain Layer)
abstract interface class AuthRepository {
  /// Authenticate parent with email and password
  ///
  /// Returns authenticated [Parent] entity with tokens on success.
  /// Returns [AuthFailure] on invalid credentials or [NetworkFailure] on network issues.
  Future<Either<Failure, Parent>> login({  // ✅ Returns Entity
    required String email,
    required String password,
  });
}

// ✅ CORRECT: Repository Implementation (Data Layer)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final HttpService _httpService;

  const AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
    required HttpService httpService,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _httpService = httpService;

  @override
  Future<Either<Failure, ParentModel>> login({  // ✅ Returns Model (extends Entity)
    required String email,
    required String password,
  }) async {
    try {
      // Call remote data source
      final parentModel = await _remoteDataSource.login(
        email: email,
        password: password,
      );

      // Set auth token in HTTP service for subsequent requests
      if (parentModel.token != null) {
        _httpService.setAuthToken(parentModel.token!);
      }

      // Cache parent data locally
      await _localDataSource.cacheParent(parentModel);

      Log.info('Login successful for: $email');

      // ✅ Convert model to entity at boundary (happens automatically via inheritance)
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
}
```

**Key Points:**
1. Interface returns `Future<Either<Failure, Parent>>` (Entity)
2. Implementation returns `Future<Either<Failure, ParentModel>>` (Model)
3. ParentModel extends Parent, so this is valid
4. Model is returned but satisfies Entity return type through inheritance

### Common Mistake: Implementation Returns Entity

```dart
// ❌ WRONG: Trying to convert model back to entity
class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<Either<Failure, Parent>> login({...}) async {  // ❌ Returning Parent instead of ParentModel
    try {
      final parentModel = await _remoteDataSource.login(...);

      // ❌ UNNECESSARY conversion
      final parent = Parent(
        id: parentModel.id,
        name: parentModel.name,
        email: parentModel.email,
      );

      return right(parent);  // ❌ Wrong, loses Model functionality
    } catch (e) {
      // ...
    }
  }
}
```

**Why Wrong:** Unnecessaryconversion loses Model functionality. ParentModel IS a Parent through inheritance.

### Common Mistake: Interface Returns Model

```dart
// ❌ WRONG: Model in domain layer
abstract interface class AuthRepository {
  Future<Either<Failure, ParentModel>> login({...});  // ❌ Model in interface
}
```

**Why Wrong:** Domain layer should not know about Models (data layer concerns).

---

## 3. Feature BLoC vs Global Cubit Confusion

### The Two Patterns Explained

**Pattern 1: Feature BLoC** (handles operations)
- Location: `features/auth/presentation/bloc/`
- Purpose: Login, register, logout operations
- Registration: `registerFactory` in DI
- Provider: Local `BlocProvider` in page

**Pattern 2: Global AuthCubit** (tracks state)
- Location: `core/common/cubits/auth/`
- Purpose: Track if user is logged in/out
- Registration: `registerLazySingleton` in DI
- Provider: Global `MultiBlocProvider` in main()

### Mistake: Not Using Both Patterns Together

```dart
// ❌ WRONG: Feature BLoC doesn't update global state
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginWithEmail _loginWithEmail;
  // ❌ Missing AuthCubit dependency

  Future<void> _onLoginRequested(event, emit) async {
    emit(AuthLoading());

    final result = await _loginWithEmail(params);

    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (parent) {
        // ❌ Not updating global AuthCubit
        emit(AuthSuccess(parent));
      },
    );
  }
}
```

**Fix:**
```dart
// ✅ CORRECT: Feature BLoC updates global cubit
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginWithEmail _loginWithEmail;
  final AuthCubit _authCubit;  // ✅ Inject global cubit

  AuthBloc({
    required LoginWithEmail loginWithEmail,
    required AuthCubit authCubit,
  })  : _loginWithEmail = loginWithEmail,
        _authCubit = authCubit,
        super(AuthInitial());

  Future<void> _onLoginRequested(event, emit) async {
    emit(AuthLoading());

    final result = await _loginWithEmail(params);

    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (parent) {
        _authCubit.login(parent);  // ✅ Update global state
        emit(AuthSuccess(parent));
      },
    );
  }
}
```

### Mistake: Complex Logic in Global Cubit

```dart
// ❌ WRONG: Business operations in global cubit
class AuthCubit extends Cubit<AuthState> {
  final LoginWithEmail _loginUseCase;

  // ❌ Operations belong in feature BLoC
  Future<void> login(String email, String password) async {
    emit(AuthLoading());

    final result = await _loginUseCase(LoginParams(email, password));

    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (parent) => emit(AuthLoggedIn(parent)),
    );
  }
}
```

**Fix:**
```dart
// ✅ CORRECT: Simple state tracking in global cubit
class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  // ✅ Simple state updates only
  void login(Parent parent) {
    emit(AuthLoggedIn(parent));
  }

  void logout() {
    emit(AuthLoggedOut());
  }
}

// ✅ Operations in feature BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  Future<void> _onLoginRequested(event, emit) async {
    // Business logic here
    final result = await _loginUseCase(params);

    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (parent) {
        _authCubit.login(parent);  // Update global state
        emit(AuthSuccess(parent));
      },
    );
  }
}
```

---

## 4. Dependency Injection Registration Errors

### Mistake: registerSingleton for BLoC/Cubit

```dart
// ❌ WRONG: registerSingleton creates instance before registration
Future<void> init() async {
  final authBloc = AuthBloc(loginWithEmail: sl());
  sl.registerSingleton<AuthBloc>(authBloc);  // ❌ Wrong - use lazy
}
```

**Fix:**
```dart
// ✅ CORRECT: Lazy singleton for ALL BLoCs
Future<void> init() async {
  sl.registerLazySingleton(() => AuthBloc(loginWithEmail: sl()));
}
```

### Mistake: registerFactory for BLoC/Cubit

```dart
// ❌ WRONG: Factory for BLoCs/Cubits
Future<void> init() async {
  sl.registerFactory(() => AuthBloc(...));  // ❌ Should be lazy singleton
  sl.registerFactory(() => AuthCubit());     // ❌ Should be lazy singleton
}
```

**Fix:**
```dart
// ✅ CORRECT: Lazy singleton for ALL BLoCs and Cubits
Future<void> init() async {
  sl.registerLazySingleton(() => AuthBloc(...));
  sl.registerLazySingleton(() => AuthCubit());
}
```

### Complete Correct Pattern

```dart
// ✅ CORRECT: Full DI setup - ALL use registerLazySingleton
Future<void> init() async {
  // Services - registerLazySingleton
  sl.registerLazySingleton<HttpService>(() => HttpService());

  // Data sources - registerLazySingleton
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(httpService: sl()),
  );

  // Repositories - registerLazySingleton
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  // Use cases - registerLazySingleton
  sl.registerLazySingleton(() => LoginWithEmail(sl()));

  // ALL BLoCs and Cubits - registerLazySingleton
  sl.registerLazySingleton(() => AuthCubit());
  sl.registerLazySingleton(() => AuthBloc(
    loginWithEmail: sl(),
    authCubit: sl(),
  ));
  sl.registerLazySingleton(() => ProfileBloc(...));
}
```

---

## 5. MultiBlocProvider Misplacement

### Mistake: Provider in MyApp.build()

```dart
// ❌ WRONG: MultiBlocProvider in MyApp
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(  // ❌ Wrong location!
      providers: [
        BlocProvider(create: (_) => di.sl<AuthCubit>()),
      ],
      child: MaterialApp.router(...),
    );
  }
}

void main() async {
  await di.init();
  runApp(const MyApp());  // ❌ No providers
}
```

**Fix:**
```dart
// ✅ CORRECT: MultiBlocProvider in main()
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();

  runApp(
    MultiBlocProvider(  // ✅ Correct location!
      providers: [
        BlocProvider(create: (_) => di.sl<AuthCubit>()),
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
        BlocProvider(create: (_) => di.sl<ThemeCubit>()),
        BlocProvider(create: (_) => di.sl<ProfileBloc>()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ✅ Just build UI, no providers
    return MaterialApp.router(...);
  }
}
```

### Mistake: Not Including All BLoCs/Cubits

```dart
// ❌ WRONG: Missing BLoCs
void main() async {
  await di.init();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthCubit>()),   // ✅ OK
        // ❌ Missing AuthBloc, ProfileBloc, etc.
      ],
      child: const MyApp(),
    ),
  );
}
```

**Fix:**
```dart
// ✅ CORRECT: ALL BLoCs and Cubits in MultiBlocProvider
void main() async {
  await di.init();

  runApp(
    MultiBlocProvider(
      providers: [
        // ALL Cubits
        BlocProvider(create: (_) => di.sl<AuthCubit>()),
        BlocProvider(create: (_) => di.sl<ThemeCubit>()),

        // ALL BLoCs
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
        BlocProvider(create: (_) => di.sl<ProfileBloc>()),
        BlocProvider(create: (_) => di.sl<OrderBloc>()),
      ],
      child: const MyApp(),
    ),
  );
}
```

---

## Quick Reference: What Goes Where

### Entity (Domain)
- ✅ Final fields
- ✅ Constructor
- ❌ NO copyWith
- ❌ NO static constants
- ❌ NO methods
- ❌ NO serialization

### Model (Data)
- ✅ Extends Entity
- ✅ copyWith
- ✅ Static constants
- ✅ fromMap/toMap
- ✅ fromJson/toJson
- ✅ Helper methods

### Repository Interface (Domain)
- ✅ Returns Entity types
- ✅ Abstract interface class
- ❌ NO Model types

### Repository Implementation (Data)
- ✅ Returns Model types (extends Entity)
- ✅ Handles exceptions
- ✅ Coordinates data sources

### Dependency Injection
- `registerLazySingleton`: Services, Repositories, Use Cases, ALL BLoCs, ALL Cubits
- `registerFactory`: ❌ NOT used for BLoCs/Cubits
- `registerSingleton`: ❌ Never for BLoCs/Cubits

### MultiBlocProvider
- ✅ In main() function
- ✅ ALL BLoCs (Feature and Global)
- ✅ ALL Cubits (Feature and Global)
- ❌ NOT in MyApp.build()
