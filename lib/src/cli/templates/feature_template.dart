import 'package:path/path.dart' as path;
import '../utils/file_utils.dart';

/// Template generator for complete feature modules.
class FeatureTemplate {
  /// Generates a complete feature structure.
  static Future<void> generate({
    required String featurePath,
    required String featureName,
    required String featureSnake,
    required String projectName,
    required bool useCubit,
  }) async {
    // Create directory structure
    final directories = [
      'domain/entities',
      'domain/repositories',
      'domain/usecases',
      'data/models',
      'data/datasources',
      'data/repositories',
      'presentation/${useCubit ? 'cubits' : 'blocs'}',
      'presentation/pages',
      'presentation/widgets',
    ];

    for (final dir in directories) {
      await FileUtils.ensureDirectory(path.join(featurePath, dir));
    }

    // Create barrel files
    await _createBarrelFile(featurePath, featureName, featureSnake, useCubit);

    // Create sample entity
    await _createSampleEntity(featurePath, featureName, featureSnake);

    // Create sample model
    await _createSampleModel(featurePath, featureName, featureSnake, projectName);

    // Create sample repository
    await _createSampleRepository(featurePath, featureName, featureSnake, projectName);

    // Create state management
    if (useCubit) {
      await _createSampleCubit(featurePath, featureName, featureSnake, projectName);
    } else {
      await _createSampleBloc(featurePath, featureName, featureSnake, projectName);
    }

    // Create sample page
    await _createSamplePage(featurePath, featureName, featureSnake, projectName, useCubit);

    // Create injection file
    await _createInjectionFile(featurePath, featureName, featureSnake, projectName, useCubit);
  }

  static Future<void> _createBarrelFile(
    String featurePath,
    String featureName,
    String featureSnake,
    bool useCubit,
  ) async {
    final content = '''
/// ${featureName} feature module.
///
/// This module contains:
/// - Domain layer: entities, repositories, use cases
/// - Data layer: models, data sources, repository implementations
/// - Presentation layer: ${useCubit ? 'cubits' : 'blocs'}, pages, widgets

// Domain
export 'domain/entities/${featureSnake}.dart';
export 'domain/repositories/${featureSnake}_repository.dart';

// Data
export 'data/models/${featureSnake}_model.dart';
export 'data/repositories/${featureSnake}_repository_impl.dart';

// Presentation
export 'presentation/${useCubit ? 'cubits' : 'blocs'}/${featureSnake}_${useCubit ? 'cubit' : 'bloc'}.dart';
export 'presentation/pages/${featureSnake}_page.dart';

// Injection
export '${featureSnake}_injection.dart';
''';

    await FileUtils.createFile(
      path.join(featurePath, '${featureSnake}_feature.dart'),
      content,
    );
  }

  static Future<void> _createSampleEntity(
    String featurePath,
    String featureName,
    String featureSnake,
  ) async {
    final content = '''
/// ${featureName} entity.
///
/// This is a domain entity - it should contain only data fields.
/// Do NOT add methods, copyWith, serialization, or static members.
///
/// See: docs/guidelines/02_entity_model_separation.md
class $featureName {
  final String id;
  final String name;
  final DateTime createdAt;

  const $featureName({
    required this.id,
    required this.name,
    required this.createdAt,
  });
}
''';

    await FileUtils.createFile(
      path.join(featurePath, 'domain/entities', '$featureSnake.dart'),
      content,
    );
  }

  static Future<void> _createSampleModel(
    String featurePath,
    String featureName,
    String featureSnake,
    String projectName,
  ) async {
    final content = '''
import '../../domain/entities/$featureSnake.dart';

/// ${featureName} data model.
///
/// This model extends the domain entity and adds data layer functionality:
/// - JSON serialization (fromJson/toJson)
/// - copyWith for immutable updates
/// - Any data transformation logic
///
/// See: docs/guidelines/02_entity_model_separation.md
class ${featureName}Model extends $featureName {
  const ${featureName}Model({
    required super.id,
    required super.name,
    required super.createdAt,
  });

  /// Creates a model from JSON data.
  factory ${featureName}Model.fromJson(Map<String, dynamic> json) {
    return ${featureName}Model(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Converts the model to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Creates a copy with optional new values.
  ${featureName}Model copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
  }) {
    return ${featureName}Model(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
''';

    await FileUtils.createFile(
      path.join(featurePath, 'data/models', '${featureSnake}_model.dart'),
      content,
    );
  }

