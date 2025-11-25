import 'package:test/test.dart';
import 'package:clean_modular_architecture/src/config/cma_config.dart';

void main() {
  group('CmaConfig', () {
    group('defaults', () {
      test('should have default features path', () {
        expect(CmaConfig.defaults.featuresPath, 'lib/features');
      });

      test('should have default core path', () {
        expect(CmaConfig.defaults.corePath, 'lib/core');
      });

      test('should have default model suffix', () {
        expect(CmaConfig.defaults.modelSuffix, 'Model');
      });

      test('should have empty entity suffix by default', () {
        expect(CmaConfig.defaults.entitySuffix, '');
      });

      test('should have lint enabled by default', () {
        expect(CmaConfig.defaults.lintEnabled, isTrue);
      });

      test('should use bloc as default state management', () {
        expect(CmaConfig.defaults.stateManagement, 'bloc');
      });

      test('should use get_it as default di package', () {
        expect(CmaConfig.defaults.diPackage, 'get_it');
      });
    });

    group('path detection', () {
      test('should detect entity paths', () {
        final config = CmaConfig.defaults;
        expect(config.isEntityPath('/lib/features/auth/domain/entities/user.dart'), isTrue);
        expect(config.isEntityPath('/lib/features/auth/data/models/user_model.dart'), isFalse);
      });

      test('should detect model paths', () {
        final config = CmaConfig.defaults;
        expect(config.isModelPath('/lib/features/auth/data/models/user_model.dart'), isTrue);
        expect(config.isModelPath('/lib/features/auth/domain/entities/user.dart'), isFalse);
      });

      test('should detect domain paths', () {
        final config = CmaConfig.defaults;
        expect(config.isDomainPath('/lib/features/auth/domain/entities/user.dart'), isTrue);
        expect(config.isDomainPath('/lib/features/auth/data/models/user.dart'), isFalse);
      });

      test('should detect data paths', () {
        final config = CmaConfig.defaults;
        expect(config.isDataPath('/lib/features/auth/data/models/user.dart'), isTrue);
        expect(config.isDataPath('/lib/features/auth/domain/entities/user.dart'), isFalse);
      });

      test('should detect presentation paths', () {
        final config = CmaConfig.defaults;
        expect(config.isPresentationPath('/lib/features/auth/presentation/pages/login.dart'), isTrue);
        expect(config.isPresentationPath('/lib/features/auth/domain/entities/user.dart'), isFalse);
      });

      test('should detect global cubit paths', () {
        final config = CmaConfig.defaults;
        expect(config.isGlobalCubitPath('/lib/core/common/cubits/auth_cubit.dart'), isTrue);
        expect(config.isGlobalCubitPath('/lib/features/auth/presentation/bloc/auth_bloc.dart'), isFalse);
      });
    });

    group('naming', () {
      test('should get model name for entity', () {
        final config = CmaConfig.defaults;
        expect(config.getModelNameForEntity('User'), 'UserModel');
        expect(config.getModelNameForEntity('AuthResponse'), 'AuthResponseModel');
      });

      test('should get entity name for model', () {
        final config = CmaConfig.defaults;
        expect(config.getEntityNameForModel('UserModel'), 'User');
        expect(config.getEntityNameForModel('AuthResponseModel'), 'AuthResponse');
      });
    });

    group('validation', () {
      test('should validate with no errors for defaults', () {
        final errors = CmaConfig.defaults.validate();
        expect(errors, isEmpty);
      });

      test('should return error for empty features path', () {
        final config = CmaConfig.defaults.copyWith(featuresPath: '');
        final errors = config.validate();
        expect(errors, contains('features_path cannot be empty'));
      });

      test('should return error for empty core path', () {
        final config = CmaConfig.defaults.copyWith(corePath: '');
        final errors = config.validate();
        expect(errors, contains('core_path cannot be empty'));
      });

      test('should return error for empty model suffix', () {
        final config = CmaConfig.defaults.copyWith(modelSuffix: '');
        final errors = config.validate();
        expect(errors, contains('model_suffix cannot be empty'));
      });

      test('should return error for invalid severity', () {
        final config = CmaConfig.defaults.copyWith(
          lintSeverity: {'entity_no_methods': 'invalid'},
        );
        final errors = config.validate();
        expect(errors.any((e) => e.contains('Invalid severity')), isTrue);
      });

      test('should return error for invalid state management', () {
        final config = CmaConfig.defaults.copyWith(stateManagement: 'invalid');
        final errors = config.validate();
        expect(errors, contains('Invalid state_management: invalid'));
      });

      test('should return error for invalid di package', () {
        final config = CmaConfig.defaults.copyWith(diPackage: 'invalid');
        final errors = config.validate();
        expect(errors, contains('Invalid di_package: invalid'));
      });
    });

    group('getSeverity', () {
      test('should return error as default severity', () {
        final config = CmaConfig.defaults;
        expect(config.getSeverity('unknown_rule'), 'error');
      });

      test('should return configured severity', () {
        final config = CmaConfig.defaults.copyWith(
          lintSeverity: {'entity_no_methods': 'warning'},
        );
        expect(config.getSeverity('entity_no_methods'), 'warning');
      });
    });

    group('copyWith', () {
      test('should create copy with modified values', () {
        final original = CmaConfig.defaults;
        final copy = original.copyWith(
          featuresPath: 'src/features',
          modelSuffix: 'Dto',
        );

        expect(copy.featuresPath, 'src/features');
        expect(copy.modelSuffix, 'Dto');
        expect(copy.corePath, original.corePath);
      });
    });

    group('toYaml', () {
      test('should generate valid YAML string', () {
        final yaml = CmaConfig.defaults.toYaml();
        expect(yaml, contains('clean_modular_architecture:'));
        expect(yaml, contains('features_path:'));
        expect(yaml, contains('model_suffix:'));
        expect(yaml, contains('state_management:'));
      });
    });
  });

  group('LintSeverity', () {
    test('should have all severity values', () {
      expect(LintSeverity.values, contains('error'));
      expect(LintSeverity.values, contains('warning'));
      expect(LintSeverity.values, contains('info'));
      expect(LintSeverity.values, contains('ignore'));
    });
  });

  group('StateManagement', () {
    test('should have all state management options', () {
      expect(StateManagement.values, contains('bloc'));
      expect(StateManagement.values, contains('cubit'));
      expect(StateManagement.values, contains('riverpod'));
      expect(StateManagement.values, contains('provider'));
    });
  });

  group('DiPackage', () {
    test('should have all DI package options', () {
      expect(DiPackage.values, contains('get_it'));
      expect(DiPackage.values, contains('injectable'));
      expect(DiPackage.values, contains('riverpod'));
    });
  });
}
