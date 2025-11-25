import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;
import '../utils/logger.dart';
import '../utils/file_utils.dart';

/// Command to initialize Clean Modular Architecture in an existing project.
///
/// Usage:
/// ```bash
/// dart run clean_arch init
/// dart run clean_arch init --force
/// ```
class InitCommand extends Command<int> {
  @override
  final String name = 'init';

  @override
  final String description = 'Initialize Clean Modular Architecture in an existing Flutter project.';

  InitCommand() {
    argParser
      ..addFlag(
        'force',
        abbr: 'f',
        negatable: false,
        help: 'Overwrite existing configuration files.',
      )
      ..addOption(
        'path',
        abbr: 'p',
        help: 'Path to the Flutter project (defaults to current directory).',
      );
  }

  @override
  Future<int> run() async {
    final projectPath = argResults?['path'] as String? ?? Directory.current.path;
    final force = argResults?['force'] as bool? ?? false;

    logger.header('Initializing Clean Modular Architecture');

    // Verify this is a Flutter project
    final pubspecPath = path.join(projectPath, 'pubspec.yaml');
    if (!File(pubspecPath).existsSync()) {
      logger.error('No pubspec.yaml found. Are you in a Flutter project?');
      return 1;
    }

    // Create directory structure
    logger.progress('Creating directory structure...');
    await _createDirectoryStructure(projectPath);
    logger.success('Directory structure created');

    // Create configuration file
    logger.progress('Creating configuration file...');
    final configCreated = await _createConfigFile(projectPath, force);
    if (configCreated) {
      logger.success('Configuration file created: cma.yaml');
    } else {
      logger.warning('Configuration file already exists (use --force to overwrite)');
    }

    // Update analysis_options.yaml
    logger.progress('Updating analysis_options.yaml...');
    await _updateAnalysisOptions(projectPath, force);
    logger.success('Analysis options updated');

    // Create core error files
    logger.progress('Creating core error handling files...');
    await _createCoreErrorFiles(projectPath, force);
    logger.success('Core files created');

    // Create injection container
    logger.progress('Creating dependency injection container...');
    await _createInjectionContainer(projectPath, force);
    logger.success('Injection container created');

    logger.newLine();
    logger.success('Clean Modular Architecture initialized successfully!');
    logger.newLine();
    logger.info('Next steps:');
    logger.list([
      'Add required dependencies to pubspec.yaml:',
    ]);
    logger.command('flutter pub add flutter_bloc get_it fpdart');
    logger.list([
      'Add dev dependencies:',
    ]);
    logger.command('flutter pub add --dev clean_modular_architecture custom_lint');
    logger.list([
      'Generate your first feature:',
    ]);
    logger.command('dart run clean_arch generate feature auth');

    return 0;
  }

  Future<void> _createDirectoryStructure(String projectPath) async {
    final directories = [
      'lib/core/common/cubits',
      'lib/core/common/widgets',
      'lib/core/errors',
      'lib/core/injection_container',
      'lib/core/network',
      'lib/core/storage',
      'lib/core/utils',
      'lib/config/routes',
      'lib/config/theme',
      'lib/features',
    ];

    for (final dir in directories) {
      await FileUtils.ensureDirectory(path.join(projectPath, dir));
    }
  }

  Future<bool> _createConfigFile(String projectPath, bool force) async {
    final configPath = path.join(projectPath, 'cma.yaml');
    final configFile = File(configPath);

    if (configFile.existsSync() && !force) {
      return false;
    }

    const content = '''
# Clean Modular Architecture Configuration
# See: https://pub.dev/packages/clean_modular_architecture

clean_modular_architecture:
  # Project structure paths
  structure:
    features_path: lib/features
    core_path: lib/core

  # Naming conventions
  naming:
    entity_suffix: ""
    model_suffix: "Model"
    repository_suffix: "Repository"
    bloc_suffix: "Bloc"
    cubit_suffix: "Cubit"

  # Lint rule configuration
  lint:
    enabled: true
    severity:
      entity_no_methods: error
      entity_no_copywith: error
      entity_no_static: error
      entity_no_serialization: error
      model_extends_entity: error
      domain_no_data_imports: error
      domain_no_presentation_imports: error
      use_lazy_singleton_for_bloc: error

  # Template configuration
  templates:
    state_management: bloc    # bloc or cubit
    di_package: get_it        # get_it or injectable
''';

    await configFile.writeAsString(content);
    return true;
  }

