# Widget Organization - File Size and Structure

**Purpose:** Maintain readable and maintainable widget files
**Critical Rule:** Maximum 1000 lines per file

## ⚠️ The 1000-Line Rule

**NEVER exceed 1000 lines in any single file.**

This is a hard limit to ensure:
- Code remains readable
- Components stay focused
- Files are easy to navigate
- Code reviews are manageable

## Widget Placement Strategy

### Decision Tree

```
Is this widget used by multiple features?
├─ YES → Place in core/common/widgets/
└─ NO → Is it feature-specific?
    └─ YES → Place in features/{feature}/presentation/widgets/
```

### Core Common Widgets

**Location:** `lib/core/common/widgets/`

**Purpose:** Reusable widgets shared across 2+ features

**Examples:**
```
core/common/widgets/
├── app_button.dart
├── app_text_field.dart
├── loading_indicator.dart
├── error_widget.dart
├── empty_state_widget.dart
├── avatar_widget.dart
├── card_container.dart
└── custom_app_bar.dart
```

**Pattern:**
```dart
// lib/core/common/widgets/app_button.dart

import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        minimumSize: const Size(double.infinity, 50),
      ),
      child: isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(text),
    );
  }
}
```

### Feature-Specific Widgets

**Location:** `lib/features/{feature}/presentation/widgets/`

**Purpose:** Widgets used only within one feature

**Examples:**
```
features/auth/presentation/widgets/
├── login_form.dart
├── register_form.dart
└── password_strength_indicator.dart

features/home/presentation/widgets/
├── dashboard_card.dart
├── statistics_widget.dart
└── quick_actions_menu.dart

features/profile/presentation/widgets/
├── profile_header.dart
├── profile_info_card.dart
└── edit_profile_form.dart
```

## Breaking Down Large Files

### When to Extract Widgets

Extract widgets when:
1. File approaches 800-1000 lines
2. Widget is reused 2+ times in same file
3. Widget has clear, independent responsibility
4. Widget has 50+ lines of code

### Extraction Strategies

#### Strategy 1: Extract to Separate Widget Files

**Before (Single File - Too Large):**
```dart
// login_page.dart (1200 lines - TOO LARGE!)

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),      // 100 lines
          _buildLoginForm(),   // 400 lines
          _buildSocialLogin(), // 300 lines
          _buildFooter(),      // 200 lines
        ],
      ),
    );
  }

  Widget _buildHeader() {
    // 100 lines of code
  }

  Widget _buildLoginForm() {
    // 400 lines of code
  }

  Widget _buildSocialLogin() {
    // 300 lines of code
  }

  Widget _buildFooter() {
    // 200 lines of code
  }
}
```

**After (Multiple Files - Better):**
```dart
// login_page.dart (100 lines)
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
          LoginHeader(),
          LoginForm(),
          SocialLoginSection(),
          LoginFooter(),
        ],
      ),
    );
  }
}

// widgets/login_header.dart (100 lines)
class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    // Header implementation
  }
}

// widgets/login_form.dart (400 lines)
class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  // Form implementation
}

// widgets/social_login_section.dart (300 lines)
class SocialLoginSection extends StatelessWidget {
  const SocialLoginSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Social login implementation
  }
}

// widgets/login_footer.dart (200 lines)
class LoginFooter extends StatelessWidget {
  const LoginFooter({super.key});

  @override
  Widget build(BuildContext context) {
    // Footer implementation
  }
}
```

#### Strategy 2: Extract Private Widgets

**Use private widgets for small, single-use components:**

```dart
// login_page.dart

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const _WelcomeHeader(),
          const LoginForm(),
          const _DividerWithText(text: 'OR'),
          const SocialLoginSection(),
        ],
      ),
    );
  }
}

// Private widget - used only in this file
class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Welcome Back', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 8),
        Text('Sign in to continue', style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

// Private widget - simple divider
class _DividerWithText extends StatelessWidget {
  final String text;
  const _DividerWithText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(text),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
```

#### Strategy 3: Extract Builder Methods to Widgets

