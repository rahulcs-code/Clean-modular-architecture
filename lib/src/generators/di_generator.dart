import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

// Type checkers for annotations using URL-based approach
const _injectableChecker = TypeChecker.fromUrl(
  'package:clean_modular_architecture/src/generators/annotations.dart#Injectable',
);
const _lazySingletonChecker = TypeChecker.fromUrl(
  'package:clean_modular_architecture/src/generators/annotations.dart#LazySingleton',
);
const _singletonChecker = TypeChecker.fromUrl(
  'package:clean_modular_architecture/src/generators/annotations.dart#Singleton',
);

/// Generator for dependency injection registrations.
///
/// Scans for classes annotated with @Injectable, @LazySingleton, @Singleton,
/// and generates get_it registration code.
class DiGenerator extends Generator {
  @override
  FutureOr<String?> generate(LibraryReader library, BuildStep buildStep) async {
    final annotatedClasses = <_AnnotatedClass>[];

    // Find all Injectable annotated classes
    for (final annotatedElement in library.annotatedWith(_injectableChecker)) {
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
    for (final annotatedElement in library.annotatedWith(_lazySingletonChecker)) {
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
    for (final annotatedElement in library.annotatedWith(_singletonChecker)) {
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

    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln('// ignore_for_file: type=lint');
    buffer.writeln();
    buffer.writeln("part of 'injection_container.dart';");
    buffer.writeln();
    buffer.writeln('/// Initialize all generated dependencies.');
    buffer.writeln('void _initGenerated(GetIt sl) {');

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
        case _RegistrationType.singleton:
          buffer.writeln('  sl.registerSingleton<$registerAs>(');
          buffer.writeln('    $className(${_formatDependencies(dependencies)}),');
          buffer.writeln('  );');
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
      return asType.getDisplayString();
    }

    return annotatedClass.element.name ?? 'dynamic';
  }

  List<_Dependency> _getDependencies(ClassElement element) {
    final dependencies = <_Dependency>[];

    // Find the primary constructor
    final constructor = element.unnamedConstructor ??
        element.constructors.firstWhere(
          (c) => !c.isFactory,
          orElse: () => element.constructors.first,
        );

    for (final param in constructor.formalParameters) {
      final paramType = param.type.getDisplayString();
      final paramName = param.name;
      if (paramName != null) {
        dependencies.add(_Dependency(
          name: paramName,
          type: paramType,
          isNamed: param.isNamed,
        ));
      }
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
