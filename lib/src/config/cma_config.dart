import 'dart:io';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as path;

/// Configuration for Clean Modular Architecture.
///
/// Reads configuration from `cma.yaml` in the project root.
///
/// ## Configuration File
///
/// ```yaml
/// clean_modular_architecture:
///   structure:
///     features_path: lib/features
///     core_path: lib/core
///   naming:
///     entity_suffix: ""
///     model_suffix: "Model"
///     repository_suffix: "Repository"
///     bloc_suffix: "Bloc"
///   lint:
///     enabled: true
///     severity:
///       entity_no_methods: error
///       model_extends_entity: warning
///   templates:
///     state_management: bloc
///     di_package: get_it
/// ```
class CmaConfig {
  /// Path to features directory.
  final String featuresPath;

  /// Path to core directory.
  final String corePath;

  /// Entity class name suffix (usually empty).
  final String entitySuffix;

  /// Model class name suffix.
  final String modelSuffix;

  /// Repository class name suffix.
  final String repositorySuffix;

  /// BLoC class name suffix.
  final String blocSuffix;

  /// Cubit class name suffix.
  final String cubitSuffix;

  /// Whether lint rules are enabled.
  final bool lintEnabled;

  /// Severity overrides for lint rules.
  final Map<String, String> lintSeverity;

  /// State management approach: 'bloc' or 'cubit'.
  final String stateManagement;

  /// DI package to use: 'get_it' or 'injectable'.
  final String diPackage;

  /// Entity path patterns for lint rules.
  final List<String> entityPatterns;

  /// Model path patterns for lint rules.
  final List<String> modelPatterns;

  /// Creates a [CmaConfig] with the given values.
  const CmaConfig({
    this.featuresPath = 'lib/features',
    this.corePath = 'lib/core',
    this.entitySuffix = '',
    this.modelSuffix = 'Model',
    this.repositorySuffix = 'Repository',
    this.blocSuffix = 'Bloc',
    this.cubitSuffix = 'Cubit',
    this.lintEnabled = true,
    this.lintSeverity = const {},
    this.stateManagement = 'bloc',
    this.diPackage = 'get_it',
    this.entityPatterns = const ['/domain/entities/'],
    this.modelPatterns = const ['/data/models/'],
  });

  /// Default configuration.
  static const CmaConfig defaults = CmaConfig();

  /// Loads configuration from `cma.yaml` in the given directory.
  ///
  /// Falls back to defaults if the file doesn't exist or is invalid.
  static CmaConfig load([String? directory]) {
    final dir = directory ?? Directory.current.path;
    final configFile = File(path.join(dir, 'cma.yaml'));

    if (!configFile.existsSync()) {
      return defaults;
    }

    try {
      final content = configFile.readAsStringSync();
      final yaml = loadYaml(content) as YamlMap?;

      if (yaml == null) {
        return defaults;
      }

      final config = yaml['clean_modular_architecture'] as YamlMap?;
      if (config == null) {
        return defaults;
      }

      return CmaConfig._fromYaml(config);
    } catch (e) {
      // Return defaults if config is invalid
      return defaults;
    }
  }

