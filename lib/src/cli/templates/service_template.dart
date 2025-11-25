/// Template for generating service classes.
///
/// Services are used in the data layer for external integrations
/// like API clients, local storage, etc.
class ServiceTemplate {
  /// Generates a service interface.
  static String generateInterface({
    required String serviceName,
    required String servicePascal,
  }) {
    return '''
/// Interface for $serviceName operations.
///
/// This service handles external integrations and should be
/// implemented in the data layer.
abstract interface class ${servicePascal}Service {
  // TODO: Add service methods
  // Example:
  // Future<Response> fetchData();
  // Future<void> saveData(Data data);
}
''';
  }

  /// Generates a service implementation.
  static String generateImplementation({
    required String serviceName,
    required String servicePascal,
    required String featureName,
  }) {
    return '''
import '../../../domain/services/${serviceName}_service.dart';

/// Implementation of [${servicePascal}Service].
///
/// This class handles the actual external integration logic.
class ${servicePascal}ServiceImpl implements ${servicePascal}Service {
  ${servicePascal}ServiceImpl();

  // TODO: Implement service methods
  // Example:
  // @override
  // Future<Response> fetchData() async {
  //   // Implementation
  // }
}
''';
  }

  /// Generates an API service implementation.
  static String generateApiService({
    required String serviceName,
    required String servicePascal,
  }) {
    return '''
import 'package:http/http.dart' as http;

/// API service for $serviceName operations.
///
/// Handles HTTP requests to the backend API.
class ${servicePascal}ApiService {
  final http.Client _client;
  final String _baseUrl;

  ${servicePascal}ApiService({
    required http.Client client,
    required String baseUrl,
  })  : _client = client,
        _baseUrl = baseUrl;

  /// Makes a GET request to the specified endpoint.
  Future<http.Response> get(String endpoint) async {
    final uri = Uri.parse('\$_baseUrl\$endpoint');
    return _client.get(uri);
  }

  /// Makes a POST request to the specified endpoint.
  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('\$_baseUrl\$endpoint');
    return _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body != null ? _encodeBody(body) : null,
    );
  }

  /// Makes a PUT request to the specified endpoint.
  Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('\$_baseUrl\$endpoint');
    return _client.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body != null ? _encodeBody(body) : null,
    );
  }

  /// Makes a DELETE request to the specified endpoint.
  Future<http.Response> delete(String endpoint) async {
    final uri = Uri.parse('\$_baseUrl\$endpoint');
    return _client.delete(uri);
  }

  String _encodeBody(Map<String, dynamic> body) {
    // Simple JSON encoding - in production use dart:convert
    return body.entries
        .map((e) => '"\${e.key}": \${_encodeValue(e.value)}')
        .join(', ');
  }

  String _encodeValue(dynamic value) {
    if (value is String) return '"\$value"';
    if (value is num || value is bool) return '\$value';
    if (value == null) return 'null';
    return '"\$value"';
  }
}
''';
  }

  /// Generates a local storage service implementation.
  static String generateStorageService({
    required String serviceName,
    required String servicePascal,
  }) {
    return '''
/// Local storage service for $serviceName data.
///
/// Handles caching and local persistence.
class ${servicePascal}StorageService {
  // TODO: Inject your preferred storage solution
  // Examples:
  // - SharedPreferences for simple key-value storage
  // - Hive for complex object storage
  // - flutter_secure_storage for sensitive data

  ${servicePascal}StorageService();

  /// Saves data to local storage.
  Future<void> save(String key, String value) async {
    // TODO: Implement save logic
    throw UnimplementedError();
  }

  /// Retrieves data from local storage.
  Future<String?> get(String key) async {
    // TODO: Implement get logic
    throw UnimplementedError();
  }

  /// Removes data from local storage.
  Future<void> remove(String key) async {
    // TODO: Implement remove logic
    throw UnimplementedError();
  }

  /// Clears all data from local storage.
  Future<void> clear() async {
    // TODO: Implement clear logic
    throw UnimplementedError();
  }
}
''';
  }
}
