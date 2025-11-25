import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Lint rule that enforces repository interfaces use `abstract interface class`.
///
/// Repository interfaces should be declared with the `interface` keyword
/// to enforce that they cannot have implementations in the domain layer.
///
/// **BAD:**
/// ```dart
/// abstract class UserRepository { ... } // BAD - missing interface keyword
/// ```
///
/// **GOOD:**
/// ```dart
/// abstract interface class UserRepository { ... } // GOOD
/// ```
class RepositoryUsesAbstractInterface extends DartLintRule {
  RepositoryUsesAbstractInterface() : super(code: _code);

  static const _code = LintCode(
    name: 'repository_uses_abstract_interface',
    problemMessage: 'Repository should be declared as "abstract interface class".',
    correctionMessage: 'Add "interface" keyword after "abstract".',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    final path = resolver.path;

    // Only check files in domain/repositories/
    if (!_isRepositoryFile(path)) {
      return;
    }

    context.registry.addClassDeclaration((node) {
      final className = node.name.lexeme;

      // Check if it's a repository interface (ends with Repository)
      if (!className.endsWith('Repository')) {
        return;
      }

      // Must be abstract
      if (node.abstractKeyword == null) {
        return;
      }

      // Check if interface keyword is present
      if (node.interfaceKeyword == null) {
        reporter.atToken(node.name, _code);
      }
    });
  }

  bool _isRepositoryFile(String path) {
    final normalizedPath = path.replaceAll('\\', '/');
    return normalizedPath.contains('/domain/repositories/') ||
        normalizedPath.contains('/domain/') && normalizedPath.contains('_repository.dart');
  }
}