**Before (Builder Methods):**
```dart
class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildProfileHeader(context),
        _buildProfileStats(context),
        _buildProfileActions(context),
      ],
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    // 100 lines
  }

  Widget _buildProfileStats(BuildContext context) {
    // 150 lines
  }

  Widget _buildProfileActions(BuildContext context) {
    // 200 lines
  }
}
```

**After (Extracted Widgets):**
```dart
class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        ProfileHeader(),
        ProfileStats(),
        ProfileActions(),
      ],
    );
  }
}

// Separate widget files
class ProfileHeader extends StatelessWidget { /* ... */ }
class ProfileStats extends StatelessWidget { /* ... */ }
class ProfileActions extends StatelessWidget { /* ... */ }
```

## Widget Composition Patterns

### Pattern 1: Page + View Structure

**Recommended for complex pages:**

```dart
// home_page.dart (Main page file)

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _HomeView();
  }
}

// Private view widget
class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) {
          return const LoadingIndicator();
        }

        if (state is HomeError) {
          return ErrorWidget(message: state.message);
        }

        if (state is HomeLoaded) {
          return _HomeContent(data: state.data);
        }

        return const SizedBox.shrink();
      },
    );
  }
}

// Private content widget
class _HomeContent extends StatelessWidget {
  final DashboardData data;

  const _HomeContent({required this.data});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(title: Text('Home')),
        SliverList(
          delegate: SliverChildListDelegate([
            DashboardCard(data: data.summary),
            StatisticsWidget(stats: data.stats),
            QuickActionsMenu(actions: data.actions),
          ]),
        ),
      ],
    );
  }
}
```

### Pattern 2: Stateful Widget Decomposition

**For complex stateful widgets:**

```dart
// Complex form with multiple sections
class RegistrationForm extends StatefulWidget {
  const RegistrationForm({super.key});

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _PersonalInfoSection(nameController: _nameController),
          _AccountInfoSection(
            emailController: _emailController,
            passwordController: _passwordController,
          ),
          _SubmitButton(onSubmit: _handleSubmit),
        ],
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      // Submit logic
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

// Private section widgets
class _PersonalInfoSection extends StatelessWidget {
  final TextEditingController nameController;

  const _PersonalInfoSection({required this.nameController});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Personal Information', style: Theme.of(context).textTheme.titleLarge),
        AppTextField(
          controller: nameController,
          label: 'Full Name',
          validator: Validators.name,
        ),
      ],
    );
  }
}

class _AccountInfoSection extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const _AccountInfoSection({
    required this.emailController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Account Information', style: Theme.of(context).textTheme.titleLarge),
        AppTextField(
          controller: emailController,
          label: 'Email',
          validator: Validators.email,
        ),
        AppTextField(
          controller: passwordController,
          label: 'Password',
          obscureText: true,
          validator: Validators.password,
        ),
      ],
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final VoidCallback onSubmit;

  const _SubmitButton({required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: 'Register',
      onPressed: onSubmit,
    );
  }
}
```

## File Organization Example

### Feature with Proper Widget Organization

```
features/order/presentation/
├── bloc/
│   ├── order_bloc.dart (300 lines)
│   ├── order_event.dart (100 lines)
│   └── order_state.dart (100 lines)
├── pages/
│   ├── order_list_page.dart (200 lines)
│   ├── order_details_page.dart (250 lines)
│   └── create_order_page.dart (300 lines)
└── widgets/
    ├── order_card.dart (150 lines)
    ├── order_status_badge.dart (80 lines)
    ├── order_summary.dart (200 lines)
    ├── order_items_list.dart (180 lines)
    ├── order_timeline.dart (220 lines)
    ├── create_order_form.dart (400 lines)
    └── order_item_selector.dart (300 lines)
```

**Total:** All files under 1000 lines ✅

## Common Violations

### ❌ Violation 1: Monolithic Page File

```dart
// order_details_page.dart (2500 lines - TOO LARGE!)

class OrderDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 500 lines of header code
          // 800 lines of order details
          // 600 lines of timeline
          // 400 lines of action buttons
          // 200 lines of footer
        ],
      ),
    );
  }

  Widget _buildHeader() { /* 500 lines */ }
  Widget _buildDetails() { /* 800 lines */ }
  Widget _buildTimeline() { /* 600 lines */ }
  Widget _buildActions() { /* 400 lines */ }
  Widget _buildFooter() { /* 200 lines */ }
}
```

