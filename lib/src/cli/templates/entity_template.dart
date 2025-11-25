import 'package:path/path.dart' as path;
import '../utils/file_utils.dart';

/// Template generator for Entity files.
class EntityTemplate {
  /// Generates a domain entity.
  static Future<void> generate({
    required String projectRoot,
    required String featureSnake,
    required String entityName,
    required String entitySnake,
  }) async {
    final featurePath = path.join(projectRoot, 'lib/features', featureSnake);

    final content = '''
/// $entityName entity.
///
/// This is a domain entity - it should contain only data fields.
/// Do NOT add methods, copyWith, serialization, or static members.
///
/// See: docs/guidelines/02_entity_model_separation.md
class $entityName {
  final String id;
  // TODO: Add entity fields

  const $entityName({
    required this.id,
  });
}
''';

    await FileUtils.createFile(
      path.join(featurePath, 'domain/entities', '$entitySnake.dart'),
      content,
    );
  }
}
