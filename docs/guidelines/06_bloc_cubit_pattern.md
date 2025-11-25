# BLoC/Cubit Pattern - Feature vs Global State

**Feature BLoC Location:** `lib/features/{feature}/presentation/bloc/`
**Global Cubit Location:** `lib/core/common/cubits/`
**Purpose:** Manage application state with clear separation between feature and global concerns

## ⚠️ CRITICAL: Two Different Patterns

This is a common source of confusion. Understand the difference:

```
Feature BLoC (Auth Feature)
├── Handles authentication operations (login, register, logout)
├── Located in features/auth/presentation/bloc/
├── Used within auth feature pages
├── Registered as LAZY SINGLETON in DI
└── Provided in main() MultiBlocProvider

Global AuthCubit (App-Wide State)
├── Tracks current authentication status (logged in/out)
├── Located in core/common/cubits/auth/
├── Used across entire app
├── Registered as LAZY SINGLETON in DI
└── Provided in main() MultiBlocProvider
```

**Note:** ALL BLoCs and Cubits are registered as `registerLazySingleton` and provided in `MultiBlocProvider` in `main()`.

## Pattern 1: Feature BLoC (Operations)

### When to Use

Use feature BLoC for:
- Feature-specific business operations
- Form submissions
- Data fetching for specific pages
- Complex state transitions within a feature
- Event-driven operations

### Example: Auth Feature BLoC

```dart
// lib/features/auth/presentation/bloc/auth_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:your_app/features/auth/domain/entities/parent.dart';
import 'package:your_app/features/auth/domain/usecases/login_with_email.dart';
import 'package:your_app/features/auth/domain/usecases/register_parent.dart';
import 'package:your_app/features/auth/domain/usecases/get_cached_parent.dart';
import 'package:your_app/core/common/cubits/auth/auth_cubit.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Feature BLoC - Handles authentication operations
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginWithEmail _loginWithEmail;
  final RegisterParent _registerParent;
  final GetCachedParent _getCachedParent;
  final AuthCubit _authCubit;  // ✅ Depends on global cubit

  AuthBloc({
    required LoginWithEmail loginWithEmail,
    required RegisterParent registerParent,
    required GetCachedParent getCachedParent,
    required AuthCubit authCubit,
  })  : _loginWithEmail = loginWithEmail,
        _registerParent = registerParent,
        _getCachedParent = getCachedParent,
        _authCubit = authCubit,
        super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthCheckCached>(_onCheckCached);
  }

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
      (failure) => emit(AuthFailure(failure.message)),
      (parent) {
        // ✅ Update global auth state
        _authCubit.login(parent);

        emit(AuthSuccess(parent));
      },
    );
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _registerParent(
      RegisterParentParams(
        name: event.name,
        email: event.email,
        password: event.password,
      ),
    );

    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (parent) {
        _authCubit.login(parent);
        emit(AuthSuccess(parent));
      },
    );
  }

  Future<void> _onCheckCached(
    AuthCheckCached event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _getCachedParent(NoParams());

    result.fold(
      (failure) => emit(AuthInitial()),
      (parent) {
        _authCubit.login(parent);
        emit(AuthSuccess(parent));
      },
    );
  }
}
```

### Feature BLoC Events

```dart
// lib/features/auth/presentation/bloc/auth_event.dart

part of 'auth_bloc.dart';

abstract class AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  AuthLoginRequested({
    required this.email,
    required this.password,
  });
}

class AuthRegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;

  AuthRegisterRequested({
    required this.name,
    required this.email,
    required this.password,
  });
}

class AuthCheckCached extends AuthEvent {}
```

### Feature BLoC States

```dart
// lib/features/auth/presentation/bloc/auth_state.dart

part of 'auth_bloc.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final Parent parent;

  AuthSuccess(this.parent);
}

class AuthFailure extends AuthState {
  final String message;

  AuthFailure(this.message);
}
```

### Using Feature BLoC in Page