  factory CmaConfig._fromYaml(YamlMap config) {
    final structure = config['structure'] as YamlMap?;
    final naming = config['naming'] as YamlMap?;
    final lint = config['lint'] as YamlMap?;
    final templates = config['templates'] as YamlMap?;

    final lintSeverityYaml = lint?['severity'] as YamlMap?;
    final lintSeverity = <String, String>{};
    if (lintSeverityYaml != null) {
      for (final entry in lintSeverityYaml.entries) {
        lintSeverity[entry.key.toString()] = entry.value.toString();
      }
    }

    final entityPatternsYaml = structure?['entity_patterns'] as YamlList?;
    final modelPatternsYaml = structure?['model_patterns'] as YamlList?;

    return CmaConfig(
      featuresPath: structure?['features_path']?.toString() ?? 'lib/features',
      corePath: structure?['core_path']?.toString() ?? 'lib/core',
      entitySuffix: naming?['entity_suffix']?.toString() ?? '',
      modelSuffix: naming?['model_suffix']?.toString() ?? 'Model',
      repositorySuffix: naming?['repository_suffix']?.toString() ?? 'Repository',
      blocSuffix: naming?['bloc_suffix']?.toString() ?? 'Bloc',
      cubitSuffix: naming?['cubit_suffix']?.toString() ?? 'Cubit',
      lintEnabled: lint?['enabled'] as bool? ?? true,
      lintSeverity: lintSeverity,
      stateManagement: templates?['state_management']?.toString() ?? 'bloc',
      diPackage: templates?['di_package']?.toString() ?? 'get_it',
      entityPatterns: entityPatternsYaml?.map((e) => e.toString()).toList() ??
          const ['/domain/entities/'],
      modelPatterns: modelPatternsYaml?.map((e) => e.toString()).toList() ??
          const ['/data/models/'],
    );
  }

  /// Gets the severity for a lint rule.
  ///
  /// Returns the configured severity or 'error' as default.
  String getSeverity(String ruleName) {
    return lintSeverity[ruleName] ?? 'error';
  }

  /// Checks if a path matches entity patterns.
  bool isEntityPath(String filePath) {
    final normalized = filePath.replaceAll('\\', '/').toLowerCase();
    return entityPatterns.any((pattern) => normalized.contains(pattern.toLowerCase()));
  }

  /// Checks if a path matches model patterns.
  bool isModelPath(String filePath) {
    final normalized = filePath.replaceAll('\\', '/').toLowerCase();
    return modelPatterns.any((pattern) => normalized.contains(pattern.toLowerCase()));
  }

  /// Checks if a path is in the domain layer.
  bool isDomainPath(String filePath) {
    final normalized = filePath.replaceAll('\\', '/').toLowerCase();
    return normalized.contains('/domain/');
  }

  /// Checks if a path is in the data layer.
  bool isDataPath(String filePath) {
    final normalized = filePath.replaceAll('\\', '/').toLowerCase();
    return normalized.contains('/data/');
  }

  /// Checks if a path is in the presentation layer.
  bool isPresentationPath(String filePath) {
    final normalized = filePath.replaceAll('\\', '/').toLowerCase();
    return normalized.contains('/presentation/');
  }

  /// Checks if a path is in the core directory.
  bool isCorePath(String filePath) {
    final normalized = filePath.replaceAll('\\', '/').toLowerCase();
    return normalized.contains(corePath.toLowerCase()) ||
        normalized.contains('/core/');
  }

  /// Checks if a path is a global cubit (in core/common/cubits/).
  bool isGlobalCubitPath(String filePath) {
    final normalized = filePath.replaceAll('\\', '/').toLowerCase();
    return normalized.contains('/core/common/cubits/') ||
        normalized.contains('/core/cubits/');
  }

  /// Checks if a path is a repository interface (in domain/repositories/).
  bool isRepositoryInterfacePath(String filePath) {
    final normalized = filePath.replaceAll('\\', '/').toLowerCase();
    return normalized.contains('/domain/repositories/');
  }

  /// Gets the expected model class name for an entity.
  String getModelNameForEntity(String entityName) {
    if (entitySuffix.isNotEmpty && entityName.endsWith(entitySuffix)) {
      final baseName = entityName.substring(
        0,
        entityName.length - entitySuffix.length,
      );
      return '$baseName$modelSuffix';
    }
    return '$entityName$modelSuffix';
  }

  /// Gets the expected entity class name for a model.
  String getEntityNameForModel(String modelName) {
    if (modelSuffix.isNotEmpty && modelName.endsWith(modelSuffix)) {
      final baseName = modelName.substring(
        0,
        modelName.length - modelSuffix.length,
      );
      return '$baseName$entitySuffix';
    }
    return modelName;
  }

