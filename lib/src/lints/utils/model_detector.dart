import 'package:analyzer/dart/ast/ast.dart';

/// Utility to detect if a class is a data model.
class ModelDetector {
  /// Determines if a class declaration is a model based on:
  /// - File path contains '/data/models/' or '/models/'
  /// - Class name ends with 'Model'
  static bool isModel(ClassDeclaration node, String filePath) {
    final className = node.name.lexeme;

    // Check if class name ends with 'Model'
    if (className.endsWith('Model')) {
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
