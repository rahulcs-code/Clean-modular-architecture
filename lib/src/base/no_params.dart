/// Use when a use case requires no parameters.
///
/// ## Usage
///
/// ```dart
/// class GetCurrentUser implements UseCase<User, NoParams> {
///   final UserRepository repository;
///
///   const GetCurrentUser(this.repository);
///
///   @override
///   Future<Either<Failure, User>> call(NoParams params) async {
///     return await repository.getCurrentUser();
///   }
/// }
///
/// // Calling the use case
/// final result = await getCurrentUser(const NoParams());
/// ```
///
/// See: docs/guidelines/04_use_case_pattern.md
class NoParams {
  /// Creates a [NoParams] instance.
  const NoParams();

  @override
  bool operator ==(Object other) => other is NoParams;

  @override
  int get hashCode => 0;

  @override
  String toString() => 'NoParams()';
}
