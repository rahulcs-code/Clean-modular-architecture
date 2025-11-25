# 📄 **Framework Requirement Description**

A custom Flutter framework and CLI tool that enforces a **Clean Architecture**, **SOLID principles**, **BLoC pattern**, and a **feature-first, repository-driven project structure**.
The framework must define strict architectural rules, validate them through custom linting, and automatically generate project boilerplate using command-line scaffolding.
*** This should be working as a dev dependecy ***

**Key capabilities required:**

1. **Fixed Architecture Enforcement**

   * Mandatory folder structure: feature-first (feature → data/domain/presentation).
   * Repository pattern enforcement.
   * Separation of concerns aligned with Clean Architecture and SOLID.
   * Predefined base classes for use cases, repositories, blocs, services, and validators.
   
   *** Rules are documented in `docs/guidelines`. Need to enforce to follow strictly. Dependencies mentioned should be strictly used for state management, dependency injection, routing, functional programming, etc. Use pub add command to ensure latest compatible version are used. ***

2. **Lint Rules & Static Analysis**

   * Custom lint package (analyzer plugin).
   * Errors/warnings when violating architecture boundaries.
   * Naming convention checks (e.g., `*Bloc`, `*Repository`, `*Service`).
   * Restricted import rules to prevent cross-layer leakage.

3. **CLI Tooling**

   * Commands to scaffold architecture components:

     * `generate feature <name>`
     * `generate bloc <name>`
     * `generate repository <name>`
     * `generate service <name>`
     * `generate validator <name>`
   * Ability to initialize a project with the full folder structure.
   * Mason-powered or custom template generation.

4. **Code Generators (Optional)**

   * Build-runner compatible generators for:

     * DI bindings
     * DTO mappers
     * Validation pipes
     * Routes
     * Use-case boilerplate

5. **Developer-Friendly Integration**

   * Publishable as a single dependency on pub.dev.
   * Easy CLI activation via `dart pub global activate`.
   * Provides a template `analysis_options.yaml`.
   * Designed to reduce boilerplate and ensure architectural consistency.