  /// Validates the configuration and returns a list of errors.
  List<String> validate() {
    final errors = <String>[];

    if (featuresPath.isEmpty) {
      errors.add('features_path cannot be empty');
    }
    if (corePath.isEmpty) {
      errors.add('core_path cannot be empty');
    }
    if (modelSuffix.isEmpty) {
      errors.add('model_suffix cannot be empty');
    }

    // Validate severity values
    const validSeverities = ['error', 'warning', 'info', 'ignore'];
    for (final entry in lintSeverity.entries) {
      if (!validSeverities.contains(entry.value)) {
        errors.add('Invalid severity "${entry.value}" for rule "${entry.key}"');
      }
    }

    // Validate state management
    const validStateManagement = ['bloc', 'cubit', 'riverpod', 'provider'];
    if (!validStateManagement.contains(stateManagement)) {
      errors.add('Invalid state_management: $stateManagement');
    }

    // Validate DI package
    const validDiPackages = ['get_it', 'injectable', 'riverpod'];
    if (!validDiPackages.contains(diPackage)) {
      errors.add('Invalid di_package: $diPackage');
    }

    return errors;
  }

  /// Generates a YAML string representation of this config.
  String toYaml() {
    final severityYaml = lintSeverity.entries
        .map((e) => '      ${e.key}: ${e.value}')
        .join('\n');

    return '''
clean_modular_architecture:
  structure:
    features_path: $featuresPath
    core_path: $corePath
    entity_patterns:
${entityPatterns.map((p) => '      - "$p"').join('\n')}
    model_patterns:
${modelPatterns.map((p) => '      - "$p"').join('\n')}
  naming:
    entity_suffix: "$entitySuffix"
    model_suffix: "$modelSuffix"
    repository_suffix: "$repositorySuffix"
    bloc_suffix: "$blocSuffix"
    cubit_suffix: "$cubitSuffix"
  lint:
    enabled: $lintEnabled
    severity:
$severityYaml
  templates:
    state_management: $stateManagement
    di_package: $diPackage
''';
  }

  /// Creates a copy with modified values.
  CmaConfig copyWith({
    String? featuresPath,
    String? corePath,
    String? entitySuffix,
    String? modelSuffix,
    String? repositorySuffix,
    String? blocSuffix,
    String? cubitSuffix,
    bool? lintEnabled,
    Map<String, String>? lintSeverity,
    String? stateManagement,
    String? diPackage,
    List<String>? entityPatterns,
    List<String>? modelPatterns,
  }) {
    return CmaConfig(
      featuresPath: featuresPath ?? this.featuresPath,
      corePath: corePath ?? this.corePath,
      entitySuffix: entitySuffix ?? this.entitySuffix,
      modelSuffix: modelSuffix ?? this.modelSuffix,
      repositorySuffix: repositorySuffix ?? this.repositorySuffix,
      blocSuffix: blocSuffix ?? this.blocSuffix,
      cubitSuffix: cubitSuffix ?? this.cubitSuffix,
      lintEnabled: lintEnabled ?? this.lintEnabled,
      lintSeverity: lintSeverity ?? this.lintSeverity,
      stateManagement: stateManagement ?? this.stateManagement,
      diPackage: diPackage ?? this.diPackage,
      entityPatterns: entityPatterns ?? this.entityPatterns,
      modelPatterns: modelPatterns ?? this.modelPatterns,
    );
  }
}

/// Severity levels for lint rules.
abstract class LintSeverity {
  static const String error = 'error';
  static const String warning = 'warning';
  static const String info = 'info';
  static const String ignore = 'ignore';

  static const List<String> values = [error, warning, info, ignore];
}

/// State management options.
abstract class StateManagement {
  static const String bloc = 'bloc';
  static const String cubit = 'cubit';
  static const String riverpod = 'riverpod';
  static const String provider = 'provider';

  static const List<String> values = [bloc, cubit, riverpod, provider];
}

/// Dependency injection package options.
abstract class DiPackage {
  static const String getIt = 'get_it';
  static const String injectable = 'injectable';
  static const String riverpod = 'riverpod';

  static const List<String> values = [getIt, injectable, riverpod];
}
