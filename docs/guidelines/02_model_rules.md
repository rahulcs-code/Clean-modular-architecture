# Model Rules - Extends Entity with Logic

**Location:** `lib/features/{feature}/data/models/`
**Layer:** Data
**Purpose:** Extend entities with serialization, logic, and data manipulation

## Core Principle

**Models extend Entities and add all the functionality that entities cannot have.**

## What Models Are

Models are the data layer's representation of entities:
- Extend their corresponding entity
- Handle serialization/deserialization (JSON, XML, etc.)
- Contain utility methods (copyWith, empty instances, etc.)
- May include computed properties and helper methods
- Bridge between raw data (API/database) and domain entities

## ✅ CORRECT Model Implementation

```dart
// lib/features/auth/data/models/parent_model.dart

import 'dart:convert';
import 'package:your_app/features/auth/domain/entities/parent.dart';

class ParentModel extends Parent {
  const ParentModel({
    required super.id,
    required super.name,
    required super.email,
    super.phoneNumber,
    super.token,
    required super.createdAt,
    required super.isVerified,
  });

  // ✅ copyWith method for immutable updates
  ParentModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? token,
    DateTime? createdAt,
    bool? isVerified,
  }) {
    return ParentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      token: token ?? this.token,
      createdAt: createdAt ?? this.createdAt,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  // ✅ Static constants for default instances
  static const ParentModel empty = ParentModel(
    id: '',
    name: '',
    email: '',
    phoneNumber: null,
    token: null,
    createdAt: DateTime(1970),
    isVerified: false,
  );

  // ✅ fromMap for deserialization
  factory ParentModel.fromMap(Map<String, dynamic> map) {
    return ParentModel(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      phoneNumber: map['phone_number'] as String?,
      token: map['token'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      isVerified: map['is_verified'] as bool,
    );
  }

  // ✅ fromJson convenience method
  factory ParentModel.fromJson(String source) {
    return ParentModel.fromMap(json.decode(source) as Map<String, dynamic>);
  }

  // ✅ toMap for serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'token': token,
      'created_at': createdAt.toIso8601String(),
      'is_verified': isVerified,
    };
  }

  // ✅ toJson convenience method
  String toJson() => json.encode(toMap());

  // ✅ Computed properties for data manipulation
  bool get canAccessDashboard => isVerified && email.isNotEmpty;

  String get displayName => name.isEmpty ? email : name;

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  // ✅ Helper methods for validation or checks
  bool hasValidToken() {
    if (token == null || token!.isEmpty) return false;
    // Additional token validation logic
    return true;
  }

  // ✅ Transformation methods
  ParentModel withVerification(bool verified) {
    return copyWith(isVerified: verified);
  }
}
```

## Model Responsibilities

### 1. Extending the Entity

```dart
// ✅ CORRECT: Extends entity and uses super parameters
class ParentModel extends Parent {
  const ParentModel({
    required super.id,
    required super.name,
    required super.email,
    super.phoneNumber,  // Optional parameter
    super.token,
    required super.createdAt,
    required super.isVerified,
  });
}
```

**Key points:**
- Use `super` parameters to pass values to entity
- Maintain same field names and types
- Preserve nullability (optional vs required)
- Use `const` constructor when possible

### 2. Serialization/Deserialization

#### fromMap (Required)

```dart
// ✅ CORRECT: Handles API field name mapping
factory ParentModel.fromMap(Map<String, dynamic> map) {
  return ParentModel(
    id: map['id'] as String,
    name: map['name'] as String,
    email: map['email'] as String,
    // Map snake_case to camelCase
    phoneNumber: map['phone_number'] as String?,
    token: map['token'] as String?,
    // Parse date strings
    createdAt: DateTime.parse(map['created_at'] as String),
    isVerified: map['is_verified'] as bool,
  );
}
```

#### toMap (Required)

```dart
// ✅ CORRECT: Converts to API format
Map<String, dynamic> toMap() {
  return {
    'id': id,
    'name': name,
    'email': email,
    // Convert camelCase to snake_case
    'phone_number': phoneNumber,
    'token': token,
    // Convert DateTime to ISO string
    'created_at': createdAt.toIso8601String(),
    'is_verified': isVerified,
  };
}
```

