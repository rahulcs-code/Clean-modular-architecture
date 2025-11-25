import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import '../utils/entity_detector.dart';

/// Lint rule that enforces entities should not have serialization methods.
///
/// Serialization (toJson, fromJson, toMap, fromMap) belongs in the data layer,
/// specifically in Model classes. Domain entities should be pure data containers.
///
/// **BAD:**
/// ```dart
/// class User {
///   final String name;
///   const User({required this.name});
///
///   factory User.fromJson(Map<String, dynamic> json) => ...; // BAD
///   Map<String, dynamic> toJson() => ...; // BAD
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
///   factory UserModel.fromJson(Map<String, dynamic> json) => ...;
///   Map<String, dynamic> toJson() => ...;
/// }
/// ```
class EntityNoSerialization extends DartLintRule {
  EntityNoSerialization() : super(code: _code);

  static const _code = LintCode(
    name: 'entity_no_serialization',
    problemMessage: 'Entities should not have serialization methods. Move serialization to the Model class.',
    correctionMessage: 'Remove fromJson/toJson from the entity and add them to the corresponding Model.',
  );

  static const _serializationMethods = [
    'fromJson',
    'toJson',
    'fromMap',
    'toMap',
    'fromDocument',
    'toDocument',
  ];

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

      // Check for serialization methods and constructors
      for (final member in node.members) {
        if (member is MethodDeclaration) {
          if (_serializationMethods.contains(member.name.lexeme)) {
            reporter.atNode(member, _code);
          }
        }
        if (member is ConstructorDeclaration) {
          final name = member.name?.lexeme;
          if (name != null && _serializationMethods.contains(name)) {
            reporter.atNode(member, _code);
          }
        }
      }
    });
  }
}
