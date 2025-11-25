import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Lint rule that enforces data layer should not import from presentation layer.
///
/// In Clean Architecture, the data layer should not depend on the presentation layer.
/// Data sources, models, and repository implementations should not import
/// BLoCs, Cubits, pages, or widgets.
///
/// **BAD:**
/// ```dart
/// // In data/repositories/user_repository_impl.dart
/// import '../../../presentation/blocs/user_bloc.dart'; // BAD
/// ```
///
/// **GOOD:**
/// ```dart
/// // In data/repositories/user_repository_impl.dart
/// import '../../domain/entities/user.dart'; // GOOD
/// import '../models/user_model.dart'; // GOOD
/// ```
class DataNoPresentationImports extends DartLintRule {
  DataNoPresentationImports() : super(code: _code);

  static const _code = LintCode(
    name: 'data_no_presentation_imports',
    problemMessage: 'Data layer should not import from presentation layer.',
    correctionMessage: 'Remove presentation layer dependencies from data layer code.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    final path = resolver.path;
    if (!_isInDataLayer(path)) {
      return;
    }

    context.registry.addImportDirective((node) {
      final importUri = node.uri.stringValue;
      if (importUri == null) return;

      if (_isPresentationLayerImport(importUri)) {
        reporter.reportErrorForNode(_code, node);
      }
    });
  }

  bool _isInDataLayer(String path) {
    final normalizedPath = path.replaceAll('\\', '/');
    return normalizedPath.contains('/data/') ||
        normalizedPath.contains('/models/') ||
        normalizedPath.contains('/datasources/');
  }

  bool _isPresentationLayerImport(String importUri) {
    return importUri.contains('/presentation/') ||
        importUri.contains('/blocs/') ||
        importUri.contains('/cubits/') ||
        importUri.contains('/pages/') ||
        importUri.contains('/widgets/') ||
        importUri.contains('/screens/');
  }
}