```dart
// lib/features/auth/presentation/pages/login_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:your_app/features/auth/presentation/bloc/auth_bloc.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Access BLoC from context (already provided in main())
    return const _LoginView();
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            // Navigate to home
            Navigator.pushReplacementNamed(context, '/home');
          } else if (state is AuthFailure) {
            // Show error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return _buildLoginForm(context);
        },
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    // Form implementation
    return Column(
      children: [
        // Email, password fields...
        ElevatedButton(
          onPressed: () {
            // ✅ Dispatch event to feature BLoC
            context.read<AuthBloc>().add(
                  AuthLoginRequested(
                    email: emailController.text,
                    password: passwordController.text,
                  ),
                );
          },
          child: const Text('Login'),
        ),
      ],
    );
  }
}
```

## Pattern 2: Global Cubit (App State)

### When to Use

Use global cubit for:
- App-wide state (authentication status, theme, language)
- State accessed from multiple features
- State that persists across navigation
- Simple state without complex events

### Example: Global AuthCubit

```dart
// lib/core/common/cubits/auth/auth_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:your_app/features/auth/domain/entities/parent.dart';

part 'auth_state.dart';

/// Global Cubit - Tracks app-wide authentication state
class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  /// Called by feature BLoC after successful login/register
  void login(Parent parent) {
    emit(AuthLoggedIn(parent));
  }

  /// Called when user logs out
  void logout() {
    emit(AuthLoggedOut());
  }

  /// Check if user is authenticated
  bool get isAuthenticated => state is AuthLoggedIn;

  /// Get current parent (null if not authenticated)
  Parent? get currentParent {
    final currentState = state;
    if (currentState is AuthLoggedIn) {
      return currentState.parent;
    }
    return null;
  }
}
```

### Global Cubit States

```dart
// lib/core/common/cubits/auth/auth_state.dart

part of 'auth_cubit.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoggedIn extends AuthState {
  final Parent parent;

  AuthLoggedIn(this.parent);
}

class AuthLoggedOut extends AuthState {}
```

### Using Global Cubit Anywhere

```dart
// Any widget in the app can access global auth state

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is AuthLoggedIn) {
              return Text('Hello, ${state.parent.name}');
            }
            return const Text('Home');
          },
        ),
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is! AuthLoggedIn) {
            return const Center(child: Text('Please login'));
          }

          return Center(
            child: Text('Welcome ${state.parent.email}'),
          );
        },
      ),
    );
  }
}

// In settings page
class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // ✅ Access global cubit from anywhere
        context.read<AuthCubit>().logout();
        Navigator.pushReplacementNamed(context, '/login');
      },
      child: const Text('Logout'),
    );
  }
}
```

## Key Differences

| Aspect | Feature BLoC | Global Cubit |
|--------|-------------|--------------|
| Purpose | Feature operations | App-wide state |
| Location | `features/{feature}/presentation/bloc/` | `core/common/cubits/` |
| Registration | `registerLazySingleton` | `registerLazySingleton` |
| Provider | Global `MultiBlocProvider` in main | Global `MultiBlocProvider` in main |
| Lifecycle | Lives entire app lifetime | Lives entire app lifetime |
| State | Complex with events | Simple state changes |
| Example | AuthBloc (login/register operations) | AuthCubit (logged in/out status) |

## ❌ Common Mistakes

### Mistake 1: Not Providing All BLoCs/Cubits in MultiBlocProvider

```dart
// ❌ WRONG: Trying to provide BLoC locally
void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AuthCubit>()),  // ✅ Cubit provided
        // ❌ Missing AuthBloc!
      ],
      child: const MyApp(),
    ),
  );
}

// Then trying to provide locally in page
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AuthBloc>(),  // ❌ Wrong - should be in main()
      child: const _LoginView(),
    );
  }
}
```

**Why wrong:** ALL BLoCs and Cubits should be provided globally in main(), not locally in pages.

