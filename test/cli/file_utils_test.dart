import 'package:test/test.dart';
import 'package:clean_modular_architecture/src/cli/utils/file_utils.dart';

void main() {
  group('FileUtils', () {
    group('toSnakeCase', () {
      test('should convert PascalCase to snake_case', () {
        expect(FileUtils.toSnakeCase('UserProfile'), equals('user_profile'));
        expect(FileUtils.toSnakeCase('AuthBloc'), equals('auth_bloc'));
        expect(FileUtils.toSnakeCase('HTTPClient'), equals('h_t_t_p_client'));
      });

      test('should convert camelCase to snake_case', () {
        expect(FileUtils.toSnakeCase('userProfile'), equals('user_profile'));
        expect(FileUtils.toSnakeCase('authBloc'), equals('auth_bloc'));
      });

      test('should handle already snake_case', () {
        expect(FileUtils.toSnakeCase('user_profile'), equals('user_profile'));
      });

      test('should handle single word', () {
        expect(FileUtils.toSnakeCase('User'), equals('user'));
        expect(FileUtils.toSnakeCase('user'), equals('user'));
      });
    });

    group('toPascalCase', () {
      test('should convert snake_case to PascalCase', () {
        expect(FileUtils.toPascalCase('user_profile'), equals('UserProfile'));
        expect(FileUtils.toPascalCase('auth_bloc'), equals('AuthBloc'));
      });

      test('should handle already PascalCase', () {
        expect(FileUtils.toPascalCase('UserProfile'), equals('UserProfile'));
      });

      test('should handle single word', () {
        expect(FileUtils.toPascalCase('user'), equals('User'));
        expect(FileUtils.toPascalCase('User'), equals('User'));
      });

      test('should handle multiple underscores', () {
        expect(
          FileUtils.toPascalCase('user_profile_settings'),
          equals('UserProfileSettings'),
        );
      });
    });

    group('toCamelCase', () {
      test('should convert snake_case to camelCase', () {
        expect(FileUtils.toCamelCase('user_profile'), equals('userProfile'));
        expect(FileUtils.toCamelCase('auth_bloc'), equals('authBloc'));
      });

      test('should convert PascalCase to camelCase', () {
        expect(FileUtils.toCamelCase('UserProfile'), equals('userProfile'));
      });

      test('should handle single word', () {
        expect(FileUtils.toCamelCase('user'), equals('user'));
        expect(FileUtils.toCamelCase('User'), equals('user'));
      });
    });
  });
}
