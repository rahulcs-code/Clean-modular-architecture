import 'package:analyzer/dart/ast/ast.dart';
import 'package:clean_modular_architecture/src/config/cma_config.dart';

/// Utility to detect if a class is a domain entity.
class EntityDetector {
  /// Determines if a class declaration is an entity based on:
  /// - File path contains '/domain/entities/' or '/entities/'
  /// - Class name doesn't end with 'Model'
  /// - Optional: Configurable patterns from cma.yaml
  static bool isEntity(
    ClassDeclaration node,
    String filePath, {
    CmaConfig? config,
  }) {
    final className = node.name.lexeme;
    final effectiveConfig = config ?? CmaConfig.defaults;

    // Skip if it's a Model class
    if (className.endsWith(effectiveConfig.modelSuffix)) {
      return false;
    }

    // Check if file is in entities directory using config
    if (effectiveConfig.isEntityPath(filePath)) {
      return true;
    }

    // Check if file is in entities directory
    final normalizedPath = filePath.replaceAll('\\', '/');

    // Check various entity path patterns
    if (normalizedPath.contains('/domain/entities/') ||
        normalizedPath.contains('/entities/') && normalizedPath.contains('/domain/')) {
      return true;
    }

    // Also check for entity suffix pattern (some projects use this)
    if (normalizedPath.contains('/domain/') && !normalizedPath.contains('/models/')) {
      // Check if the class looks like an entity (has const constructor, only final fields)
      return _looksLikeEntity(node);
    }

    return false;
  }

  /// Heuristic check if a class looks like an entity.
  static bool _looksLikeEntity(ClassDeclaration node) {
    // Check if class has only final fields
    for (final member in node.members) {
      if (member is FieldDeclaration) {
        // Check if field is final
        if (!member.fields.isFinal) {
          return false;
        }
      }
    }

    // Check for const constructor
    for (final member in node.members) {
      if (member is ConstructorDeclaration) {
        if (member.constKeyword != null) {
          return true;
        }
      }
    }

    return false;
  }
}
