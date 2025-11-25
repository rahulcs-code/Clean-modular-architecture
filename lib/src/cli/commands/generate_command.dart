import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;
import '../utils/logger.dart';
import '../utils/file_utils.dart';
import '../templates/feature_template.dart';
import '../templates/bloc_template.dart';
import '../templates/cubit_template.dart';
import '../templates/repository_template.dart';
import '../templates/entity_template.dart';
import '../templates/model_template.dart';
import '../templates/use_case_template.dart';

/// Command to generate architecture components.
///
/// Usage:
/// ```bash
/// dart run clean_arch generate feature auth
/// dart run clean_arch generate bloc login --feature auth
/// dart run clean_arch generate cubit theme --global
/// dart run clean_arch generate repository user --feature auth
/// dart run clean_arch generate entity user --feature auth
/// dart run clean_arch generate model user --feature auth
/// dart run clean_arch generate usecase login --feature auth
/// ```
class GenerateCommand extends Command<int> {
  @override
  final String name = 'generate';

  @override
  final String description = 'Generate architecture components (feature, bloc, cubit, repository, entity, model, usecase).';

  @override
  final List<String> aliases = ['g'];

  GenerateCommand() {
    addSubcommand(_GenerateFeatureCommand());
    addSubcommand(_GenerateBlocCommand());
    addSubcommand(_GenerateCubitCommand());
    addSubcommand(_GenerateRepositoryCommand());
    addSubcommand(_GenerateEntityCommand());
    addSubcommand(_GenerateModelCommand());
    addSubcommand(_GenerateUseCaseCommand());
  }
}

/// Generates a complete feature module.
class _GenerateFeatureCommand extends Command<int> {
  @override
  final String name = 'feature';

  @override
  final String description = 'Generate a complete feature module with all layers.';

  _GenerateFeatureCommand() {
    argParser
      ..addOption(
        'path',
        abbr: 'p',
        help: 'Path to the Flutter project (defaults to current directory).',
      )
      ..addFlag(
        'bloc',
        defaultsTo: true,
        help: 'Use BLoC for state management (default: true).',
      )
      ..addFlag(
        'cubit',
        negatable: false,
        help: 'Use Cubit for state management instead of BLoC.',
      );
  }

  @override
  Future<int> run() async {
    final args = argResults!.rest;
    if (args.isEmpty) {
      logger.error('Please provide a feature name.');
      logger.command('dart run clean_arch generate feature <name>');
      return 1;
    }

    final featureName = args.first;
    final projectPath = argResults?['path'] as String? ?? Directory.current.path;
    final useCubit = argResults?['cubit'] as bool? ?? false;

    logger.header('Generating Feature: $featureName');

    final projectRoot = FileUtils.findProjectRoot(projectPath);
    if (projectRoot == null) {
      logger.error('No Flutter project found. Run this command from a Flutter project directory.');
      return 1;
    }

    final projectName = FileUtils.getProjectName(projectRoot) ?? 'app';
    final featureSnake = FileUtils.toSnakeCase(featureName);
    final featurePascal = FileUtils.toPascalCase(featureName);
    final featurePath = path.join(projectRoot, 'lib/features', featureSnake);

    // Check if feature already exists
    if (Directory(featurePath).existsSync()) {
      logger.error('Feature "$featureName" already exists at: $featurePath');
      return 1;
    }

    // Create feature structure
    logger.progress('Creating feature structure...');
    await FeatureTemplate.generate(
      featurePath: featurePath,
      featureName: featurePascal,
      featureSnake: featureSnake,
      projectName: projectName,
      useCubit: useCubit,
    );

    logger.success('Feature "$featureName" generated successfully!');
    logger.newLine();
    logger.info('Generated structure:');
    logger.list([
      'lib/features/$featureSnake/',
      '  ├── domain/',
      '  │   ├── entities/',
      '  │   ├── repositories/',
      '  │   └── usecases/',
      '  ├── data/',
      '  │   ├── models/',
      '  │   ├── datasources/',
      '  │   └── repositories/',
      '  └── presentation/',
      '      ├── ${useCubit ? 'cubits' : 'blocs'}/',
      '      ├── pages/',
      '      └── widgets/',
    ]);

    logger.newLine();
    logger.info('Next steps:');
    logger.list([
      'Register the feature in lib/core/injection_container/injection_container.dart',
    ]);

    return 0;
  }
}

