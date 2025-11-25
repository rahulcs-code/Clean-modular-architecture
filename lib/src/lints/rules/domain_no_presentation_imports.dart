import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Lint rule that enforces domain layer should not import from presentation layer.
///
/// In Clean Architecture, the domain layer is the innermost layer and should
/// not depend on outer layers (data, presentation). The domain layer should
/// only contain entities, repository interfaces, and use cases.
///
/// **BAD:**
/// ```dart
/// // In domain/usecases/get_user.dart
/// import '../../../presentation/blocs/user_bloc.dart'; // BAD
/// import '../../../presentation/pages/user_page.dart'; // BAD
/// import 'package:flutter/material.dart'; // BAD - Flutter UI
/// ```
///
/// **GOOD:**
/// ```dart
/// // In domain/usecases/get_user.dart
/// import '../entities/user.dart'; // GOOD
/// import '../repositories/user_repository.dart'; // GOOD
/// ```
class DomainNoPresentationImports extends DartLintRule {
  DomainNoPresentationImports() : super(code: _code);

  static const _code = LintCode(
    name: 'domain_no_presentation_imports',
    problemMessage: 'Domain layer should not import from presentation layer.',
    correctionMessage: 'Remove presentation layer dependencies from domain code.',
  );

  static const _flutterUiPackages = [
    'package:flutter/material.dart',
    'package:flutter/widgets.dart',
    'package:flutter/cupertino.dart',
    'package:flutter_bloc/flutter_bloc.dart',
  ];

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // Check if this file is in the domain layer
    final path = resolver.path;
    if (!_isInDomainLayer(path)) {
      return;
    }

    context.registry.addImportDirective((node) {
      final importUri = node.uri.stringValue;
      if (importUri == null) return;

      // Check if importing from presentation layer
      if (_isPresentationLayerImport(importUri)) {
        reporter.reportErrorForNode(_code, node);
      }

      // Check if importing Flutter UI packages
      if (_flutterUiPackages.contains(importUri)) {
        reporter.reportErrorForNode(_code, node);
      }
    });
  }

  bool _isInDomainLayer(String path) {
    return path.contains('/domain/') ||
        path.contains('\\domain\\') ||
        path.contains('/domain\\') ||
        path.contains('\\domain/');
  }

  bool _isPresentationLayerImport(String importUri) {
    // Direct presentation layer import patterns
    if (importUri.contains('/presentation/') ||
        importUri.contains('\\presentation\\') ||
        importUri.contains('/blocs/') ||
        importUri.contains('/cubits/') ||
        importUri.contains('/pages/') ||
        importUri.contains('/widgets/') ||
        importUri.contains('/screens/')) {
      return true;
    }

    // Relative imports going to presentation layer
    if (importUri.startsWith('../') || importUri.startsWith('..\\')) {
      if (importUri.contains('presentation/') ||
          importUri.contains('presentation\\')) {
        return true;
      }
    }

    return false;
  }
}
