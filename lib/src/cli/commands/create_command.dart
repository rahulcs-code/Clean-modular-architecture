import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;
import '../utils/logger.dart';
import '../utils/file_utils.dart';

/// Command to create a new Flutter project with Clean Modular Architecture.
///
/// Usage:
/// ```bash
/// dart run clean_arch create my_app
/// dart run clean_arch create my_app --org com.example
/// ```
class CreateCommand extends Command<int> {
  @override
  final String name = 'create';

  @override
  final String description = 'Create a new Flutter project with Clean Modular Architecture structure.';

  CreateCommand() {
    argParser
      ..addOption(
        'org',
        abbr: 'o',
        defaultsTo: 'com.example',
        help: 'Organization name for the Flutter project.',
      )
      ..addOption(
        'description',
        abbr: 'd',
        defaultsTo: 'A new Flutter project with Clean Architecture',
        help: 'Description for the project.',
      )
      ..addFlag(
        'offline',
        negatable: false,
        help: 'Create project without fetching dependencies.',
      );
  }

  @override
  Future<int> run() async {
    final args = argResults!.rest;
    if (args.isEmpty) {
      logger.error('Please provide a project name.');
      logger.command('dart run clean_arch create <project_name>');
      return 1;
    }

    final projectName = args.first;
    final org = argResults?['org'] as String;
    final description = argResults?['description'] as String;
    final offline = argResults?['offline'] as bool? ?? false;

    // Validate project name
    if (!_isValidProjectName(projectName)) {
      logger.error('Invalid project name. Use lowercase letters, numbers, and underscores only.');
      return 1;
    }

    final projectPath = path.join(Directory.current.path, projectName);

    // Check if directory already exists
    if (Directory(projectPath).existsSync()) {
      logger.error('Directory "$projectName" already exists.');
      return 1;
    }

    logger.header('Creating Flutter project with Clean Modular Architecture');

    // Create Flutter project
    logger.progress('Creating Flutter project...');
    final flutterResult = await Process.run(
      'flutter',
      [
        'create',
        '--org',
        org,
        '--description',
        description,
        if (offline) '--offline',
        projectName,
      ],
      workingDirectory: Directory.current.path,
    );

    if (flutterResult.exitCode != 0) {
      logger.error('Failed to create Flutter project:');
      logger.error(flutterResult.stderr.toString());
      return 1;
    }
    logger.success('Flutter project created');

    // Create CMA directory structure
    logger.progress('Creating Clean Architecture structure...');
    await _createDirectoryStructure(projectPath);
    logger.success('Directory structure created');

    // Create configuration file
    logger.progress('Creating configuration file...');
    await _createConfigFile(projectPath);
    logger.success('Configuration file created');

    // Create core files
    logger.progress('Creating core files...');
    await _createCoreFiles(projectPath, projectName);
    logger.success('Core files created');

    // Update pubspec.yaml
    logger.progress('Updating pubspec.yaml...');
    await _updatePubspec(projectPath, projectName, description);
    logger.success('pubspec.yaml updated');

    // Update analysis_options.yaml
    logger.progress('Updating analysis_options.yaml...');
    await _updateAnalysisOptions(projectPath);
    logger.success('analysis_options.yaml updated');

    // Update main.dart
    logger.progress('Updating main.dart...');
    await _updateMainDart(projectPath, projectName);
    logger.success('main.dart updated');

    logger.newLine();
    logger.success('Project "$projectName" created successfully!');
    logger.newLine();
    logger.info('Next steps:');
    logger.list(['Navigate to the project:']);
    logger.command('cd $projectName');
    logger.list(['Get dependencies:']);
    logger.command('flutter pub get');
    logger.list(['Generate your first feature:']);
    logger.command('dart run clean_arch generate feature auth');

    return 0;
  }

  bool _isValidProjectName(String name) {
    return RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(name);
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

  Future<void> _createConfigFile(String projectPath) async {
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

    await FileUtils.createFile(path.join(projectPath, 'cma.yaml'), content);
  }

  Future<void> _createCoreFiles(String projectPath, String projectName) async {
    // Create exceptions.dart
    await FileUtils.createFile(
      path.join(projectPath, 'lib/core/errors/exceptions.dart'),
      '''
/// Data layer exceptions.
///
/// Exceptions are thrown by data sources and caught by repositories.

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
''',
    );

    // Create failures.dart
    await FileUtils.createFile(
      path.join(projectPath, 'lib/core/errors/failures.dart'),
      '''
/// Domain layer failures.
///
/// Failures are returned from repositories via Either<Failure, Success>.

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
''',
    );

    // Create injection_container.dart
    await FileUtils.createFile(
      path.join(projectPath, 'lib/core/injection_container/injection_container.dart'),
      '''
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

  // ============================================================================
  // GLOBAL CUBITS
  // ============================================================================

  // TODO: Register global cubits here

  // ============================================================================
  // FEATURES
  // ============================================================================

  // Feature registrations will be added here by the CLI
}
''',
    );
  }

  Future<void> _updatePubspec(
    String projectPath,
    String projectName,
    String description,
  ) async {
    final pubspecPath = path.join(projectPath, 'pubspec.yaml');
    final pubspecFile = File(pubspecPath);
    var content = await pubspecFile.readAsString();

    // Add dependencies
    const dependencies = '''
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  # Clean Architecture dependencies
  fpdart: ^1.1.0
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  get_it: ^7.6.0
''';

    const devDependencies = '''
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  clean_modular_architecture: ^1.0.0
  custom_lint: ^0.6.0
  mocktail: ^1.0.0
''';

    // Replace dependencies section
    content = content.replaceFirst(
      RegExp(r'dependencies:[\s\S]*?(?=dev_dependencies:|flutter:[\s]*test:|$)'),
      '$dependencies\n',
    );

    // Replace dev_dependencies section
    content = content.replaceFirst(
      RegExp(r'dev_dependencies:[\s\S]*?(?=flutter:[\s]*sdk:|$)'),
      '$devDependencies\n',
    );

    await pubspecFile.writeAsString(content);
  }

  Future<void> _updateAnalysisOptions(String projectPath) async {
    final content = '''
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

    await FileUtils.createFile(
      path.join(projectPath, 'analysis_options.yaml'),
      content,
    );
  }

  Future<void> _updateMainDart(String projectPath, String projectName) async {
    final pascalName = FileUtils.toPascalCase(projectName);

    final content = '''
import 'package:flutter/material.dart';
import 'core/injection_container/injection_container.dart' as di;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await di.init();

  runApp(const ${pascalName}App());
}

class ${pascalName}App extends StatelessWidget {
  const ${pascalName}App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '$pascalName',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Welcome to $pascalName!'),
        ),
      ),
    );
  }
}
''';

    await FileUtils.createFile(
      path.join(projectPath, 'lib/main.dart'),
      content,
    );
  }
}
