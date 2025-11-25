import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Lint rule that warns against complex business logic in global Cubits.
///
/// Global Cubits (in core/common/cubits/) should primarily track state
/// and emit state changes. Complex operations should be handled by
/// feature BLoCs that call use cases.
///
/// **BAD:**
/// ```dart
/// // In core/common/cubits/auth_cubit.dart
/// class AuthCubit extends Cubit<AuthState> {
///   final AuthRepository repository;
///
///   Future<void> login(String email, String password) async {
///     // BAD - complex business logic in global cubit
///     final result = await repository.login(email, password);
///     result.fold(
///       (failure) => emit(AuthError(failure.message)),
///       (user) => emit(AuthAuthenticated(user)),
///     );
///   }
/// }
/// ```
///
/// **GOOD:**
/// ```dart
/// // In core/common/cubits/auth_cubit.dart
/// class AuthCubit extends Cubit<AuthState> {
///   AuthCubit() : super(AuthInitial());
///
///   void setAuthenticated(User user) => emit(AuthAuthenticated(user));
///   void setUnauthenticated() => emit(AuthUnauthenticated());
/// }
///
/// // In features/auth/presentation/blocs/auth_bloc.dart
/// class AuthBloc extends Bloc<AuthEvent, AuthState> {
///   final LoginWithEmail loginWithEmail;
///   final AuthCubit authCubit;
///
///   // Complex login logic here, updates AuthCubit on success
/// }
/// ```
class CubitSimpleState extends DartLintRule {
  CubitSimpleState() : super(code: _code);

  static const _code = LintCode(
    name: 'cubit_simple_state',
    problemMessage: 'Global Cubits should only track state, not perform complex operations.',
    correctionMessage: 'Move business logic to a feature BLoC and use the Cubit only for state tracking.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    final path = resolver.path;

    // Only check files in core/common/cubits/
    if (!_isGlobalCubitFile(path)) {
      return;
    }

    context.registry.addClassDeclaration((node) {
      // Check if it's a Cubit class
      if (!_isCubitClass(node)) {
        return;
      }

      // Check for repository/usecase dependencies (indicates complex logic)
      for (final member in node.members) {
        if (member is FieldDeclaration) {
          final typeName = member.fields.type?.toString() ?? '';
          if (_isComplexDependency(typeName)) {
            reporter.reportErrorForNode(_code, member);
          }
        }

        // Check for async methods with await (likely business logic)
        if (member is MethodDeclaration) {
          if (member.isAbstract) continue;
          if (_hasComplexAsyncLogic(member)) {
            reporter.reportErrorForNode(_code, member);
          }
        }
      }
    });
  }

  bool _isGlobalCubitFile(String path) {
    final normalizedPath = path.replaceAll('\\', '/');
    return normalizedPath.contains('/core/common/cubits/') ||
        normalizedPath.contains('/core/cubits/');
  }

  bool _isCubitClass(ClassDeclaration node) {
    final extendsClause = node.extendsClause;
    if (extendsClause == null) return false;

    final superclass = extendsClause.superclass.toString();
    return superclass.startsWith('Cubit<');
  }

  bool _isComplexDependency(String typeName) {
    return typeName.endsWith('Repository') ||
        typeName.endsWith('UseCase') ||
        typeName.endsWith('Service') ||
        typeName.endsWith('DataSource');
  }

  bool _hasComplexAsyncLogic(MethodDeclaration method) {
    // Check if method is async and has significant await calls
    if (!method.body.toString().contains('await')) {
      return false;
    }

    // If method has try-catch with await, it's likely complex
    final bodyString = method.body.toString();
    return bodyString.contains('try') && bodyString.contains('await');
  }
}
