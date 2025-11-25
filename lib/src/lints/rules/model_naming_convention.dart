import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Lint rule that enforces model classes should end with "Model".
///
/// **BAD:**
/// ```dart
/// // In data/models/user_data.dart
/// class UserData extends User { ... } // BAD - should be UserModel
/// ```
///
/// **GOOD:**
/// ```dart
/// // In data/models/user_model.dart
/// class UserModel extends User { ... } // GOOD
/// ```
class ModelNamingConvention extends DartLintRule {
  ModelNamingConvention() : super(code: _code);

  static const _code = LintCode(
    name: 'model_naming_convention',
    problemMessage: 'Model classes should be named with "Model" suffix.',
    correctionMessage: 'Rename this class to {ClassName}Model.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addClassDeclaration((node) {
      final path = resolver.path;

      // Check if file is in models directory but class doesn't end with Model
      if (_isInModelsDirectory(path)) {
        final className = node.name.lexeme;
        if (!className.endsWith('Model')) {
          reporter.atToken(node.name, _code);
        }
      }
    });
  }

  bool _isInModelsDirectory(String path) {
    final normalizedPath = path.replaceAll('\\', '/');
    return normalizedPath.contains('/data/models/') ||
        (normalizedPath.contains('/models/') && normalizedPath.contains('/data/'));
  }
}