  static Future<void> _createSampleRepository(
    String featurePath,
    String featureName,
    String featureSnake,
    String projectName,
  ) async {
    // Domain repository interface
    final interfaceContent = '''
import 'package:fpdart/fpdart.dart';
import 'package:$projectName/core/errors/failures.dart';
import '../entities/$featureSnake.dart';

/// Repository interface for $featureName operations.
///
/// This is a domain contract - implementations belong in the data layer.
/// Methods should return Entity types, not Model types.
///
/// See: docs/guidelines/05_repository_pattern.md
abstract class ${featureName}Repository {
  /// Gets a $featureName by ID.
  Future<Either<Failure, $featureName>> getById(String id);

  /// Gets all ${featureName}s.
  Future<Either<Failure, List<$featureName>>> getAll();

  /// Creates a new $featureName.
  Future<Either<Failure, $featureName>> create($featureName entity);

  /// Updates an existing $featureName.
  Future<Either<Failure, $featureName>> update($featureName entity);

  /// Deletes a $featureName by ID.
  Future<Either<Failure, void>> delete(String id);
}
''';

    await FileUtils.createFile(
      path.join(featurePath, 'domain/repositories', '${featureSnake}_repository.dart'),
      interfaceContent,
    );

    // Data repository implementation
    final implContent = '''
import 'package:fpdart/fpdart.dart';
import 'package:$projectName/core/errors/exceptions.dart';
import 'package:$projectName/core/errors/failures.dart';
import '../../domain/entities/$featureSnake.dart';
import '../../domain/repositories/${featureSnake}_repository.dart';
import '../models/${featureSnake}_model.dart';

/// Implementation of [${featureName}Repository].
///
/// This implementation:
/// - Catches exceptions and converts them to failures
/// - Can work with Models internally but returns Entities
/// - Handles data source coordination (remote/local)
class ${featureName}RepositoryImpl implements ${featureName}Repository {
  // TODO: Add data sources
  // final ${featureName}RemoteDataSource remoteDataSource;
  // final ${featureName}LocalDataSource localDataSource;

  const ${featureName}RepositoryImpl();

  @override
  Future<Either<Failure, $featureName>> getById(String id) async {
    try {
      // TODO: Implement with data sources
      throw UnimplementedError();
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<$featureName>>> getAll() async {
    try {
      // TODO: Implement with data sources
      throw UnimplementedError();
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, $featureName>> create($featureName entity) async {
    try {
      // TODO: Implement with data sources
      throw UnimplementedError();
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, $featureName>> update($featureName entity) async {
    try {
      // TODO: Implement with data sources
      throw UnimplementedError();
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> delete(String id) async {
    try {
      // TODO: Implement with data sources
      throw UnimplementedError();
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
''';

    await FileUtils.createFile(
      path.join(featurePath, 'data/repositories', '${featureSnake}_repository_impl.dart'),
      implContent,
    );
  }

