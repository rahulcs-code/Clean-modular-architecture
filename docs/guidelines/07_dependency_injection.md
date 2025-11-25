# Dependency Injection - registerSingleton vs registerLazySingleton vs registerFactory

**Location:** `lib/core/injection_container/`
**Tool:** GetIt Service Locator
**Purpose:** Manage dependencies and their lifecycles

## ⚠️ CRITICAL: Registration Type Rules

This is commonly misunderstood. Each dependency type has specific registration requirements.

## Registration Types

### 1. registerLazySingleton (Standard for Everything)

**When to use:**
- ✅ **ALL Services**
- ✅ **ALL Repositories**
- ✅ **ALL Data sources**
- ✅ **ALL Use cases**
- ✅ **ALL BLoCs** (Feature and Global)
- ✅ **ALL Cubits** (Feature and Global)
- ✅ HTTP clients, Database instances

**Behavior:**
- Creates instance on FIRST access
- Same instance returned for all subsequent calls
- Lazy initialization (not created until needed)

```dart
// ✅ CORRECT: Use registerLazySingleton for EVERYTHING
final sl = GetIt.instance;

Future<void> init() async {
  // Services
  sl.registerLazySingleton<HttpService>(() => HttpService());
  sl.registerLazySingleton<Database>(() => Database());

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(httpService: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginWithEmail(sl()));
  sl.registerLazySingleton(() => RegisterParent(sl()));

  // ALL BLoCs and Cubits - registerLazySingleton
  sl.registerLazySingleton(() => AuthCubit());
  sl.registerLazySingleton(() => ThemeCubit());
  sl.registerLazySingleton(() => LanguageCubit());
  sl.registerLazySingleton(() => AuthBloc(
    loginWithEmail: sl(),
    registerParent: sl(),
    getCachedParent: sl(),
    authCubit: sl(),
  ));
  sl.registerLazySingleton(() => ProfileBloc(
    updateProfile: sl(),
    getProfile: sl(),
  ));
  sl.registerLazySingleton(() => OrderBloc(
    placeOrder: sl(),
    getOrders: sl(),
  ));
}
```

### 2. registerFactory (NOT Used in This Architecture)

**When to use:**
- ❌ **NOT for BLoCs** - Use lazy singleton
- ❌ **NOT for Cubits** - Use lazy singleton
- ❌ **Generally not used in this pattern**

**Note:** This architecture uses `registerLazySingleton` for all dependencies to maintain single instances across the app.

### 3. registerSingleton (Rarely Used)

**When to use:**
- ❌ **NEVER for BLoCs** - Use lazy singleton
- ❌ **NEVER for Cubits** - Use lazy singleton
- Only for instances already created before registration
- Pre-configured objects (rare use case)

**Behavior:**
- Registers already-created instance
- Instance created BEFORE registration
- Not lazy (instance exists immediately)

```dart
// ❌ WRONG: Never do this for BLoCs
sl.registerSingleton<AuthBloc>(AuthBloc(...));

// ✅ RARE VALID USE: Pre-configured objects only
final logger = Logger(
  printer: PrettyPrinter(),
  level: Level.debug,
);
sl.registerSingleton<Logger>(logger);  // Already configured
```

## Complete Dependency Injection Example

