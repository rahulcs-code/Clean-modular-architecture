# Clean Modular Architecture

A Flutter dev dependency that enforces Clean Architecture patterns through CLI tooling, custom lint rules, base classes, and code generators.

[![Pub Version](https://img.shields.io/pub/v/clean_modular_architecture)](https://pub.dev/packages/clean_modular_architecture)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

## Features

- **CLI Tool** (`clean_arch`) - Generate features, BLoCs, Cubits, repositories, entities, models, and use cases
- **16 Custom Lint Rules** - Enforce Clean Architecture patterns at compile time
- **Base Classes** - UseCase, Failure, and Exception hierarchies with fpdart Either support
- **Code Generators** - Auto-generate DI registration and routing configuration
- **Configurable** - Customize paths, naming conventions, and lint severity via `cma.yaml`

## Installation

Install the package and its dependencies using `flutter pub add`:

```bash
# Add dev dependencies
flutter pub add --dev clean_modular_architecture custom_lint

# Add required production dependencies
flutter pub add fpdart flutter_bloc equatable get_it go_router
```

Then enable custom_lint in `analysis_options.yaml`:

```yaml
analyzer:
  plugins:
    - custom_lint
```

> **Note:** Always use `flutter pub add` or `dart pub add` to install dependencies. This ensures you get the latest compatible versions automatically.

## Quick Start

### Initialize a Project

```bash
# Initialize CMA in an existing Flutter project
dart run clean_arch init

# Or create a new project with CMA structure
dart run clean_arch create my_app
```

### Generate Components

```bash
# Generate a complete feature with all layers
dart run clean_arch generate feature auth

# Generate individual components
dart run clean_arch generate bloc login --feature auth
dart run clean_arch generate cubit theme --global
dart run clean_arch generate repository user --feature auth
dart run clean_arch generate entity user --feature auth
dart run clean_arch generate model user --feature auth
dart run clean_arch generate usecase login_with_email --feature auth
```

### Check Project Health

```bash
dart run clean_arch doctor
```

## Architecture Overview

This package enforces a three-layer Clean Architecture:

```
┌─────────────────────────────────────────────────┐
│                 Presentation                     │
│         (BLoC/Cubit, Pages, Widgets)            │
└────────────────────┬────────────────────────────┘
                     │ depends on
                     ▼
┌─────────────────────────────────────────────────┐
│                    Domain                        │
│    (Entities, Repository Interfaces, UseCases)  │
└────────────────────┬────────────────────────────┘
                     │ implemented by
                     ▼
┌─────────────────────────────────────────────────┐
│                     Data                         │
│   (Models, Repository Impl, DataSources)        │
└─────────────────────────────────────────────────┘
```

### Project Structure

```
lib/
├── core/
│   ├── common/
│   │   ├── cubits/          # Global state (AuthCubit, ThemeCubit)
│   │   └── widgets/         # Shared widgets
│   ├── errors/
│   │   ├── exceptions.dart  # Data layer exceptions
│   │   └── failures.dart    # Domain layer failures
│   ├── injection_container/ # get_it setup
│   └── network/             # API clients
└── features/
    └── {feature}/
        ├── data/
        │   ├── datasources/
        │   ├── models/      # Extend entities, have serialization
        │   └── repositories/
        ├── domain/
        │   ├── entities/    # Pure data, no logic
        │   ├── repositories/ # Abstract interfaces
        │   └── usecases/
        └── presentation/
            ├── bloc/        # Feature BLoCs
            └── pages/
```

## Lint Rules

### Entity Rules (Critical)

| Rule | Description |
|------|-------------|
| `entity_no_methods` | Entities must not have methods (except toString) |
| `entity_no_copywith` | Entities must not have copyWith |
| `entity_no_static` | Entities must not have static members |
| `entity_no_serialization` | Entities must not have fromJson/toJson |
| `entity_no_getters` | Entities must not have computed getters |

**Correct Entity:**
```dart
// lib/features/auth/domain/entities/user.dart
class User {
  final String id;
  final String name;
  final String email;

  const User({
    required this.id,
    required this.name,
    required this.email,
  });
}
```

### Model Rules

| Rule | Description |
|------|-------------|
| `model_extends_entity` | Models must extend their entity |
| `model_naming_convention` | Models should end with "Model" |

**Correct Model:**
```dart
// lib/features/auth/data/models/user_model.dart
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    name: json['name'],
    email: json['email'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
  };

  UserModel copyWith({String? id, String? name, String? email}) => UserModel(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
  );
}
```

### Repository Rules

| Rule | Description |
|------|-------------|
| `repository_interface_returns_entity` | Interfaces return Entity, not Model |
| `repository_uses_abstract_interface` | Use `abstract interface class` |

### Import Rules

| Rule | Description |
|------|-------------|
| `domain_no_data_imports` | Domain cannot import from data layer |
| `domain_no_presentation_imports` | Domain cannot import from presentation |
| `data_no_presentation_imports` | Data cannot import from presentation |

### DI Rules

| Rule | Description |
|------|-------------|
| `use_lazy_singleton_for_bloc` | BLoCs/Cubits use registerLazySingleton |
| `bloc_in_multiprovider` | MultiBlocProvider should be in main() |

### BLoC/Cubit Rules

| Rule | Description |
|------|-------------|
| `bloc_naming_convention` | BLoC classes end with Bloc, events with Event, states with State |
| `cubit_simple_state` | Global Cubits should only track state |

## Base Classes

### UseCase

```dart
import 'package:clean_modular_architecture/clean_modular_architecture.dart';

class LoginWithEmail extends UseCase<User, LoginParams> {
  final AuthRepository repository;

  LoginWithEmail(this.repository);

  @override
  Future<Either<Failure, User>> call(LoginParams params) async {
    return repository.login(
      email: params.email,
      password: params.password,
    );
  }
}

class LoginParams {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});
}
```

### Failures

```dart
// Available failures:
ServerFailure(message: 'Custom message')
NetworkFailure(message: 'No internet connection')
CacheFailure(message: 'Cache error')
AuthFailure(message: 'Unauthorized')
ValidationFailure(message: 'Invalid input', errors: {'email': 'Invalid email'})
```

## Configuration

Create `cma.yaml` in your project root:

```yaml
clean_modular_architecture:
  structure:
    features_path: lib/features
    core_path: lib/core
    entity_patterns:
      - "/domain/entities/"
    model_patterns:
      - "/data/models/"

  naming:
    entity_suffix: ""
    model_suffix: "Model"
    repository_suffix: "Repository"
    bloc_suffix: "Bloc"
    cubit_suffix: "Cubit"

  lint:
    enabled: true
    severity:
      entity_no_methods: error
      entity_no_copywith: error
      model_extends_entity: error
      domain_no_data_imports: error
      use_lazy_singleton_for_bloc: error
      bloc_naming_convention: warning

  templates:
    state_management: bloc  # bloc, cubit, riverpod, provider
    di_package: get_it      # get_it, injectable, riverpod
```

## CLI Commands

### `init`

Initialize CMA in an existing Flutter project:

```bash
dart run clean_arch init [--path <project_path>] [--force]
```

### `create`

Create a new Flutter project with full CMA structure:

```bash
dart run clean_arch create <project_name> [--path <parent_path>]
```

### `generate` (alias: `g`)

Generate architecture components:

```bash
# Feature (all layers)
dart run clean_arch g feature <name>

# BLoC
dart run clean_arch g bloc <name> --feature <feature>

# Cubit (feature or global)
dart run clean_arch g cubit <name> --feature <feature>
dart run clean_arch g cubit <name> --global

# Repository (interface + implementation)
dart run clean_arch g repository <name> --feature <feature>

# Entity
dart run clean_arch g entity <name> --feature <feature>

# Model
dart run clean_arch g model <name> --feature <feature>

# UseCase
dart run clean_arch g usecase <name> --feature <feature>
```

### `doctor`

Check project configuration and structure:

```bash
dart run clean_arch doctor [--path <project_path>]
```

## Code Generation (build_runner)

### DI Registration

Annotate classes for automatic DI registration:

```dart
import 'package:clean_modular_architecture/clean_modular_architecture.dart';

@LazySingleton()
class AuthRepositoryImpl implements AuthRepository {
  // ...
}

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  // ...
}
```

Run code generation:

```bash
dart run build_runner build
```

### Route Generation

Annotate pages for automatic route generation:

```dart
@RoutePage(path: '/login')
class LoginPage extends StatelessWidget {
  // ...
}

@RoutePage(path: '/home', initial: true)
class HomePage extends StatelessWidget {
  // ...
}
```

## Best Practices

### 1. Entities are Pure Data

```dart
// GOOD - Entity is just data
class User {
  final String id;
  final String name;
  const User({required this.id, required this.name});
}

// BAD - Entity has logic
class User {
  final String id;
  final String name;

  String get initials => name.split(' ').map((n) => n[0]).join(); // NO!
  User copyWith({String? id}) => User(id: id ?? this.id, name: name); // NO!
}
```

### 2. Models Extend Entities

```dart
// Model adds serialization and utility methods
class UserModel extends User {
  const UserModel({required super.id, required super.name});

  factory UserModel.fromJson(Map<String, dynamic> json) => ...
  Map<String, dynamic> toJson() => ...
  UserModel copyWith({String? id, String? name}) => ...
}
```

### 3. Repository Interface in Domain, Implementation in Data

```dart
// domain/repositories/auth_repository.dart
abstract interface class AuthRepository {
  Future<Either<Failure, User>> login({required String email, required String password});
}

// data/repositories/auth_repository_impl.dart
class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<Either<Failure, UserModel>> login({...}) async {
    // Returns UserModel which extends User
  }
}
```

### 4. Use registerLazySingleton for BLoCs

```dart
// injection_container.dart
sl.registerLazySingleton(() => AuthCubit());
sl.registerLazySingleton(() => AuthBloc(loginWithEmail: sl(), authCubit: sl()));
```

### 5. MultiBlocProvider in main()

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthCubit>()),
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
      ],
      child: const MyApp(),
    ),
  );
}
```

## Contributing

Contributions are welcome! Please read our contributing guidelines before submitting PRs.

## License

MIT License - see [LICENSE](LICENSE) for details.
