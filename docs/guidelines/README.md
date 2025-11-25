# Flutter Clean Architecture Guidelines

**Quick Reference Guide for AI Coding Agents**

This directory contains focused, individual rule files for implementing Flutter Clean Architecture. Each file addresses one specific concept with clear DO/DON'T examples to prevent common implementation mistakes.

## Navigation

### Critical Rules (Start Here)

1. **[Entity Rules](01_entity_rules.md)** ⚠️ **CRITICAL**
   - Entities MUST be pure data containers only
   - NO logic, NO copyWith, NO static constants, NO methods
   - Most commonly violated rule by AI agents

2. **[Model Rules](02_model_rules.md)**
   - Models extend entities and contain ALL logic
   - copyWith, static constants, helper methods belong here
   - Handles serialization/deserialization

3. **[Repository Pattern](03_repository_pattern.md)** ⚠️ **CRITICAL**
   - Interface returns Entity types
   - Implementation returns Model types (which extend Entity)
   - Boundary between domain and data layers

### State Management

4. **[BLoC/Cubit Pattern](06_bloc_cubit_pattern.md)** ⚠️ **CRITICAL**
   - Feature BLoC: handles feature-specific operations
   - Global Cubit: tracks app-wide state
   - When to use which pattern

5. **[Dependency Injection](07_dependency_injection.md)** ⚠️ **CRITICAL**
   - registerSingleton vs registerLazySingleton rules
   - What gets registered where
   - BLoC registration patterns

6. **[Main App Setup](08_main_app_setup.md)** ⚠️ **CRITICAL**
   - MultiBlocProvider placement (in main, NOT MyApp.build)
   - Global provider registration
   - App initialization sequence

### Core Patterns

7. **[Use Case Pattern](04_use_case_pattern.md)**
   - Single responsibility business operations
   - Either<Failure, Success> return type
   - Params classes

8. **[Data Source Pattern](05_data_source_pattern.md)**
   - Mandatory error handling structure
   - Stack trace logging requirements
   - Exception rethrowing rules

9. **[Error Handling](09_error_handling.md)**
   - Exceptions (data layer) vs Failures (domain layer)
   - Either type usage
   - Error conversion flow

### Organization & Standards

10. **[Project Structure](10_project_structure.md)**
    - Complete directory structure template
    - Feature-based organization
    - Core directory organization
    - File and folder placement rules

11. **[Dependencies Setup](11_dependencies_setup.md)**
    - Flutter pub add commands for latest versions
    - Essential packages for Clean Architecture
    - Package verification checklist
    - Post-installation configuration

12. **[Naming Conventions](12_naming_conventions.md)**
    - File naming patterns (snake_case)
    - Class naming patterns (PascalCase)
    - Consistent naming across layers
    - Variable and method naming

13. **[Widget Organization](13_widget_organization.md)**
    - Maximum 1000 lines per file
    - Shared vs feature-specific widgets
    - When to extract components
    - Widget decomposition strategies

14. **[Architecture Rules](14_architecture_rules.md)**
    - SOLID principles application
    - Layer dependency rules
    - Clean Architecture boundaries
    - Common violations to avoid

### Examples & Common Issues

15. **[Common Mistakes](examples/common_mistakes.md)** ⭐ **Must Read**
    - Real violation examples from AI agents
    - Specific fixes for each mistake
    - Side-by-side correct/incorrect code

## Quick Decision Trees

### "Where does this code belong?"

```
Is it data-related (fields, constructor)?
├─ YES → Entity (domain layer)
└─ NO → Is it serialization/logic?
    └─ YES → Model (data layer)

Is it a business operation?
├─ YES → Use Case (domain layer)
└─ NO → Is it data fetching?
    └─ YES → Data Source (data layer)

Is it state management?
├─ Global state? → Cubit in core/common/cubits/
└─ Feature state? → BLoC in features/{feature}/presentation/bloc/

Is it a widget?
├─ Used by multiple features? → core/common/widgets/
└─ Feature-specific? → features/{feature}/presentation/widgets/
```

### "What return type should I use?"

