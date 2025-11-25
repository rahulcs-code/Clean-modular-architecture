# Project Structure - Directory Organization

**Purpose:** Complete project structure template for Flutter Clean Architecture
**Pattern:** Feature-based organization with clear layer separation

## Complete Directory Structure

```
lib/
├── main.dart
├── my_app.dart
├── config/
│   ├── routes/
│   │   └── router_config.dart
│   └── theme/
│       ├── app_theme.dart
│       └── theme_constants.dart
├── core/
│   ├── common/
│   │   ├── cubits/
│   │   │   ├── auth/
│   │   │   │   ├── auth_cubit.dart
│   │   │   │   └── auth_state.dart
│   │   │   ├── theme/
│   │   │   │   ├── theme_cubit.dart
│   │   │   │   └── theme_state.dart
│   │   │   └── language/
│   │   │       ├── language_cubit.dart
│   │   │       └── language_state.dart
│   │   └── widgets/
│   │       ├── app_button.dart
│   │       ├── app_text_field.dart
│   │       ├── loading_indicator.dart
│   │       └── error_widget.dart
│   ├── errors/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── injection_container/
│   │   └── injection_container.dart
│   ├── network/
│   │   ├── http_service.dart
│   │   └── endpoints.dart
│   ├── storage/
│   │   └── secure_storage_service.dart
│   └── utils/
│       ├── constants.dart
│       ├── logger.dart
│       └── validators.dart
└── features/
    ├── auth/
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   ├── auth_local_data_source.dart
    │   │   │   └── auth_remote_data_source.dart
    │   │   ├── models/
    │   │   │   └── parent_model.dart
    │   │   └── repositories/
    │   │       └── auth_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   └── parent.dart
    │   │   ├── repositories/
    │   │   │   └── auth_repository.dart
    │   │   └── usecases/
    │   │       ├── login_with_email.dart
    │   │       ├── register_parent.dart
    │   │       ├── logout.dart
    │   │       └── get_cached_parent.dart
    │   └── presentation/
    │       ├── bloc/
    │       │   ├── auth_bloc.dart
    │       │   ├── auth_event.dart
    │       │   └── auth_state.dart
    │       ├── pages/
    │       │   ├── login_page.dart
    │       │   └── register_page.dart
    │       └── widgets/
    │           ├── login_form.dart
    │           └── register_form.dart
    ├── home/
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   └── home_remote_data_source.dart
    │   │   ├── models/
    │   │   │   └── dashboard_data_model.dart
    │   │   └── repositories/
    │   │       └── home_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   └── dashboard_data.dart
    │   │   ├── repositories/
    │   │   │   └── home_repository.dart
    │   │   └── usecases/
    │   │       └── get_dashboard_data.dart
    │   └── presentation/
    │       ├── bloc/
    │       │   ├── home_bloc.dart
    │       │   ├── home_event.dart
    │       │   └── home_state.dart
    │       ├── pages/
    │       │   └── home_page.dart
    │       └── widgets/
    │           ├── dashboard_card.dart
    │           └── statistics_widget.dart
    └── profile/
        ├── data/
        │   ├── datasources/
        │   │   ├── profile_local_data_source.dart
        │   │   └── profile_remote_data_source.dart
        │   ├── models/
        │   │   └── user_profile_model.dart
        │   └── repositories/
        │       └── profile_repository_impl.dart
        ├── domain/
        │   ├── entities/
        │   │   └── user_profile.dart
        │   ├── repositories/
        │   │   └── profile_repository.dart
        │   └── usecases/
        │       ├── get_profile.dart
        │       └── update_profile.dart
        └── presentation/
            ├── bloc/
            │   ├── profile_bloc.dart
            │   ├── profile_event.dart
            │   └── profile_state.dart
            ├── pages/
            │   ├── profile_page.dart
            │   └── edit_profile_page.dart
            └── widgets/
                ├── profile_header.dart
                └── profile_info_card.dart
```

## Directory Purposes

### Root Level

