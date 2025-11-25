import 'package:path/path.dart' as path;
import '../utils/file_utils.dart';

/// Template generator for Repository files.
class RepositoryTemplate {
  /// Generates a repository interface and implementation.
  static Future<void> generate({
    required String projectRoot,
    required String featureSnake,
    required String repoName,
    required String repoSnake,
    required String projectName,
  }) async {
    final featurePath = path.join(projectRoot, 'lib/features', featureSnake);

    // Domain repository interface
    final interfaceContent = '''
import 'package:fpdart/fpdart.dart';
import 'package:$projectName/core/errors/failures.dart';

/// Repository interface for $repoName operations.
///
/// This is a domain contract - implementations belong in the data layer.
/// Methods should return Entity types, not Model types.
///
/// See: docs/guidelines/05_repository_pattern.md
abstract class ${repoName}Repository {
  // TODO: Define repository methods
  // Example:
  // Future<Either<Failure, Entity>> getById(String id);
  // Future<Either<Failure, List<Entity>>> getAll();
}
''';

    await FileUtils.createFile(
      path.join(featurePath, 'domain/repositories', '${repoSnake}_repository.dart'),
      interfaceContent,
    );

    // Data repository implementation
    final implContent = '''
import 'package:fpdart/fpdart.dart';
import 'package:$projectName/core/errors/exceptions.dart';
import 'package:$projectName/core/errors/failures.dart';
import '../../domain/repositories/${repoSnake}_repository.dart';

/// Implementation of [${repoName}Repository].
///
/// This implementation:
/// - Catches exceptions and converts them to failures
/// - Can work with Models internally but returns Entities
/// - Handles data source coordination (remote/local)
class ${repoName}RepositoryImpl implements ${repoName}Repository {
  // TODO: Add data sources
  // final ${repoName}RemoteDataSource remoteDataSource;
  // final ${repoName}LocalDataSource localDataSource;

  const ${repoName}RepositoryImpl();

  // TODO: Implement repository methods
}
''';

    await FileUtils.createFile(
      path.join(featurePath, 'data/repositories', '${repoSnake}_repository_impl.dart'),
      implContent,
    );
  }
}
