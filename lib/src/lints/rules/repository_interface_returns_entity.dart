import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Lint rule that enforces repository interfaces return Entity types, not Model types.
///
/// Repository interfaces in the domain layer should return Entity types.
/// The implementation in the data layer can work with Models internally,
/// but the contract should use domain entities.
///
/// **BAD:**
/// ```dart
/// // In domain/repositories/user_repository.dart
/// abstract class UserRepository {
///   Future<Either<Failure, UserModel>> getUser(String id); // BAD - returns Model
/// }
/// ```
///
/// **GOOD:**
/// ```dart
/// // In domain/repositories/user_repository.dart
/// abstract class UserRepository {
///   Future<Either<Failure, User>> getUser(String id); // GOOD - returns Entity
/// }
/// ```
class RepositoryInterfaceReturnsEntity extends DartLintRule {
  RepositoryInterfaceReturnsEntity() : super(code: _code);

  static const _code = LintCode(
    name: 'repository_interface_returns_entity',
    problemMessage: 'Repository interface should return Entity type, not Model.',
    correctionMessage: 'Change return type from Model to Entity.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    final path = resolver.path;

    // Only check files in domain/repositories/
    if (!_isRepositoryInterface(path)) {
      return;
    }

    context.registry.addClassDeclaration((node) {
      // Check if it's an abstract class (interface)
      if (node.abstractKeyword == null) {
        return;
      }

      // Check all method return types
      for (final member in node.members) {
        if (member is MethodDeclaration) {
          final returnType = member.returnType;
          if (returnType != null && _containsModelType(returnType)) {
            reporter.atNode(returnType, _code);
          }
        }
      }
    });
  }

  bool _isRepositoryInterface(String path) {
    final normalizedPath = path.replaceAll('\\', '/');
    return normalizedPath.contains('/domain/repositories/') ||
        (normalizedPath.contains('/domain/') && normalizedPath.contains('_repository.dart'));
  }

  bool _containsModelType(TypeAnnotation type) {
    final typeString = type.toString();
    // Check if type contains "Model" suffix
    return RegExp(r'\b\w+Model\b').hasMatch(typeString);
  }
}