#### `main.dart`
**Purpose:** Application entry point
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();

  runApp(
    MultiBlocProvider(
      providers: [
        // All global providers
      ],
      child: const MyApp(),
    ),
  );
}
```

#### `my_app.dart`
**Purpose:** Root widget with theme and routing
```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: RouterConfig.router,
      theme: AppTheme.lightTheme,
    );
  }
}
```

### Config Directory

#### `config/routes/`
**Purpose:** App-wide routing configuration
- `router_config.dart` - GoRouter setup with route guards

#### `config/theme/`
**Purpose:** App-wide theming
- `app_theme.dart` - ThemeData configurations
- `theme_constants.dart` - Colors, text styles, spacing

### Core Directory

#### `core/common/cubits/`
**Purpose:** Global state management (app-wide)
**Examples:**
- `auth/` - Authentication status (logged in/out)
- `theme/` - Theme mode (light/dark)
- `language/` - Selected language/locale

**Pattern:**
```dart
// Global Cubit - tracks app state
class AuthCubit extends Cubit<AuthState> {
  void login(Parent parent) => emit(AuthLoggedIn(parent));
  void logout() => emit(AuthLoggedOut());
}
```

#### `core/common/widgets/`
**Purpose:** Reusable widgets shared across features
**Examples:**
- `app_button.dart` - Styled buttons
- `app_text_field.dart` - Custom text inputs
- `loading_indicator.dart` - Loading states
- `error_widget.dart` - Error displays

**Rule:** If widget is used by 2+ features, put it here

#### `core/errors/`
**Purpose:** Error handling types
- `exceptions.dart` - Data layer exceptions
- `failures.dart` - Domain layer failures

#### `core/injection_container/`
**Purpose:** Dependency injection setup
```dart
// injection_container.dart
final sl = GetIt.instance;

Future<void> init() async {
  // Register all dependencies
  _initCore();
  _initAuth();
  _initHome();
  _initProfile();
}
```

#### `core/network/`
**Purpose:** Network layer services
- `http_service.dart` - HTTP client wrapper
- `endpoints.dart` - API endpoint constants

#### `core/storage/`
**Purpose:** Local storage services
- `secure_storage_service.dart` - Secure data storage
- `cache_service.dart` - General caching

#### `core/utils/`
**Purpose:** Utility functions and constants
- `constants.dart` - App-wide constants
- `logger.dart` - Logging utility
- `validators.dart` - Input validation

### Features Directory

Each feature follows the same structure:

#### `features/{feature}/data/`

**datasources/**
- Remote data sources (API calls)
- Local data sources (cache, database)

**Pattern:**
```dart
abstract interface class AuthRemoteDataSource {
  Future<ParentModel> login({required String email, required String password});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<ParentModel> login({...}) async {
    // API call, throw exceptions
  }
}
```

**models/**
- Data transfer objects
- Extend domain entities
- Include serialization logic

**Pattern:**
```dart
class ParentModel extends Parent {
  const ParentModel({...});

  factory ParentModel.fromMap(Map<String, dynamic> map) {...}
  Map<String, dynamic> toMap() {...}
}
```

**repositories/**
- Implement domain repository interfaces
- Convert exceptions to Either<Failure, Success>

#### `features/{feature}/domain/`

**entities/**
- Pure data classes
- NO logic, NO methods, NO copyWith

**Pattern:**
```dart
class Parent {
  final String id;
  final String name;

  const Parent({required this.id, required this.name});
}
```

**repositories/**
- Abstract interfaces
- Return Entity types

**Pattern:**
```dart
abstract interface class AuthRepository {
  Future<Either<Failure, Parent>> login({...});
}
```

**usecases/**
- Single responsibility operations
- Call repository methods

**Pattern:**
```dart
class LoginWithEmail {
  final AuthRepository repository;

  Future<Either<Failure, Parent>> call(LoginWithEmailParams params) {
    return repository.login(email: params.email, password: params.password);
  }
}
```

#### `features/{feature}/presentation/`

**bloc/**
- Feature-specific BLoCs
- Handle business operations
- Update global cubits after success

**Pattern:**
```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginWithEmail _loginWithEmail;
  final AuthCubit _authCubit;

  AuthBloc({...}) : super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
  }
}
```

**pages/**
- Full screen widgets
- Route destinations
- Maximum 1000 lines per file

**Pattern:**
```dart
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LoginView();
  }
}
```

**widgets/**
- Feature-specific widgets
- Used within this feature only
- Extract if file exceeds 1000 lines

## Feature Template

When creating a new feature, follow this template:

```
features/
└── new_feature/
    ├── data/
    │   ├── datasources/
    │   │   ├── new_feature_local_data_source.dart
    │   │   └── new_feature_remote_data_source.dart
    │   ├── models/
    │   │   └── new_feature_model.dart
    │   └── repositories/
    │       └── new_feature_repository_impl.dart
    ├── domain/
    │   ├── entities/
    │   │   └── new_feature_entity.dart
    │   ├── repositories/
    │   │   └── new_feature_repository.dart
    │   └── usecases/
    │       ├── get_new_feature.dart
    │       ├── create_new_feature.dart
    │       └── update_new_feature.dart
    └── presentation/
        ├── bloc/
        │   ├── new_feature_bloc.dart
        │   ├── new_feature_event.dart
        │   └── new_feature_state.dart
        ├── pages/
        │   └── new_feature_page.dart
        └── widgets/
            └── new_feature_widget.dart
```

## Organization Rules

### 1. Feature Independence

**Rule:** Features should be independent and self-contained

```
✅ CORRECT: Feature has own data/domain/presentation
features/auth/
    ├── data/
    ├── domain/
    └── presentation/