/// Generates a BLoC.
class _GenerateBlocCommand extends Command<int> {
  @override
  final String name = 'bloc';

  @override
  final String description = 'Generate a BLoC with events and states.';

  _GenerateBlocCommand() {
    argParser
      ..addOption(
        'feature',
        abbr: 'f',
        help: 'Feature to add the bloc to (required).',
      )
      ..addFlag(
        'global',
        abbr: 'g',
        negatable: false,
        help: 'Create a global cubit in lib/core/common/cubits.',
      )
      ..addOption(
        'path',
        abbr: 'p',
        help: 'Path to the Flutter project (defaults to current directory).',
      );
  }

  @override
  Future<int> run() async {
    final args = argResults!.rest;
    if (args.isEmpty) {
      logger.error('Please provide a bloc name.');
      logger.command('dart run clean_arch generate bloc <name> --feature <feature>');
      return 1;
    }

    final blocName = args.first;
    final featureName = argResults?['feature'] as String?;
    final isGlobal = argResults?['global'] as bool? ?? false;
    final projectPath = argResults?['path'] as String? ?? Directory.current.path;

    if (!isGlobal && featureName == null) {
      logger.error('Please provide a feature name with --feature or use --global.');
      return 1;
    }

    logger.header('Generating BLoC: $blocName');

    final projectRoot = FileUtils.findProjectRoot(projectPath);
    if (projectRoot == null) {
      logger.error('No Flutter project found.');
      return 1;
    }

    final projectName = FileUtils.getProjectName(projectRoot) ?? 'app';
    final blocSnake = FileUtils.toSnakeCase(blocName);
    final blocPascal = FileUtils.toPascalCase(blocName);

    String blocPath;
    if (isGlobal) {
      blocPath = path.join(projectRoot, 'lib/core/common/blocs', blocSnake);
    } else {
      final featureSnake = FileUtils.toSnakeCase(featureName!);
      blocPath = path.join(projectRoot, 'lib/features', featureSnake, 'presentation/blocs', blocSnake);
    }

    await BlocTemplate.generate(
      blocPath: blocPath,
      blocName: blocPascal,
      blocSnake: blocSnake,
      projectName: projectName,
      featureName: featureName != null ? FileUtils.toSnakeCase(featureName) : null,
    );

    logger.success('BLoC "$blocName" generated at: $blocPath');
    return 0;
  }
}

/// Generates a Cubit.
class _GenerateCubitCommand extends Command<int> {
  @override
  final String name = 'cubit';

  @override
  final String description = 'Generate a Cubit with state.';

  _GenerateCubitCommand() {
    argParser
      ..addOption(
        'feature',
        abbr: 'f',
        help: 'Feature to add the cubit to.',
      )
      ..addFlag(
        'global',
        abbr: 'g',
        negatable: false,
        help: 'Create a global cubit in lib/core/common/cubits.',
      )
      ..addOption(
        'path',
        abbr: 'p',
        help: 'Path to the Flutter project (defaults to current directory).',
      );
  }

  @override
  Future<int> run() async {
    final args = argResults!.rest;
    if (args.isEmpty) {
      logger.error('Please provide a cubit name.');
      logger.command('dart run clean_arch generate cubit <name> --feature <feature>');
      return 1;
    }

    final cubitName = args.first;
    final featureName = argResults?['feature'] as String?;
    final isGlobal = argResults?['global'] as bool? ?? false;
    final projectPath = argResults?['path'] as String? ?? Directory.current.path;

    if (!isGlobal && featureName == null) {
      logger.error('Please provide a feature name with --feature or use --global.');
      return 1;
    }

    logger.header('Generating Cubit: $cubitName');

    final projectRoot = FileUtils.findProjectRoot(projectPath);
    if (projectRoot == null) {
      logger.error('No Flutter project found.');
      return 1;
    }

    final projectName = FileUtils.getProjectName(projectRoot) ?? 'app';
    final cubitSnake = FileUtils.toSnakeCase(cubitName);
    final cubitPascal = FileUtils.toPascalCase(cubitName);

    String cubitPath;
    if (isGlobal) {
      cubitPath = path.join(projectRoot, 'lib/core/common/cubits', cubitSnake);
    } else {
      final featureSnake = FileUtils.toSnakeCase(featureName!);
      cubitPath = path.join(projectRoot, 'lib/features', featureSnake, 'presentation/cubits', cubitSnake);
    }

    await CubitTemplate.generate(
      cubitPath: cubitPath,
      cubitName: cubitPascal,
      cubitSnake: cubitSnake,
      projectName: projectName,
      featureName: featureName != null ? FileUtils.toSnakeCase(featureName) : null,
    );

    logger.success('Cubit "$cubitName" generated at: $cubitPath');
    return 0;
  }
}

