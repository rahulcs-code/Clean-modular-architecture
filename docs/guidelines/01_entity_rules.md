# Entity Rules - Pure Data Containers Only

**Location:** `lib/features/{feature}/domain/entities/`
**Layer:** Domain
**Purpose:** Represent core business concepts as pure data structures

## ⚠️ CRITICAL RULE

**Entities MUST be pure data containers with ZERO logic.**

This is the **MOST FREQUENTLY VIOLATED** rule by AI coding agents.

## What Entities Are

Entities represent your business domain concepts in their purest form:
- User, Product, Order, Invoice, etc.
- Container for related data fields only
- No knowledge of data sources, APIs, or databases
- No business logic or helper methods
- No serialization concerns

## ✅ CORRECT Entity Implementation

```dart
// lib/features/auth/domain/entities/parent.dart

class Parent {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? token;
  final DateTime createdAt;
  final bool isVerified;

  const Parent({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.token,
    required this.createdAt,
    required this.isVerified,
  });
}
```

**Why this is correct:**
- Only `final` fields (immutable)
- Only constructor with parameters
- Uses `const` constructor when possible
- No methods, no logic, no serialization
- Nullable fields use `?` when appropriate

## ❌ WRONG: Entity with Logic

### Violation 1: copyWith Method

```dart
// ❌ NEVER DO THIS
class Parent {
  final String id;
  final String name;
  final String email;

  const Parent({
    required this.id,
    required this.name,
    required this.email,
  });

  // ❌ WRONG: copyWith belongs in Model, not Entity
  Parent copyWith({
    String? id,
    String? name,
    String? email,
  }) {
    return Parent(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }
}
```

**Why this is wrong:** copyWith is a utility method for data manipulation. It belongs in the Model class (data layer), not Entity (domain layer).

### Violation 2: Static Constants

```dart
// ❌ NEVER DO THIS
class Parent {
  final String id;
  final String name;
  final String email;

  // ❌ WRONG: Static constants belong in Model
  static const Parent empty = Parent(
    id: '',
    name: '',
    email: '',
  );

  const Parent({
    required this.id,
    required this.name,
    required this.email,
  });
}
```

**Why this is wrong:** Static constants (empty, initial, etc.) are data layer concerns. They belong in the Model class.

### Violation 3: Helper Methods/Logic

```dart
// ❌ NEVER DO THIS
class Parent {
  final String id;
  final String name;
  final String email;
  final bool isVerified;

  const Parent({
    required this.id,
    required this.name,
    required this.email,
    required this.isVerified,
  });

  // ❌ WRONG: Business logic in entity
  bool get canAccessDashboard => isVerified && email.isNotEmpty;

  // ❌ WRONG: Computed properties
  String get displayName => name.isEmpty ? email : name;

  // ❌ WRONG: Helper methods
  bool hasValidEmail() {
    return email.contains('@') && email.contains('.');
  }

  // ❌ WRONG: Validation logic
  String? validateEmail() {
    if (email.isEmpty) return 'Email cannot be empty';
    if (!email.contains('@')) return 'Invalid email format';
    return null;
  }
}
```

**Why this is wrong:** All logic, getters, computed properties, and helper methods belong in the Model (data layer) or in separate validation/utility classes.

### Violation 4: Serialization Methods

```dart
// ❌ NEVER DO THIS
class Parent {
  final String id;
  final String name;
  final String email;

  const Parent({
    required this.id,
    required this.name,
    required this.email,
  });

  // ❌ WRONG: Serialization in entity
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }

  // ❌ WRONG: Deserialization in entity
  factory Parent.fromJson(Map<String, dynamic> json) {
    return Parent(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }
}
```

**Why this is wrong:** Serialization/deserialization is a data layer concern. It belongs in the Model class, which extends the Entity.

### Violation 5: Equality/Hashcode Overrides

```dart
// ❌ NEVER DO THIS
class Parent {
  final String id;
  final String name;
  final String email;

  const Parent({
    required this.id,
    required this.name,
    required this.email,
  });

  // ❌ WRONG: Equality logic in entity
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Parent &&
        other.id == id &&
        other.name == name &&
        other.email == email;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ email.hashCode;
}
```

**Why this is wrong:** While equality can be useful, it's a data manipulation concern. Use packages like `equatable` in the Model layer if needed.

## ✅ Where Does All That Logic Go?

