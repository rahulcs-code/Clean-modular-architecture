/// Clean Modular Architecture Framework
///
/// A Flutter framework that enforces Clean Architecture patterns through:
/// - CLI tooling for code generation
/// - Custom lint rules for architecture enforcement
/// - Base classes for common patterns
/// - Code generators for DI and routing
///
/// ## Installation
///
/// Add to your `pubspec.yaml`:
/// ```yaml
/// dev_dependencies:
///   clean_modular_architecture: ^1.0.0
///   custom_lint: ^0.6.0
/// ```
///
/// ## Usage
///
/// ### CLI Commands
/// ```bash
/// # Initialize in existing project
/// dart run clean_arch init
///
/// # Generate a complete feature
/// dart run clean_arch generate feature auth
///
/// # Generate individual components
/// dart run clean_arch generate bloc login --feature auth
/// ```
///
/// ### Base Classes
/// ```dart
/// import 'package:clean_modular_architecture/clean_modular_architecture.dart';
///
/// class LoginWithEmail implements UseCase<User, LoginParams> {
///   @override
///   Future<Either<Failure, User>> call(LoginParams params) async {
///     // implementation
///   }
/// }
/// ```
library clean_modular_architecture;

import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'src/lints/plugin.dart';

// Base classes
export 'src/base/use_case.dart';
export 'src/base/failure.dart';
export 'src/base/exceptions.dart';
export 'src/base/no_params.dart';

// Annotations for code generation
export 'src/generators/annotations.dart';

// Configuration
export 'src/config/cma_config.dart';

/// Entry point for custom_lint plugin.
PluginBase createPlugin() => CleanArchLintPlugin();
