/// Annotations for code generation.
///
/// These annotations are used by the build_runner generators to automatically
/// generate dependency injection bindings, routes, and other boilerplate.

/// Marks a class for dependency injection registration.
///
/// By default, classes are registered as lazy singletons.
///
/// ## Usage
///
/// ```dart
/// @Injectable()
/// class AuthRepositoryImpl implements AuthRepository {
///   // ...
/// }
///
/// // With custom registration
/// @Injectable(as: AuthRepository)
/// class AuthRepositoryImpl implements AuthRepository {
///   // ...
/// }
/// ```
class Injectable {
  /// The type to register this class as.
  /// If null, registers as the class's own type.
  final Type? as;

  /// Environment tags for conditional registration.
  final List<String>? env;

  /// Creates an [Injectable] annotation.
  const Injectable({this.as, this.env});
}

/// Marks a class for lazy singleton registration.
///
/// The instance is created only when first accessed and reused thereafter.
/// This is the recommended registration type for most dependencies.
///
/// ## Usage
///
/// ```dart
/// @LazySingleton()
/// class HttpService {
///   // ...
/// }
///
/// @LazySingleton(as: AuthRepository)
/// class AuthRepositoryImpl implements AuthRepository {
///   // ...
/// }
/// ```
class LazySingleton {
  /// The type to register this class as.
  final Type? as;

  /// Environment tags for conditional registration.
  final List<String>? env;

  /// Creates a [LazySingleton] annotation.
  const LazySingleton({this.as, this.env});
}

/// Marks a class for singleton registration.
///
/// The instance is created immediately during registration.
/// Use sparingly - prefer [LazySingleton] in most cases.
///
/// ## Usage
///
/// ```dart
/// @Singleton()
/// class AppConfig {
///   // ...
/// }
/// ```
class Singleton {
  /// The type to register this class as.
  final Type? as;

  /// Environment tags for conditional registration.
  final List<String>? env;

  /// Creates a [Singleton] annotation.
  const Singleton({this.as, this.env});
}

/// Marks a module class that groups related dependency registrations.
///
/// ## Usage
///
/// ```dart
/// @Module()
/// abstract class AuthModule {
///   @LazySingleton(as: AuthRepository)
///   AuthRepositoryImpl get authRepository;
///
///   @LazySingleton()
///   LoginWithEmail get loginWithEmail;
/// }
/// ```
class Module {
  /// Creates a [Module] annotation.
  const Module();
}

/// Marks a class as a route for navigation.
///
/// Used by the route generator to automatically build router configuration.
///
/// ## Usage
///
/// ```dart
/// @RoutePage(path: '/login')
/// class LoginPage extends StatelessWidget {
///   // ...
/// }
///
/// @RoutePage(path: '/home', guards: [AuthGuard])
/// class HomePage extends StatelessWidget {
///   // ...
/// }
/// ```
class RoutePage {
  /// The route path.
  final String path;

  /// Route guards to apply.
  final List<Type>? guards;

  /// Whether this is the initial route.
  final bool initial;

  /// Creates a [RoutePage] annotation.
  const RoutePage({
    required this.path,
    this.guards,
    this.initial = false,
  });
}

/// Marks a class as a route guard.
///
/// ## Usage
///
/// ```dart
/// @RouteGuard()
/// class AuthGuard {
///   Future<bool> canActivate() async {
///     // Check if user is authenticated
///   }
/// }
/// ```
class RouteGuard {
  /// Creates a [RouteGuard] annotation.
  const RouteGuard();
}