❌ WRONG: Mixing feature code
features/auth/data/ contains profile logic
```

### 2. Widget Placement

**Rule:** Shared widgets in core, feature-specific in feature

```
✅ CORRECT:
core/common/widgets/app_button.dart (used by all features)
features/auth/presentation/widgets/login_form.dart (auth only)

❌ WRONG:
features/auth/widgets/app_button.dart (should be in core)
```

### 3. Layer Separation

**Rule:** Clear boundaries between layers

```
Domain Layer:
├── Pure entities
├── Abstract repositories
└── Use cases

Data Layer:
├── Models extending entities
├── Repository implementations
└── Data sources

Presentation Layer:
├── BLoCs
├── Pages
└── Widgets
```

### 4. Import Rules

**Rule:** Domain should never import from data or presentation

```
✅ CORRECT:
domain/repositories/auth_repository.dart
└── imports: domain/entities/parent.dart

❌ WRONG:
domain/repositories/auth_repository.dart
└── imports: data/models/parent_model.dart
```

## Naming Conventions

### Files
```
✅ snake_case for all files:
- login_page.dart
- auth_bloc.dart
- parent_model.dart
- auth_repository_impl.dart
```

### Directories
```
✅ lowercase for directories:
- features/auth/
- core/common/
- presentation/bloc/
```

### Classes
```
✅ PascalCase for classes:
- LoginPage
- AuthBloc
- ParentModel
- AuthRepositoryImpl
```

## File Size Limits

**Rule:** Maximum 1000 lines per file

### When to Split Files

```
If page exceeds 1000 lines:
├── Extract widgets to presentation/widgets/
├── Break into multiple smaller widgets
└── Create widget composition

If bloc exceeds 1000 lines:
├── Consider splitting into multiple BLoCs
├── Extract helper methods to separate files
└── Review if BLoC has too many responsibilities
```

## Asset Organization

```
assets/
├── fonts/
│   └── custom_font.ttf
├── images/
│   ├── logo.png
│   └── splash.png
└── icons/
    └── app_icon.png
```

**pubspec.yaml:**
```yaml
flutter:
  assets:
    - assets/images/
    - assets/icons/
  fonts:
    - family: CustomFont
      fonts:
        - asset: assets/fonts/custom_font.ttf
```

## Environment Configuration

```
lib/
└── config/
    └── env/
        ├── env.dart
        ├── env_dev.dart
        ├── env_prod.dart
        └── env_staging.dart
```

**Pattern:**
```dart
// env.dart
abstract class Env {
  static String get apiBaseUrl => _EnvConfig.apiBaseUrl;
  static String get apiKey => _EnvConfig.apiKey;
}

// env_prod.dart
class _EnvConfig {
  static const String apiBaseUrl = 'https://api.prod.com';
  static const String apiKey = 'prod_key';
}
```

## Test Structure

Mirror the lib/ structure in test/:

```
test/
├── features/
│   └── auth/
│       ├── data/
│       │   ├── datasources/
│       │   ├── models/
│       │   └── repositories/
│       ├── domain/
│       │   └── usecases/
│       └── presentation/
│           └── bloc/
└── core/
    ├── network/
    └── utils/
```

## Checklist

- [ ] Feature directories follow data/domain/presentation structure
- [ ] Global cubits in core/common/cubits/
- [ ] Shared widgets in core/common/widgets/
- [ ] Feature-specific widgets in features/{feature}/presentation/widgets/
- [ ] Entities in domain/entities/
- [ ] Models in data/models/
- [ ] Repository interfaces in domain/repositories/
- [ ] Repository implementations in data/repositories/
- [ ] Use cases in domain/usecases/
- [ ] BLoCs in presentation/bloc/
- [ ] Pages in presentation/pages/
- [ ] No file exceeds 1000 lines
- [ ] Domain layer doesn't import from data or presentation
- [ ] All files use snake_case naming
- [ ] All classes use PascalCase naming

## Related Guidelines

- [06_bloc_cubit_pattern.md](06_bloc_cubit_pattern.md) - BLoC vs Cubit placement
- [11_naming_conventions.md](11_naming_conventions.md) - Naming standards
- [13_widget_organization.md](13_widget_organization.md) - Widget placement rules

## Summary

**Core Structure:**
- `core/` - Shared across features (cubits, widgets, services, errors)
- `features/` - Feature-based organization (data/domain/presentation)
- `config/` - App-wide configuration (routes, theme)

**Feature Structure:**
```
features/{feature}/
├── data/       (Models, Data Sources, Repository Impl)
├── domain/     (Entities, Repository Interface, Use Cases)
└── presentation/ (BLoC, Pages, Widgets)
```

**Key Rules:**
1. Features are self-contained
2. Shared code in core/
3. Maximum 1000 lines per file
4. Domain never imports from data/presentation
5. Follow snake_case for files, PascalCase for classes
