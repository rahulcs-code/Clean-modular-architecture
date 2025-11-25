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

    // Install dependencies using pub add
    logger.progress('Installing dependencies...');
    await _installDependencies(projectPath);
    logger.success('Dependencies installed');

    // Update analysis_options.yaml
    logger.progress('Updating analysis_options.yaml...');
    await _updateAnalysisOptions(projectPath);
    logger.success('analysis_options.yaml updated');

    // Update main.dart
    logger.progress('Updating main.dart...');
    await _updateMainDart(projectPath, projectName);
    logger.success('main.dart updated');

    // Create sample feature
    logger.progress('Creating sample feature...');
    await _createSampleFeature(projectPath, projectName);
    logger.success('Sample feature created');

    logger.newLine();
    logger.success('Project "$projectName" created successfully!');
    logger.newLine();
    logger.info('Next steps:');
    logger.list(['Navigate to the project:']);
    logger.command('cd $projectName');
    logger.list(['Get dependencies:']);
    logger.command('flutter pub get');
    logger.list(['Run the app:']);
    logger.command('flutter run');

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

  Future<void> _installDependencies(String projectPath) async {
    // Install production dependencies using flutter pub add
    final prodDeps = [
      'fpdart',
      'flutter_bloc',
      'equatable',
      'get_it',
      'go_router',
    ];

    logger.info('Adding production dependencies...');
    final prodResult = await Process.run(
      'flutter',
      ['pub', 'add', ...prodDeps],
      workingDirectory: projectPath,
    );

    if (prodResult.exitCode != 0) {
      logger.warning('Some dependencies may not have been added: ${prodResult.stderr}');
    }

    // Install dev dependencies using flutter pub add --dev
    final devDeps = [
      'clean_modular_architecture',
      'custom_lint',
      'mocktail',
      'bloc_test',
    ];

    logger.info('Adding dev dependencies...');
    final devResult = await Process.run(
      'flutter',
      ['pub', 'add', '--dev', ...devDeps],
      workingDirectory: projectPath,
    );

    if (devResult.exitCode != 0) {
      logger.warning('Some dev dependencies may not have been added: ${devResult.stderr}');
    }
  }

  Future<void> _updateAnalysisOptions(String projectPath) async {
    const content = '''
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

  Future<void> _createSampleFeature(String projectPath, String projectName) async {
    final featurePath = path.join(projectPath, 'lib/features/home');

    // Create feature directories
    final dirs = [
      'domain/entities',
      'domain/repositories',
      'domain/usecases',
      'data/models',
      'data/datasources',
      'data/repositories',
      'presentation/bloc',
      'presentation/pages',
      'presentation/widgets',
    ];

    for (final dir in dirs) {
      await FileUtils.ensureDirectory(path.join(featurePath, dir));
    }

    // Create sample entity
    await FileUtils.createFile(
      path.join(featurePath, 'domain/entities/greeting.dart'),
      '''
/// Sample entity demonstrating Clean Architecture principles.
///
/// Entities are pure data containers with:
/// - Only final fields
/// - A const constructor
/// - No methods (except toString)
/// - No copyWith, fromJson, toJson
class Greeting {
  final String message;
  final DateTime timestamp;

  const Greeting({
    required this.message,
    required this.timestamp,
  });
}
''',
    );

    // Create sample model
    await FileUtils.createFile(
      path.join(featurePath, 'data/models/greeting_model.dart'),
      '''
import '../../domain/entities/greeting.dart';

/// Model extending the Greeting entity.
///
/// Models contain all the logic entities don't have:
/// - fromJson/toJson for serialization
/// - copyWith for immutable updates
/// - Any computed properties
class GreetingModel extends Greeting {
  const GreetingModel({
    required super.message,
    required super.timestamp,
  });

  factory GreetingModel.fromJson(Map<String, dynamic> json) {
    return GreetingModel(
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  GreetingModel copyWith({
    String? message,
    DateTime? timestamp,
  }) {
    return GreetingModel(
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Sample factory for creating a welcome greeting.
  static GreetingModel welcome() {
    return GreetingModel(
      message: 'Welcome to Clean Architecture!',
      timestamp: DateTime.now(),
    );
  }
}
''',
    );

    // Create sample repository interface
    await FileUtils.createFile(
      path.join(featurePath, 'domain/repositories/home_repository.dart'),
      '''
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/greeting.dart';

/// Repository interface for home feature.
///
/// Note: Returns Entity types (Greeting), not Model types (GreetingModel).
/// The implementation in data layer will return GreetingModel which extends Greeting.
abstract interface class HomeRepository {
  /// Gets the current greeting.
  Future<Either<Failure, Greeting>> getGreeting();
}
''',
    );

    // Create sample repository implementation
    await FileUtils.createFile(
      path.join(featurePath, 'data/repositories/home_repository_impl.dart'),
      '''
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/home_repository.dart';
import '../models/greeting_model.dart';

/// Implementation of [HomeRepository].
///
/// Note: Returns GreetingModel which extends Greeting,
/// satisfying the interface contract.
class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl();

  @override
  Future<Either<Failure, GreetingModel>> getGreeting() async {
    try {
      // In a real app, this might fetch from an API or database
      final greeting = GreetingModel.welcome();
      return Right(greeting);
    } catch (e) {
      return const Left(ServerFailure('Failed to get greeting'));
    }
  }
}
''',
    );

    // Create sample use case
    await FileUtils.createFile(
      path.join(featurePath, 'domain/usecases/get_greeting.dart'),
      '''
import 'package:fpdart/fpdart.dart';
import 'package:clean_modular_architecture/clean_modular_architecture.dart';
import '../../../../core/errors/failures.dart';
import '../entities/greeting.dart';
import '../repositories/home_repository.dart';

/// Use case for getting the greeting.
///
/// Use cases contain business logic and orchestrate
/// data flow between repositories and the presentation layer.
class GetGreeting implements UseCase<Greeting, NoParams> {
  final HomeRepository repository;

  GetGreeting(this.repository);

  @override
  Future<Either<Failure, Greeting>> call(NoParams params) async {
    return repository.getGreeting();
  }
}
''',
    );

    // Create sample BLoC
    await FileUtils.createFile(
      path.join(featurePath, 'presentation/bloc/home_bloc.dart'),
      '''
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clean_modular_architecture/clean_modular_architecture.dart';
import '../../domain/entities/greeting.dart';
import '../../domain/usecases/get_greeting.dart';

part 'home_event.dart';
part 'home_state.dart';

/// BLoC for the home feature.
///
/// Handles loading and displaying the greeting.
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetGreeting getGreeting;

  HomeBloc({required this.getGreeting}) : super(HomeInitial()) {
    on<HomeLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(
    HomeLoadRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());

    final result = await getGreeting(const NoParams());

    result.fold(
      (failure) => emit(HomeError(failure.message)),
      (greeting) => emit(HomeLoaded(greeting)),
    );
  }
}
''',
    );

    // Create BLoC events
    await FileUtils.createFile(
      path.join(featurePath, 'presentation/bloc/home_event.dart'),
      '''
part of 'home_bloc.dart';

/// Base class for home events.
sealed class HomeEvent {}

/// Event to request loading the home data.
final class HomeLoadRequested extends HomeEvent {}
''',
    );

    // Create BLoC states
    await FileUtils.createFile(
      path.join(featurePath, 'presentation/bloc/home_state.dart'),
      '''
part of 'home_bloc.dart';

/// Base class for home states.
sealed class HomeState {}

/// Initial state before any data is loaded.
final class HomeInitial extends HomeState {}

/// State while data is being loaded.
final class HomeLoading extends HomeState {}

/// State when data has been successfully loaded.
final class HomeLoaded extends HomeState {
  final Greeting greeting;

  HomeLoaded(this.greeting);
}

/// State when an error occurred.
final class HomeError extends HomeState {
  final String message;

  HomeError(this.message);
}
''',
    );

    // Create sample page
    await FileUtils.createFile(
      path.join(featurePath, 'presentation/pages/home_page.dart'),
      '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/home_bloc.dart';

/// Home page demonstrating Clean Architecture.
///
/// Uses BlocBuilder to reactively render UI based on state.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clean Architecture'),
        centerTitle: true,
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return switch (state) {
            HomeInitial() => const _InitialView(),
            HomeLoading() => const _LoadingView(),
            HomeLoaded(:final greeting) => _LoadedView(message: greeting.message),
            HomeError(:final message) => _ErrorView(message: message),
          };
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<HomeBloc>().add(HomeLoadRequested());
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

class _InitialView extends StatelessWidget {
  const _InitialView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Press the button to load greeting'),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class _LoadedView extends StatelessWidget {
  final String message;

  const _LoadedView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          message,
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
''',
    );
  }
}