```dart
// lib/core/injection_container/injection_container.dart

import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

// Core
import 'package:your_app/core/services/http_service.dart';
import 'package:your_app/core/services/database/database.dart';

// Global Cubits
import 'package:your_app/core/common/cubits/auth/auth_cubit.dart';
import 'package:your_app/core/common/cubits/theme/theme_cubit.dart';

// Auth Feature
import 'package:your_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:your_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:your_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:your_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:your_app/features/auth/domain/usecases/login_with_email.dart';
import 'package:your_app/features/auth/domain/usecases/register_parent.dart';
import 'package:your_app/features/auth/domain/usecases/get_cached_parent.dart';
import 'package:your_app/features/auth/domain/usecases/logout.dart';
import 'package:your_app/features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ============================================================================
  // CORE SERVICES - registerLazySingleton
  // ============================================================================

  // External dependencies
  sl.registerLazySingleton(() => http.Client());

  // Core services
  sl.registerLazySingleton<HttpService>(
    () => HttpService(client: sl()),
  );

  sl.registerLazySingleton<Database>(
    () => Database(),
  );

  // ============================================================================
  // GLOBAL CUBITS - registerLazySingleton (app-wide state)
  // ============================================================================

  sl.registerLazySingleton(() => AuthCubit());
  sl.registerLazySingleton(() => ThemeCubit());

  // ============================================================================
  // AUTH FEATURE
  // ============================================================================

  // Data sources - registerLazySingleton
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(httpService: sl()),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(),
  );

  // Repository - registerLazySingleton
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Use cases - registerLazySingleton
  sl.registerLazySingleton(() => LoginWithEmail(sl()));
  sl.registerLazySingleton(() => RegisterParent(sl()));
  sl.registerLazySingleton(() => GetCachedParent(sl()));
  sl.registerLazySingleton(() => Logout(sl()));

  // BLoCs and Cubits - ALL registerLazySingleton
  sl.registerLazySingleton(() => AuthCubit());
  sl.registerLazySingleton(
    () => AuthBloc(
      loginWithEmail: sl(),
      registerParent: sl(),
      getCachedParent: sl(),
      logout: sl(),
      authCubit: sl(),
    ),
  );
}
```

## Registration Decision Tree

```
What are you registering?

├─ Service (HttpService, Database, etc.)
│   └─ registerLazySingleton ✅

├─ Data Source (Remote/Local)
│   └─ registerLazySingleton ✅

├─ Repository
│   └─ registerLazySingleton ✅

├─ Use Case
│   └─ registerLazySingleton ✅

├─ BLoC (ANY BLoC - Feature or Global)
│   └─ registerLazySingleton ✅

└─ Cubit (ANY Cubit - Feature or Global)
    └─ registerLazySingleton ✅
```

## ❌ Common Mistakes

### Mistake 1: registerSingleton for BLoC/Cubit

```dart
// ❌ WRONG: registerSingleton (instance created before registration)
Future<void> init() async {
  final authBloc = AuthBloc(loginWithEmail: sl());
  sl.registerSingleton<AuthBloc>(authBloc);  // ❌ Wrong - use lazy
}
```

**Why wrong:** Should use registerLazySingleton for lazy initialization.

**Fix:**
```dart
// ✅ CORRECT: Lazy singleton for ALL BLoCs
Future<void> init() async {
  sl.registerLazySingleton(() => AuthBloc(loginWithEmail: sl()));
}
```

### Mistake 2: registerFactory for BLoC/Cubit

```dart
// ❌ WRONG: Factory creates new instance each time
Future<void> init() async {
  sl.registerFactory(() => AuthBloc(...));  // ❌ Should be lazy singleton
  sl.registerFactory(() => AuthCubit());     // ❌ Should be lazy singleton
}
```

**Why wrong:** This architecture uses single instances for all BLoCs and Cubits.

**Fix:**
```dart
// ✅ CORRECT: Lazy singleton for ALL BLoCs and Cubits
Future<void> init() async {
  sl.registerLazySingleton(() => AuthBloc(...));
  sl.registerLazySingleton(() => AuthCubit());
}
```

### Mistake 3: Mixing Registration Types

```dart
// ❌ WRONG: Inconsistent registration
Future<void> init() async {
  sl.registerLazySingleton(() => AuthCubit());  // ✅ Cubit lazy
  sl.registerFactory(() => AuthBloc(...));       // ❌ BLoC should also be lazy
}
```

**Why wrong:** Inconsistent patterns cause confusion.

**Fix:**
```dart
// ✅ CORRECT: All BLoCs and Cubits as lazy singleton
Future<void> init() async {
  sl.registerLazySingleton(() => AuthCubit());
  sl.registerLazySingleton(() => AuthBloc(...));
}
```

## Dependency Resolution

### Using sl() to Resolve

```dart
// Get dependency
final authRepository = sl<AuthRepository>();

// Or let type inference work
final AuthRepository authRepository = sl();

// Common in constructors
sl.registerLazySingleton<AuthRepository>(
  () => AuthRepositoryImpl(
    remoteDataSource: sl(),  // Automatically resolves to AuthRemoteDataSource
    localDataSource: sl(),   // Automatically resolves to AuthLocalDataSource
  ),
);
```

