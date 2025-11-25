# Main App Setup - MultiBlocProvider Placement

**Location:** `lib/main.dart` and `lib/my_app.dart`
**Purpose:** Initialize app with global providers and configuration

## ⚠️ CRITICAL: MultiBlocProvider Location

**MUST be in main() function, NOT in MyApp.build() method.**

This is a common mistake by AI agents.

## ✅ CORRECT Pattern

### main.dart

```dart
// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:your_app/core/injection_container/injection_container.dart' as di;
import 'package:your_app/core/common/cubits/auth/auth_cubit.dart';
import 'package:your_app/core/common/cubits/theme/theme_cubit.dart';
import 'package:your_app/my_app.dart';

void main() async {
  // 1. Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize dependency injection
  await di.init();

  // 3. ✅ CORRECT: MultiBlocProvider wraps MyApp in main()
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthCubit>()),
        BlocProvider(create: (_) => di.sl<ThemeCubit>()),
      ],
      child: const MyApp(),
    ),
  );
}
```

### my_app.dart

```dart
// lib/my_app.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:your_app/core/common/cubits/theme/theme_cubit.dart';
import 'package:your_app/config/routes/router_config.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ CORRECT: No MultiBlocProvider here, just consume global cubits
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        return MaterialApp.router(
          title: 'Your App',
          theme: themeState.themeData,
          routerConfig: RouterConfig.router,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
```

## Why This Placement Matters

### Lifecycle Issues

```dart
// ❌ WRONG: MultiBlocProvider in MyApp.build()
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(  // ❌ Wrong location
      providers: [
        BlocProvider(create: (_) => di.sl<AuthCubit>()),
      ],
      child: MaterialApp(...),
    );
  }
}
```

**Problems:**
1. Cubits get recreated on hot reload
2. State is lost during rebuilds
3. Multiple instances may be created
4. Initialization order issues

### Correct Placement Benefits

```dart
// ✅ CORRECT: MultiBlocProvider in main()
void main() async {
  await di.init();

  runApp(
    MultiBlocProvider(  // ✅ Correct location
      providers: [
        BlocProvider(create: (_) => di.sl<AuthCubit>()),
      ],
      child: const MyApp(),
    ),
  );
}
```

**Benefits:**
1. Cubits created once at app startup
2. State persists across hot reloads
3. Single instance guaranteed
4. Clear initialization order

## Complete main.dart Template

```dart
// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:your_app/core/injection_container/injection_container.dart' as di;
import 'package:your_app/core/common/cubits/auth/auth_cubit.dart';
import 'package:your_app/core/common/cubits/theme/theme_cubit.dart';
import 'package:your_app/core/common/cubits/language/language_cubit.dart';
import 'package:your_app/my_app.dart';

void main() async {
  // ============================================================================
  // 1. INITIALIZATION
  // ============================================================================

  // Ensure Flutter widgets binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // ============================================================================
  // 2. DEPENDENCY INJECTION
  // ============================================================================

  // Initialize all dependencies (services, repositories, use cases, BLoCs)
  await di.init();

  // ============================================================================
  // 3. RUN APP WITH GLOBAL PROVIDERS
  // ============================================================================

  runApp(
    MultiBlocProvider(
      providers: [
        // Global Cubits (app-wide state)
        BlocProvider(create: (_) => di.sl<AuthCubit>()),
        BlocProvider(create: (_) => di.sl<ThemeCubit>()),
        BlocProvider(create: (_) => di.sl<LanguageCubit>()),
      ],
      child: const MyApp(),
    ),
  );
}
```

## MyApp Structure

```dart
// lib/my_app.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:your_app/core/common/cubits/auth/auth_cubit.dart';
import 'package:your_app/core/common/cubits/theme/theme_cubit.dart';
import 'package:your_app/core/common/cubits/language/language_cubit.dart';
import 'package:your_app/config/routes/router_config.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to multiple cubits if needed
    return MultiBlocListener(
      listeners: [
        // Listen to auth changes for navigation
        BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthLoggedOut) {
              // Navigate to login when logged out
              context.go('/login');
            }
          },
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return BlocBuilder<LanguageCubit, LanguageState>(
            builder: (context, languageState) {
              return MaterialApp.router(
                title: 'Your App',
                debugShowCheckedModeBanner: false,

                // Theme from ThemeCubit
                theme: themeState.lightTheme,
                darkTheme: themeState.darkTheme,
                themeMode: themeState.themeMode,

                // Localization from LanguageCubit
                locale: languageState.locale,
                supportedLocales: languageState.supportedLocales,

                // Routing
                routerConfig: RouterConfig.router,
              );
            },
          );
        },
      ),
    );
  }
}
```

## ❌ Common Mistakes

### Mistake 1: MultiBlocProvider in MyApp.build()

```dart
// ❌ WRONG: Providers in MyApp
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
  runApp(const MyApp());  // ❌ No providers here
}
```

