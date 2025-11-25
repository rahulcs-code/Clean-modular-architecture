import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import '../utils/entity_detector.dart';

/// Lint rule that enforces entities should not have methods.
///
/// Entities in Clean Architecture should be pure data classes.
/// All business logic should be in use cases, and all data manipulation
/// should be in models.
///
/// **BAD:**
/// ```dart
/// class User {
///   final String name;
///   const User({required this.name});
///
///   String getDisplayName() => name.toUpperCase(); // BAD
/// }
/// ```
///
/// **GOOD:**
/// ```dart
/// class User {
///   final String name;
///   const User({required this.name});
/// }
/// ```
class EntityNoMethods extends DartLintRule {
  EntityNoMethods() : super(code: _code);

  static const _code = LintCode(
    name: 'entity_no_methods',
    problemMessage: 'Entities should not have methods. Move this logic to a UseCase or Model.',
    correctionMessage: 'Remove the method or move it to the corresponding Model class.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addClassDeclaration((node) {
      // Skip if not an entity
      if (!EntityDetector.isEntity(node, resolver.path)) {
        return;
      }

      // Check for methods (excluding constructors and getters)
      for (final member in node.members) {
        if (member is MethodDeclaration) {
          // Allow getters that simply return field values
          if (member.isGetter && _isSimpleGetter(member)) {
            continue;
          }

          // Allow operators like == and hashCode
          if (member.isOperator) {
            continue;
          }

          // Allow toString override
          if (member.name.lexeme == 'toString') {
            continue;
          }

          reporter.reportErrorForNode(_code, member);
        }
      }
    });
  }

  bool _isSimpleGetter(MethodDeclaration getter) {
    // Check if the getter just returns a field
    final body = getter.body;
    if (body is ExpressionFunctionBody) {
      final expression = body.expression;
      if (expression is SimpleIdentifier) {
        return true;
      }
    }
    return false;
  }
}
