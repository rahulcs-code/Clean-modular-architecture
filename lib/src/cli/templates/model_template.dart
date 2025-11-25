import 'package:path/path.dart' as path;
import '../utils/file_utils.dart';

/// Template generator for Model files.
class ModelTemplate {
  /// Generates a data model that extends an entity.
  static Future<void> generate({
    required String projectRoot,
    required String featureSnake,
    required String modelName,
    required String modelSnake,
    required String entityName,
    required String entitySnake,
    required String projectName,
  }) async {
    final featurePath = path.join(projectRoot, 'lib/features', featureSnake);

    final content = '''
import '../../domain/entities/$entitySnake.dart';

/// ${modelName} data model.
///
/// This model extends the domain entity and adds data layer functionality:
/// - JSON serialization (fromJson/toJson)
/// - copyWith for immutable updates
/// - Any data transformation logic
///
/// See: docs/guidelines/02_entity_model_separation.md
class ${modelName}Model extends $entityName {
  const ${modelName}Model({
    required super.id,
    // TODO: Add model fields matching entity
  });

  /// Creates a model from JSON data.
  factory ${modelName}Model.fromJson(Map<String, dynamic> json) {
    return ${modelName}Model(
      id: json['id'] as String,
      // TODO: Add JSON parsing
    );
  }

  /// Converts the model to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      // TODO: Add JSON serialization
    };
  }

  /// Creates a copy with optional new values.
  ${modelName}Model copyWith({
    String? id,
    // TODO: Add copyWith parameters
  }) {
    return ${modelName}Model(
      id: id ?? this.id,
      // TODO: Add copyWith logic
    );
  }
}
''';

    await FileUtils.createFile(
      path.join(featurePath, 'data/models', '${modelSnake}_model.dart'),
      content,
    );
  }
}