```
Repository Interface (domain/repositories/)
└─ Returns: Entity
   Example: Future<Either<Failure, Parent>> login()

Repository Implementation (data/repositories/)
└─ Returns: Model (which extends Entity)
   Example: Future<Either<Failure, ParentModel>> login()

Data Source (data/datasources/)
└─ Returns: Model
   Example: Future<ParentModel> login()

Use Case (domain/usecases/)
└─ Returns: Entity (via repository interface)
   Example: Future<Either<Failure, Parent>> call()
```

## Critical Warnings for AI Agents

### ⚠️ STOP: Before Writing Entity Code

1. Does this entity have ANY methods? → **VIOLATION**
2. Does this entity have copyWith? → **VIOLATION**
3. Does this entity have static constants? → **VIOLATION**
4. Does this entity have any logic? → **VIOLATION**

**Entities are ONLY:**
- `final` fields
- Constructor with `required` parameters
- NOTHING else

### ⚠️ STOP: Before Writing Repository Code

1. Does the interface return Entity? → **CORRECT**
2. Does the implementation return Model? → **CORRECT**
3. Does Model extend Entity? → **CORRECT**
4. Are you confused about types? → Read [03_repository_pattern.md](03_repository_pattern.md)

### ⚠️ STOP: Before Registering Dependencies

1. Is it a service/repository/data source? → `registerLazySingleton` ✅
2. Is it a BLoC (ANY BLoC)? → `registerLazySingleton` ✅
3. Is it a Cubit (ANY Cubit)? → `registerLazySingleton` ✅
4. NEVER use `registerSingleton` for BLoCs/Cubits → **VIOLATION**
5. NEVER use `registerFactory` for BLoCs/Cubits → **VIOLATION**

### ⚠️ STOP: Before Setting Up Main

1. MultiBlocProvider wraps MyApp in `main()` → **CORRECT** ✅
2. MultiBlocProvider in MyApp.build() → **VIOLATION** ❌
3. ALL Cubits in MultiBlocProvider → **CORRECT** ✅
4. ALL BLoCs in MultiBlocProvider → **CORRECT** ✅
5. Missing any BLoC/Cubit → **VIOLATION** ❌

## How to Use These Guidelines

### For AI Coding Agents

1. **Read these files IN ORDER** when implementing new features
2. **Verify against checklists** before considering code complete
3. **Reference specific guideline** when uncertain about pattern
4. **Check "Common Mistakes"** if implementation feels wrong

### For Developers

1. Use as onboarding material for new team members
2. Reference during code reviews
3. Update when patterns evolve
4. Add project-specific examples to examples/ directory

## Pattern Summary

```
Layer          | Contains              | Uses Type | Returns Type
---------------|----------------------|-----------|-------------
Domain         | Entities             | Entity    | Entity
Domain         | Repository Interface | Entity    | Entity
Domain         | Use Cases            | Entity    | Entity
Data           | Models               | Model     | Model
Data           | Repository Impl      | Model     | Model*
Data           | Data Sources         | Model     | Model
Presentation   | BLoC/Cubit           | Entity    | Entity
Presentation   | Pages/Widgets        | Entity    | Entity

* Returns Model which extends Entity, so it satisfies Entity return type
```

## Architectural Flow

```
User Action
    ↓
Widget (Entity)
    ↓
BLoC (Entity)
    ↓
Use Case (Entity)
    ↓
Repository Interface (Entity) ← Domain/Data Boundary
    ↓
Repository Implementation (Model → Entity)
    ↓
Data Source (Model)
    ↓
API/Database
```

## Next Steps

1. ⭐ Start with [01_entity_rules.md](01_entity_rules.md) - Most critical
2. ⭐ Read [03_repository_pattern.md](03_repository_pattern.md) - Most confusing
3. ⭐ Review [examples/common_mistakes.md](examples/common_mistakes.md) - Learn from errors
4. ⭐ Check [10_project_structure.md](10_project_structure.md) - Set up directories
5. ⭐ Run [11_dependencies_setup.md](11_dependencies_setup.md) - Install packages

## Maintenance

When adding new patterns:
- Create focused file in this directory
- Update this README navigation
- Add examples to examples/ directory
- Update common_mistakes.md with new violations