**Fix:**
```dart
// ✅ CORRECT: All BLoCs and Cubits in MultiBlocProvider
void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AuthCubit>()),  // ✅ Global cubit
        BlocProvider(create: (_) => sl<AuthBloc>()),   // ✅ Feature BLoC also here
        BlocProvider(create: (_) => sl<ThemeCubit>()),
        BlocProvider(create: (_) => sl<ProfileBloc>()),
      ],
      child: const MyApp(),
    ),
  );
}

// ✅ Access from context in page
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const _LoginView();  // ✅ BLoC already available
  }
}
```

### Mistake 2: Not Updating Global State After Operations

```dart
// ❌ WRONG: Feature BLoC doesn't update global state
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  Future<void> _onLoginRequested(event, emit) async {
    final result = await _loginWithEmail(params);

    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (parent) {
        // ❌ Not updating AuthCubit
        emit(AuthSuccess(parent));
      },
    );
  }
}
```

**Why wrong:** Rest of app won't know user is authenticated.

**Fix:**
```dart
// ✅ CORRECT: Update global state after successful operation
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthCubit _authCubit;

  Future<void> _onLoginRequested(event, emit) async {
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

### Mistake 3: Complex Logic in Global Cubit

```dart
// ❌ WRONG: Business logic in global cubit
class AuthCubit extends Cubit<AuthState> {
  final LoginWithEmail _loginUseCase;

  Future<void> login(String email, String password) async {  // ❌ Too complex
    emit(AuthLoading());

    final result = await _loginUseCase(LoginParams(email, password));

    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (parent) => emit(AuthLoggedIn(parent)),
    );
  }
}
```

**Why wrong:** Global cubits should only track state, not perform operations. Operations belong in feature BLoCs.

**Fix:**
```dart
// ✅ CORRECT: Simple state tracking
class AuthCubit extends Cubit<AuthState> {
  void login(Parent parent) {  // ✅ Simple state update
    emit(AuthLoggedIn(parent));
  }

  void logout() {  // ✅ Simple state update
    emit(AuthLoggedOut());
  }
}

// ✅ Operations in feature BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  Future<void> _onLoginRequested(event, emit) async {
    emit(AuthLoading());

    final result = await _loginUseCase(params);  // ✅ Operation here

    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (parent) {
        _authCubit.login(parent);  // ✅ Then update global state
        emit(AuthSuccess(parent));
      },
    );
  }
}
```

## Checklist

**Feature BLoC:**
- [ ] Located in `features/{feature}/presentation/bloc/`
- [ ] Registered with `registerLazySingleton` in DI
- [ ] Provided globally in `main()` MultiBlocProvider
- [ ] Handles feature-specific operations
- [ ] Updates global cubit after operations
- [ ] Uses events and states

**Global Cubit:**
- [ ] Located in `core/common/cubits/`
- [ ] Registered with `registerLazySingleton` in DI
- [ ] Provided globally in `main()` MultiBlocProvider
- [ ] Tracks simple app-wide state
- [ ] No complex business logic
- [ ] Accessible from anywhere in app

## Related Guidelines

- [07_dependency_injection.md](07_dependency_injection.md) - How to register BLoCs vs Cubits
- [08_main_app_setup.md](08_main_app_setup.md) - Where to provide global cubits
- [04_use_case_pattern.md](04_use_case_pattern.md) - What BLoCs call

## Summary

**Two Patterns:**

1. **Feature BLoC** (operations): Lives in feature, handles business operations, registered as lazy singleton, provided globally in main()
2. **Global Cubit** (state): Lives in core, tracks app state, registered as lazy singleton, provided globally in main()

**They work together:**
- Feature BLoC performs operations (login, register)
- Feature BLoC updates Global Cubit after success
- Global Cubit tracks current state (logged in/out)
- Rest of app reads Global Cubit state

**Registration & Provider:**
- ALL BLoCs: `registerLazySingleton` + `MultiBlocProvider` in main()
- ALL Cubits: `registerLazySingleton` + `MultiBlocProvider` in main()
