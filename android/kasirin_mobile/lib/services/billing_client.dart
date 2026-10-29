import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'billing_config.dart' as config;

class BillingClient {
  BillingClient(this._billingConfig);

  final config.BillingConfig _billingConfig;

  String get _baseUrl => _billingConfig.baseUrl.replaceAll(RegExp(r'/$'), '');

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  /// Default headers for JSON API requests.
  Map<String, String> get _defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    // Free ngrok tunnels return an HTML interstitial unless API clients opt out.
    'ngrok-skip-browser-warning': '1',
  };

  /// Helper method to handle HTTP responses uniformly.
  dynamic _handleResponse(http.Response response) {
    final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
    if (response.body.isEmpty) {
      if (isSuccess) return null;
      throw Exception('Server error: HTTP ${response.statusCode}.');
    }
    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      final contentType = response.headers['content-type'] ?? '';
      if (contentType.contains('text/html')) {
        throw Exception(
          'Server billing mengirim halaman web, bukan respons API. '
          'Periksa URL billing server dan tunnel.',
        );
      }
      throw Exception(
        'Respons server bukan JSON (HTTP ${response.statusCode}).',
      );
    }
    if (isSuccess) return decoded;
    final detail = decoded is Map ? decoded['detail']?.toString() : null;
    throw Exception(
      'Server error: HTTP ${response.statusCode}'
      '${detail == null || detail.isEmpty ? '' : ' — $detail'}',
    );
  }

  /// Check whether the server is reachable.
  Future<bool> checkServerHealth() async {
    try {
      final response = await http
          .get(_uri('/health'), headers: _defaultHeaders)
          .timeout(const Duration(seconds: 5));

      return response.statusCode >= 200 && response.statusCode < 300;
    } on TimeoutException {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Register a POS device with the server.
  Future<dynamic> registerDevice({
    required String installationId,
    required String deviceId,
    required String storeName,
    required String customerToken,
  }) async {
    final response = await http
        .post(
          _uri('/api/pos/register'),
          headers: {
            ..._defaultHeaders,
            'Authorization': 'Bearer $customerToken',
          },
          body: jsonEncode({
            'posreq': jsonEncode({
              'schema_version': 1,
              'product': 'POS Retail',
              'installation_id': installationId,
              'device_id': deviceId,
              'store_name': storeName,
            }),
          }),
        )
        .timeout(const Duration(seconds: 10));

    return _handleResponse(response);
  }

  /// Check the license status of the current device.
  Future<dynamic> checkLicense({required String bearerToken}) async {
    final response = await http
        .get(
          _uri('/api/pos/license'),
          headers: {..._defaultHeaders, 'Authorization': 'Bearer $bearerToken'},
        )
        .timeout(const Duration(seconds: 10));

    return _handleResponse(response);
  }

  Future<dynamic> loginCustomer({
    required String email,
    required String password,
  }) async {
    final response = await http
        .post(
          _uri('/api/auth/login'),
          headers: _defaultHeaders,
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(const Duration(seconds: 12));
    return _handleResponse(response);
  }

  Future<dynamic> registerCustomer({
    required String email,
    required String password,
    required String storeName,
  }) async {
    final response = await http
        .post(
          _uri('/api/auth/register'),
          headers: _defaultHeaders,
          body: jsonEncode({
            'email': email,
            'password': password,
            'store_name': storeName,
          }),
        )
        .timeout(const Duration(seconds: 12));
    return _handleResponse(response);
  }

  Future<dynamic> getPlans() async {
    final response = await http
        .get(_uri('/api/pos/status'), headers: _defaultHeaders)
        .timeout(const Duration(seconds: 10));
    return _handleResponse(response);
  }

  Future<dynamic> createLicenseCheckout({
    required String customerToken,
    required int devicePk,
    required String planCode,
  }) async {
    final response = await http
        .post(
          _uri('/api/checkout/create'),
          headers: {
            ..._defaultHeaders,
            'Authorization': 'Bearer $customerToken',
          },
          body: jsonEncode({'device_pk': devicePk, 'plan_code': planCode}),
        )
        .timeout(const Duration(seconds: 20));
    return _handleResponse(response);
  }

  /// Get device status and subscription information.
  Future<dynamic> getDeviceStatus({required String bearerToken}) async {
    final response = await http
        .get(
          _uri('/api/pos/status'),
          headers: {..._defaultHeaders, 'Authorization': 'Bearer $bearerToken'},
        )
        .timeout(const Duration(seconds: 10));

    return _handleResponse(response);
  }
}
