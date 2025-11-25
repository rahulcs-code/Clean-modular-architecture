# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-XX

### Added

#### CLI Tool (`clean_arch`)
- `init` command - Initialize CMA in existing Flutter projects
- `create` command - Create new Flutter projects with full CMA structure
- `generate` command with subcommands:
  - `feature` - Generate complete feature modules with all layers
  - `bloc` - Generate BLoC with events and states
  - `cubit` - Generate Cubit (feature or global)
  - `repository` - Generate repository interface and implementation
  - `entity` - Generate domain entity
  - `model` - Generate data model extending entity
  - `usecase` - Generate use case
- `doctor` command - Check project configuration and structure

#### Custom Lint Rules (16 rules)
- **Entity Rules:**
  - `entity_no_methods` - Entities must not have methods
  - `entity_no_copywith` - Entities must not have copyWith
  - `entity_no_static` - Entities must not have static members
  - `entity_no_serialization` - Entities must not have serialization
  - `entity_no_getters` - Entities must not have computed getters
- **Model Rules:**
  - `model_extends_entity` - Models must extend entities
  - `model_naming_convention` - Models should end with "Model"
- **Repository Rules:**
  - `repository_interface_returns_entity` - Interfaces return Entity types
  - `repository_uses_abstract_interface` - Use abstract interface class
- **Import Rules:**
  - `domain_no_data_imports` - Domain cannot import data layer
  - `domain_no_presentation_imports` - Domain cannot import presentation
  - `data_no_presentation_imports` - Data cannot import presentation
- **DI Rules:**
  - `use_lazy_singleton_for_bloc` - BLoCs use registerLazySingleton
  - `bloc_in_multiprovider` - MultiBlocProvider in main()
- **BLoC/Cubit Rules:**
  - `bloc_naming_convention` - Proper BLoC/Event/State naming
  - `cubit_simple_state` - Global Cubits should only track state

#### Base Classes
- `UseCase<SuccessType, Params>` - Async use case base class
- `SyncUseCase<SuccessType, Params>` - Synchronous use case
- `StreamUseCase<SuccessType, Params>` - Stream-based use case
- `NoParams` - Parameter class for use cases without params
- **Failure hierarchy:**
  - `Failure` (base)
  - `ServerFailure`
  - `NetworkFailure`
  - `CacheFailure`
  - `AuthFailure`
  - `ValidationFailure`
  - `PermissionFailure`
  - `NotFoundFailure`
  - `UnexpectedFailure`
- **Exception hierarchy:**
  - `AppException` (base)
  - `ServerException`
  - `NetworkException`
  - `CacheException`
  - `AuthException`
  - `ValidationException`

#### Code Generators (build_runner)
- DI Registration Generator with annotations:
  - `@Injectable()`
  - `@LazySingleton()`
  - `@Singleton()`
- Route Generator with annotations:
  - `@RoutePage()`
  - `@RouteGuard()`

#### Configuration System
- `cma.yaml` configuration file support
- Configurable paths (features_path, core_path)
- Configurable naming conventions
- Per-rule lint severity configuration
- Template configuration (state_management, di_package)

### Documentation
- Comprehensive README with examples
- Architecture overview and best practices
- CLI command reference
- Lint rule reference with examples
- Configuration reference
