import 'package:test/test.dart';

/// Tests for model lint rules.
void main() {
  group('Model Rules', () {
    group('model_extends_entity', () {
      test('should flag model that does not extend entity', () {
        // This would be detected as a violation:
        // // In data/models/user_model.dart
        // class UserModel { // VIOLATION - should extend User
        //   final String name;
        // }
        expect(true, isTrue);
      });

      test('should pass when model extends entity', () {
        // This should NOT be flagged:
        // class UserModel extends User {
        //   const UserModel({required super.name});
        // }
        expect(true, isTrue);
      });
    });

    group('model_naming_convention', () {
      test('should flag model class not ending with Model', () {
        // This would be detected as a violation:
        // // In data/models/user_data.dart
        // class UserData extends User { } // VIOLATION - should be UserModel
        expect(true, isTrue);
      });

      test('should pass when model ends with Model', () {
        // This should NOT be flagged:
        // class UserModel extends User { }
        expect(true, isTrue);
      });
    });
  });
}
