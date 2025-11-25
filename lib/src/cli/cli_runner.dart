import 'package:args/command_runner.dart';
import 'commands/init_command.dart';
import 'commands/generate_command.dart';
import 'commands/create_command.dart';
import 'commands/doctor_command.dart';

/// Command runner for the Clean Architecture CLI.
///
/// Provides commands for:
/// - `init` - Initialize CMA in an existing project
/// - `create` - Create a new project with CMA structure
/// - `generate` - Generate architecture components
/// - `doctor` - Check project setup and configuration
class CleanArchCommandRunner extends CommandRunner<int> {
  /// Creates a new [CleanArchCommandRunner].
  CleanArchCommandRunner()
      : super(
          'clean_arch',
          'Clean Modular Architecture CLI\n\n'
              'A Flutter framework for enforcing Clean Architecture patterns.',
        ) {
    // Add global flags
    argParser
      ..addFlag(
        'verbose',
        abbr: 'v',
        negatable: false,
        help: 'Show verbose output.',
      )
      ..addFlag(
        'version',
        negatable: false,
        help: 'Print the CLI version.',
      );

    // Register commands
    addCommand(InitCommand());
    addCommand(CreateCommand());
    addCommand(GenerateCommand());
    addCommand(DoctorCommand());
  }

  @override
  Future<int?> run(Iterable<String> args) async {
    try {
      final results = parse(args);

      // Handle --version flag
      if (results['version'] == true) {
        print('clean_arch version 1.0.0');
        return 0;
      }

      return await runCommand(results) ?? 0;
    } on UsageException catch (e) {
      print(e);
      return 64; // Exit code for command line usage error
    } on Exception catch (e) {
      print('Error: $e');
      return 1;
    }
  }
}
