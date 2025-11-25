import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import '../utils/entity_detector.dart';

/// Lint rule that enforces entities should not have computed getters.
///
/// Simple field getters are allowed, but computed getters with logic
/// belong in the Model class.
///
/// **BAD:**
/// ```dart
/// class User {
///   final String firstName;
///   final String lastName;
///   const User({required this.firstName, required this.lastName});
///
///   String get fullName => '$firstName $lastName'; // BAD - computed
/// }
/// ```
///
/// **GOOD:**
/// ```dart
/// class User {
///   final String firstName;
///   final String lastName;
///   const User({required this.firstName, required this.lastName});
/// }
///
/// // In UserModel
/// class UserModel extends User {
///   String get fullName => '$firstName $lastName'; // OK in model
/// }
/// ```
class EntityNoGetters extends DartLintRule {
  EntityNoGetters() : super(code: _code);

  static const _code = LintCode(
    name: 'entity_no_getters',
    problemMessage: 'Entities should not have computed getters. Move to Model class.',
    correctionMessage: 'Remove the getter or move it to the corresponding Model.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addClassDeclaration((node) {
      if (!EntityDetector.isEntity(node, resolver.path)) {
        return;
      }

      for (final member in node.members) {
        if (member is MethodDeclaration && member.isGetter) {
          // Check if it's a computed getter (has expression body with operations)
          if (_isComputedGetter(member)) {
            reporter.atNode(member, _code);
          }
        }
      }
    });
  }

  bool _isComputedGetter(MethodDeclaration getter) {
    final body = getter.body;
    if (body is ExpressionFunctionBody) {
      final expression = body.expression;
      // Simple field return is OK
      if (expression is SimpleIdentifier) {
        return false;
      }
      // Any other expression is a computed getter
      return true;
    }
    // Block body getters are always computed
    if (body is BlockFunctionBody) {
      return true;
    }
    return false;
  }
}
