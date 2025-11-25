# Clean Modular Architecture Framework - Implementation Plan

## Overview

A Flutter dev dependency package that enforces Clean Architecture patterns through CLI tooling, custom lint rules, base classes, and code generators.

**Package Name:** `clean_modular_architecture`
**CLI Executable:** `clean_arch`
**Target:** Publishable on pub.dev as a single dev dependency

---

## User Decisions

| Decision | Choice |
|----------|--------|
| Template Engine | Mason bricks (flexible, customizable) |
| Code Generators | Include in Phase 1 (full automation) |
| Lint Severity | ERROR (strict enforcement) |
| CLI Name | `clean_arch` |

---

## Phase 1: Package Foundation

### 1.1 Project Structure Setup

- [x] **1.1.1** Update `pubspec.yaml` with package metadata
  - Name: `clean_modular_architecture`
  - Description: Flutter Clean Architecture framework with CLI, lint rules, and base classes
  - Version: `1.0.0`
  - SDK constraint: `>=3.0.0 <4.0.0`

- [x] **1.1.2** Add core dependencies to `pubspec.yaml`
  ```yaml
  dependencies:
    fpdart: ^1.1.0              # Either type for error handling
    args: ^2.4.0                # CLI argument parsing
    path: ^1.8.0                # Path manipulation
    mason: ^0.1.0-dev.58        # Template generation
    yaml: ^3.1.0                # Config file parsing
    build: ^2.4.0               # Code generation
    source_gen: ^1.4.0          # Code generation helpers
    meta: ^1.9.0                # Annotations
  ```

- [x] **1.1.3** Add dev dependencies to `pubspec.yaml`
  ```yaml
  dev_dependencies:
    test: ^1.24.0
    mocktail: ^1.0.0
    custom_lint_builder: ^0.6.0
    analyzer: ^6.0.0
    build_runner: ^2.4.0
  ```

- [x] **1.1.4** Add executables section to `pubspec.yaml`
  ```yaml
  executables:
    clean_arch: clean_arch
  ```

- [x] **1.1.5** Create directory structure
  ```
  lib/
  ├── clean_modular_architecture.dart
  ├── lints.dart
  └── src/
      ├── base/
      ├── cli/
      │   ├── commands/
      │   └── generators/
      ├── lints/
      │   ├── rules/
      │   │   ├── entity_rules/
      │   │   ├── model_rules/
      │   │   ├── repository_rules/
      │   │   ├── di_rules/
      │   │   └── import_rules/
      │   └── fixes/
      ├── generators/
      └── templates/
  bin/
  └── clean_arch.dart
  templates/
  └── bricks/
  ```

- [x] **1.1.6** Create main export file `lib/clean_modular_architecture.dart`
  - Export base classes
  - Export annotations for code generation

- [x] **1.1.7** Create `lib/lints.dart` for custom_lint plugin entry
  - Export `createPlugin()` function

---

### 1.2 Base Classes Implementation

- [x] **1.2.1** Create `lib/src/base/use_case.dart`
  - [x] Abstract `UseCase<SuccessType, Params>` class with `call()` method returning `Future<Either<Failure, SuccessType>>`
  - [x] Abstract `SyncUseCase<SuccessType, Params>` for synchronous operations
  - [x] Abstract `StreamUseCase<SuccessType, Params>` for reactive operations

- [x] **1.2.2** Create `lib/src/base/no_params.dart`
  - [x] `NoParams` class with const constructor for use cases without parameters

- [x] **1.2.3** Create `lib/src/base/failure.dart`
  - [x] Abstract `Failure` base class with `message` property
  - [x] `ServerFailure` extends Failure
  - [x] `NetworkFailure` extends Failure
  - [x] `CacheFailure` extends Failure
  - [x] `AuthFailure` extends Failure
  - [x] `ValidationFailure` extends Failure with `errors` map

- [x] **1.2.4** Create `lib/src/base/exceptions.dart`
  - [x] Abstract `AppException` base class implementing `Exception`
  - [x] `ServerException` extends AppException
  - [x] `NetworkException` extends AppException
  - [x] `CacheException` extends AppException
  - [x] `AuthException` extends AppException
  - [x] `ValidationException` extends AppException with `errors` map

- [x] **1.2.5** Create `lib/src/base/base.dart` barrel export file
  - Export all base classes

- [x] **1.2.6** Write unit tests for base classes
  - [x] Test UseCase contract
  - [x] Test Failure equality
  - [x] Test Exception messages

---

### 1.3 CLI Foundation

- [x] **1.3.1** Create `bin/clean_arch.dart` CLI entry point
  - [x] Set up `CommandRunner` with name `clean_arch`
  - [x] Add description for the CLI tool
  - [x] Register all commands
  - [x] Handle errors and exit codes