  static Future<void> _createSampleBloc(
    String featurePath,
    String featureName,
    String featureSnake,
    String projectName,
  ) async {
    // BLoC file
    final blocContent = '''
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/$featureSnake.dart';
import '../../domain/repositories/${featureSnake}_repository.dart';

part '${featureSnake}_event.dart';
part '${featureSnake}_state.dart';

/// BLoC for managing $featureName state.
///
/// Register with registerLazySingleton in the injection container.
/// See: docs/guidelines/08_di_guidelines.md
class ${featureName}Bloc extends Bloc<${featureName}Event, ${featureName}State> {
  final ${featureName}Repository repository;

  ${featureName}Bloc({required this.repository}) : super(${featureName}Initial()) {
    on<Load${featureName}s>(_onLoadAll);
    on<Load${featureName}>(_onLoadOne);
  }

  Future<void> _onLoadAll(
    Load${featureName}s event,
    Emitter<${featureName}State> emit,
  ) async {
    emit(${featureName}Loading());

    final result = await repository.getAll();

    result.fold(
      (failure) => emit(${featureName}Error(failure.message)),
      (items) => emit(${featureName}Loaded(items)),
    );
  }

  Future<void> _onLoadOne(
    Load${featureName} event,
    Emitter<${featureName}State> emit,
  ) async {
    emit(${featureName}Loading());

    final result = await repository.getById(event.id);

    result.fold(
      (failure) => emit(${featureName}Error(failure.message)),
      (item) => emit(${featureName}DetailLoaded(item)),
    );
  }
}
''';

    await FileUtils.createFile(
      path.join(featurePath, 'presentation/blocs', '${featureSnake}_bloc.dart'),
      blocContent,
    );

    // Events file
    final eventsContent = '''
part of '${featureSnake}_bloc.dart';

/// Base event for $featureName BLoC.
abstract class ${featureName}Event extends Equatable {
  const ${featureName}Event();

  @override
  List<Object?> get props => [];
}

/// Event to load all ${featureName}s.
class Load${featureName}s extends ${featureName}Event {
  const Load${featureName}s();
}

/// Event to load a single $featureName by ID.
class Load${featureName} extends ${featureName}Event {
  final String id;

  const Load${featureName}(this.id);

  @override
  List<Object?> get props => [id];
}
''';

    await FileUtils.createFile(
      path.join(featurePath, 'presentation/blocs', '${featureSnake}_event.dart'),
      eventsContent,
    );

    // States file
    final statesContent = '''
part of '${featureSnake}_bloc.dart';

/// Base state for $featureName BLoC.
abstract class ${featureName}State extends Equatable {
  const ${featureName}State();

  @override
  List<Object?> get props => [];
}

/// Initial state.
class ${featureName}Initial extends ${featureName}State {}

/// Loading state.
class ${featureName}Loading extends ${featureName}State {}

/// Loaded state with list of items.
class ${featureName}Loaded extends ${featureName}State {
  final List<$featureName> items;

  const ${featureName}Loaded(this.items);

  @override
  List<Object?> get props => [items];
}

/// Loaded state with single item.
class ${featureName}DetailLoaded extends ${featureName}State {
  final $featureName item;

  const ${featureName}DetailLoaded(this.item);

  @override
  List<Object?> get props => [item];
}

/// Error state.
class ${featureName}Error extends ${featureName}State {
  final String message;

  const ${featureName}Error(this.message);

  @override
  List<Object?> get props => [message];
}
''';

    await FileUtils.createFile(
      path.join(featurePath, 'presentation/blocs', '${featureSnake}_state.dart'),
      statesContent,
    );
  }

  static Future<void> _createSampleCubit(
    String featurePath,
    String featureName,
    String featureSnake,
    String projectName,
  ) async {
    // Cubit file
    final cubitContent = '''
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/$featureSnake.dart';
import '../../domain/repositories/${featureSnake}_repository.dart';

part '${featureSnake}_state.dart';

/// Cubit for managing $featureName state.
///
/// Register with registerLazySingleton in the injection container.
/// See: docs/guidelines/08_di_guidelines.md
class ${featureName}Cubit extends Cubit<${featureName}State> {
  final ${featureName}Repository repository;

  ${featureName}Cubit({required this.repository}) : super(${featureName}Initial());

  /// Loads all ${featureName}s.
  Future<void> loadAll() async {
    emit(${featureName}Loading());

    final result = await repository.getAll();

    result.fold(
      (failure) => emit(${featureName}Error(failure.message)),
      (items) => emit(${featureName}Loaded(items)),
    );
  }

  /// Loads a single $featureName by ID.
  Future<void> loadOne(String id) async {
    emit(${featureName}Loading());

    final result = await repository.getById(id);

    result.fold(
      (failure) => emit(${featureName}Error(failure.message)),
      (item) => emit(${featureName}DetailLoaded(item)),
    );
  }
}
''';

    await FileUtils.createFile(
      path.join(featurePath, 'presentation/cubits', '${featureSnake}_cubit.dart'),
      cubitContent,
    );

    // States file
    final statesContent = '''
part of '${featureSnake}_cubit.dart';

/// Base state for $featureName Cubit.
abstract class ${featureName}State extends Equatable {
  const ${featureName}State();

  @override
  List<Object?> get props => [];
}

/// Initial state.
class ${featureName}Initial extends ${featureName}State {}

/// Loading state.
class ${featureName}Loading extends ${featureName}State {}

/// Loaded state with list of items.
class ${featureName}Loaded extends ${featureName}State {
  final List<$featureName> items;

  const ${featureName}Loaded(this.items);

  @override
  List<Object?> get props => [items];
}

/// Loaded state with single item.
class ${featureName}DetailLoaded extends ${featureName}State {
  final $featureName item;

  const ${featureName}DetailLoaded(this.item);

  @override
  List<Object?> get props => [item];
}

/// Error state.
class ${featureName}Error extends ${featureName}State {
  final String message;

  const ${featureName}Error(this.message);

  @override
  List<Object?> get props => [message];
}
''';

    await FileUtils.createFile(
      path.join(featurePath, 'presentation/cubits', '${featureSnake}_state.dart'),
      statesContent,
    );
  }