/// Generates a Repository.
class _GenerateRepositoryCommand extends Command<int> {
  @override
  final String name = 'repository';

  @override
  final String description = 'Generate a repository interface and implementation.';

  @override
  final List<String> aliases = ['repo'];

  _GenerateRepositoryCommand() {
    argParser
      ..addOption(
        'feature',
        abbr: 'f',
        mandatory: true,
        help: 'Feature to add the repository to (required).',
      )
      ..addOption(
        'path',
        abbr: 'p',
        help: 'Path to the Flutter project (defaults to current directory).',
      );
  }

  @override
  Future<int> run() async {
    final args = argResults!.rest;
    if (args.isEmpty) {
      logger.error('Please provide a repository name.');
      logger.command('dart run clean_arch generate repository <name> --feature <feature>');
      return 1;
    }

    final repoName = args.first;
    final featureName = argResults!['feature'] as String;
    final projectPath = argResults?['path'] as String? ?? Directory.current.path;

    logger.header('Generating Repository: $repoName');

    final projectRoot = FileUtils.findProjectRoot(projectPath);
    if (projectRoot == null) {
      logger.error('No Flutter project found.');
      return 1;
    }

    final projectName = FileUtils.getProjectName(projectRoot) ?? 'app';
    final repoSnake = FileUtils.toSnakeCase(repoName);
    final repoPascal = FileUtils.toPascalCase(repoName);
    final featureSnake = FileUtils.toSnakeCase(featureName);

    await RepositoryTemplate.generate(
      projectRoot: projectRoot,
      featureSnake: featureSnake,
      repoName: repoPascal,
      repoSnake: repoSnake,
      projectName: projectName,
    );

    logger.success('Repository "$repoName" generated!');
    logger.info('Interface: lib/features/$featureSnake/domain/repositories/${repoSnake}_repository.dart');
    logger.info('Implementation: lib/features/$featureSnake/data/repositories/${repoSnake}_repository_impl.dart');
    return 0;
  }
}

/// Generates an Entity.
class _GenerateEntityCommand extends Command<int> {
  @override
  final String name = 'entity';

  @override
  final String description = 'Generate a domain entity.';

  _GenerateEntityCommand() {
    argParser
      ..addOption(
        'feature',
        abbr: 'f',
        mandatory: true,
        help: 'Feature to add the entity to (required).',
      )
      ..addOption(
        'path',
        abbr: 'p',
        help: 'Path to the Flutter project (defaults to current directory).',
      );
  }

  @override
  Future<int> run() async {
    final args = argResults!.rest;
    if (args.isEmpty) {
      logger.error('Please provide an entity name.');
      logger.command('dart run clean_arch generate entity <name> --feature <feature>');
      return 1;
    }

    final entityName = args.first;
    final featureName = argResults!['feature'] as String;
    final projectPath = argResults?['path'] as String? ?? Directory.current.path;

    logger.header('Generating Entity: $entityName');

    final projectRoot = FileUtils.findProjectRoot(projectPath);
    if (projectRoot == null) {
      logger.error('No Flutter project found.');
      return 1;
    }

    final entitySnake = FileUtils.toSnakeCase(entityName);
    final entityPascal = FileUtils.toPascalCase(entityName);
    final featureSnake = FileUtils.toSnakeCase(featureName);

    await EntityTemplate.generate(
      projectRoot: projectRoot,
      featureSnake: featureSnake,
      entityName: entityPascal,
      entitySnake: entitySnake,
    );

    logger.success('Entity "$entityName" generated at: lib/features/$featureSnake/domain/entities/${entitySnake}.dart');
    return 0;
  }
}

/// Generates a Model.
class _GenerateModelCommand extends Command<int> {
  @override
  final String name = 'model';

  @override
  final String description = 'Generate a data model that extends an entity.';

