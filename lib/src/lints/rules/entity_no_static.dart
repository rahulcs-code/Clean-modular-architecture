import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import '../utils/entity_detector.dart';

/// Lint rule that enforces entities should not have static members.
///
/// Static members in entities often indicate factory methods or singleton
/// patterns that should be handled elsewhere (repositories, models, etc.).
///
/// **BAD:**
/// ```dart
/// class User {
///   final String name;
///   const User({required this.name});
///
///   static User empty = const User(name: ''); // BAD
///   static User fromId(String id) => ... // BAD
/// }
/// ```
///
/// **GOOD:**
/// ```dart
/// class User {
///   final String name;
///   const User({required this.name});
/// }
///
/// // In UserModel
/// class UserModel extends User {
///   static UserModel empty = const UserModel(name: '');
///   static UserModel fromId(String id) => ...
/// }
/// ```
class EntityNoStatic extends DartLintRule {
  EntityNoStatic() : super(code: _code);

  static const _code = LintCode(
    name: 'entity_no_static',
    problemMessage: 'Entities should not have static members. Move static members to the Model class.',
    correctionMessage: 'Remove the static member or move it to the corresponding Model.',
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

      // Check for static members
      for (final member in node.members) {
        if (member is FieldDeclaration && member.isStatic) {
          reporter.atNode(member, _code);
        }
        if (member is MethodDeclaration && member.isStatic) {
          reporter.atNode(member, _code);
        }
      }
    });
  }
}
