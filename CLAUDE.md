# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter Clean Architecture guidelines package that provides patterns and rules for implementing modular Flutter applications. The package contains comprehensive documentation in `docs/guidelines/` with specific patterns for entities, models, repositories, BLoCs, and dependency injection.

## Commands

```bash
# Get dependencies
flutter pub get

# Run tests
flutter test

# Run a single test file
flutter test test/path/to/test_file.dart

# Analyze code
flutter analyze

# Format code
dart format .
```

## Architecture Overview

This project follows **Flutter Clean Architecture** with three layers:

```
Presentation → Domain ← Data
```

### Layer Structure

Each feature follows this structure:
```
features/{feature}/
├── data/           # Models, DataSources, Repository Implementations
├── domain/         # Entities, Repository Interfaces, Use Cases
└── presentation/   # BLoC, Pages, Widgets
```

Global shared code lives in:
```
core/
├── common/cubits/    # Global state (AuthCubit, ThemeCubit)
├── common/widgets/   # Shared widgets
├── errors/           # Exceptions and Failures
├── injection_container/
└── network/
```

## Critical Rules

### Entities (domain/entities/)

Entities are **pure data containers only**:
- Only `final` fields and `const` constructor
- **NO** methods, copyWith, static constants, serialization, or logic
- All logic goes in Models (data layer)

```dart
// CORRECT
class Parent {
  final String id;
  final String name;
  const Parent({required this.id, required this.name});
}
```

### Models (data/models/)

Models extend entities and contain all logic:
```dart
class ParentModel extends Parent {
  const ParentModel({required super.id, required super.name});

  ParentModel copyWith({String? id, String? name}) => ...
  factory ParentModel.fromMap(Map<String, dynamic> map) => ...
  Map<String, dynamic> toMap() => ...
  static const ParentModel empty = ParentModel(id: '', name: '');
}
```

### Repository Pattern

- **Interface** (domain): Returns `Entity` types
- **Implementation** (data): Returns `Model` types (which extend Entity)

```dart
// Interface
abstract interface class AuthRepository {
  Future<Either<Failure, Parent>> login({...});  // Entity
}

// Implementation
class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<Either<Failure, ParentModel>> login({...}) async {...}  // Model
}
```

### BLoC/Cubit Pattern

Two distinct patterns:

1. **Feature BLoC** (`features/{feature}/presentation/bloc/`): Handles operations (login, register), uses events
2. **Global Cubit** (`core/common/cubits/`): Tracks app-wide state (logged in/out)

Feature BLoCs update Global Cubits after successful operations.

### Dependency Injection

Use `registerLazySingleton` for **everything**:
- Services, Repositories, Data Sources, Use Cases
- **ALL BLoCs** (feature and global)
- **ALL Cubits** (feature and global)

**Never** use `registerSingleton` or `registerFactory` for BLoCs/Cubits.

```dart
sl.registerLazySingleton(() => AuthCubit());
sl.registerLazySingleton(() => AuthBloc(loginWithEmail: sl(), authCubit: sl()));
```

### Main App Setup

MultiBlocProvider goes in `main()`, **not** in `MyApp.build()`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthCubit>()),
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
        // ALL BLoCs and Cubits here
      ],
      child: const MyApp(),
    ),
  );
}
```

## Key Packages

- **State Management**: flutter_bloc, get_it
- **Functional**: fpdart (Either type for error handling)
- **Network**: http
- **Storage**: flutter_secure_storage, shared_preferences
- **Routing**: go_router

## Guidelines Reference

Read in order when implementing features:
1. `docs/guidelines/01_entity_rules.md` - Most critical
2. `docs/guidelines/02_model_rules.md`
3. `docs/guidelines/03_repository_pattern.md` - Most confusing
4. `docs/guidelines/06_bloc_cubit_pattern.md`
5. `docs/guidelines/07_dependency_injection.md`
6. `docs/guidelines/examples/common_mistakes.md` - Learn from errors