  _GenerateModelCommand() {
    argParser
      ..addOption(
        'feature',
        abbr: 'f',
        mandatory: true,
        help: 'Feature to add the model to (required).',
      )
      ..addOption(
        'entity',
        abbr: 'e',
        help: 'Entity that this model extends (defaults to model name).',
      )
      ..addOption(
        'path',
        abbr: 'p',
        help: 'Path to the Flutter project (defaults to current directory).',
      );
  }

  @override
  Future<int> run() async {
    final args = argResults!.rest;
    if (args.isEmpty) {
      logger.error('Please provide a model name.');
      logger.command('dart run clean_arch generate model <name> --feature <feature>');
      return 1;
    }

    final modelName = args.first;
    final featureName = argResults!['feature'] as String;
    final entityName = argResults?['entity'] as String? ?? modelName;
    final projectPath = argResults?['path'] as String? ?? Directory.current.path;

    logger.header('Generating Model: $modelName');

    final projectRoot = FileUtils.findProjectRoot(projectPath);
    if (projectRoot == null) {
      logger.error('No Flutter project found.');
      return 1;
    }

    final projectName = FileUtils.getProjectName(projectRoot) ?? 'app';
    final modelSnake = FileUtils.toSnakeCase(modelName);
    final modelPascal = FileUtils.toPascalCase(modelName);
    final entitySnake = FileUtils.toSnakeCase(entityName);
    final entityPascal = FileUtils.toPascalCase(entityName);
    final featureSnake = FileUtils.toSnakeCase(featureName);

    await ModelTemplate.generate(
      projectRoot: projectRoot,
      featureSnake: featureSnake,
      modelName: modelPascal,
      modelSnake: modelSnake,
      entityName: entityPascal,
      entitySnake: entitySnake,
      projectName: projectName,
    );

    logger.success('Model "$modelName" generated at: lib/features/$featureSnake/data/models/${modelSnake}_model.dart');
    return 0;
  }
}

/// Generates a UseCase.
class _GenerateUseCaseCommand extends Command<int> {
  @override
  final String name = 'usecase';

  @override
  final String description = 'Generate a use case.';

  @override
  final List<String> aliases = ['uc'];

  _GenerateUseCaseCommand() {
    argParser
      ..addOption(
        'feature',
        abbr: 'f',
        mandatory: true,
        help: 'Feature to add the use case to (required).',
      )
      ..addFlag(
        'sync',
        negatable: false,
        help: 'Generate a synchronous use case.',
      )
      ..addFlag(
        'stream',
        negatable: false,
        help: 'Generate a stream use case.',
      )
      ..addOption(
        'path',
        abbr: 'p',
        help: 'Path to the Flutter project (defaults to current directory).',
      );
  }

  @override
  Future<int> run() async {
    final args = argResults!.rest;
    if (args.isEmpty) {
      logger.error('Please provide a use case name.');
      logger.command('dart run clean_arch generate usecase <name> --feature <feature>');
      return 1;
    }

    final useCaseName = args.first;
    final featureName = argResults!['feature'] as String;
    final isSync = argResults?['sync'] as bool? ?? false;
    final isStream = argResults?['stream'] as bool? ?? false;
    final projectPath = argResults?['path'] as String? ?? Directory.current.path;

    logger.header('Generating UseCase: $useCaseName');

    final projectRoot = FileUtils.findProjectRoot(projectPath);
    if (projectRoot == null) {
      logger.error('No Flutter project found.');
      return 1;
    }

    final projectName = FileUtils.getProjectName(projectRoot) ?? 'app';
    final useCaseSnake = FileUtils.toSnakeCase(useCaseName);
    final useCasePascal = FileUtils.toPascalCase(useCaseName);
    final featureSnake = FileUtils.toSnakeCase(featureName);

    String useCaseType = 'async';
    if (isSync) useCaseType = 'sync';
    if (isStream) useCaseType = 'stream';

    await UseCaseTemplate.generate(
      projectRoot: projectRoot,
      featureSnake: featureSnake,
      useCaseName: useCasePascal,
      useCaseSnake: useCaseSnake,
      projectName: projectName,
      useCaseType: useCaseType,
    );

    logger.success('UseCase "$useCaseName" generated at: lib/features/$featureSnake/domain/usecases/${useCaseSnake}.dart');
    return 0;
  }
}