**Fix:**
```dart
// ✅ CORRECT: Providers in main()
void main() async {
  await di.init();

  runApp(
    MultiBlocProvider(  // ✅ Correct location
      providers: [
        BlocProvider(create: (_) => di.sl<AuthCubit>()),
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

### Mistake 2: Not Including All BLoCs/Cubits

```dart
// ❌ WRONG: Missing BLoCs
void main() async {
  await di.init();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthCubit>()),  // ✅ Cubit included
        // ❌ Missing AuthBloc, ProfileBloc, etc.
      ],
      child: const MyApp(),
    ),
  );
}
```

**Why wrong:** ALL BLoCs and Cubits must be provided in MultiBlocProvider.

**Fix:**
```dart
// ✅ CORRECT: ALL BLoCs and Cubits in MultiBlocProvider
void main() async {
  await di.init();

  runApp(
    MultiBlocProvider(
      providers: [
        // Global Cubits
        BlocProvider(create: (_) => di.sl<AuthCubit>()),
        BlocProvider(create: (_) => di.sl<ThemeCubit>()),

        // Feature BLoCs (also provided here!)
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
        BlocProvider(create: (_) => di.sl<ProfileBloc>()),
        BlocProvider(create: (_) => di.sl<OrderBloc>()),
      ],
      child: const MyApp(),
    ),
  );
}
```

### Mistake 3: Not Initializing DI Before Providers

```dart
// ❌ WRONG: Accessing sl before init()
void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthCubit>()),  // ❌ sl not initialized yet!
      ],
      child: const MyApp(),
    ),
  );

  di.init();  // ❌ Too late!
}
```

**Fix:**
```dart
// ✅ CORRECT: Initialize DI first
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await di.init();  // ✅ Initialize first

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthCubit>()),  // ✅ Now sl is ready
      ],
      child: const MyApp(),
    ),
  );
}
```

## Initialization Checklist

### main() Function Order

```dart
void main() async {
  // 1. ✅ Ensure binding initialized
  WidgetsFlutterBinding.ensureInitialized();

  // 2. ✅ Set system preferences (optional)
  await SystemChrome.setPreferredOrientations([...]);

  // 3. ✅ Initialize DI
  await di.init();

  // 4. ✅ Run app with global providers
  runApp(
    MultiBlocProvider(
      providers: [...],
      child: const MyApp(),
    ),
  );
}
```

### What Goes in MultiBlocProvider

```
✅ INCLUDE (EVERYTHING):
- ALL Cubits (global state like AuthCubit, ThemeCubit, LanguageCubit)
- ALL BLoCs (feature operations like AuthBloc, ProfileBloc, OrderBloc)
- Every BLoC and Cubit in your app

❌ DON'T INCLUDE:
- Page-specific widgets
- Form controllers
- Non-BLoC/Cubit state management
```

## Router Integration

### With GoRouter

```dart
// lib/config/routes/router_config.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:your_app/core/common/cubits/auth/auth_cubit.dart';
import 'package:your_app/features/auth/presentation/pages/login_page.dart';
import 'package:your_app/features/home/presentation/pages/home_page.dart';

class RouterConfig {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      // Access global AuthCubit for route protection
      final authState = context.read<AuthCubit>().state;
      final isLoggedIn = authState is AuthLoggedIn;

      // If not logged in and not on login page, redirect to login
      if (!isLoggedIn && state.matchedLocation != '/login') {
        return '/login';
      }

      // If logged in and on login page, redirect to home
      if (isLoggedIn && state.matchedLocation == '/login') {
        return '/home';
      }

      return null;  // No redirect needed
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
    ],
  );
}

// In MyApp
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: RouterConfig.router,  // ✅ Global routing with cubit access
    );
  }
}
```

## Complete Checklist

Before considering main.dart setup complete:

- [ ] `WidgetsFlutterBinding.ensureInitialized()` called
- [ ] `await di.init()` called before providers
- [ ] MultiBlocProvider in main() (NOT MyApp.build())
- [ ] ALL BLoCs included in MultiBlocProvider
- [ ] ALL Cubits included in MultiBlocProvider
- [ ] MyApp receives providers as parent
- [ ] MyApp.build() only builds UI
- [ ] Router configured if using go_router
- [ ] System preferences set if needed

## Related Guidelines

- [06_bloc_cubit_pattern.md](06_bloc_cubit_pattern.md) - Which providers are global
- [07_dependency_injection.md](07_dependency_injection.md) - Initializing DI

## Summary

**Critical Rules:**

1. ✅ MultiBlocProvider goes in main(), wraps MyApp
2. ✅ Initialize DI with `await di.init()` first
3. ✅ ALL BLoCs in MultiBlocProvider (Feature and Global)
4. ✅ ALL Cubits in MultiBlocProvider (Feature and Global)
5. ❌ Never put MultiBlocProvider in MyApp.build()

**Pattern:**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();

  runApp(
    MultiBlocProvider(
      providers: [
        // ALL BLoCs and Cubits here
        BlocProvider(create: (_) => di.sl<AuthCubit>()),
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
        BlocProvider(create: (_) => di.sl<ThemeCubit>()),
        BlocProvider(create: (_) => di.sl<ProfileBloc>()),
        // ... all other BLoCs and Cubits
      ],
      child: const MyApp(),
    ),
  );
}
```
