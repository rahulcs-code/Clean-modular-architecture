import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'annotations.dart';

/// Generator for dependency injection registrations.
///
/// Scans for classes annotated with @Injectable, @LazySingleton, @Singleton,
/// and generates get_it registration code.
class DiGenerator extends Generator {
  @override
  FutureOr<String?> generate(LibraryReader library, BuildStep buildStep) async {
    final annotatedClasses = <_AnnotatedClass>[];

    // Find all Injectable annotated classes
    for (final annotatedElement
        in library.annotatedWith(const TypeChecker.fromRuntime(Injectable))) {
      final element = annotatedElement.element;
      if (element is ClassElement) {
        annotatedClasses.add(_AnnotatedClass(
          element: element,
          annotation: annotatedElement.annotation,
          type: _RegistrationType.injectable,
        ));
      }
    }

    // Find all LazySingleton annotated classes
    for (final annotatedElement
        in library.annotatedWith(const TypeChecker.fromRuntime(LazySingleton))) {
      final element = annotatedElement.element;
      if (element is ClassElement) {
        annotatedClasses.add(_AnnotatedClass(
          element: element,
          annotation: annotatedElement.annotation,
          type: _RegistrationType.lazySingleton,
        ));
      }
    }

    // Find all Singleton annotated classes
    for (final annotatedElement
        in library.annotatedWith(const TypeChecker.fromRuntime(Singleton))) {
      final element = annotatedElement.element;
      if (element is ClassElement) {
        annotatedClasses.add(_AnnotatedClass(
          element: element,
          annotation: annotatedElement.annotation,
          type: _RegistrationType.singleton,
        ));
      }
    }

    if (annotatedClasses.isEmpty) {
      return null;
    }

    return _generateRegistrations(annotatedClasses);
  }

  String _generateRegistrations(List<_AnnotatedClass> classes) {
    final buffer = StringBuffer();

    buffer.writeln("// GENERATED CODE - DO NOT MODIFY BY HAND");
    buffer.writeln("// ignore_for_file: type=lint");
    buffer.writeln();
    buffer.writeln("part of 'injection_container.dart';");
    buffer.writeln();
    buffer.writeln("/// Initialize all generated dependencies.");
    buffer.writeln("void _initGenerated(GetIt sl) {");

    for (final annotatedClass in classes) {
      final className = annotatedClass.element.name;
      final registerAs = _getRegisterAsType(annotatedClass);
      final dependencies = _getDependencies(annotatedClass.element);

      switch (annotatedClass.type) {
        case _RegistrationType.lazySingleton:
        case _RegistrationType.injectable:
          buffer.writeln('  sl.registerLazySingleton<$registerAs>(');
          buffer.writeln('    () => $className(${_formatDependencies(dependencies)}),');
          buffer.writeln('  );');
          break;
        case _RegistrationType.singleton:
          buffer.writeln('  sl.registerSingleton<$registerAs>(');
          buffer.writeln('    $className(${_formatDependencies(dependencies)}),');
          buffer.writeln('  );');
          break;
      }
      buffer.writeln();
    }

    buffer.writeln('}');

    return buffer.toString();
  }

  String _getRegisterAsType(_AnnotatedClass annotatedClass) {
    final annotation = annotatedClass.annotation;
    final asType = annotation.peek('as')?.typeValue;

    if (asType != null) {
      return asType.getDisplayString(withNullability: false);
    }

    return annotatedClass.element.name;
  }

  List<_Dependency> _getDependencies(ClassElement element) {
    final dependencies = <_Dependency>[];

    // Find the primary constructor
    final constructor = element.unnamedConstructor ??
        element.constructors.firstWhere(
          (c) => !c.isFactory,
          orElse: () => element.constructors.first,
        );

    for (final param in constructor.parameters) {
      final paramType = param.type.getDisplayString(withNullability: false);
      dependencies.add(_Dependency(
        name: param.name,
        type: paramType,
        isNamed: param.isNamed,
      ));
    }

    return dependencies;
  }

  String _formatDependencies(List<_Dependency> dependencies) {
    if (dependencies.isEmpty) return '';

    return dependencies.map((dep) {
      if (dep.isNamed) {
        return '${dep.name}: sl<${dep.type}>()';
      }
      return 'sl<${dep.type}>()';
    }).join(', ');
  }
}

enum _RegistrationType {
  injectable,
  lazySingleton,
  singleton,
}

class _AnnotatedClass {
  final ClassElement element;
  final ConstantReader annotation;
  final _RegistrationType type;

  _AnnotatedClass({
    required this.element,
    required this.annotation,
    required this.type,
  });
}

class _Dependency {
  final String name;
  final String type;
  final bool isNamed;

  _Dependency({
    required this.name,
    required this.type,
    required this.isNamed,
  });
}

/// Builder factory for the DI generator.
Builder diBuilder(BuilderOptions options) => SharedPartBuilder(
      [DiGenerator()],
      'di',
    );
