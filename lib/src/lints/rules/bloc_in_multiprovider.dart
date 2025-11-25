import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Lint rule that verifies BLoCs are provided in MultiBlocProvider in main().
///
/// BLoCs should be registered in MultiBlocProvider at the app root level
/// (in main()) rather than in individual widgets, to ensure proper
/// lifecycle management and avoid unnecessary re-creation.
///
/// **BAD:**
/// ```dart
/// class MyApp extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return MultiBlocProvider(  // BAD - should be in main()
///       providers: [...],
///       child: MaterialApp(...),
///     );
///   }
/// }
/// ```
///
/// **GOOD:**
/// ```dart
/// void main() {
///   runApp(
///     MultiBlocProvider(  // GOOD - at app root in main()
///       providers: [...],
///       child: const MyApp(),
///     ),
///   );
/// }
/// ```
class BlocInMultiprovider extends DartLintRule {
  BlocInMultiprovider() : super(code: _code);

  static const _code = LintCode(
    name: 'bloc_in_multiprovider',
    problemMessage: 'MultiBlocProvider should be in main(), not in widget build methods.',
    correctionMessage: 'Move MultiBlocProvider to main() and wrap your app with it.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodInvocation((node) {
      // Check if it's a MultiBlocProvider call
      final methodName = node.methodName.name;
      if (methodName != 'MultiBlocProvider') {
        return;
      }

      // Check if we're inside a build method of a widget
      final enclosingMethod = _findEnclosingMethod(node);
      if (enclosingMethod != null && enclosingMethod.name.lexeme == 'build') {
        // Check if the enclosing class extends StatelessWidget or StatefulWidget
        final enclosingClass = _findEnclosingClass(node);
        if (enclosingClass != null && _isWidgetClass(enclosingClass)) {
          reporter.reportErrorForNode(_code, node.methodName);
        }
      }
    });

    // Also check for MultiBlocProvider instance creation
    context.registry.addInstanceCreationExpression((node) {
      final typeName = node.constructorName.type.name2.lexeme;
      if (typeName != 'MultiBlocProvider') {
        return;
      }

      final enclosingMethod = _findEnclosingMethod(node);
      if (enclosingMethod != null && enclosingMethod.name.lexeme == 'build') {
        final enclosingClass = _findEnclosingClass(node);
        if (enclosingClass != null && _isWidgetClass(enclosingClass)) {
          reporter.reportErrorForNode(_code, node.constructorName);
        }
      }
    });
  }

  MethodDeclaration? _findEnclosingMethod(AstNode node) {
    AstNode? current = node.parent;
    while (current != null) {
      if (current is MethodDeclaration) {
        return current;
      }
      current = current.parent;
    }
    return null;
  }

  ClassDeclaration? _findEnclosingClass(AstNode node) {
    AstNode? current = node.parent;
    while (current != null) {
      if (current is ClassDeclaration) {
        return current;
      }
      current = current.parent;
    }
    return null;
  }

  bool _isWidgetClass(ClassDeclaration classDecl) {
    final extendsClause = classDecl.extendsClause;
    if (extendsClause == null) return false;

    final superclassName = extendsClause.superclass.name2.lexeme;
    return superclassName == 'StatelessWidget' ||
        superclassName == 'StatefulWidget' ||
        superclassName == 'State';
  }
}
