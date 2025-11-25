import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Lint rule that enforces BLoCs/Cubits should be registered with registerLazySingleton.
///
/// Using registerFactory for BLoCs can cause state management issues as a new
/// instance is created every time. registerLazySingleton ensures proper
/// lifecycle management while avoiding memory leaks.
///
/// **BAD:**
/// ```dart
/// sl.registerFactory(() => UserBloc(repository: sl())); // BAD
/// sl.registerSingleton(UserBloc(repository: sl())); // BAD - eager, blocks init
/// ```
///
/// **GOOD:**
/// ```dart
/// sl.registerLazySingleton(() => UserBloc(repository: sl())); // GOOD
/// ```
class UseLazySingletonForBloc extends DartLintRule {
  UseLazySingletonForBloc() : super(code: _code);

  static const _code = LintCode(
    name: 'use_lazy_singleton_for_bloc',
    problemMessage: 'BLoCs and Cubits should be registered with registerLazySingleton.',
    correctionMessage: 'Replace registerFactory or registerSingleton with registerLazySingleton.',
  );

  static const _blocSuffixes = ['Bloc', 'Cubit'];
  static const _badRegistrations = ['registerFactory', 'registerSingleton'];

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodInvocation((node) {
      final methodName = node.methodName.name;

      // Check if it's a bad registration method
      if (!_badRegistrations.contains(methodName)) {
        return;
      }

      // Check if the registered type is a BLoC or Cubit
      final typeArgs = node.typeArguments;
      if (typeArgs != null && typeArgs.arguments.isNotEmpty) {
        final typeName = typeArgs.arguments.first.toString();
        if (_isBlocOrCubit(typeName)) {
          reporter.atNode(node, _code);
          return;
        }
      }

      // Check the factory function for BLoC/Cubit creation
      final args = node.argumentList.arguments;
      if (args.isNotEmpty) {
        final firstArg = args.first;
        if (firstArg is FunctionExpression) {
          final body = firstArg.body;
          if (body is ExpressionFunctionBody) {
            final expression = body.expression;
            if (expression is MethodInvocation || expression is InstanceCreationExpression) {
              final expressionStr = expression.toString();
              if (_blocSuffixes.any((suffix) => expressionStr.contains(suffix))) {
                reporter.atNode(node, _code);
              }
            }
          }
        }
      }
    });
  }

  bool _isBlocOrCubit(String typeName) {
    return _blocSuffixes.any((suffix) => typeName.endsWith(suffix));
  }
}
