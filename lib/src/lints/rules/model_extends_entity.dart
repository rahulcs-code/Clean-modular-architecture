import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import '../utils/model_detector.dart';

/// Lint rule that enforces models should extend their corresponding entity.
///
/// In Clean Architecture, Models are data layer representations that extend
/// domain Entities. This ensures type compatibility while keeping serialization
/// logic in the data layer.
///
/// **BAD:**
/// ```dart
/// // In data/models/user_model.dart
/// class UserModel { // BAD - should extend User entity
///   final String name;
///   UserModel.fromJson(Map<String, dynamic> json) : name = json['name'];
/// }
/// ```
///
/// **GOOD:**
/// ```dart
/// // In data/models/user_model.dart
/// class UserModel extends User {
///   const UserModel({required super.name});
///
///   factory UserModel.fromJson(Map<String, dynamic> json) {
///     return UserModel(name: json['name']);
///   }
/// }
/// ```
class ModelExtendsEntity extends DartLintRule {
  ModelExtendsEntity() : super(code: _code);

  static const _code = LintCode(
    name: 'model_extends_entity',
    problemMessage: 'Model classes should extend their corresponding Entity.',
    correctionMessage: 'Add "extends EntityName" to this model class.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addClassDeclaration((node) {
      // Skip if not a model
      if (!ModelDetector.isModel(node, resolver.path)) {
        return;
      }

      // Check if the model extends something
      final extendsClause = node.extendsClause;
      if (extendsClause == null) {
        reporter.reportErrorForToken(_code, node.name);
        return;
      }

      // Check if it extends Object (implicitly no real extends)
      final superclassName = extendsClause.superclass.name2.lexeme;
      if (superclassName == 'Object') {
        reporter.reportErrorForToken(_code, node.name);
      }
    });
  }
}
