# Dependencies Setup - Package Installation

**Purpose:** Install and configure essential packages for Flutter Clean Architecture
**Pattern:** Use `flutter pub add` to always get latest versions

## ⚠️ Important Notes

1. **Always use latest versions** - Commands below use `flutter pub add` which automatically fetches the latest compatible version
2. **Verify maintenance status** - Before using any package, check pub.dev for:
   - Recent updates (within last 6 months)
   - Active maintenance
   - Pub Points score (90+ preferred)
   - Popularity percentage
3. **Check breaking changes** - Review package changelog after updates

## Installation Steps

### Step 1: Core Architecture Dependencies

These are essential for Clean Architecture implementation:

```bash
# State Management - BLoC Pattern
flutter pub add flutter_bloc

# Dependency Injection - Service Locator
flutter pub add get_it

# Functional Programming - Either type for error handling
flutter pub add fpdart

```

**Why these packages:**
- `flutter_bloc` - Official BLoC state management (well-maintained by Felix Angelov)
- `get_it` - Simple service locator for dependency injection
- `fpdart` - Functional programming with Either<Left, Right> for error handling

### Step 2: Network & API

```bash
# HTTP Client
flutter pub add http

# JSON Serialization (if not using code generation)
# dart:convert is built-in, no package needed

# OR use JSON Serialization with code generation:
flutter pub add json_annotation
flutter pub add --dev json_serializable
flutter pub add --dev build_runner
```

**Why these packages:**
- `http` - Official HTTP client from Dart team
- `json_annotation` + `json_serializable` - Type-safe JSON serialization (optional)

### Step 3: Local Storage

```bash
# Secure Storage - For sensitive data (tokens, credentials)
flutter pub add flutter_secure_storage

# Shared Preferences - For simple key-value storage
flutter pub add shared_preferences

# Path Provider - For file system access
flutter pub add path_provider
```

**Why these packages:**
- `flutter_secure_storage` - Encrypted storage for sensitive data
- `shared_preferences` - Simple persistent storage
- `path_provider` - Access to common file system locations

### Step 4: Routing & Navigation

```bash
# Declarative Routing
flutter pub add go_router
```

**Why this package:**
- `go_router` - Official Flutter team routing solution with deep linking support

### Step 5: Utilities

```bash
# Logging
flutter pub add logger

# Network Connectivity
flutter pub add connectivity_plus

# Device Info
flutter pub add device_info_plus

# Package Info
flutter pub add package_info_plus
```

**Why these packages:**
- `logger` - Beautiful console logging with levels
- `connectivity_plus` - Check network connectivity status
- `device_info_plus` - Get device information
- `package_info_plus` - Access app version and build number

### Step 6: UI & Widgets

```bash
# Cached Network Images
flutter pub add cached_network_image

# SVG Support
flutter pub add flutter_svg

# Shimmer Loading Effect
flutter pub add shimmer
```

**Why these packages:**
- `cached_network_image` - Image caching and loading
- `flutter_svg` - SVG rendering support
- `shimmer` - Loading skeleton screens

### Step 7: Development Tools

```bash
# Linting
flutter pub add --dev flutter_lints

# Testing
flutter pub add --dev mocktail

# BLoC Testing
flutter pub add --dev bloc_test
```

**Why these packages:**
- `flutter_lints` - Official Flutter linting rules
- `mocktail` - Mocking framework for tests
- `bloc_test` - Testing utilities for BLoC

## Complete Installation Script

Run all commands at once:

```bash
# Core Architecture
flutter pub add flutter_bloc get_it fpdart

# Network & API
flutter pub add http

# Local Storage
flutter pub add flutter_secure_storage shared_preferences path_provider

# Routing
flutter pub add go_router

# Utilities
flutter pub add logger connectivity_plus device_info_plus package_info_plus

# UI & Widgets
flutter pub add cached_network_image flutter_svg shimmer

# Dev Dependencies
flutter pub add --dev flutter_lints mocktail bloc_test
```

## Optional Dependencies

Based on project needs:

### Firebase Integration

```bash
flutter pub add firebase_core
flutter pub add firebase_auth
flutter pub add cloud_firestore
flutter pub add firebase_messaging
flutter pub add firebase_analytics
```

### Forms & Validation

```bash
# Form Management
flutter pub add flutter_form_builder

# Validation
flutter pub add form_builder_validators
```

### Image Handling

```bash
# Image Picker
flutter pub add image_picker

# Image Cropper
flutter pub add image_cropper
```

### Internationalization

```bash
# Localization
flutter pub add flutter_localizations --sdk=flutter
flutter pub add intl
```

### Date & Time

```bash
# Date Formatting
flutter pub add intl

# Date Picker
flutter pub add flutter_datetime_picker
```

### Permissions

```bash
# Permission Handling
flutter pub add permission_handler
```

## Package Verification Checklist

Before using any package, verify on pub.dev:

- [ ] **Last updated:** Within 6 months (12 months acceptable for stable packages)
- [ ] **Pub Points:** 90+ out of 130
- [ ] **Popularity:** 70%+
- [ ] **Likes:** 100+ (for critical packages)
- [ ] **Issues:** Active issue resolution
- [ ] **Documentation:** Comprehensive README
- [ ] **Examples:** Working example code
- [ ] **Null Safety:** Full null safety support
- [ ] **Platforms:** Supports required platforms (iOS, Android, Web, etc.)

