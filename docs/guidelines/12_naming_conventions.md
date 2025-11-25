# Naming Conventions - Consistent Naming Patterns

**Purpose:** Establish consistent naming patterns across all layers
**Pattern:** Follow Dart style guide with Clean Architecture specifics

## File Naming

### General Rule

**All files use snake_case**

```
✅ CORRECT:
- login_page.dart
- auth_bloc.dart
- parent_model.dart
- auth_repository_impl.dart
- login_with_email.dart
- get_cached_parent.dart

❌ WRONG:
- LoginPage.dart
- authBloc.dart
- ParentModel.dart
- AuthRepositoryImpl.dart
- loginWithEmail.dart
```

### Layer-Specific File Naming

#### Entities
```
✅ Pattern: {entity_name}.dart
Examples:
- parent.dart
- user_profile.dart
- order.dart
- product.dart
```

#### Models
```
✅ Pattern: {entity_name}_model.dart
Examples:
- parent_model.dart
- user_profile_model.dart
- order_model.dart
- product_model.dart
```

#### Repository Interfaces
```
✅ Pattern: {feature}_repository.dart
Examples:
- auth_repository.dart
- profile_repository.dart
- order_repository.dart
```

#### Repository Implementations
```
✅ Pattern: {feature}_repository_impl.dart
Examples:
- auth_repository_impl.dart
- profile_repository_impl.dart
- order_repository_impl.dart
```

#### Data Sources
```
✅ Pattern: {feature}_{source_type}_data_source.dart
Examples:
- auth_remote_data_source.dart
- auth_local_data_source.dart
- profile_remote_data_source.dart
- order_local_data_source.dart
```

#### Use Cases
```
✅ Pattern: {action}_{entity}.dart or {action}_{description}.dart
Examples:
- login_with_email.dart
- register_parent.dart
- get_cached_parent.dart
- logout.dart
- get_user_profile.dart
- update_profile.dart
- create_order.dart
- get_order_history.dart
```

#### BLoCs
```
✅ Pattern: {feature}_bloc.dart, {feature}_event.dart, {feature}_state.dart
Examples:
- auth_bloc.dart, auth_event.dart, auth_state.dart
- profile_bloc.dart, profile_event.dart, profile_state.dart
- order_bloc.dart, order_event.dart, order_state.dart
```

#### Cubits
```
✅ Pattern: {feature}_cubit.dart, {feature}_state.dart
Examples:
- auth_cubit.dart, auth_state.dart
- theme_cubit.dart, theme_state.dart
- language_cubit.dart, language_state.dart
```

#### Pages
```
✅ Pattern: {page_name}_page.dart
Examples:
- login_page.dart
- register_page.dart
- home_page.dart
- profile_page.dart
- order_details_page.dart
```

#### Widgets
```
✅ Pattern: {widget_name}.dart or {widget_name}_widget.dart
Examples:
- login_form.dart
- profile_header.dart
- order_card.dart
- app_button.dart
- loading_indicator.dart
```

## Class Naming

### General Rule

**All classes use PascalCase**

```
✅ CORRECT:
- LoginPage
- AuthBloc
- ParentModel
- AuthRepository
- LoginWithEmail

❌ WRONG:
- loginPage
- authBloc
- parentModel
- auth_repository
- login_with_email
```

### Layer-Specific Class Naming

#### Entities
```
✅ Pattern: {EntityName}
Examples:
- Parent
- UserProfile
- Order
- Product
- CartItem
```

#### Models
```
✅ Pattern: {EntityName}Model
Examples:
- ParentModel extends Parent
- UserProfileModel extends UserProfile
- OrderModel extends Order
- ProductModel extends Product
```

**Rule:** Model class name = Entity name + "Model" suffix

#### Repository Interfaces
```
✅ Pattern: {Feature}Repository
Examples:
- abstract interface class AuthRepository
- abstract interface class ProfileRepository
- abstract interface class OrderRepository
```

#### Repository Implementations
```
✅ Pattern: {Feature}RepositoryImpl
Examples:
- class AuthRepositoryImpl implements AuthRepository
- class ProfileRepositoryImpl implements ProfileRepository
- class OrderRepositoryImpl implements OrderRepository
```

**Rule:** Implementation class name = Interface name + "Impl" suffix