- [x] **1.3.2** Create `lib/src/cli/cli_runner.dart`
  - [x] `CleanArchCommandRunner` class extending `CommandRunner<int>`
  - [x] Register `InitCommand`
  - [x] Register `GenerateCommand`
  - [x] Register `CreateCommand`
  - [x] Register `DoctorCommand`

- [x] **1.3.3** Create `lib/src/cli/commands/init_command.dart`
  - [x] Initialize CMA in existing Flutter project
  - [x] Create `cma.yaml` configuration file
  - [x] Update `analysis_options.yaml` with custom_lint plugin
  - [x] Create core directory structure if missing
  - [x] Add required dependencies suggestion

- [x] **1.3.4** Create `lib/src/cli/commands/generate_command.dart`
  - [x] Parent command for all generate subcommands
  - [x] Add `feature` subcommand
  - [x] Add `bloc` subcommand
  - [x] Add `cubit` subcommand
  - [x] Add `repository` subcommand
  - [x] Add `usecase` subcommand
  - [x] Add `entity` subcommand
  - [x] Add `model` subcommand
  - [x] Add `service` subcommand 

- [x] **1.3.5** Create `lib/src/cli/commands/create_command.dart`
  - [x] Create new Flutter project with full CMA structure
  - [x] Install dependencies using `flutter pub add`
  - [x] Set up complete folder structure
  - [x] Create sample feature (home feature with entity, model, repository, usecase, bloc, page) 

- [x] **1.3.6** Create `lib/src/cli/commands/doctor_command.dart`
  - [x] Check project structure compliance
  - [x] Verify required dependencies
  - [x] Validate configuration file
  - [x] Report issues and suggestions

- [x] **1.3.7** Create `lib/src/cli/utils/logger.dart`
  - [x] Colored console output (success, error, warning, info)
  - [x] Progress indicators
  - [x] Formatting helpers

- [x] **1.3.8** Create `lib/src/cli/utils/file_utils.dart`
  - [x] File creation helpers
  - [x] Directory creation helpers
  - [x] Path resolution utilities
  - [x] Template variable substitution

---

### 1.4 Code Generation Templates (Inline, not Mason)

Note: Implemented as inline Dart templates instead of Mason bricks for simplicity

- [x] **1.4.1** Create feature template
  - [x] Complete feature structure with all layers

- [x] **1.4.2** Create feature template files (inline templates in lib/src/cli/templates/)
  - [x] feature_template.dart - Complete feature generation
  - [x] bloc_template.dart - BLoC generation
  - [x] cubit_template.dart - Cubit generation
  - [x] repository_template.dart - Repository generation
  - [x] entity_template.dart - Entity generation
  - [x] model_template.dart - Model generation
  - [x] use_case_template.dart - UseCase generation

---

## Phase 2: Custom Lint Rules

### 2.1 Lint Plugin Setup

- [x] **2.1.1** Create `lib/src/lints/plugin.dart`
  - [x] `createPlugin()` function returning `PluginBase`
  - [x] `CleanArchLintPlugin` class extending `PluginBase`
  - [x] `getLintRules()` returning list of all rules
  - [x] `getAssists()` returning list of quick fixes (empty for now, TODO for future) 

- [x] **2.1.2** Create `lib/src/lints/utils/entity_detector.dart`
  - [x] `isEntity(ClassDeclaration node, String path)` - check if class is an entity

- [x] **2.1.3** Create `lib/src/lints/utils/model_detector.dart`
  - [x] `isModel(ClassDeclaration node, String path)` - check if class is a model

---

### 2.2 Entity Rules (CRITICAL - Most Violated)

- [x] **2.2.1** Create `lib/src/lints/rules/entity_no_methods.dart`
  - [x] Detect any methods in entity classes
  - [x] Error severity: ERROR
  - [x] Message: "Entities should not have methods. Move this logic to a UseCase or Model."

- [x] **2.2.2** Create `lib/src/lints/rules/entity_no_copywith.dart`
  - [x] Detect `copyWith` method in entities
  - [x] Error severity: ERROR
  - [x] Message: "Entities should not have copyWith methods. Move copyWith to the Model class."

- [x] **2.2.3** Create `lib/src/lints/rules/entity_no_static.dart`
  - [x] Detect static fields/constants in entities
  - [x] Error severity: ERROR
  - [x] Message: "Entities should not have static members. Move static members to the Model class."

- [x] **2.2.4** Create `lib/src/lints/rules/entity_no_serialization.dart`
  - [x] Detect `fromJson`, `toJson`, `fromMap`, `toMap` methods
  - [x] Detect factory constructors for deserialization
  - [x] Error severity: ERROR
  - [x] Message: "Entities should not have serialization methods. Move serialization to the Model class."

