import 'dart:io';

/// ANSI color codes for terminal output.
class _AnsiColors {
  static const String reset = '\x1B[0m';
  static const String red = '\x1B[31m';
  static const String green = '\x1B[32m';
  static const String yellow = '\x1B[33m';
  static const String blue = '\x1B[34m';
  static const String magenta = '\x1B[35m';
  static const String cyan = '\x1B[36m';
  static const String white = '\x1B[37m';
  static const String bold = '\x1B[1m';
}

/// Logger for CLI output with colored messages.
class CliLogger {
  /// Whether to use colors in output.
  final bool useColors;

  /// Whether to show verbose output.
  bool verbose;

  /// Creates a [CliLogger].
  CliLogger({this.useColors = true, this.verbose = false});

  /// Prints an info message.
  void info(String message) {
    _print(message, _AnsiColors.blue, '');
  }

  /// Prints a success message.
  void success(String message) {
    _print(message, _AnsiColors.green, '✓');
  }

  /// Prints a warning message.
  void warning(String message) {
    _print(message, _AnsiColors.yellow, '⚠');
  }

  /// Prints an error message.
  void error(String message) {
    _print(message, _AnsiColors.red, '✗', isError: true);
  }

  /// Prints a detail message (only in verbose mode).
  void detail(String message) {
    if (verbose) {
      _print(message, _AnsiColors.white, '  ');
    }
  }

  /// Prints a progress message.
  void progress(String message) {
    _print(message, _AnsiColors.cyan, '→');
  }

  /// Prints a header.
  void header(String message) {
    print('');
    if (useColors) {
      print('${_AnsiColors.bold}${_AnsiColors.magenta}$message${_AnsiColors.reset}');
    } else {
      print(message);
    }
    print('');
  }

  /// Prints a newline.
  void newLine() {
    print('');
  }

  /// Prints a list of items.
  void list(List<String> items, {String prefix = '  •'}) {
    for (final item in items) {
      if (useColors) {
        print('${_AnsiColors.white}$prefix $item${_AnsiColors.reset}');
      } else {
        print('$prefix $item');
      }
    }
  }

  /// Prints a command hint.
  void command(String command) {
    if (useColors) {
      print('  ${_AnsiColors.cyan}\$ $command${_AnsiColors.reset}');
    } else {
      print('  \$ $command');
    }
  }

  void _print(
    String message,
    String color,
    String prefix, {
    bool isError = false,
  }) {
    final output = isError ? stderr : stdout;
    final prefixStr = prefix.isNotEmpty ? '$prefix ' : '';

    if (useColors) {
      output.writeln('$color$prefixStr$message${_AnsiColors.reset}');
    } else {
      output.writeln('$prefixStr$message');
    }
  }
}

/// Default logger instance.
final logger = CliLogger();