  Future<void> _updateAnalysisOptions(String projectPath, bool force) async {
    final analysisPath = path.join(projectPath, 'analysis_options.yaml');
    final analysisFile = File(analysisPath);

    String content;
    if (analysisFile.existsSync()) {
      content = await analysisFile.readAsString();

      // Check if custom_lint is already configured
      if (content.contains('custom_lint') && !force) {
        return;
      }

      // Add custom_lint configuration if not present
      if (!content.contains('plugins:')) {
        content += '''

analyzer:
  plugins:
    - custom_lint

custom_lint:
  rules:
    - entity_no_methods
    - entity_no_copywith
    - entity_no_static
    - entity_no_serialization
    - model_extends_entity
    - domain_no_data_imports
    - domain_no_presentation_imports
    - use_lazy_singleton_for_bloc
''';
      }
    } else {
      content = '''
include: package:flutter_lints/flutter.yaml

analyzer:
  plugins:
    - custom_lint
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"

custom_lint:
  rules:
    - entity_no_methods
    - entity_no_copywith
    - entity_no_static
    - entity_no_serialization
    - model_extends_entity
    - domain_no_data_imports
    - domain_no_presentation_imports
    - use_lazy_singleton_for_bloc

linter:
  rules:
    - always_declare_return_types
    - prefer_const_constructors
    - prefer_final_fields
    - prefer_final_locals
''';
    }

    await analysisFile.writeAsString(content);
  }

  Future<void> _createCoreErrorFiles(String projectPath, bool force) async {
    final projectName = FileUtils.getProjectName(projectPath) ?? 'app';

    // Create exceptions.dart
    final exceptionsPath = path.join(projectPath, 'lib/core/errors/exceptions.dart');
    if (!File(exceptionsPath).existsSync() || force) {
      await FileUtils.createFile(exceptionsPath, '''
/// Data layer exceptions.
///
/// Exceptions are thrown by data sources and caught by repositories.
/// See: docs/guidelines/09_error_handling.md

abstract class AppException implements Exception {
  final String message;
  const AppException([this.message = 'An error occurred']);

  @override
  String toString() => '\$runtimeType: \$message';
}

class ServerException extends AppException {
  final int? statusCode;
  const ServerException([super.message = 'Server error', this.statusCode]);
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Network error']);
}

class CacheException extends AppException {
  const CacheException([super.message = 'Cache error']);
}

class AuthException extends AppException {
  const AuthException([super.message = 'Authentication error']);
}

class ValidationException extends AppException {
  final Map<String, List<String>>? errors;
  const ValidationException([super.message = 'Validation error', this.errors]);
}
''');
    }

    // Create failures.dart
    final failuresPath = path.join(projectPath, 'lib/core/errors/failures.dart');
    if (!File(failuresPath).existsSync() || force) {
      await FileUtils.createFile(failuresPath, '''
/// Domain layer failures.
///
/// Failures are returned from repositories via Either<Failure, Success>.
/// See: docs/guidelines/09_error_handling.md

abstract class Failure {
  final String message;
  const Failure([this.message = 'An unexpected error occurred']);

  @override
  String toString() => '\$runtimeType: \$message';
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error. Please try again later.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error. Please check your connection.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local storage error.']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed.']);
}

class ValidationFailure extends Failure {
  final Map<String, List<String>>? errors;
  const ValidationFailure([super.message = 'Validation failed.', this.errors]);
}
''');
    }
  }

  Future<void> _createInjectionContainer(String projectPath, bool force) async {
    final containerPath = path.join(
      projectPath,
      'lib/core/injection_container/injection_container.dart',
    );

    if (!File(containerPath).existsSync() || force) {
      await FileUtils.createFile(containerPath, '''
import 'package:get_it/get_it.dart';

/// Service locator instance.
final sl = GetIt.instance;

/// Initialize all dependencies.
///
/// Call this in main() before runApp().
Future<void> init() async {
  // ============================================================================
  // CORE SERVICES
  // ============================================================================

  // TODO: Register core services here
  // sl.registerLazySingleton<HttpService>(() => HttpService());

  // ============================================================================
  // GLOBAL CUBITS
  // ============================================================================

  // TODO: Register global cubits here
  // sl.registerLazySingleton(() => AuthCubit());
  // sl.registerLazySingleton(() => ThemeCubit());

  // ============================================================================
  // FEATURES
  // ============================================================================

  // Feature registrations will be added here by the CLI
}
''');
    }
  }
}