#### Data Sources
```
✅ Pattern: {Feature}{Source}DataSource (interface)
✅ Pattern: {Feature}{Source}DataSourceImpl (implementation)

Examples:
- abstract interface class AuthRemoteDataSource
- class AuthRemoteDataSourceImpl implements AuthRemoteDataSource
- abstract interface class AuthLocalDataSource
- class AuthLocalDataSourceImpl implements AuthLocalDataSource
```

#### Use Cases
```
✅ Pattern: {ActionVerb}{Entity/Description}
Examples:
- LoginWithEmail
- RegisterParent
- GetCachedParent
- Logout
- GetUserProfile
- UpdateProfile
- CreateOrder
- GetOrderHistory
```

**Naming Guide:**
- Start with action verb (Get, Create, Update, Delete, Login, Register, etc.)
- Follow with entity or description
- Use PascalCase

#### BLoCs
```
✅ Pattern: {Feature}Bloc
Examples:
- class AuthBloc extends Bloc<AuthEvent, AuthState>
- class ProfileBloc extends Bloc<ProfileEvent, ProfileState>
- class OrderBloc extends Bloc<OrderEvent, OrderState>
```

#### BLoC Events
```
✅ Pattern: {Feature}{Action}{Context}
Examples:
// Base event
- abstract class AuthEvent

// Specific events
- class AuthLoginRequested extends AuthEvent
- class AuthRegisterRequested extends AuthEvent
- class AuthLogoutRequested extends AuthEvent
- class ProfileUpdateRequested extends ProfileEvent
- class OrderCreateRequested extends OrderEvent
```

**Structure:**
1. Feature name (Auth, Profile, Order)
2. Action (Login, Register, Logout, Update, Create)
3. Context (Requested, Started, Completed)

#### BLoC States
```
✅ Pattern: {Feature}{Status}
Examples:
// Base state
- abstract class AuthState

// Specific states
- class AuthInitial extends AuthState
- class AuthLoading extends AuthState
- class AuthSuccess extends AuthState
- class AuthFailure extends AuthState
- class ProfileLoading extends ProfileState
- class OrderCreated extends OrderState
```

#### Cubits
```
✅ Pattern: {Feature}Cubit
Examples:
- class AuthCubit extends Cubit<AuthState>
- class ThemeCubit extends Cubit<ThemeState>
- class LanguageCubit extends Cubit<LanguageState>
```

#### Cubit States
```
✅ Pattern: {Feature}{Status}
Examples:
// Base state
- abstract class AuthState

// Specific states
- class AuthInitial extends AuthState
- class AuthLoggedIn extends AuthState
- class AuthLoggedOut extends AuthState
- class ThemeLight extends ThemeState
- class ThemeDark extends ThemeState
```

#### Pages
```
✅ Pattern: {PageName}Page
Examples:
- class LoginPage extends StatelessWidget
- class RegisterPage extends StatelessWidget
- class HomePage extends StatelessWidget
- class ProfilePage extends StatelessWidget
- class OrderDetailsPage extends StatelessWidget
```

#### Widgets
```
✅ Pattern: {WidgetName} or {WidgetName}Widget
Examples:
- class LoginForm extends StatelessWidget
- class ProfileHeader extends StatelessWidget
- class OrderCard extends StatelessWidget
- class AppButton extends StatelessWidget
- class LoadingIndicator extends StatelessWidget
```

**Rule:** Use descriptive names, add "Widget" suffix only if ambiguity exists

## Variable Naming

### General Rules

**Use camelCase for variables, parameters, and method names**

```dart
✅ CORRECT:
final String userName;
final int orderCount;
final List<Product> productList;
void getUserProfile() {}
Future<void> loginUser() async {}

❌ WRONG:
final String UserName;
final int order_count;
void GetUserProfile() {}
```

### Specific Patterns

#### Private Members
```dart
✅ Use underscore prefix for private members:
class AuthBloc {
  final LoginWithEmail _loginWithEmail;
  final AuthCubit _authCubit;

  Future<void> _onLoginRequested() async {}
}
```

#### Constants
```dart
✅ Use lowerCamelCase for constants:
const String apiBaseUrl = 'https://api.example.com';
const int maxRetryAttempts = 3;
const Duration requestTimeout = Duration(seconds: 30);

✅ Or SCREAMING_SNAKE_CASE for global constants:
const String API_BASE_URL = 'https://api.example.com';
const int MAX_RETRY_ATTEMPTS = 3;
```

#### Boolean Variables
```dart
✅ Prefix with is/has/can/should:
bool isLoggedIn;
bool hasToken;
bool canEdit;
bool shouldRetry;
```

