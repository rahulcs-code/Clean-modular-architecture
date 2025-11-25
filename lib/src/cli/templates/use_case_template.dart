import 'package:path/path.dart' as path;
import '../utils/file_utils.dart';

/// Template generator for UseCase files.
class UseCaseTemplate {
  /// Generates a use case.
  static Future<void> generate({
    required String projectRoot,
    required String featureSnake,
    required String useCaseName,
    required String useCaseSnake,
    required String projectName,
    required String useCaseType, // 'async', 'sync', or 'stream'
  }) async {
    final featurePath = path.join(projectRoot, 'lib/features', featureSnake);

    String content;
    switch (useCaseType) {
      case 'sync':
        content = _generateSyncUseCase(useCaseName, projectName);
        break;
      case 'stream':
        content = _generateStreamUseCase(useCaseName, projectName);
        break;
      default:
        content = _generateAsyncUseCase(useCaseName, projectName);
    }

    await FileUtils.createFile(
      path.join(featurePath, 'domain/usecases', '$useCaseSnake.dart'),
      content,
    );
  }

  static String _generateAsyncUseCase(String useCaseName, String projectName) {
    return '''
import 'package:fpdart/fpdart.dart';
import 'package:$projectName/core/errors/failures.dart';
import 'package:clean_modular_architecture/clean_modular_architecture.dart';

/// $useCaseName use case.
///
/// Use cases represent single business operations and follow the Single
/// Responsibility Principle. Each use case should do one thing only.
///
/// See: docs/guidelines/04_use_case_pattern.md
class $useCaseName implements UseCase<void, ${useCaseName}Params> {
  // TODO: Add repository dependency
  // final SomeRepository repository;

  const $useCaseName();

  @override
  Future<Either<Failure, void>> call(${useCaseName}Params params) async {
    // TODO: Implement use case logic
    throw UnimplementedError();
  }
}

/// Parameters for [$useCaseName].
class ${useCaseName}Params {
  // TODO: Add parameters

  const ${useCaseName}Params();
}
''';
  }

  static String _generateSyncUseCase(String useCaseName, String projectName) {
    return '''
import 'package:fpdart/fpdart.dart';
import 'package:$projectName/core/errors/failures.dart';
import 'package:clean_modular_architecture/clean_modular_architecture.dart';

/// $useCaseName synchronous use case.
///
/// Use this for operations that don't require async execution.
///
/// See: docs/guidelines/04_use_case_pattern.md
class $useCaseName implements SyncUseCase<void, ${useCaseName}Params> {
  const $useCaseName();

  @override
  Either<Failure, void> call(${useCaseName}Params params) {
    // TODO: Implement use case logic
    throw UnimplementedError();
  }
}

/// Parameters for [$useCaseName].
class ${useCaseName}Params {
  // TODO: Add parameters

  const ${useCaseName}Params();
}
''';
  }

  static String _generateStreamUseCase(String useCaseName, String projectName) {
    return '''
import 'package:fpdart/fpdart.dart';
import 'package:$projectName/core/errors/failures.dart';
import 'package:clean_modular_architecture/clean_modular_architecture.dart';

/// $useCaseName stream use case.
///
/// Use this for reactive operations that emit multiple values over time.
///
/// See: docs/guidelines/04_use_case_pattern.md
class $useCaseName implements StreamUseCase<void, ${useCaseName}Params> {
  // TODO: Add repository dependency
  // final SomeRepository repository;

  const $useCaseName();

  @override
  Stream<Either<Failure, void>> call(${useCaseName}Params params) {
    // TODO: Implement use case logic
    throw UnimplementedError();
  }
}

/// Parameters for [$useCaseName].
class ${useCaseName}Params {
  // TODO: Add parameters

  const ${useCaseName}Params();
}
''';
  }
}
