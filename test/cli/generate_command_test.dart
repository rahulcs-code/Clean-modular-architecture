import 'dart:io';
import 'package:test/test.dart';
import 'package:path/path.dart' as path;

void main() {
  group('GenerateCommand', () {
    late Directory tempDir;
    late String projectPath;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('cma_generate_test_');
      projectPath = tempDir.path;

      // Create mock Flutter project structure
      File(path.join(projectPath, 'pubspec.yaml')).writeAsStringSync('''
name: test_app
environment:
  sdk: ">=3.0.0 <4.0.0"
''');

      Directory(path.join(projectPath, 'lib/features')).createSync(recursive: true);
      Directory(path.join(projectPath, 'lib/core')).createSync(recursive: true);
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    group('feature generation', () {
      test('should create complete feature directory structure', () {
        final featurePath = path.join(projectPath, 'lib/features/auth');

        // Simulate feature generation
        final dirs = [
          'domain/entities',
          'domain/repositories',
          'domain/usecases',
          'data/models',
          'data/datasources',
          'data/repositories',
          'presentation/bloc',
          'presentation/pages',
          'presentation/widgets',
        ];

        for (final dir in dirs) {
          Directory(path.join(featurePath, dir)).createSync(recursive: true);
        }

        // Verify structure
        for (final dir in dirs) {
          expect(
            Directory(path.join(featurePath, dir)).existsSync(),
            isTrue,
            reason: '$dir should exist',
          );
        }
      });

      test('should prevent duplicate feature creation', () {
        final featurePath = path.join(projectPath, 'lib/features/auth');
        Directory(featurePath).createSync(recursive: true);

        // Feature already exists
        expect(Directory(featurePath).existsSync(), isTrue);
      });
    });

    group('entity generation', () {
      test('should create entity file in correct location', () {
        final entityPath = path.join(
          projectPath,
          'lib/features/auth/domain/entities/user.dart',
        );

        Directory(path.dirname(entityPath)).createSync(recursive: true);

        File(entityPath).writeAsStringSync('''
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
''');

        expect(File(entityPath).existsSync(), isTrue);
        final content = File(entityPath).readAsStringSync();
        expect(content, contains('class User'));
        expect(content, contains('final String id'));
        expect(content, contains('const User'));
      });
    });

    group('model generation', () {
      test('should create model that extends entity', () {
        final modelPath = path.join(
          projectPath,
          'lib/features/auth/data/models/user_model.dart',
        );

        Directory(path.dirname(modelPath)).createSync(recursive: true);

        File(modelPath).writeAsStringSync('''
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
}
''');

        expect(File(modelPath).existsSync(), isTrue);
        final content = File(modelPath).readAsStringSync();
        expect(content, contains('extends User'));
        expect(content, contains('fromJson'));
        expect(content, contains('toJson'));
      });
    });

    group('repository generation', () {
      test('should create repository interface in domain', () {
        final repoPath = path.join(
          projectPath,
          'lib/features/auth/domain/repositories/auth_repository.dart',
        );

        Directory(path.dirname(repoPath)).createSync(recursive: true);

        File(repoPath).writeAsStringSync('''
import 'package:fpdart/fpdart.dart';
import '../entities/user.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    required String password,
  });

  Future<Either<Failure, Unit>> logout();
}
''');

        expect(File(repoPath).existsSync(), isTrue);
        final content = File(repoPath).readAsStringSync();
        expect(content, contains('abstract interface class'));
        expect(content, contains('Either<Failure, User>'));
      });

      test('should create repository implementation in data', () {
        final implPath = path.join(
          projectPath,
          'lib/features/auth/data/repositories/auth_repository_impl.dart',
        );

        Directory(path.dirname(implPath)).createSync(recursive: true);

        File(implPath).writeAsStringSync('''
import 'package:fpdart/fpdart.dart';
import '../../domain/repositories/auth_repository.dart';
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
      final result = await remoteDataSource.login(email, password);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
''');

        expect(File(implPath).existsSync(), isTrue);
        final content = File(implPath).readAsStringSync();
        expect(content, contains('implements AuthRepository'));
        expect(content, contains('UserModel'));
      });
    });

    group('bloc generation', () {
      test('should create BLoC with events and states', () {
        final blocDir = path.join(
          projectPath,
          'lib/features/auth/presentation/bloc',
        );
        Directory(blocDir).createSync(recursive: true);

        // BLoC file
        File(path.join(blocDir, 'auth_bloc.dart')).writeAsStringSync('''
import 'package:flutter_bloc/flutter_bloc.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    // implementation
  }
}
''');

        // Event file
        File(path.join(blocDir, 'auth_event.dart')).writeAsStringSync('''
part of 'auth_bloc.dart';

sealed class AuthEvent {}

final class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  AuthLoginRequested({required this.email, required this.password});
}
''');

        // State file
        File(path.join(blocDir, 'auth_state.dart')).writeAsStringSync('''
part of 'auth_bloc.dart';

sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthAuthenticated extends AuthState {
  final User user;
  AuthAuthenticated(this.user);
}

final class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
''');

        expect(File(path.join(blocDir, 'auth_bloc.dart')).existsSync(), isTrue);
        expect(File(path.join(blocDir, 'auth_event.dart')).existsSync(), isTrue);
        expect(File(path.join(blocDir, 'auth_state.dart')).existsSync(), isTrue);
      });
    });

    group('cubit generation', () {
      test('should create global cubit in core directory', () {
        final cubitPath = path.join(
          projectPath,
          'lib/core/common/cubits/auth_cubit.dart',
        );

        Directory(path.dirname(cubitPath)).createSync(recursive: true);

        File(cubitPath).writeAsStringSync('''
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthCubitState> {
  AuthCubit() : super(AuthCubitInitial());

  void setAuthenticated(User user) => emit(AuthCubitAuthenticated(user));
  void setUnauthenticated() => emit(AuthCubitUnauthenticated());
}

sealed class AuthCubitState {}

final class AuthCubitInitial extends AuthCubitState {}

final class AuthCubitAuthenticated extends AuthCubitState {
  final User user;
  AuthCubitAuthenticated(this.user);
}

final class AuthCubitUnauthenticated extends AuthCubitState {}
''');

        expect(File(cubitPath).existsSync(), isTrue);
        final content = File(cubitPath).readAsStringSync();
        expect(content, contains('extends Cubit'));
        expect(content, contains('setAuthenticated'));
      });
    });

    group('usecase generation', () {
      test('should create usecase with proper structure', () {
        final usecasePath = path.join(
          projectPath,
          'lib/features/auth/domain/usecases/login_with_email.dart',
        );

        Directory(path.dirname(usecasePath)).createSync(recursive: true);

        File(usecasePath).writeAsStringSync('''
import 'package:fpdart/fpdart.dart';
import 'package:clean_modular_architecture/clean_modular_architecture.dart';
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
''');

        expect(File(usecasePath).existsSync(), isTrue);
        final content = File(usecasePath).readAsStringSync();
        expect(content, contains('implements UseCase'));
        expect(content, contains('Either<Failure, User>'));
      });
    });
  });
}
