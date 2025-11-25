import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'annotations.dart';

/// Generator for route configuration.
///
/// Scans for classes annotated with @RoutePage and @RouteGuard,
/// and generates go_router configuration code.
class RouteGenerator extends Generator {
  @override
  FutureOr<String?> generate(LibraryReader library, BuildStep buildStep) async {
    final routes = <_RouteInfo>[];
    final guards = <_GuardInfo>[];

    // Find all RoutePage annotated classes
    for (final annotatedElement
        in library.annotatedWith(const TypeChecker.fromRuntime(RoutePage))) {
      final element = annotatedElement.element;
      if (element is ClassElement) {
        routes.add(_RouteInfo(
          element: element,
          annotation: annotatedElement.annotation,
        ));
      }
    }

    // Find all RouteGuard annotated classes
    for (final annotatedElement
        in library.annotatedWith(const TypeChecker.fromRuntime(RouteGuard))) {
      final element = annotatedElement.element;
      if (element is ClassElement) {
        guards.add(_GuardInfo(element: element));
      }
    }

    if (routes.isEmpty) {
      return null;
    }

    return _generateRoutes(routes, guards);
  }

  String _generateRoutes(List<_RouteInfo> routes, List<_GuardInfo> guards) {
    final buffer = StringBuffer();

    buffer.writeln("// GENERATED CODE - DO NOT MODIFY BY HAND");
    buffer.writeln("// ignore_for_file: type=lint");
    buffer.writeln();
    buffer.writeln("part of 'app_router.dart';");
    buffer.writeln();

    // Generate route constants
    buffer.writeln("/// Route path constants.");
    buffer.writeln("abstract class AppRoutes {");
    for (final route in routes) {
      final path = route.annotation.peek('path')?.stringValue ?? '/';
      final constantName = _pathToConstantName(path);
      buffer.writeln("  static const String $constantName = '$path';");
    }
    buffer.writeln("}");
    buffer.writeln();

    // Generate router configuration
    buffer.writeln("/// Generated router configuration.");
    buffer.writeln("List<RouteBase> get _generatedRoutes => [");

    for (final route in routes) {
      final className = route.element.name;
      final path = route.annotation.peek('path')?.stringValue ?? '/';

      buffer.writeln("  GoRoute(");
      buffer.writeln("    path: '$path',");
      buffer.writeln("    builder: (context, state) => const $className(),");
      buffer.writeln("  ),");
    }

    buffer.writeln("];");

    return buffer.toString();
  }

  String _pathToConstantName(String path) {
    // Convert /user-profile to userProfile
    final segments = path
        .replaceAll(RegExp(r'^/'), '')
        .split(RegExp(r'[/-]'))
        .where((s) => s.isNotEmpty);

    if (segments.isEmpty) return 'root';

    final first = segments.first.toLowerCase();
    final rest = segments.skip(1).map((s) =>
      s[0].toUpperCase() + s.substring(1).toLowerCase()
    );

    return first + rest.join();
  }
}

class _RouteInfo {
  final ClassElement element;
  final ConstantReader annotation;

  _RouteInfo({
    required this.element,
    required this.annotation,
  });
}

class _GuardInfo {
  final ClassElement element;

  _GuardInfo({required this.element});
}

/// Builder factory for the route generator.
Builder routeBuilder(BuilderOptions options) => SharedPartBuilder(
      [RouteGenerator()],
      'routes',
    );
