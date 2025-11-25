# Clean Modular Architecture Example

This example demonstrates how to use the Clean Modular Architecture package in a Flutter project.

## Quick Setup

```bash
# Create a new Flutter project with CMA structure
dart run clean_arch create my_app

# Or initialize in an existing project
dart run clean_arch init
```

## Generate Components

```bash
# Generate a complete feature
dart run clean_arch generate feature auth

# Generate individual components
dart run clean_arch generate entity user --feature auth
dart run clean_arch generate model user --feature auth
dart run clean_arch generate repository user --feature auth
dart run clean_arch generate usecase login_with_email --feature auth
dart run clean_arch generate bloc auth --feature auth
```

## Example Structure

After running the commands above, your project will have:

```
lib/
├── core/
│   ├── common/
│   │   ├── cubits/
│   │   │   └── auth_cubit.dart      # Global auth state
│   │   └── widgets/
│   ├── errors/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   └── injection_container/
│       └── injection_container.dart
└── features/
    └── auth/
        ├── data/
        │   ├── datasources/
        │   │   └── auth_remote_data_source.dart
        │   ├── models/
        │   │   └── user_model.dart
        │   └── repositories/
        │       └── auth_repository_impl.dart
        ├── domain/
        │   ├── entities/
        │   │   └── user.dart
        │   ├── repositories/
        │   │   └── auth_repository.dart
        │   └── usecases/
        │       └── login_with_email.dart
        └── presentation/
            ├── bloc/
            │   ├── auth_bloc.dart
            │   ├── auth_event.dart
            │   └── auth_state.dart
            └── pages/
                └── login_page.dart
```

## Example Code

### Entity (Domain Layer)

```dart
// lib/features/auth/domain/entities/user.dart
class User {
  final String id;
  final String name;
  final String email;

  const User({
    required this.id,
    required this.name,
    required this.email,
  });
}
```

### Model (Data Layer)

```dart
// lib/features/auth/data/models/user_model.dart
import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
  };

  UserModel copyWith({String? id, String? name, String? email}) => UserModel(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
  );
}
```

### Repository Interface (Domain Layer)

```dart
// lib/features/auth/domain/repositories/auth_repository.dart
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, Unit>> logout();
}
```

### Repository Implementation (Data Layer)

```dart
// lib/features/auth/data/repositories/auth_repository_impl.dart
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.login(email: email, password: password);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
```

### UseCase (Domain Layer)

```dart
// lib/features/auth/domain/usecases/login_with_email.dart
import 'package:clean_modular_architecture/clean_modular_architecture.dart';
import 'package:fpdart/fpdart.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginWithEmail implements UseCase<User, LoginParams> {
  final AuthRepository repository;

  LoginWithEmail(this.repository);

  @override
  Future<Either<Failure, User>> call(LoginParams params) async {
    return repository.login(
      email: params.email,
      password: params.password,
    );
  }
}

class LoginParams {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});
}
```

### BLoC (Presentation Layer)

```dart
// lib/features/auth/presentation/bloc/auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/common/cubits/auth_cubit.dart';
import '../../domain/usecases/login_with_email.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginWithEmail loginWithEmail;
  final AuthCubit authCubit;

  AuthBloc({
    required this.loginWithEmail,
    required this.authCubit,
  }) : super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await loginWithEmail(
      LoginParams(email: event.email, password: event.password),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) {
        authCubit.setAuthenticated(user);
        emit(AuthAuthenticated(user));
      },
    );
  }
}
```

### Dependency Injection

```dart
// lib/core/injection_container/injection_container.dart
import 'package:get_it/get_it.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_with_email.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../common/cubits/auth_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Cubits
  sl.registerLazySingleton(() => AuthCubit());

  // BLoCs
  sl.registerLazySingleton(() => AuthBloc(
    loginWithEmail: sl(),
    authCubit: sl(),
  ));

  // UseCases
  sl.registerLazySingleton(() => LoginWithEmail(sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
    remoteDataSource: sl(),
  ));

  // DataSources
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl());
}
```

### Main App Setup

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/injection_container/injection_container.dart' as di;
import 'core/common/cubits/auth_cubit.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthCubit>()),
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CMA Example',
      home: const LoginPage(),
    );
  }
}
```

## Run Doctor

Check your project setup:

```bash
dart run clean_arch doctor
```

## Lint Rules

The package includes 16 custom lint rules that will flag architecture violations in your IDE. See the main README for details.