  static Future<void> _createSamplePage(
    String featurePath,
    String featureName,
    String featureSnake,
    String projectName,
    bool useCubit,
  ) async {
    final stateManager = useCubit ? 'Cubit' : 'Bloc';
    final stateManagerSnake = useCubit ? 'cubit' : 'bloc';
    final stateManagerPath = useCubit ? 'cubits' : 'blocs';

    final content = '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:$projectName/core/injection_container/injection_container.dart';
import '../$stateManagerPath/${featureSnake}_$stateManagerSnake.dart';

/// Main page for $featureName feature.
class ${featureName}Page extends StatelessWidget {
  const ${featureName}Page({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<${featureName}$stateManager>()${useCubit ? '..loadAll()' : '..add(const Load${featureName}s())'},
      child: const ${featureName}View(),
    );
  }
}

class ${featureName}View extends StatelessWidget {
  const ${featureName}View({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('$featureName'),
      ),
      body: BlocBuilder<${featureName}$stateManager, ${featureName}State>(
        builder: (context, state) {
          if (state is ${featureName}Loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ${featureName}Error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ${useCubit ? 'context.read<${featureName}Cubit>().loadAll()' : 'context.read<${featureName}Bloc>().add(const Load${featureName}s())'};
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ${featureName}Loaded) {
            if (state.items.isEmpty) {
              return const Center(child: Text('No items found'));
            }

            return ListView.builder(
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                final item = state.items[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text(item.id),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
''';

    await FileUtils.createFile(
      path.join(featurePath, 'presentation/pages', '${featureSnake}_page.dart'),
      content,
    );
  }

  static Future<void> _createInjectionFile(
    String featurePath,
    String featureName,
    String featureSnake,
    String projectName,
    bool useCubit,
  ) async {
    final stateManager = useCubit ? 'Cubit' : 'Bloc';
    final stateManagerPath = useCubit ? 'cubits' : 'blocs';
    final stateManagerSnake = useCubit ? 'cubit' : 'bloc';

    final content = '''
import 'package:get_it/get_it.dart';
import 'domain/repositories/${featureSnake}_repository.dart';
import 'data/repositories/${featureSnake}_repository_impl.dart';
import 'presentation/$stateManagerPath/${featureSnake}_$stateManagerSnake.dart';

/// Registers $featureName feature dependencies.
///
/// Call this from the main injection container init() method.
void init${featureName}Feature(GetIt sl) {
  // ${stateManager}s - use registerLazySingleton for proper lifecycle management
  sl.registerLazySingleton(
    () => ${featureName}$stateManager(repository: sl()),
  );

  // Repositories
  sl.registerLazySingleton<${featureName}Repository>(
    () => const ${featureName}RepositoryImpl(),
  );

  // Data sources
  // TODO: Register data sources
  // sl.registerLazySingleton<${featureName}RemoteDataSource>(
  //   () => ${featureName}RemoteDataSourceImpl(client: sl()),
  // );
}
''';

    await FileUtils.createFile(
      path.join(featurePath, '${featureSnake}_injection.dart'),
      content,
    );
  }
}
