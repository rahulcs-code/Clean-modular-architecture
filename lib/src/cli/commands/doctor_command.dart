import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;
import '../../config/cma_config.dart';
import '../utils/logger.dart';
import '../utils/file_utils.dart';

/// Command to check project setup and configuration.
///
/// Usage:
/// ```bash
/// dart run clean_arch doctor
/// ```
class DoctorCommand extends Command<int> {
  @override
  final String name = 'doctor';

  @override
  final String description = 'Check project setup and Clean Modular Architecture configuration.';

  DoctorCommand() {
    argParser.addOption(
      'path',
      abbr: 'p',
      help: 'Path to the Flutter project (defaults to current directory).',
    );
  }

  @override
  Future<int> run() async {
    final projectPath = argResults?['path'] as String? ?? Directory.current.path;

    logger.header('Clean Modular Architecture Doctor');

    final projectRoot = FileUtils.findProjectRoot(projectPath);
    if (projectRoot == null) {
      logger.error('No Flutter project found. Run this command from a Flutter project directory.');
      return 1;
    }

    var hasErrors = false;
    var hasWarnings = false;

    // Check 1: Flutter project
    logger.info('Checking Flutter project...');
    final pubspecFile = File(path.join(projectRoot, 'pubspec.yaml'));
    if (pubspecFile.existsSync()) {
      logger.success('Flutter project found');
    } else {
      logger.error('No pubspec.yaml found');
      hasErrors = true;
    }

    // Check 2: CMA configuration
    logger.info('Checking CMA configuration...');
    final cmaConfigFile = File(path.join(projectRoot, 'cma.yaml'));
    final config = CmaConfig.load(projectRoot);

    if (cmaConfigFile.existsSync()) {
      logger.success('CMA configuration file found (cma.yaml)');

      // Validate configuration
      final configErrors = config.validate();
      if (configErrors.isNotEmpty) {
        for (final error in configErrors) {
          logger.error('  Config error: $error');
        }
        hasErrors = true;
      }
    } else {
      logger.warning('No cma.yaml found - using defaults');
      hasWarnings = true;
    }

    // Check 3: Directory structure
    logger.info('Checking directory structure...');
    final requiredDirs = [
      config.corePath,
      config.featuresPath,
    ];

    for (final dir in requiredDirs) {
      final dirPath = path.join(projectRoot, dir);
      if (Directory(dirPath).existsSync()) {
        logger.success('  $dir exists');
      } else {
        logger.warning('  $dir missing');
        hasWarnings = true;
      }
    }

    // Check 4: Core files
    logger.info('Checking core files...');
    final coreFiles = {
      'lib/core/errors/failures.dart': 'Failure classes',
      'lib/core/errors/exceptions.dart': 'Exception classes',
      'lib/core/injection_container/injection_container.dart': 'Injection container',
    };

    for (final entry in coreFiles.entries) {
      final filePath = path.join(projectRoot, entry.key);
      if (File(filePath).existsSync()) {
        logger.success('  ${entry.value} found');
      } else {
        logger.warning('  ${entry.value} missing (${entry.key})');
        hasWarnings = true;
      }
    }

    // Check 5: Dependencies in pubspec.yaml
    logger.info('Checking dependencies...');
    final pubspecContent = pubspecFile.readAsStringSync();
    final requiredDeps = [
      'fpdart',
      'flutter_bloc',
      'get_it',
    ];

    for (final dep in requiredDeps) {
      if (pubspecContent.contains(dep)) {
        logger.success('  $dep found');
      } else {
        logger.warning('  $dep missing - run: flutter pub add $dep');
        hasWarnings = true;
      }
    }

    // Check 6: Dev dependencies
    logger.info('Checking dev dependencies...');
    final requiredDevDeps = [
      'clean_modular_architecture',
      'custom_lint',
    ];

    for (final dep in requiredDevDeps) {
      if (pubspecContent.contains(dep)) {
        logger.success('  $dep found');
      } else {
        logger.warning('  $dep missing - run: flutter pub add --dev $dep');
        hasWarnings = true;
      }
    }

    // Check 7: Analysis options
    logger.info('Checking analysis_options.yaml...');
    final analysisFile = File(path.join(projectRoot, 'analysis_options.yaml'));
    if (analysisFile.existsSync()) {
      final analysisContent = analysisFile.readAsStringSync();
      if (analysisContent.contains('custom_lint')) {
        logger.success('  custom_lint plugin configured');
      } else {
        logger.warning('  custom_lint plugin not configured');
        hasWarnings = true;
      }
    } else {
      logger.warning('  analysis_options.yaml not found');
      hasWarnings = true;
    }

    // Check 8: Features structure
    logger.info('Checking features...');
    final featuresDir = Directory(path.join(projectRoot, config.featuresPath));
    if (featuresDir.existsSync()) {
      final features = featuresDir
          .listSync()
          .whereType<Directory>()
          .map((d) => path.basename(d.path))
          .toList();

      if (features.isEmpty) {
        logger.info('  No features found yet');
      } else {
        logger.success('  Found ${features.length} feature(s): ${features.join(", ")}');

        // Check each feature's structure
        for (final feature in features) {
          final featurePath = path.join(projectRoot, 'lib/features', feature);
          final hasValidStructure = await _checkFeatureStructure(featurePath, feature);
          if (!hasValidStructure) {
            hasWarnings = true;
          }
        }
      }
    }

    // Summary
    logger.newLine();
    if (hasErrors) {
      logger.error('Doctor found errors that need to be fixed.');
      return 1;
    } else if (hasWarnings) {
      logger.warning('Doctor found warnings. Your project may work but might be missing some features.');
      logger.newLine();
      logger.info('To fix warnings, run:');
      logger.command('dart run clean_arch init');
      return 0;
    } else {
      logger.success('No issues found! Your project is properly configured.');
      return 0;
    }
  }

  Future<bool> _checkFeatureStructure(String featurePath, String featureName) async {
    final requiredDirs = [
      'domain',
      'data',
      'presentation',
    ];

    var isValid = true;

    for (final dir in requiredDirs) {
      final dirPath = path.join(featurePath, dir);
      if (!Directory(dirPath).existsSync()) {
        logger.warning('    Feature "$featureName" missing $dir layer');
        isValid = false;
      }
    }

    return isValid;
  }
}
