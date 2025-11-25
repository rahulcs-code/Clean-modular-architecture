/// Base classes for Clean Modular Architecture.
///
/// This library exports all base classes used in Clean Architecture:
/// - UseCase, SyncUseCase, StreamUseCase for business logic
/// - Failure hierarchy for error handling in domain layer
/// - Exception hierarchy for error handling in data layer
/// - NoParams for use cases without parameters
library cma_base;

export 'use_case.dart';
export 'failure.dart';
export 'exceptions.dart';
export 'no_params.dart';
