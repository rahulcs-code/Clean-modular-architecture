import 'package:custom_lint_builder/custom_lint_builder.dart';

// Entity Rules
import 'rules/entity_no_methods.dart';
import 'rules/entity_no_copywith.dart';
import 'rules/entity_no_static.dart';
import 'rules/entity_no_serialization.dart';
import 'rules/entity_no_getters.dart';

// Model Rules
import 'rules/model_extends_entity.dart';
import 'rules/model_naming_convention.dart';

// Repository Rules
import 'rules/repository_interface_returns_entity.dart';
import 'rules/repository_uses_abstract_interface.dart';

// Import Restriction Rules
import 'rules/domain_no_data_imports.dart';
import 'rules/domain_no_presentation_imports.dart';
import 'rules/data_no_presentation_imports.dart';

// DI Rules
import 'rules/use_lazy_singleton_for_bloc.dart';

// BLoC Rules
import 'rules/bloc_naming_convention.dart';
import 'rules/bloc_in_multiprovider.dart';

// Cubit Rules
import 'rules/cubit_simple_state.dart';

/// Clean Modular Architecture lint plugin.
///
/// This plugin provides custom lint rules that enforce Clean Architecture patterns.
///
/// ## Available Rules
///
/// ### Entity Rules
/// - `entity_no_methods` - Entities should not have methods
/// - `entity_no_copywith` - Entities should not have copyWith
/// - `entity_no_static` - Entities should not have static members
/// - `entity_no_serialization` - Entities should not have fromJson/toJson
/// - `entity_no_getters` - Entities should not have computed getters
///
/// ### Model Rules
/// - `model_extends_entity` - Models must extend entities
/// - `model_naming_convention` - Models should end with "Model"
///
/// ### Repository Rules
/// - `repository_interface_returns_entity` - Interfaces should return Entity types
/// - `repository_uses_abstract_interface` - Use "abstract interface class"
///
/// ### Import Restriction Rules
/// - `domain_no_data_imports` - Domain cannot import from data layer
/// - `domain_no_presentation_imports` - Domain cannot import from presentation
/// - `data_no_presentation_imports` - Data cannot import from presentation
///
/// ### DI Rules
/// - `use_lazy_singleton_for_bloc` - BLoCs should use registerLazySingleton
///
/// ### BLoC Rules
/// - `bloc_naming_convention` - BLoC/Event/State naming conventions
/// - `bloc_in_multiprovider` - MultiBlocProvider should be in main()
///
/// ### Cubit Rules
/// - `cubit_simple_state` - Global Cubits should only track state
class CleanArchLintPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) {
    return [
      // Entity Rules
      EntityNoMethods(),
      EntityNoCopyWith(),
      EntityNoStatic(),
      EntityNoSerialization(),
      EntityNoGetters(),

      // Model Rules
      ModelExtendsEntity(),
      ModelNamingConvention(),

      // Repository Rules
      RepositoryInterfaceReturnsEntity(),
      RepositoryUsesAbstractInterface(),

      // Import Restriction Rules
      DomainNoDataImports(),
      DomainNoPresentationImports(),
      DataNoPresentationImports(),

      // DI Rules
      UseLazySingletonForBloc(),

      // BLoC Rules
      BlocNamingConvention(),
      BlocInMultiprovider(),

      // Cubit Rules
      CubitSimpleState(),
    ];
  }

  @override
  List<Assist> getAssists() {
    // Quick fixes and code assists for Clean Architecture
    // TODO: Implement assists in future versions
    // Potential assists:
    // - Move method from entity to model
    // - Extract entity from model
    // - Convert registerFactory to registerLazySingleton
    // - Generate model from entity
    return [];
  }
}