## pubspec.yaml Configuration

After adding dependencies, your `pubspec.yaml` should look like:

```yaml
name: your_app_name
description: A Flutter Clean Architecture project
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # Core Architecture
  flutter_bloc: ^latest
  get_it: ^latest
  fpdart: ^latest

  # Network & API
  http: ^latest

  # Local Storage
  flutter_secure_storage: ^latest
  shared_preferences: ^latest
  path_provider: ^latest

  # Routing
  go_router: ^latest

  # Utilities
  logger: ^latest
  connectivity_plus: ^latest
  device_info_plus: ^latest
  package_info_plus: ^latest

  # UI & Widgets
  cached_network_image: ^latest
  flutter_svg: ^latest
  shimmer: ^latest

dev_dependencies:
  flutter_test:
    sdk: flutter

  flutter_lints: ^latest
  mocktail: ^latest
  bloc_test: ^latest

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
```

**Note:** Replace `^latest` with actual versions after running `flutter pub add`

## Post-Installation Setup

### 1. Configure Logger

```dart
// lib/core/utils/logger.dart

import 'package:logger/logger.dart';

class Log {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  static void debug(String message) => _logger.d(message);
  static void info(String message) => _logger.i(message);
  static void warning(String message) => _logger.w(message);
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}
```

### 2. Configure HTTP Service

```dart
// lib/core/network/http_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';

class HttpService {
  final http.Client _client;
  final String baseUrl;

  HttpService({
    http.Client? client,
    required this.baseUrl,
  }) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await _client.get(Uri.parse('$baseUrl$endpoint'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw ServerException('GET request failed: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final response = await _client.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw ServerException('POST request failed: ${response.statusCode}');
    }
  }
}
```

### 3. Configure Secure Storage

```dart
// lib/core/storage/secure_storage_service.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}
```

### 4. Configure Connectivity Checker

```dart
// lib/core/network/network_info.dart

import 'package:connectivity_plus/connectivity_plus.dart';

abstract interface class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;

  NetworkInfoImpl(this._connectivity);

  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
}
```

### 5. Register in Dependency Injection

```dart
// lib/core/injection_container/injection_container.dart

import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External Dependencies
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton(() => const FlutterSecureStorage());

  // Core Services
  sl.registerLazySingleton(() => HttpService(
        client: sl(),
        baseUrl: 'https://your-api.com',
      ));

  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  sl.registerLazySingleton(() => SecureStorageService(storage: sl()));

  // Continue with feature registrations...
}
```

## Update Commands

To update all packages to latest versions:

```bash
# Update all dependencies
flutter pub upgrade

# Check for outdated packages
flutter pub outdated

# Update major versions (breaking changes)
flutter pub upgrade --major-versions
```

## Alternative Packages

If primary packages have issues:

| Category | Primary | Alternative |
|----------|---------|-------------|
| State Management | flutter_bloc | riverpod, provider |
| DI | get_it | injectable, riverpod |
| Either type | fpdart | dartz |
| HTTP | http | dio |
| Routing | go_router | auto_route, beamer |
| Secure Storage | flutter_secure_storage | hive (encrypted) |
| Logging | logger | talker, pretty_dio_logger |

## Troubleshooting

### Version Conflicts

```bash
# Clean and get dependencies
flutter clean
flutter pub get
```

### Platform-Specific Issues

**iOS:**
```bash
cd ios
pod install
cd ..
```

**Android:**
- Update `android/app/build.gradle` minSdkVersion if needed
- Check AndroidManifest.xml permissions

### Cache Issues

```bash
# Clear pub cache
flutter pub cache clean

# Clear Flutter cache
flutter clean
```

## Checklist

- [ ] All core dependencies installed
- [ ] Network dependencies installed
- [ ] Storage dependencies installed
- [ ] Routing dependencies installed
- [ ] Utilities installed
- [ ] Dev dependencies installed
- [ ] pubspec.yaml validated (no errors)
- [ ] Logger configured
- [ ] HTTP service configured
- [ ] Secure storage configured
- [ ] Network info configured
- [ ] All services registered in DI
- [ ] Platform-specific setup completed
- [ ] App runs without dependency errors

## Related Guidelines

- [07_dependency_injection.md](07_dependency_injection.md) - How to register dependencies
- [10_project_structure.md](10_project_structure.md) - Where to place service files
- [05_data_source_pattern.md](05_data_source_pattern.md) - Using HTTP service

## Summary

**Essential Packages:**
1. **State Management:** flutter_bloc, get_it
2. **Functional:** fpdart (Either type)
3. **Network:** http
4. **Storage:** flutter_secure_storage, shared_preferences
5. **Routing:** go_router
6. **Utilities:** logger, connectivity_plus

**Installation Pattern:**
```bash
flutter pub add <package_name>  # Always gets latest version
```

**Verification:**
- Check pub.dev for maintenance status
- Verify pub points (90+)
- Check last update date (within 6 months)
- Review breaking changes

**Post-Installation:**
- Configure services (Logger, HTTP, Storage)
- Register in dependency injection
- Test on all target platforms
