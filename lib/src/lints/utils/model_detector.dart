import 'package:analyzer/dart/ast/ast.dart';
import 'package:clean_modular_architecture/src/config/cma_config.dart';

/// Utility to detect if a class is a data model.
class ModelDetector {
  /// Determines if a class declaration is a model based on:
  /// - File path contains '/data/models/' or '/models/'
  /// - Class name ends with 'Model'
  /// - Optional: Configurable patterns from cma.yaml
  static bool isModel(
    ClassDeclaration node,
    String filePath, {
    CmaConfig? config,
  }) {
    final className = node.name.lexeme;
    final effectiveConfig = config ?? CmaConfig.defaults;

    // Check if class name ends with configured model suffix
    if (className.endsWith(effectiveConfig.modelSuffix)) {
      return true;
    }

    // Check if file is in models directory using config
    if (effectiveConfig.isModelPath(filePath)) {
      return true;
    }

    // Check if file is in models directory
    final normalizedPath = filePath.replaceAll('\\', '/');

    if (normalizedPath.contains('/data/models/') ||
        normalizedPath.contains('/models/') && normalizedPath.contains('/data/')) {
      return true;
    }

    return false;
  }
}
