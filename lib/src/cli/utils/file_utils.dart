import 'dart:io';
import 'package:path/path.dart' as path;

/// Utility functions for file operations.
class FileUtils {
  /// Creates a directory if it doesn't exist.
  static Future<Directory> ensureDirectory(String dirPath) async {
    final dir = Directory(dirPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Creates a file with content.
  static Future<File> createFile(String filePath, String content) async {
    final file = File(filePath);
    await ensureDirectory(path.dirname(filePath));
    await file.writeAsString(content);
    return file;
  }

  /// Checks if a file exists.
  static Future<bool> fileExists(String filePath) async {
    return File(filePath).exists();
  }

  /// Checks if a directory exists.
  static Future<bool> directoryExists(String dirPath) async {
    return Directory(dirPath).exists();
  }

  /// Gets the project root directory (containing pubspec.yaml).
  static String? findProjectRoot([String? startPath]) {
    var current = startPath ?? Directory.current.path;

    while (true) {
      final pubspec = File(path.join(current, 'pubspec.yaml'));
      if (pubspec.existsSync()) {
        return current;
      }

      final parent = path.dirname(current);
      if (parent == current) {
        // Reached root without finding pubspec.yaml
        return null;
      }
      current = parent;
    }
  }

  /// Reads the project name from pubspec.yaml.
  static String? getProjectName([String? projectRoot]) {
    final root = projectRoot ?? findProjectRoot();
    if (root == null) return null;

    final pubspecFile = File(path.join(root, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) return null;

    final content = pubspecFile.readAsStringSync();
    final nameMatch = RegExp(r'^name:\s*(\S+)', multiLine: true).firstMatch(content);
    return nameMatch?.group(1);
  }

  /// Converts a string to snake_case.
  static String toSnakeCase(String input) {
    return input
        .replaceAllMapped(
          RegExp(r'[A-Z]'),
          (match) => '_${match.group(0)!.toLowerCase()}',
        )
        .replaceAll(RegExp(r'^_'), '')
        .replaceAll(RegExp(r'[-\s]+'), '_')
        .toLowerCase();
  }

  /// Converts a string to PascalCase.
  static String toPascalCase(String input) {
    // If input contains separators, split by them
    if (RegExp(r'[-_\s]').hasMatch(input)) {
      return input
          .replaceAll(RegExp(r'[-_\s]+'), ' ')
          .split(' ')
          .map((word) => word.isEmpty
              ? ''
              : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
          .join();
    }
    // If already in PascalCase or camelCase, just capitalize first letter
    if (input.isEmpty) return input;
    return '${input[0].toUpperCase()}${input.substring(1)}';
  }

  /// Converts a string to camelCase.
  static String toCamelCase(String input) {
    final pascal = toPascalCase(input);
    if (pascal.isEmpty) return pascal;
    return '${pascal[0].toLowerCase()}${pascal.substring(1)}';
  }

  /// Gets the relative path from one path to another.
  static String relativePath(String from, String to) {
    return path.relative(to, from: from);
  }

  /// Joins path segments.
  static String joinPath(List<String> segments) {
    return path.joinAll(segments);
  }
}