#### Collections
```dart
✅ Use plural nouns:
List<User> users;
List<Order> orders;
Map<String, String> errorMessages;
Set<String> selectedIds;
```

#### Parameters
```dart
✅ Use descriptive camelCase:
Future<Either<Failure, Parent>> login({
  required String email,
  required String password,
});

class LoginWithEmailParams {
  final String email;
  final String password;

  const LoginWithEmailParams({
    required this.email,
    required this.password,
  });
}
```

## Method Naming

### General Pattern

```dart
✅ Use verb phrases in camelCase:
void login() {}
Future<void> getUserProfile() async {}
bool isAuthenticated() {}
void updateTheme() {}
String formatDate() {}
```

### BLoC Event Handlers

```dart
✅ Pattern: _on{EventName}
Examples:
Future<void> _onLoginRequested(AuthLoginRequested event, Emitter<AuthState> emit) async {}
Future<void> _onRegisterRequested(AuthRegisterRequested event, Emitter<AuthState> emit) async {}
Future<void> _onProfileUpdateRequested(ProfileUpdateRequested event, Emitter<ProfileState> emit) async {}
```

### Use Case Call Method

```dart
✅ Always use "call" method:
class LoginWithEmail {
  Future<Either<Failure, Parent>> call(LoginWithEmailParams params) async {
    return await repository.login(
      email: params.email,
      password: params.password,
    );
  }
}
```

### Repository Methods

```dart
✅ Use verb + noun pattern:
abstract interface class AuthRepository {
  Future<Either<Failure, Parent>> login({required String email, required String password});
  Future<Either<Failure, Parent>> register({required String name, required String email, required String password});
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, Parent>> getStoredUser();
}
```

### Data Source Methods

```dart
✅ Match repository method names:
abstract interface class AuthRemoteDataSource {
  Future<ParentModel> login({required String email, required String password});
  Future<ParentModel> register({required String name, required String email, required String password});
  Future<void> logout();
}

abstract interface class AuthLocalDataSource {
  Future<ParentModel> getCachedParent();
  Future<void> cacheParent(ParentModel parent);
  Future<void> clearCache();
}
```

## Parameter Class Naming

### Pattern

```dart
✅ Pattern: {UseCaseName}Params
Examples:
class LoginWithEmailParams {
  final String email;
  final String password;
}

class RegisterParentParams {
  final String name;
  final String email;
  final String password;
}

class UpdateProfileParams {
  final String userId;
  final String name;
  final String phone;
}
```

### No Parameters

```dart
✅ Use NoParams class:
class NoParams {
  const NoParams();
}

// Usage
class GetCachedParent {
  Future<Either<Failure, Parent>> call(NoParams params) async {
    return await repository.getCachedParent();
  }
}
```

## Exception & Failure Naming

### Exceptions (Data Layer)

```dart
✅ Pattern: {Type}Exception
Examples:
class ServerException extends AppException {}
class NetworkException extends AppException {}
class CacheException extends AppException {}
class AuthException extends AppException {}
class ValidationException extends AppException {}
```

### Failures (Domain Layer)

```dart
✅ Pattern: {Type}Failure
Examples:
class ServerFailure extends Failure {}
class NetworkFailure extends Failure {}
class CacheFailure extends Failure {}
class AuthFailure extends Failure {}
class ValidationFailure extends Failure {}
```

**Rule:** Exception/Failure names should match (ServerException → ServerFailure)

## Test File Naming

```
✅ Pattern: {file_name}_test.dart
Examples:
- login_page_test.dart
- auth_bloc_test.dart
- parent_model_test.dart
- auth_repository_impl_test.dart
- login_with_email_test.dart
```

## Directory Naming

```
✅ Use lowercase with underscores:
features/
core/
presentation/
domain/
data/
datasources/
repositories/
usecases/
```

## Consistency Examples

### Complete Feature Naming