#### fromJson & toJson (Convenience)

```dart
// ✅ CORRECT: Convenience wrappers
factory ParentModel.fromJson(String source) {
  return ParentModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

String toJson() => json.encode(toMap());
```

### 3. copyWith Method

```dart
// ✅ CORRECT: Immutable updates
ParentModel copyWith({
  String? id,
  String? name,
  String? email,
  String? phoneNumber,
  String? token,
  DateTime? createdAt,
  bool? isVerified,
}) {
  return ParentModel(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    token: token ?? this.token,
    createdAt: createdAt ?? this.createdAt,
    isVerified: isVerified ?? this.isVerified,
  );
}
```

**When to use copyWith:**
- Updating single fields without modifying original
- State management updates
- Caching modifications

### 4. Static Constants

```dart
// ✅ CORRECT: Default instances
class ParentModel extends Parent {
  static const ParentModel empty = ParentModel(
    id: '',
    name: '',
    email: '',
    createdAt: DateTime(1970),
    isVerified: false,
  );

  static const ParentModel initial = ParentModel(
    id: 'temp-id',
    name: 'Guest',
    email: 'guest@example.com',
    createdAt: DateTime(1970),
    isVerified: false,
  );
}
```

**Common use cases:**
- Initial state in BLoC
- Default values
- Placeholder data
- Testing fixtures

### 5. Computed Properties & Helpers

```dart
// ✅ CORRECT: Data-related logic in model
class ParentModel extends Parent {
  // Computed display properties
  String get displayName => name.isEmpty ? email : name;

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  // Validation helpers
  bool get hasValidEmail => email.contains('@') && email.contains('.');

  bool hasValidToken() {
    return token != null && token!.isNotEmpty && token!.length > 10;
  }

  // Status checks
  bool get canAccessDashboard => isVerified && hasValidEmail;

  bool get needsVerification => !isVerified;

  // Transformation helpers
  ParentModel markAsVerified() => copyWith(isVerified: true);

  ParentModel updateEmail(String newEmail) => copyWith(email: newEmail);
}
```

## Model Naming Convention

```
Entity name + "Model" suffix

Parent → ParentModel
Order → OrderModel
Product → ProductModel
UserProfile → UserProfileModel
```

## Model with Nested Entities

When entity has nested entities, model must handle nested models:

```dart
// Entity with nested entity
class Order {
  final String id;
  final List<Product> products;  // Nested entity
  final User customer;  // Nested entity

  const Order({
    required this.id,
    required this.products,
    required this.customer,
  });
}

// Model with nested models
class OrderModel extends Order {
  const OrderModel({
    required super.id,
    required super.products,
    required super.customer,
  });

  // ✅ CORRECT: Convert nested models during deserialization
  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] as String,
      // Convert list of maps to list of ProductModel
      products: (map['products'] as List)
          .map((p) => ProductModel.fromMap(p as Map<String, dynamic>))
          .toList(),
      // Convert nested map to UserModel
      customer: UserModel.fromMap(map['customer'] as Map<String, dynamic>),
    );
  }

  // ✅ CORRECT: Convert nested models during serialization
  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      // Convert list of ProductModel to list of maps
      'products': products.map((p) => (p as ProductModel).toMap()).toList(),
      // Convert UserModel to map
      'customer': (customer as UserModel).toMap(),
    };
  }
}
```

## Using Equatable (Optional)

For easy equality comparisons:

```dart
import 'package:equatable/equatable.dart';

class ParentModel extends Parent with EquatableMixin {
  const ParentModel({
    required super.id,
    required super.name,
    required super.email,
    required super.createdAt,
    required super.isVerified,
  });

  // ✅ CORRECT: Define properties for equality
  @override
  List<Object?> get props => [id, name, email, phoneNumber, token, createdAt, isVerified];
}
```

Now you can compare models easily:
```dart
final parent1 = ParentModel(id: '1', ...);
final parent2 = ParentModel(id: '1', ...);
print(parent1 == parent2); // true if all props are equal
```

## ❌ Common Mistakes

### Mistake 1: Not Extending Entity

