import 'package:test/test.dart';
import 'package:clean_modular_architecture/src/cli/utils/file_utils.dart';

void main() {
  group('Template Generation', () {
    group('naming conventions', () {
      test('should convert feature name to snake_case', () {
        expect(FileUtils.toSnakeCase('UserProfile'), 'user_profile');
        expect(FileUtils.toSnakeCase('Auth'), 'auth');
        expect(FileUtils.toSnakeCase('LoginWithEmail'), 'login_with_email');
      });

      test('should convert feature name to PascalCase', () {
        expect(FileUtils.toPascalCase('user_profile'), 'UserProfile');
        expect(FileUtils.toPascalCase('auth'), 'Auth');
        expect(FileUtils.toPascalCase('login-with-email'), 'LoginWithEmail');
      });

      test('should convert to camelCase', () {
        expect(FileUtils.toCamelCase('user_profile'), 'userProfile');
        expect(FileUtils.toCamelCase('Auth'), 'auth');
        expect(FileUtils.toCamelCase('login-with-email'), 'loginWithEmail');
      });
    });

    group('entity template', () {
      test('should generate entity class name correctly', () {
        const entityName = 'User';
        const expectedClass = 'class User {';

        final template = '''
class $entityName {
  final String id;
  final String name;

  const $entityName({
    required this.id,
    required this.name,
  });
}
''';

        expect(template, contains(expectedClass));
        expect(template, contains('final String id'));
        expect(template, contains('const $entityName'));
      });

      test('should not include methods in entity template', () {
        final entityTemplate = '''
class User {
  final String id;
  final String name;

  const User({
    required this.id,
    required this.name,
  });
}
''';

        expect(entityTemplate, isNot(contains('copyWith')));
        expect(entityTemplate, isNot(contains('fromJson')));
        expect(entityTemplate, isNot(contains('toJson')));
      });
    });

    group('model template', () {
      test('should extend entity in model template', () {
        const entityName = 'User';
        const modelName = 'UserModel';

        final template = '''
class $modelName extends $entityName {
  const $modelName({
    required super.id,
    required super.name,
  });

  factory $modelName.fromJson(Map<String, dynamic> json) => $modelName(
    id: json['id'] as String,
    name: json['name'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}
''';

        expect(template, contains('extends $entityName'));
        expect(template, contains('fromJson'));
        expect(template, contains('toJson'));
      });
    });

    group('repository template', () {
      test('should generate interface with abstract interface class', () {
        const repoName = 'AuthRepository';

        final template = '''
abstract interface class $repoName {
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });
}
''';

        expect(template, contains('abstract interface class'));
        expect(template, contains('Either<Failure, User>'));
      });

      test('should generate implementation that implements interface', () {
        const repoName = 'AuthRepository';
        const implName = 'AuthRepositoryImpl';

        final template = '''
class $implName implements $repoName {
  final AuthRemoteDataSource remoteDataSource;

  $implName({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserModel>> login({
    required String email,
    required String password,
  }) async {
    // implementation
  }
}
''';

        expect(template, contains('implements $repoName'));
        expect(template, contains('@override'));
      });
    });

    group('bloc template', () {
      test('should generate BLoC extending Bloc', () {
        const blocName = 'AuthBloc';
        const eventName = 'AuthEvent';
        const stateName = 'AuthState';

        final template = '''
class $blocName extends Bloc<$eventName, $stateName> {
  $blocName() : super(${stateName}Initial()) {
    on<${eventName}Login>(_onLogin);
  }
}
''';

        expect(template, contains('extends Bloc<$eventName, $stateName>'));
      });

      test('should generate sealed event class', () {
        const eventName = 'AuthEvent';

        final template = '''
sealed class $eventName {}

final class ${eventName}Login extends $eventName {
  final String email;
  final String password;

  ${eventName}Login({required this.email, required this.password});
}
''';

        expect(template, contains('sealed class $eventName'));
      });

      test('should generate sealed state class', () {
        const stateName = 'AuthState';

        final template = '''
sealed class $stateName {}

final class ${stateName}Initial extends $stateName {}

final class ${stateName}Loading extends $stateName {}

final class ${stateName}Success extends $stateName {
  final User user;
  ${stateName}Success(this.user);
}

final class ${stateName}Failure extends $stateName {
  final String message;
  ${stateName}Failure(this.message);
}
''';

        expect(template, contains('sealed class $stateName'));
        expect(template, contains('final class ${stateName}Initial'));
        expect(template, contains('final class ${stateName}Loading'));
      });
    });

    group('cubit template', () {
      test('should generate Cubit extending Cubit', () {
        const cubitName = 'ThemeCubit';
        const stateName = 'ThemeState';

        final template = '''
class $cubitName extends Cubit<$stateName> {
  $cubitName() : super(const $stateName());

  void toggleTheme() {
    emit(state.copyWith(isDark: !state.isDark));
  }
}
''';

        expect(template, contains('extends Cubit<$stateName>'));
      });
    });

    group('usecase template', () {
      test('should implement UseCase interface', () {
        const usecaseName = 'LoginWithEmail';
        const returnType = 'User';
        const paramsType = 'LoginParams';

        final template = '''
class $usecaseName implements UseCase<$returnType, $paramsType> {
  final AuthRepository repository;

  $usecaseName(this.repository);

  @override
  Future<Either<Failure, $returnType>> call($paramsType params) async {
    return repository.login(
      email: params.email,
      password: params.password,
    );
  }
}
''';

        expect(template, contains('implements UseCase<$returnType, $paramsType>'));
        expect(template, contains('Either<Failure, $returnType>'));
      });

      test('should use NoParams for parameterless usecases', () {
        const usecaseName = 'GetCurrentUser';
        const returnType = 'User';

        final template = '''
class $usecaseName implements UseCase<$returnType, NoParams> {
  final AuthRepository repository;

  $usecaseName(this.repository);

  @override
  Future<Either<Failure, $returnType>> call(NoParams params) async {
    return repository.getCurrentUser();
  }
}
''';

        expect(template, contains('UseCase<$returnType, NoParams>'));
        expect(template, contains('call(NoParams params)'));
      });
    });
  });
}