**Answer:** In the MODEL class!

The Model extends the Entity and adds all the functionality:

```dart
// lib/features/auth/data/models/parent_model.dart

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

  // ✅ CORRECT: copyWith in Model
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

  // ✅ CORRECT: Static constants in Model
  static const ParentModel empty = ParentModel(
    id: '',
    name: '',
    email: '',
    createdAt: DateTime.now,
    isVerified: false,
  );

  // ✅ CORRECT: Serialization in Model
  factory ParentModel.fromJson(Map<String, dynamic> json) {
    return ParentModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String?,
      token: json['token'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      isVerified: json['is_verified'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
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

  // ✅ CORRECT: Helper methods in Model
  bool get canAccessDashboard => isVerified && email.isNotEmpty;

  String get displayName => name.isEmpty ? email : name;
}
```

See [02_model_rules.md](02_model_rules.md) for complete Model guidelines.

## Entity Checklist for AI Agents

Before marking entity code as complete, verify:

- [ ] Contains ONLY `final` fields
- [ ] Contains ONLY constructor
- [ ] NO methods of any kind
- [ ] NO copyWith
- [ ] NO static constants
- [ ] NO toJson/fromJson
- [ ] NO computed properties (getters)
- [ ] NO business logic
- [ ] NO validation methods
- [ ] NO operator overrides (==, hashCode)
- [ ] Uses `const` constructor when possible
- [ ] All fields are appropriately nullable

## Why This Rule Exists

### 1. Separation of Concerns
Domain layer should not know about:
- How data is stored (JSON, database, etc.)
- How data is transmitted (API, cache, etc.)
- Data manipulation utilities

### 2. Testability
Pure entities are trivial to instantiate in tests:
```dart
final parent = Parent(
  id: 'test-id',
  name: 'Test User',
  email: 'test@example.com',
  createdAt: DateTime.now(),
  isVerified: true,
);
```

### 3. Maintainability
When API changes, only Models change, not Entities. The domain remains stable.

### 4. Clean Architecture Principles
Entities represent business rules independent of:
- Frameworks
- UI
- Databases
- External agencies

## Common Scenarios

### "But I need to compare entities!"

**Wrong approach:**
```dart
// ❌ Adding == operator to entity
class Parent {
  @override
  bool operator ==(other) => ...
}
```

**Correct approach:**
```dart
// ✅ Use Equatable in Model
class ParentModel extends Parent with EquatableMixin {
  @override
  List<Object?> get props => [id, name, email, ...];
}
```

### "But I need an empty instance for initial state!"

**Wrong approach:**
```dart
// ❌ Static const in entity
class Parent {
  static const Parent empty = Parent(...);
}
```

**Correct approach:**
```dart
// ✅ Static const in Model
class ParentModel extends Parent {
  static const ParentModel empty = ParentModel(...);
}

// In BLoC state:
final initialState = ParentLoaded(parent: ParentModel.empty);
```

### "But I need to copy with updated fields!"

**Wrong approach:**
```dart
// ❌ copyWith in entity
class Parent {
  Parent copyWith(...) => ...;
}
```

**Correct approach:**
```dart
// ✅ copyWith in Model
class ParentModel extends Parent {
  ParentModel copyWith(...) => ...;
}

// In repository:
final updatedParent = currentParentModel.copyWith(name: newName);
```

## Verification Questions

When reviewing entity code, ask:

1. **Can this entity be understood without knowing about:**
   - JSON?
   - API?
   - Database?
   - **If NO → You have violations**

2. **If I delete the Model class, would this entity still make sense as a business concept?**
   - **If NO → Entity depends on data layer concerns**

3. **Could this entity exist in a different framework (e.g., backend, desktop app)?**
   - **If NO → Entity is too coupled to Flutter/mobile specifics**

## Related Guidelines

- [02_model_rules.md](02_model_rules.md) - Where all entity logic goes
- [03_repository_pattern.md](03_repository_pattern.md) - How entities flow through layers
- [examples/common_mistakes.md](examples/common_mistakes.md) - See real violation examples

## Summary

**Entities are simple:**

```dart
class EntityName {
  final Type field1;
  final Type field2;

  const EntityName({
    required this.field1,
    required this.field2,
  });
}
```

**That's it. Nothing more.**

If you're adding anything else, you're violating Clean Architecture principles. Move it to the Model.
