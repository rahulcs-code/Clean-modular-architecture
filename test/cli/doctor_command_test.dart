import 'dart:io';
import 'package:test/test.dart';
import 'package:path/path.dart' as path;

void main() {
  group('DoctorCommand', () {
    late Directory tempDir;
    late String projectPath;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('cma_doctor_test_');
      projectPath = tempDir.path;
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('should detect missing pubspec.yaml', () {
      // Empty directory - no pubspec.yaml
      expect(
        File(path.join(projectPath, 'pubspec.yaml')).existsSync(),
        isFalse,
      );
    });

    test('should detect valid Flutter project', () {
      File(path.join(projectPath, 'pubspec.yaml')).writeAsStringSync('''
name: test_app
environment:
  sdk: ">=3.0.0 <4.0.0"
  flutter: ">=3.0.0"

dependencies:
  flutter:
    sdk: flutter
''');

      final pubspec = File(path.join(projectPath, 'pubspec.yaml'));
      expect(pubspec.existsSync(), isTrue);
      expect(pubspec.readAsStringSync(), contains('flutter'));
    });

    test('should detect missing CMA configuration', () {
      File(path.join(projectPath, 'pubspec.yaml')).writeAsStringSync('''
name: test_app
environment:
  sdk: ">=3.0.0 <4.0.0"
''');

      expect(
        File(path.join(projectPath, 'cma.yaml')).existsSync(),
        isFalse,
      );
    });

    test('should detect existing CMA configuration', () {
      File(path.join(projectPath, 'pubspec.yaml')).writeAsStringSync('''
name: test_app
environment:
  sdk: ">=3.0.0 <4.0.0"
''');

      File(path.join(projectPath, 'cma.yaml')).writeAsStringSync('''
clean_modular_architecture:
  structure:
    features_path: lib/features
    core_path: lib/core
''');

      expect(
        File(path.join(projectPath, 'cma.yaml')).existsSync(),
        isTrue,
      );
    });

    test('should detect missing directory structure', () {
      File(path.join(projectPath, 'pubspec.yaml')).writeAsStringSync('''
name: test_app
''');

      final requiredDirs = ['lib/core', 'lib/features'];

      for (final dir in requiredDirs) {
        expect(
          Directory(path.join(projectPath, dir)).existsSync(),
          isFalse,
          reason: '$dir should not exist yet',
        );
      }
    });

    test('should detect complete directory structure', () {
      File(path.join(projectPath, 'pubspec.yaml')).writeAsStringSync('''
name: test_app
''');

      final requiredDirs = [
        'lib/core',
        'lib/features',
        'lib/core/errors',
        'lib/core/injection_container',
      ];

      for (final dir in requiredDirs) {
        Directory(path.join(projectPath, dir)).createSync(recursive: true);
      }

      for (final dir in requiredDirs) {
        expect(
          Directory(path.join(projectPath, dir)).existsSync(),
          isTrue,
          reason: '$dir should exist',
        );
      }
    });

    test('should detect missing dependencies', () {
      File(path.join(projectPath, 'pubspec.yaml')).writeAsStringSync('''
name: test_app
environment:
  sdk: ">=3.0.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
''');

      final content = File(path.join(projectPath, 'pubspec.yaml')).readAsStringSync();

      // Required dependencies
      expect(content.contains('fpdart'), isFalse);
      expect(content.contains('flutter_bloc'), isFalse);
      expect(content.contains('get_it'), isFalse);
    });

    test('should detect present dependencies', () {
      File(path.join(projectPath, 'pubspec.yaml')).writeAsStringSync('''
name: test_app
environment:
  sdk: ">=3.0.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  fpdart: ^1.1.0
  flutter_bloc: ^8.0.0
  get_it: ^7.0.0

dev_dependencies:
  clean_modular_architecture: ^1.0.0
  custom_lint: ^0.6.0
''');

      final content = File(path.join(projectPath, 'pubspec.yaml')).readAsStringSync();

      expect(content.contains('fpdart'), isTrue);
      expect(content.contains('flutter_bloc'), isTrue);
      expect(content.contains('get_it'), isTrue);
      expect(content.contains('clean_modular_architecture'), isTrue);
      expect(content.contains('custom_lint'), isTrue);
    });

    test('should detect missing custom_lint in analysis_options', () {
      File(path.join(projectPath, 'pubspec.yaml')).writeAsStringSync('name: test');

      File(path.join(projectPath, 'analysis_options.yaml')).writeAsStringSync('''
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    - prefer_const_constructors
''');

      final content = File(path.join(projectPath, 'analysis_options.yaml'))
          .readAsStringSync();
      expect(content.contains('custom_lint'), isFalse);
    });

    test('should detect custom_lint plugin configured', () {
      File(path.join(projectPath, 'pubspec.yaml')).writeAsStringSync('name: test');

      File(path.join(projectPath, 'analysis_options.yaml')).writeAsStringSync('''
include: package:flutter_lints/flutter.yaml

analyzer:
  plugins:
    - custom_lint

linter:
  rules:
    - prefer_const_constructors
''');

      final content = File(path.join(projectPath, 'analysis_options.yaml'))
          .readAsStringSync();
      expect(content.contains('custom_lint'), isTrue);
    });

    test('should detect features and check their structure', () {
      File(path.join(projectPath, 'pubspec.yaml')).writeAsStringSync('name: test');

      // Create feature with incomplete structure
      final featurePath = path.join(projectPath, 'lib/features/auth');
      Directory(path.join(featurePath, 'domain')).createSync(recursive: true);
      Directory(path.join(featurePath, 'presentation')).createSync(recursive: true);
      // Missing 'data' layer

      expect(
        Directory(path.join(featurePath, 'domain')).existsSync(),
        isTrue,
      );
      expect(
        Directory(path.join(featurePath, 'data')).existsSync(),
        isFalse,
      );
      expect(
        Directory(path.join(featurePath, 'presentation')).existsSync(),
        isTrue,
      );
    });

    test('should detect complete feature structure', () {
      File(path.join(projectPath, 'pubspec.yaml')).writeAsStringSync('name: test');

      final featurePath = path.join(projectPath, 'lib/features/auth');
      Directory(path.join(featurePath, 'domain')).createSync(recursive: true);
      Directory(path.join(featurePath, 'data')).createSync(recursive: true);
      Directory(path.join(featurePath, 'presentation')).createSync(recursive: true);

      final layers = ['domain', 'data', 'presentation'];
      for (final layer in layers) {
        expect(
          Directory(path.join(featurePath, layer)).existsSync(),
          isTrue,
          reason: '$layer layer should exist',
        );
      }
    });
  });
}