**Fix:** Extract each section to separate widget file

### ❌ Violation 2: Not Using Common Widgets

```dart
// Multiple features have their own button implementations
features/auth/presentation/widgets/auth_button.dart
features/profile/presentation/widgets/profile_button.dart
features/order/presentation/widgets/order_button.dart

// All implementing same styled button
```

**Fix:** Create single common widget

```dart
// core/common/widgets/app_button.dart
class AppButton extends StatelessWidget { /* shared implementation */ }

// Use in all features
```

### ❌ Violation 3: Too Many Responsibilities

```dart
// A single widget handling too much
class UserDashboard extends StatefulWidget {
  // Handles:
  // - User profile display
  // - Statistics rendering
  // - Chart visualization
  // - Action buttons
  // - Navigation
  // - State management
  // Result: 1800 lines
}
```

**Fix:** Split into focused widgets

```dart
class UserDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        UserProfileHeader(),
        UserStatistics(),
        UserCharts(),
        UserActions(),
      ],
    );
  }
}
```

## Guidelines for Widget Size

| Widget Type | Target Lines | Max Lines | Action if Exceeded |
|-------------|--------------|-----------|-------------------|
| Simple Widget | < 100 | 200 | Keep as is |
| Page Widget | 200-400 | 600 | Extract sections to widgets/ |
| Form Widget | 200-500 | 700 | Break into form sections |
| Complex Widget | 300-600 | 800 | Decompose into sub-widgets |
| Any Widget | - | 1000 | MUST extract/refactor |

## Widget Extraction Checklist

Before extracting a widget, ensure:

- [ ] Widget has clear, single responsibility
- [ ] Widget is used 2+ times OR file exceeds 800 lines
- [ ] Widget can be tested independently
- [ ] Widget has well-defined props/parameters
- [ ] Extracted to appropriate location (core vs feature)
- [ ] Proper naming convention followed
- [ ] Original file is now under 1000 lines
- [ ] All imports updated correctly

## Performance Considerations

### Use const Constructors

```dart
✅ CORRECT:
class LoginForm extends StatelessWidget {
  const LoginForm({super.key});
}

// Usage
const LoginForm()

❌ WRONG:
class LoginForm extends StatelessWidget {
  LoginForm();
}

// Usage
LoginForm()  // Creates new instance every rebuild
```

### Extract Expensive Widgets

```dart
✅ CORRECT:
class ExpensiveChart extends StatelessWidget {
  final List<DataPoint> data;
  const ExpensiveChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Complex chart rendering
  }
}

// In parent:
class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExpensiveChart(data: chartData);  // Rebuilds only when data changes
  }
}

❌ WRONG:
class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: /* inline complex chart code */,  // Rebuilds every time
    );
  }
}
```

## Checklist

- [ ] No file exceeds 1000 lines
- [ ] Shared widgets in core/common/widgets/
- [ ] Feature widgets in features/{feature}/presentation/widgets/
- [ ] Complex pages decomposed into smaller widgets
- [ ] Builder methods extracted to widgets
- [ ] Private widgets used for single-use components
- [ ] Const constructors used where possible
- [ ] Each widget has single responsibility
- [ ] Widget names are descriptive
- [ ] Proper file naming (snake_case)
- [ ] Imports organized and clean

## Related Guidelines

- [10_project_structure.md](10_project_structure.md) - Widget directory structure
- [12_naming_conventions.md](12_naming_conventions.md) - Widget naming patterns

## Summary

**Critical Rules:**
1. ⚠️ **Never exceed 1000 lines per file**
2. Extract at 800-1000 lines
3. Shared widgets → core/common/widgets/
4. Feature widgets → features/{feature}/presentation/widgets/
5. Use composition over monolithic files

**Extraction Triggers:**
- File approaching 1000 lines
- Widget used 2+ times
- Widget has clear responsibility
- Widget exceeds 50 lines

**Benefits:**
- Improved readability
- Better testability
- Easier maintenance
- Better performance (with const)
- Clear separation of concerns
