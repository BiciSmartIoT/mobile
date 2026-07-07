import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/api_models.dart';

class ApiException implements Exception {
  ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  static const _timeout = Duration(seconds: 12);

  final http.Client _client = http.Client();
  String? _token;

  AppUser? currentUser;

  bool get isAuthenticated => _token != null && _token!.isNotEmpty;
  String? get token => _token;

  Future<Map<String, dynamic>> health() async {
    final response = await _client
        .get(ApiConfig.uri('/actuator/health'))
        .timeout(_timeout);
    return _decodeResponse(response) as Map<String, dynamic>;
  }

  Future<AuthResponse> login(String email, String password) async {
    final decoded = await _request(
      'POST',
      '/api/iam/auth/login',
      authenticated: false,
      body: {
        'email': email.trim(),
        'password': password,
      },
    ) as Map<String, dynamic>;

    final auth = AuthResponse.fromJson(decoded);
    _storeSession(auth.token, auth.user);
    return auth;
  }

  Future<AppUser> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final decoded = await _request(
      'POST',
      '/api/iam/auth/register',
      authenticated: false,
      body: {
        'email': email.trim(),
        'password': password,
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
      },
    ) as Map<String, dynamic>;
    return AppUser.fromJson(decoded);
  }

  Future<AppUser> me() async {
    final decoded = await _request('GET', '/api/iam/me') as Map<String, dynamic>;
    final user = AppUser.fromJson(decoded);
    _storeUser(user);
    return user;
  }

  Future<List<AppUser>> adminUsers() async {
    final decoded = await _request('GET', '/api/admin/users') as List<dynamic>;
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(AppUser.fromJson)
        .toList();
  }

  Future<MetricsResource> metrics() async {
    final decoded = await _request(
      'GET',
      '/api/metrics/overview',
      authenticated: false,
    ) as Map<String, dynamic>;
    return MetricsResource.fromJson(decoded);
  }

  Future<List<VehicleResource>> vehicles() async {
    final decoded = await _request(
      'GET',
      '/api/vehicles',
      authenticated: false,
    ) as List<dynamic>;
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(VehicleResource.fromJson)
        .toList();
  }

  Future<List<VehicleResource>> ownVehicles() async {
    final decoded = await _request('GET', '/api/vehicles/own') as List<dynamic>;
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(VehicleResource.fromJson)
        .toList();
  }

  Future<VehicleResource> createVehicle({
    required String title,
    required String description,
    required double hourlyPrice,
    required double latitude,
    required double longitude,
  }) async {
    final decoded = await _request(
      'POST',
      '/api/vehicles',
      body: {
        'title': title.trim(),
        'description': description.trim(),
        'hourlyPrice': hourlyPrice,
        'latitude': latitude,
        'longitude': longitude,
      },
    ) as Map<String, dynamic>;
    return VehicleResource.fromJson(decoded);
  }

  Future<AppUser> onboardProviderRole() async {
    final decoded = await _request(
      'POST',
      '/api/iam/providers/onboard',
    ) as Map<String, dynamic>;
    final user = AppUser.fromJson(decoded);
    _storeUser(user);
    return user;
  }

  Future<ProviderResource> requestProviderOnboarding({
    required String displayName,
    required String phone,
    required String docType,
    required String docNumber,
  }) async {
    final decoded = await _request(
      'POST',
      '/api/providing/onboarding',
      body: {
        'displayName': displayName.trim(),
        'phone': phone.trim(),
        'docType': docType.trim(),
        'docNumber': docNumber.trim(),
      },
    ) as Map<String, dynamic>;
    return ProviderResource.fromJson(decoded);
  }

  Future<ProviderResource?> myProvider() async {
    try {
      final decoded = await _request('GET', '/api/providing/me')
          as Map<String, dynamic>;
      return ProviderResource.fromJson(decoded);
    } on ApiException catch (error) {
      if (error.statusCode == 403 || error.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  Future<List<PaymentMethodResource>> paymentMethods() async {
    final decoded = await _request('GET', '/api/payments/methods')
        as List<dynamic>;
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(PaymentMethodResource.fromJson)
        .toList();
  }

  Future<PaymentMethodResource> addPaymentMethod({
    required String tokenRef,
    required String brand,
    required String last4,
    required bool makeDefault,
  }) async {
    final decoded = await _request(
      'POST',
      '/api/payments/methods',
      body: {
        'tokenRef': tokenRef.trim(),
        'brand': brand.trim(),
        'last4': last4.trim(),
        'makeDefault': makeDefault,
      },
    ) as Map<String, dynamic>;
    return PaymentMethodResource.fromJson(decoded);
  }

  Future<List<PayoutResource>> payouts() async {
    final decoded = await _request('GET', '/api/payments/payouts/mine')
        as List<dynamic>;
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(PayoutResource.fromJson)
        .toList();
  }

  Future<void> logout() async {
    _token = null;
    currentUser = null;
  }

  void _storeSession(String token, AppUser user) {
    _token = token;
    _storeUser(user);
  }

  void _storeUser(AppUser user) {
    currentUser = user;
  }

  Future<dynamic> _request(
    String method,
    String path, {
    bool authenticated = true,
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
  }) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (authenticated && isAuthenticated) {
      headers['Authorization'] = 'Bearer $_token';
    }

    try {
      final uri = ApiConfig.uri(path, query);
      final encodedBody = body == null ? null : jsonEncode(body);
      final response = switch (method) {
        'GET' => await _client.get(uri, headers: headers).timeout(_timeout),
        'POST' => await _client
            .post(uri, headers: headers, body: encodedBody)
            .timeout(_timeout),
        'PATCH' => await _client
            .patch(uri, headers: headers, body: encodedBody)
            .timeout(_timeout),
        'DELETE' => await _client.delete(uri, headers: headers).timeout(_timeout),
        _ => throw ApiException(0, 'Metodo HTTP no soportado'),
      };

      return _decodeResponse(response);
    } on TimeoutException {
      throw ApiException(0, 'El backend demoro demasiado en responder.');
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException(0, 'No se pudo conectar al backend: $error');
    }
  }

  dynamic _decodeResponse(http.Response response) {
    final body = response.body.trim();
    final decoded = _safeDecode(body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    throw ApiException(
      response.statusCode,
      'HTTP ${response.statusCode}: ${_extractError(decoded)}',
    );
  }

  dynamic _safeDecode(String body) {
    if (body.isEmpty) return null;
    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }

  String _extractError(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final candidates = [
        decoded['message'],
        decoded['detail'],
        decoded['title'],
        decoded['error'],
      ];
      for (final candidate in candidates) {
        final value = candidate?.toString().trim();
        if (value != null && value.isNotEmpty) {
          return value;
        }
      }
    }
    if (decoded is String && decoded.trim().isNotEmpty) {
      return decoded.trim();
    }
    return 'El backend respondio con error.';
  }
}
