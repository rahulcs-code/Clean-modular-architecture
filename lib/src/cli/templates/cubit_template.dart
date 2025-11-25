import 'package:path/path.dart' as path;
import '../utils/file_utils.dart';

/// Template generator for Cubit files.
class CubitTemplate {
  /// Generates a Cubit with state.
  static Future<void> generate({
    required String cubitPath,
    required String cubitName,
    required String cubitSnake,
    required String projectName,
    String? featureName,
  }) async {
    await FileUtils.ensureDirectory(cubitPath);

    // Cubit file
    final cubitContent = '''
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part '${cubitSnake}_state.dart';

/// Cubit for managing $cubitName state.
///
/// Register with registerLazySingleton in the injection container.
/// See: docs/guidelines/08_di_guidelines.md
class ${cubitName}Cubit extends Cubit<${cubitName}State> {
  ${cubitName}Cubit() : super(${cubitName}Initial());

  /// Initializes the cubit.
  Future<void> init() async {
    emit(${cubitName}Loading());

    try {
      // TODO: Implement logic
      emit(${cubitName}Loaded());
    } catch (e) {
      emit(${cubitName}Error(e.toString()));
    }
  }
}
''';

    await FileUtils.createFile(
      path.join(cubitPath, '${cubitSnake}_cubit.dart'),
      cubitContent,
    );

    // States file
    final statesContent = '''
part of '${cubitSnake}_cubit.dart';

/// Base state for $cubitName Cubit.
abstract class ${cubitName}State extends Equatable {
  const ${cubitName}State();

  @override
  List<Object?> get props => [];
}

/// Initial state.
class ${cubitName}Initial extends ${cubitName}State {}

/// Loading state.
class ${cubitName}Loading extends ${cubitName}State {}

/// Loaded state.
class ${cubitName}Loaded extends ${cubitName}State {}

/// Error state.
class ${cubitName}Error extends ${cubitName}State {
  final String message;

  const ${cubitName}Error(this.message);

  @override
  List<Object?> get props => [message];
}
''';

    await FileUtils.createFile(
      path.join(cubitPath, '${cubitSnake}_state.dart'),
      statesContent,
    );
  }
}