```
Feature: Authentication

Files:
- features/auth/domain/entities/parent.dart
- features/auth/data/models/parent_model.dart
- features/auth/domain/repositories/auth_repository.dart
- features/auth/data/repositories/auth_repository_impl.dart
- features/auth/data/datasources/auth_remote_data_source.dart
- features/auth/data/datasources/auth_local_data_source.dart
- features/auth/domain/usecases/login_with_email.dart
- features/auth/domain/usecases/register_parent.dart
- features/auth/presentation/bloc/auth_bloc.dart
- features/auth/presentation/bloc/auth_event.dart
- features/auth/presentation/bloc/auth_state.dart
- features/auth/presentation/pages/login_page.dart
- features/auth/presentation/widgets/login_form.dart

Classes:
- class Parent {...}
- class ParentModel extends Parent {...}
- abstract interface class AuthRepository {...}
- class AuthRepositoryImpl implements AuthRepository {...}
- abstract interface class AuthRemoteDataSource {...}
- class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {...}
- class LoginWithEmail {...}
- class RegisterParent {...}
- class AuthBloc extends Bloc<AuthEvent, AuthState> {...}
- abstract class AuthEvent {...}
- class AuthLoginRequested extends AuthEvent {...}
- abstract class AuthState {...}
- class AuthLoading extends AuthState {...}
- class LoginPage extends StatelessWidget {...}
- class LoginForm extends StatelessWidget {...}

Variables:
- final String email;
- final String password;
- final AuthCubit _authCubit;
- bool isLoggedIn;
- List<Parent> parents;

Methods:
- void login() {}
- Future<void> _onLoginRequested() async {}
- Future<Either<Failure, Parent>> call() async {}
```

## Abbreviation Rules

### Avoid Abbreviations

```dart
❌ AVOID:
- usr instead of user
- pwd instead of password
- auth instead of authentication (use auth only in class names)
- repo instead of repository
- msg instead of message

✅ ACCEPTABLE abbreviations:
- id (identifier)
- url (Uniform Resource Locator)
- api (Application Programming Interface)
- http (HyperText Transfer Protocol)
- dto (Data Transfer Object - but prefer Model)
```

## Common Patterns Summary

| Type | Pattern | Example |
|------|---------|---------|
| Entity | PascalCase | Parent, UserProfile |
| Model | PascalCaseModel | ParentModel, UserProfileModel |
| Repository Interface | PascalCaseRepository | AuthRepository |
| Repository Impl | PascalCaseRepositoryImpl | AuthRepositoryImpl |
| Data Source Interface | PascalCase{Type}DataSource | AuthRemoteDataSource |
| Data Source Impl | PascalCase{Type}DataSourceImpl | AuthRemoteDataSourceImpl |
| Use Case | VerbNoun | LoginWithEmail, GetUserProfile |
| BLoC | PascalCaseBloc | AuthBloc, ProfileBloc |
| Cubit | PascalCaseCubit | AuthCubit, ThemeCubit |
| Event | PascalCaseActionContext | AuthLoginRequested |
| State | PascalCaseStatus | AuthLoading, AuthSuccess |
| Page | PascalCasePage | LoginPage, HomePage |
| Widget | PascalCase(Widget) | LoginForm, AppButton |
| File | snake_case.dart | login_page.dart |
| Directory | lowercase | features/, domain/ |
| Variable | camelCase | userName, isLoggedIn |
| Method | camelCase | login(), getUserProfile() |
| Constant | camelCase or SCREAMING_SNAKE_CASE | apiBaseUrl, MAX_RETRY |

## Checklist

- [ ] All files use snake_case
- [ ] All classes use PascalCase
- [ ] All variables use camelCase
- [ ] All methods use camelCase
- [ ] Model classes end with "Model" suffix
- [ ] Repository implementations end with "Impl" suffix
- [ ] Use cases start with action verb
- [ ] BLoC events end with context (Requested, Started, etc.)
- [ ] BLoC states describe status (Loading, Success, Failure)
- [ ] Pages end with "Page" suffix
- [ ] Private members start with underscore
- [ ] Boolean variables start with is/has/can/should
- [ ] Collections use plural nouns
- [ ] Test files end with "_test.dart"
- [ ] Consistent naming across related classes

## Related Guidelines

- [10_project_structure.md](10_project_structure.md) - File organization
- [01_entity_rules.md](01_entity_rules.md) - Entity naming
- [02_model_rules.md](02_model_rules.md) - Model naming
- [03_repository_pattern.md](03_repository_pattern.md) - Repository naming

## Summary

**Key Principles:**
1. **Files:** snake_case
2. **Classes:** PascalCase
3. **Variables/Methods:** camelCase
4. **Constants:** camelCase or SCREAMING_SNAKE_CASE
5. **Private:** _underscore prefix

**Suffixes:**
- Models: EntityNameModel
- Repository Impl: RepositoryNameImpl
- Data Source Impl: DataSourceNameImpl
- Pages: PageNamePage
- BLoCs: FeatureNameBloc
- Cubits: FeatureNameCubit

**Consistency is key:** Follow patterns across entire codebase for maintainability
