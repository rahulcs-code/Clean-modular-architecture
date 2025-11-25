import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import '../utils/entity_detector.dart';

/// Lint rule that enforces entities should not have copyWith methods.
///
/// copyWith methods belong in Model classes, not in domain entities.
/// Entities should be immutable and only created through constructors.
///
/// **BAD:**
/// ```dart
/// class User {
///   final String name;
///   const User({required this.name});
///
///   User copyWith({String? name}) => User(name: name ?? this.name); // BAD
/// }
/// ```
///
/// **GOOD:**
/// ```dart
/// // In domain/entities/user.dart
/// class User {
///   final String name;
///   const User({required this.name});
/// }
///
/// // In data/models/user_model.dart
/// class UserModel extends User {
///   const UserModel({required super.name});
///
///   UserModel copyWith({String? name}) => UserModel(name: name ?? this.name);
/// }
/// ```
class EntityNoCopyWith extends DartLintRule {
  EntityNoCopyWith() : super(code: _code);

  static const _code = LintCode(
    name: 'entity_no_copywith',
    problemMessage: 'Entities should not have copyWith methods. Move copyWith to the Model class.',
    correctionMessage: 'Remove copyWith from the entity and add it to the corresponding Model.',
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

      // Check for copyWith method
      for (final member in node.members) {
        if (member is MethodDeclaration) {
          if (member.name.lexeme == 'copyWith') {
            reporter.reportErrorForNode(_code, member);
          }
        }
      }
    });
  }
}