### Named Instances (Rare)

```dart
// Register with names
sl.registerLazySingleton<HttpService>(
  () => HttpService(baseUrl: 'https://api.example.com'),
  instanceName: 'mainApi',
);

sl.registerLazySingleton<HttpService>(
  () => HttpService(baseUrl: 'https://backup.example.com'),
  instanceName: 'backupApi',
);

// Resolve with names
final mainApi = sl<HttpService>(instanceName: 'mainApi');
final backupApi = sl<HttpService>(instanceName: 'backupApi');
```

## Initialization in main()

```dart
// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:your_app/core/injection_container/injection_container.dart' as di;
import 'package:your_app/core/common/cubits/auth/auth_cubit.dart';
import 'package:your_app/core/common/cubits/theme/theme_cubit.dart';
import 'package:your_app/my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize dependency injection first
  await di.init();

  runApp(
    // ✅ Provide global cubits (lazy singletons)
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthCubit>()),  // ✅ Global cubit
        BlocProvider(create: (_) => di.sl<ThemeCubit>()),  // ✅ Global cubit
      ],
      child: const MyApp(),
    ),
  );
}
```

## Feature Module Pattern (Optional)

For large apps, organize DI by feature:

```dart
// lib/core/injection_container/injection_container.dart

final sl = GetIt.instance;

Future<void> init() async {
  await initCore();
  await initAuth();
  await initProfile();
  await initOrders();
}

Future<void> initCore() async {
  sl.registerLazySingleton<HttpService>(() => HttpService(client: sl()));
  sl.registerLazySingleton(() => http.Client());
}

// lib/core/injection_container/features/auth_injection.dart
Future<void> initAuth() async {
  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(httpService: sl()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginWithEmail(sl()));

  // BLoCs - ALL registerLazySingleton
  sl.registerLazySingleton(() => AuthBloc(loginWithEmail: sl()));
}
```

## Testing with Dependency Injection

```dart
// In tests, reset and register mocks
void main() {
  setUp(() {
    sl.reset();  // Clear all registrations

    // Register mocks
    sl.registerLazySingleton<AuthRepository>(() => MockAuthRepository());
    sl.registerLazySingleton(() => AuthBloc(loginWithEmail: sl()));
  });

  test('login success', () async {
    final authBloc = sl<AuthBloc>();
    // Test with mocked dependencies
  });
}
```

## Checklist

- [ ] Services: `registerLazySingleton`
- [ ] Data Sources: `registerLazySingleton`
- [ ] Repositories: `registerLazySingleton`
- [ ] Use Cases: `registerLazySingleton`
- [ ] ALL BLoCs: `registerLazySingleton`
- [ ] ALL Cubits: `registerLazySingleton`
- [ ] Never `registerSingleton` for BLoCs/Cubits
- [ ] Never `registerFactory` for BLoCs/Cubits
- [ ] Dependencies initialized in `main()` before app
- [ ] BLoCs and Cubits provided in MultiBlocProvider in main()

## Related Guidelines

- [06_bloc_cubit_pattern.md](06_bloc_cubit_pattern.md) - BLoC vs Cubit registration
- [08_main_app_setup.md](08_main_app_setup.md) - Providing global cubits

## Summary

**Registration Rules:**

```dart
// ✅ CORRECT Pattern - Use registerLazySingleton for EVERYTHING
sl.registerLazySingleton(() => HttpService());        // Services
sl.registerLazySingleton<AuthRepository>(() => ...);  // Repositories
sl.registerLazySingleton(() => LoginWithEmail(sl())); // Use Cases
sl.registerLazySingleton(() => AuthCubit());          // Cubits (Global)
sl.registerLazySingleton(() => AuthBloc(...));        // BLoCs (Feature/Global)
sl.registerLazySingleton(() => ProfileBloc(...));     // BLoCs (Feature/Global)
```

**Never:**
- ❌ `registerSingleton` for BLoCs/Cubits
- ❌ `registerFactory` for BLoCs/Cubits
- ❌ `registerFactory` for services/repositories

**Always:**
- ✅ `registerLazySingleton` for everything (Services, Repos, BLoCs, Cubits)