```dart
// ❌ WRONG: Model doesn't extend entity
class ParentModel {
  final String id;
  final String name;
  final String email;

  ParentModel({
    required this.id,
    required this.name,
    required this.email,
  });
}
```

**Why wrong:** Model must extend entity for proper type relationships. This breaks the repository pattern.

**Fix:**
```dart
// ✅ CORRECT
class ParentModel extends Parent {
  ParentModel({
    required super.id,
    required super.name,
    required super.email,
  });
}
```

### Mistake 2: Duplicating Fields

```dart
// ❌ WRONG: Duplicating entity fields
class ParentModel extends Parent {
  final String id;  // ❌ Already in Parent
  final String name;  // ❌ Already in Parent

  ParentModel({
    required this.id,
    required this.name,
    required super.email,
  }) : super(id: id, name: name);
}
```

**Why wrong:** Fields are inherited from entity, no need to duplicate.

**Fix:**
```dart
// ✅ CORRECT: Use super parameters
class ParentModel extends Parent {
  ParentModel({
    required super.id,
    required super.name,
    required super.email,
  });
}
```

### Mistake 3: Unsafe Type Casting

```dart
// ❌ WRONG: No null checking or type validation
factory ParentModel.fromMap(Map<String, dynamic> map) {
  return ParentModel(
    id: map['id'],  // ❌ No type cast
    name: map['name'],  // ❌ No type cast
    email: map['email'],  // ❌ No type cast
    createdAt: DateTime.parse(map['created_at']),  // ❌ No null check
  );
}
```

**Why wrong:** Can throw runtime errors if data is null or wrong type.

**Fix:**
```dart
// ✅ CORRECT: Safe type casting with validation
factory ParentModel.fromMap(Map<String, dynamic> map) {
  return ParentModel(
    id: map['id'] as String,
    name: map['name'] as String,
    email: map['email'] as String,
    phoneNumber: map['phone_number'] as String?,  // Nullable
    createdAt: map['created_at'] != null
        ? DateTime.parse(map['created_at'] as String)
        : DateTime.now(),  // Fallback
    isVerified: (map['is_verified'] as bool?) ?? false,  // Default
  );
}
```

## Model Checklist

Before marking model code as complete:

- [ ] Extends corresponding entity
- [ ] Uses super parameters correctly
- [ ] Implements `fromMap` factory
- [ ] Implements `toMap` method
- [ ] Implements `fromJson` convenience method
- [ ] Implements `toJson` convenience method
- [ ] Implements `copyWith` method
- [ ] Handles nullable fields appropriately
- [ ] Maps API field names (snake_case ↔ camelCase)
- [ ] Handles nested models correctly
- [ ] Includes static constants if needed (empty, initial)
- [ ] Safe type casting in fromMap
- [ ] Proper null checks

## Where Models Are Used

```dart
// Data sources return models
class AuthRemoteDataSource {
  Future<ParentModel> login(...) async {
    final response = await http.post(...);
    return ParentModel.fromJson(response.body);  // ✅
  }
}

// Repository implementation uses models internally
class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<Either<Failure, ParentModel>> login(...) async {
    final parentModel = await _remoteDataSource.login(...);
    await _localDataSource.cacheParent(parentModel);
    return right(parentModel);  // Returns as entity due to inheritance
  }
}

// BLoC receives entity, but it's actually a model
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  Future<void> _onLogin(AuthLogin event, emit) async {
    final result = await _loginUseCase(params);
    result.fold(
      (failure) => emit(AuthFailure(...)),
      (parent) => emit(AuthSuccess(parent)),  // Parent (actually ParentModel)
    );
  }
}
```

## Related Guidelines

- [01_entity_rules.md](01_entity_rules.md) - What entities must NOT have
- [03_repository_pattern.md](03_repository_pattern.md) - How models flow through repositories
- [05_data_source_pattern.md](05_data_source_pattern.md) - How data sources use models

## Summary

**Models are the workhorses of the data layer:**
- Extend entities
- Handle serialization
- Contain utility methods
- Bridge raw data and domain
- Return as entities to domain layer

**Everything that entities can't have, models have.**
