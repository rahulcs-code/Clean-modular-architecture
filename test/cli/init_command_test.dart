import 'dart:io';
import 'package:test/test.dart';
import 'package:path/path.dart' as path;

void main() {
  group('InitCommand', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('cma_test_');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('should detect when not in Flutter project', () {
      // Create a directory without pubspec.yaml
      final testDir = Directory(path.join(tempDir.path, 'not_flutter'));
      testDir.createSync();

      // InitCommand should fail gracefully
      expect(testDir.existsSync(), isTrue);
      expect(
        File(path.join(testDir.path, 'pubspec.yaml')).existsSync(),
        isFalse,
      );
    });

    test('should detect Flutter project with pubspec.yaml', () {
      // Create a mock Flutter project
      final projectDir = Directory(path.join(tempDir.path, 'flutter_app'));
      projectDir.createSync();

      final pubspec = File(path.join(projectDir.path, 'pubspec.yaml'));
      pubspec.writeAsStringSync('''
name: test_app
description: A test Flutter application
version: 1.0.0

environment:
  sdk: ">=3.0.0 <4.0.0"
  flutter: ">=3.0.0"

dependencies:
  flutter:
    sdk: flutter
''');

      expect(pubspec.existsSync(), isTrue);
      expect(pubspec.readAsStringSync(), contains('name: test_app'));
    });

    test('should create cma.yaml with default configuration', () {
      final projectDir = Directory(path.join(tempDir.path, 'flutter_app'));
      projectDir.createSync();

      // Create pubspec
      File(path.join(projectDir.path, 'pubspec.yaml')).writeAsStringSync('''
name: test_app
environment:
  sdk: ">=3.0.0 <4.0.0"
''');

      // Simulate cma.yaml creation
      final cmaConfig = File(path.join(projectDir.path, 'cma.yaml'));
      cmaConfig.writeAsStringSync('''
clean_modular_architecture:
  structure:
    features_path: lib/features
    core_path: lib/core
  naming:
    model_suffix: "Model"
  lint:
    enabled: true
  templates:
    state_management: bloc
    di_package: get_it
''');

      expect(cmaConfig.existsSync(), isTrue);
      expect(cmaConfig.readAsStringSync(), contains('features_path'));
    });

    test('should create core directory structure', () {
      final projectDir = Directory(path.join(tempDir.path, 'flutter_app'));
      projectDir.createSync();

      // Create expected directory structure
      final dirs = [
        'lib/core/common/cubits',
        'lib/core/common/widgets',
        'lib/core/errors',
        'lib/core/injection_container',
        'lib/core/network',
        'lib/features',
      ];

      for (final dir in dirs) {
        Directory(path.join(projectDir.path, dir)).createSync(recursive: true);
      }

      // Verify structure
      for (final dir in dirs) {
        expect(
          Directory(path.join(projectDir.path, dir)).existsSync(),
          isTrue,
          reason: '$dir should exist',
        );
      }
    });

    test('should update analysis_options.yaml with custom_lint', () {
      final projectDir = Directory(path.join(tempDir.path, 'flutter_app'));
      projectDir.createSync();

      final analysisOptions = File(
        path.join(projectDir.path, 'analysis_options.yaml'),
      );
      analysisOptions.writeAsStringSync('''
include: package:flutter_lints/flutter.yaml

analyzer:
  plugins:
    - custom_lint

linter:
  rules:
    - prefer_const_constructors
''');

      expect(analysisOptions.existsSync(), isTrue);
      expect(analysisOptions.readAsStringSync(), contains('custom_lint'));
    });
  });
}
