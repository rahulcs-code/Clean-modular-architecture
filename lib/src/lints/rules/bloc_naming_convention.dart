import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Lint rule that enforces BLoC naming conventions.
///
/// - BLoC classes should end with "Bloc"
/// - Event classes should end with "Event"
/// - State classes should end with "State"
///
/// **BAD:**
/// ```dart
/// class UserManager extends Bloc<UserAction, UserStatus> { } // BAD
/// class UserAction { } // BAD - should be UserEvent
/// class UserStatus { } // BAD - should be UserState
/// ```
///
/// **GOOD:**
/// ```dart
/// class UserBloc extends Bloc<UserEvent, UserState> { } // GOOD
/// class UserEvent { } // GOOD
/// class UserState { } // GOOD
/// ```
class BlocNamingConvention extends DartLintRule {
  BlocNamingConvention() : super(code: _blocCode);

  static const _blocCode = LintCode(
    name: 'bloc_naming_convention',
    problemMessage: 'BLoC class should end with "Bloc".',
    correctionMessage: 'Rename this class to end with "Bloc".',
  );

  static const _eventCode = LintCode(
    name: 'bloc_naming_convention',
    problemMessage: 'Event class should end with "Event".',
    correctionMessage: 'Rename this class to end with "Event".',
  );

  static const _stateCode = LintCode(
    name: 'bloc_naming_convention',
    problemMessage: 'State class should end with "State".',
    correctionMessage: 'Rename this class to end with "State".',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    final path = resolver.path;

    // Only check files in bloc directories
    if (!_isBlocFile(path)) {
      return;
    }

    context.registry.addClassDeclaration((node) {
      final className = node.name.lexeme;
      final extendsClause = node.extendsClause;

      if (extendsClause != null) {
        final superclassName = extendsClause.superclass.name2.lexeme;

        // Check if extends Bloc
        if (superclassName == 'Bloc' && !className.endsWith('Bloc')) {
          reporter.atToken(node.name, _blocCode);
        }

        // Check if extends Equatable and is event-like
        if (_isEventClass(node, path) && !className.endsWith('Event')) {
          reporter.atToken(node.name, _eventCode);
        }

        // Check if extends Equatable and is state-like
        if (_isStateClass(node, path) && !className.endsWith('State')) {
          reporter.atToken(node.name, _stateCode);
        }
      }
    });
  }

  bool _isBlocFile(String path) {
    final normalizedPath = path.replaceAll('\\', '/');
    return normalizedPath.contains('/blocs/') ||
        normalizedPath.contains('/bloc/') ||
        normalizedPath.contains('_bloc.dart') ||
        normalizedPath.contains('_event.dart') ||
        normalizedPath.contains('_state.dart');
  }

  bool _isEventClass(ClassDeclaration node, String path) {
    final normalizedPath = path.replaceAll('\\', '/');
    return normalizedPath.contains('_event.dart');
  }

  bool _isStateClass(ClassDeclaration node, String path) {
    final normalizedPath = path.replaceAll('\\', '/');
    return normalizedPath.contains('_state.dart');
  }
}
