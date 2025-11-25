/// Custom lint rules for Clean Modular Architecture.
///
/// This library provides custom lint rules that enforce Clean Architecture patterns.
///
/// ## Configuration
///
/// Add to your `analysis_options.yaml`:
/// ```yaml
/// analyzer:
///   plugins:
///     - custom_lint
///
/// custom_lint:
///   rules:
///     - entity_no_methods
///     - entity_no_copywith
///     - entity_no_static
///     - entity_no_serialization
///     - model_extends_entity
///     - domain_no_data_imports
///     - domain_no_presentation_imports
///     - use_lazy_singleton_for_bloc
/// ```
library cma_lints;

import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'src/lints/plugin.dart';

/// Entry point for custom_lint plugin.
PluginBase createPlugin() => CleanArchLintPlugin();
