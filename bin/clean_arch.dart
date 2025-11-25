import 'dart:io';
import 'package:clean_modular_architecture/src/cli/cli_runner.dart';

/// Clean Modular Architecture CLI entry point.
///
/// Usage:
/// ```bash
/// dart run clean_arch init
/// dart run clean_arch generate feature auth
/// dart run clean_arch generate bloc login --feature auth
/// dart run clean_arch doctor
/// ```
Future<void> main(List<String> arguments) async {
  final runner = CleanArchCommandRunner();

  try {
    final exitCode = await runner.run(arguments);
    exit(exitCode ?? 0);
  } on Exception catch (e) {
    stderr.writeln('Error: $e');
    exit(1);
  }
}