- [x] **2.2.5** Create `lib/src/lints/rules/entity_no_getters.dart`
  - [x] Detect computed getters in entities

- [x] **2.2.6** Write tests for entity rules
  - [x] Test with violation examples
  - [x] Test with correct entity examples

---

### 2.3 Model Rules

- [x] **2.3.1** Create `lib/src/lints/rules/model_extends_entity.dart`
  - [x] Verify model classes extend their corresponding entity
  - [x] Error severity: ERROR
  - [x] Message: "Model classes should extend their corresponding Entity."

- [x] **2.3.2** Create `lib/src/lints/rules/model_naming_convention.dart`
  - [x] Verify model class names end with "Model"

- [x] **2.3.3** Write tests for model rules

---

### 2.4 Repository Rules

- [x] **2.4.1** Create `lib/src/lints/rules/repository_interface_returns_entity.dart`
- [x] **2.4.2** Create `lib/src/lints/rules/repository_uses_abstract_interface.dart`
- [x] **2.4.3** Write tests for repository rules

---

### 2.5 Import Restriction Rules

- [x] **2.5.1** Create `lib/src/lints/rules/domain_no_data_imports.dart`
  - [x] Detect imports from data layer in domain files
  - [x] Check for `/data/`, `/models/`, `/datasources/` in import paths
  - [x] Error severity: ERROR
  - [x] Message: "Domain layer should not import from data layer."

- [x] **2.5.2** Create `lib/src/lints/rules/domain_no_presentation_imports.dart`
  - [x] Detect imports from presentation layer in domain files
  - [x] Detect Flutter UI package imports in domain
  - [x] Error severity: ERROR
  - [x] Message: "Domain layer should not import from presentation layer."

- [x] **2.5.3** Create `lib/src/lints/rules/data_no_presentation_imports.dart`
  - [x] Detect imports from presentation layer in data files

- [x] **2.5.4** Write tests for import rules

---

### 2.6 Dependency Injection Rules

- [x] **2.6.1** Create `lib/src/lints/rules/use_lazy_singleton_for_bloc.dart`
  - [x] Detect `registerFactory` for BLoC/Cubit registration
  - [x] Detect `registerSingleton` for BLoC/Cubit registration
  - [x] Error severity: ERROR
  - [x] Message: "BLoCs and Cubits should be registered with registerLazySingleton."

- [x] **2.6.2** Create `lib/src/lints/rules/bloc_in_multiprovider.dart`
- [x] **2.6.3** Write tests for DI rules

---

### 2.7 BLoC/Cubit Rules

- [x] **2.7.1** Create `lib/src/lints/rules/bloc_naming_convention.dart`
- [x] **2.7.2** Create `lib/src/lints/rules/cubit_simple_state.dart`
- [x] **2.7.3** Write tests for BLoC/Cubit rules

---

## Phase 3: Code Generators (build_runner)

### 3.1 DI Registration Generator

- [x] **3.1.1** Create `lib/src/generators/annotations.dart`
  - [x] `@Injectable()` annotation for classes to be registered
  - [x] `@LazySingleton()` annotation
  - [x] `@Singleton()` annotation
  - [x] `@Module()` annotation for grouping

- [x] **3.1.2** Create `lib/src/generators/di_generator.dart`
  - [x] Scan for annotated classes
  - [x] Generate `injection_container.g.dart`
  - [x] Generate `registerLazySingleton` calls
  - [x] Resolve dependency order
  - [x] Support for abstract/interface types

- [x] **3.1.3** Create `build.yaml` for build_runner configuration
  - [x] Configure DI generator builder
  - [x] Set up build extensions

- [x] **3.1.4** Write tests for DI generator
  - [x] Test annotation detection
  - [x] Test code generation output
  - [x] Test dependency resolution

---

### 3.2 Route Generator

- [x] **3.2.1** Create route annotations
  - [x] `@RoutePage()` annotation for pages
  - [x] `@RouteGuard()` annotation for guards

- [x] **3.2.2** Create route generator
  - [x] Scan for annotated pages
  - [x] Generate go_router configuration
  - [x] Generate route constants

- [x] **3.2.3** Write tests for route generator

---

## Phase 4: Configuration System

### 4.1 Configuration File Support

- [x] **4.1.1** Create `lib/src/config/cma_config.dart`
  - [x] Parse `cma.yaml` configuration file
  - [x] Default values for all options
  - [x] Validation of configuration

