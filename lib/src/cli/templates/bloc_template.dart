import 'package:path/path.dart' as path;
import '../utils/file_utils.dart';

/// Template generator for BLoC files.
class BlocTemplate {
  /// Generates a BLoC with events and states.
  static Future<void> generate({
    required String blocPath,
    required String blocName,
    required String blocSnake,
    required String projectName,
    String? featureName,
  }) async {
    await FileUtils.ensureDirectory(blocPath);

    // BLoC file
    final blocContent = '''
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part '${blocSnake}_event.dart';
part '${blocSnake}_state.dart';

/// BLoC for managing $blocName state.
///
/// Register with registerLazySingleton in the injection container.
/// See: docs/guidelines/08_di_guidelines.md
class ${blocName}Bloc extends Bloc<${blocName}Event, ${blocName}State> {
  ${blocName}Bloc() : super(${blocName}Initial()) {
    on<${blocName}Started>(_onStarted);
  }

  Future<void> _onStarted(
    ${blocName}Started event,
    Emitter<${blocName}State> emit,
  ) async {
    emit(${blocName}Loading());

    try {
      // TODO: Implement logic
      emit(${blocName}Loaded());
    } catch (e) {
      emit(${blocName}Error(e.toString()));
    }
  }
}
''';

    await FileUtils.createFile(
      path.join(blocPath, '${blocSnake}_bloc.dart'),
      blocContent,
    );

    // Events file
    final eventsContent = '''
part of '${blocSnake}_bloc.dart';

/// Base event for $blocName BLoC.
abstract class ${blocName}Event extends Equatable {
  const ${blocName}Event();

  @override
  List<Object?> get props => [];
}

/// Event to start $blocName operations.
class ${blocName}Started extends ${blocName}Event {
  const ${blocName}Started();
}
''';

    await FileUtils.createFile(
      path.join(blocPath, '${blocSnake}_event.dart'),
      eventsContent,
    );

    // States file
    final statesContent = '''
part of '${blocSnake}_bloc.dart';

/// Base state for $blocName BLoC.
abstract class ${blocName}State extends Equatable {
  const ${blocName}State();

  @override
  List<Object?> get props => [];
}

/// Initial state.
class ${blocName}Initial extends ${blocName}State {}

/// Loading state.
class ${blocName}Loading extends ${blocName}State {}

/// Loaded state.
class ${blocName}Loaded extends ${blocName}State {}

/// Error state.
class ${blocName}Error extends ${blocName}State {
  final String message;

  const ${blocName}Error(this.message);

  @override
  List<Object?> get props => [message];
}
''';

    await FileUtils.createFile(
      path.join(blocPath, '${blocSnake}_state.dart'),
      statesContent,
    );
  }
}
