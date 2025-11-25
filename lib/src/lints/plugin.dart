import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'rules/entity_no_methods.dart';
import 'rules/entity_no_copywith.dart';
import 'rules/entity_no_static.dart';
import 'rules/entity_no_serialization.dart';
import 'rules/model_extends_entity.dart';
import 'rules/domain_no_data_imports.dart';
import 'rules/domain_no_presentation_imports.dart';
import 'rules/use_lazy_singleton_for_bloc.dart';

/// Clean Modular Architecture lint plugin.
///
/// This plugin provides custom lint rules that enforce Clean Architecture patterns.
class CleanArchLintPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) {
    return [
      EntityNoMethods(),
      EntityNoCopyWith(),
      EntityNoStatic(),
      EntityNoSerialization(),
      ModelExtendsEntity(),
      DomainNoDataImports(),
      DomainNoPresentationImports(),
      UseLazySingletonForBloc(),
    ];
  }
}