- [x] **4.1.2** Define configuration schema
  ```yaml
  clean_modular_architecture:
    structure:
      features_path: lib/features
      core_path: lib/core
      entity_pattern: "*/domain/entities/*"
      model_pattern: "*/data/models/*"
    naming:
      entity_suffix: ""
      model_suffix: "Model"
      repository_suffix: "Repository"
      bloc_suffix: "Bloc"
    lint:
      enabled: true
      severity:
        entity_no_methods: error
        model_extends_entity: warning
    templates:
      state_management: bloc
      di_package: get_it
  ```

- [x] **4.1.3** Integrate configuration with lint rules
  - [x] Load config in entity/model detectors
  - [x] Use config for path patterns
  - [x] Use config for naming conventions

- [x] **4.1.4** Integrate configuration with CLI
  - [x] Read config for generate commands (features path)
  - [x] Doctor command validates configuration
  - [x] Use config for directory paths

---

## Phase 5: Documentation & Testing

### 5.1 Documentation

- [ ] **5.1.1** Create comprehensive `README.md`
  - [ ] Installation instructions
  - [ ] Quick start guide
  - [ ] CLI command reference
  - [ ] Lint rule reference
  - [ ] Configuration reference

- [ ] **5.1.2** Create `CHANGELOG.md`
  - [ ] Document version 1.0.0 features

- [ ] **5.1.3** Add inline documentation
  - [ ] Document all public APIs
  - [ ] Add examples in doc comments

- [ ] **5.1.4** Update `docs/guidelines/` if needed
  - [ ] Add CLI usage examples
  - [ ] Add lint rule configuration examples

---

### 5.2 Testing

- [ ] **5.2.1** CLI command tests
  - [ ] Test `init` command in temp directory
  - [ ] Test `generate feature` command
  - [ ] Test `generate bloc` command
  - [ ] Test `doctor` command

- [ ] **5.2.2** Lint rule integration tests
  - [ ] Golden file tests for each rule
  - [ ] Test with real project structure

- [ ] **5.2.3** Template tests
  - [ ] Verify generated code is valid Dart
  - [ ] Verify generated structure matches spec

- [ ] **5.2.4** Code generator tests
  - [ ] Test DI generator output
  - [ ] Test with various annotation combinations

---

### 5.3 Example Project

- [ ] **5.3.1** Create `example/` directory
  - [ ] Sample Flutter project using the package
  - [ ] Demonstrate feature generation
  - [ ] Show lint rules in action
  - [ ] Show code generation usage

- [ ] **5.3.2** Add example README
  - [ ] Step-by-step usage guide
  - [ ] Expected output examples

---

## Phase 6: Publishing Preparation

### 6.1 Package Finalization

- [ ] **6.1.1** Run `dart pub publish --dry-run`
  - [ ] Fix any publishing warnings
  - [ ] Verify package score

- [ ] **6.1.2** Add `LICENSE` file
  - [ ] Choose appropriate license (MIT recommended)

- [ ] **6.1.3** Verify `pubspec.yaml` metadata
  - [ ] Homepage URL
  - [ ] Repository URL
  - [ ] Issue tracker URL
  - [ ] Topics/keywords

- [ ] **6.1.4** Test global activation
  - [ ] `dart pub global activate --source path .`
  - [ ] Verify `clean_arch` command works globally

- [ ] **6.1.5** Create release tag
  - [ ] Tag version 1.0.0
  - [ ] Publish to pub.dev

---

## Summary Checklist

### Phase 1: Package Foundation ✅
- [x] 1.1 Project Structure Setup (7 tasks)
- [x] 1.2 Base Classes Implementation (6 tasks)
- [x] 1.3 CLI Foundation (8 tasks)
- [x] 1.4 Inline Templates (7 tasks)

### Phase 2: Custom Lint Rules ✅
- [x] 2.1 Lint Plugin Setup (3 tasks)
- [x] 2.2 Entity Rules (6 tasks)
- [x] 2.3 Model Rules (3 tasks)
- [x] 2.4 Repository Rules (3 tasks)
- [x] 2.5 Import Restriction Rules (4 tasks)
- [x] 2.6 DI Rules (3 tasks)
- [x] 2.7 BLoC/Cubit Rules (3 tasks)

### Phase 3: Code Generators ✅
- [x] 3.1 DI Registration Generator (4 tasks)
- [x] 3.2 Route Generator (3 tasks)

### Phase 4: Configuration System ✅
- [x] 4.1 Configuration File Support (4 tasks)

### Phase 5: Documentation & Testing
- [ ] 5.1 Documentation (4 tasks)
- [ ] 5.2 Testing (4 tasks)
- [ ] 5.3 Example Project (2 tasks)

### Phase 6: Publishing Preparation
- [ ] 6.1 Package Finalization (5 tasks)

---

**Total Tasks:** 82 tasks across 6 phases
