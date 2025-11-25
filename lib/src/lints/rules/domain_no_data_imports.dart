import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Lint rule that enforces domain layer should not import from data layer.
///
/// In Clean Architecture, the domain layer is the innermost layer and should
/// not depend on outer layers (data, presentation). The domain layer should
/// only contain entities, repository interfaces, and use cases.
///
/// **BAD:**
/// ```dart
/// // In domain/usecases/get_user.dart
/// import '../../../data/models/user_model.dart'; // BAD
/// import '../../../data/datasources/user_remote.dart'; // BAD
/// ```
///
/// **GOOD:**
/// ```dart
/// // In domain/usecases/get_user.dart
/// import '../entities/user.dart'; // GOOD - same layer
/// import '../repositories/user_repository.dart'; // GOOD - same layer
/// ```
class DomainNoDataImports extends DartLintRule {
  DomainNoDataImports() : super(code: _code);

  static const _code = LintCode(
    name: 'domain_no_data_imports',
    problemMessage: 'Domain layer should not import from data layer.',
    correctionMessage: 'Use repository interfaces and entities instead of data layer implementations.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // Check if this file is in the domain layer
    final path = resolver.path;
    if (!_isInDomainLayer(path)) {
      return;
    }

    context.registry.addImportDirective((node) {
      final importUri = node.uri.stringValue;
      if (importUri == null) return;

      // Check if importing from data layer
      if (_isDataLayerImport(importUri, path)) {
        reporter.atNode(node, _code);
      }
    });
  }

  bool _isInDomainLayer(String path) {
    // Check various patterns for domain layer
    return path.contains('/domain/') ||
        path.contains('\\domain\\') ||
        path.contains('/domain\\') ||
        path.contains('\\domain/');
  }

  bool _isDataLayerImport(String importUri, String currentPath) {
    // Direct data layer import patterns
    if (importUri.contains('/data/') ||
        importUri.contains('\\data\\') ||
        importUri.contains('/models/') ||
        importUri.contains('/datasources/') ||
        importUri.contains('/data/repositories/')) {
      return true;
    }

    // Relative imports going to data layer
    if (importUri.startsWith('../') || importUri.startsWith('..\\')) {
      // Check if the resolved path would be in data layer
      if (importUri.contains('data/') || importUri.contains('data\\')) {
        return true;
      }
    }

    return false;
  }
}
