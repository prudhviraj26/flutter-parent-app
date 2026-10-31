import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // Base URL for API
  static String get baseUrl {
    return 'https://veyhoprod-crb8ahfge9dmhwep.centralindia-01.azurewebsites.net/v1';
  }

  static const _storage = FlutterSecureStorage();
  static const String _tokenKey = 'veyho_parent_access_token';
  static const String _refreshTokenKey = 'veyho_parent_refresh_token';

  static Completer<bool>? _refreshCompleter;

  // Save Tokens securely
  static Future<void> saveTokens({required String accessToken, String? refreshToken}) async {
    await _storage.write(key: _tokenKey, value: accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    }
  }

  // Get Access Token
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Get Refresh Token
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  // Clear Tokens
  static Future<void> clearTokens() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  // Silent Token Renewal
  static Future<bool> refreshTokenSilently() async {
    // If a refresh is already in progress, await its completion
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    final completer = Completer<bool>();
    _refreshCompleter = completer;


    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        if (!completer.isCompleted) completer.complete(false);
        return false;
      }

      final url = Uri.parse('$baseUrl/auth/refresh');
      final res = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'x-refresh-token': refreshToken,
        },
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final body = jsonDecode(res.body);
        if (body is Map<String, dynamic> && body['accessToken'] != null) {
          final newAccess = body['accessToken'] as String;
          final newRefresh = body['refreshToken'] as String? ?? refreshToken;
          await saveTokens(accessToken: newAccess, refreshToken: newRefresh);
          debugPrint('Parent App silent token refresh succeeded');
          if (!completer.isCompleted) completer.complete(true);
          return true;
        }
      } else if (res.statusCode == 401 || res.statusCode == 403) {
        // Refresh token is expired or revoked on server
        debugPrint('Parent App refresh token expired/revoked on server');
        debugPrint('Parent App refresh rejected: ${res.statusCode}');
      }
    } catch (e) {
      debugPrint('Parent App silent token refresh failed: $e');
    } finally {
      if (!completer.isCompleted) {
        completer.complete(false);
      }
      _refreshCompleter = null;
    }
    return false;
  }

  // Headers Helper
  static Future<Map<String, String>> _getHeaders({bool requireAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requireAuth) {
      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // GET Request with Auto-Token Refresh Retry
  static Future<dynamic> get(String endpoint, {bool requireAuth = true, bool isRetry = false}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders(requireAuth: requireAuth);

    final http.Response response;
    try {
      response = await http.get(url, headers: headers);
    } catch (e) {
      throw Exception('Unable to connect to server. Please check your internet connection.');
    }

    if (response.statusCode == 401 && requireAuth && !isRetry) {
      final refreshed = await refreshTokenSilently();
      if (refreshed) {
        return await get(endpoint, requireAuth: requireAuth, isRetry: true);
      }
    }
    return _processResponse(response);
  }

  // POST Request with Auto-Token Refresh Retry
  static Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool requireAuth = true,
    bool isRetry = false,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders(requireAuth: requireAuth);

    final http.Response response;
    try {
      response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
    } catch (e) {
      throw Exception('Unable to connect to server. Please check your internet connection.');
    }

    if (response.statusCode == 401 && requireAuth && !isRetry) {
      final refreshed = await refreshTokenSilently();
      if (refreshed) {
        return await post(endpoint, body, requireAuth: requireAuth, isRetry: true);
      }
    }
    return _processResponse(response);
  }

  // PATCH Request with Auto-Token Refresh Retry
  static Future<dynamic> patch(
    String endpoint,
    Map<String, dynamic> body, {
    bool requireAuth = true,
    bool isRetry = false,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders(requireAuth: requireAuth);

    final http.Response response;
    try {
      response = await http.patch(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
    } catch (e) {
      throw Exception('Unable to connect to server. Please check your internet connection.');
    }

    if (response.statusCode == 401 && requireAuth && !isRetry) {
      final refreshed = await refreshTokenSilently();
      if (refreshed) {
        return await patch(endpoint, body, requireAuth: requireAuth, isRetry: true);
      }
    }
    return _processResponse(response);
  }

  // DELETE Request with Auto-Token Refresh Retry
  static Future<dynamic> delete(
    String endpoint, {
    bool requireAuth = true,
    bool isRetry = false,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders(requireAuth: requireAuth);

    try {
      final response = await http.delete(url, headers: headers);
      if (response.statusCode == 401 && requireAuth && !isRetry) {
        final refreshed = await refreshTokenSilently();
        if (refreshed) {
          return await delete(endpoint, requireAuth: requireAuth, isRetry: true);
        }
      }
      return _processResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Response Processing
  static dynamic _processResponse(http.Response response) {
    final statusCode = response.statusCode;
    final responseBody = response.body;

    dynamic jsonBody;
    try {
      jsonBody = jsonDecode(responseBody);
    } catch (_) {
      jsonBody = responseBody;
    }

    if (statusCode >= 200 && statusCode < 300) {
      return jsonBody;
    } else {
      String errorMessage = 'An error occurred';
      if (jsonBody is Map<String, dynamic>) {
        errorMessage = jsonBody['message']?.toString() ?? jsonBody['error']?.toString() ?? errorMessage;
      }
      throw Exception(errorMessage);
    }
  }

  // Legal & Clickwrap Endpoints
  static Future<Map<String, dynamic>?> fetchActiveLegalDocuments() async {
    try {
      final res = await get('/legal/active', requireAuth: false);
      if (res is Map<String, dynamic>) {
        return res;
      }
    } catch (e) {
      debugPrint('[ApiService] Failed to fetch active legal documents: $e');
    }
    return null;
  }

  static Future<bool> recordLegalConsent({
    required List<Map<String, dynamic>> consents,
    String? deviceUuid,
    String? deviceToken,
  }) async {
    try {
      final payload = <String, dynamic>{
        'consents': consents,
      };
      if (deviceUuid != null) payload['deviceUuid'] = deviceUuid;
      if (deviceToken != null) payload['deviceToken'] = deviceToken;

      final res = await post('/legal/consent', payload, requireAuth: true);
      return res != null && res['success'] == true;
    } catch (e) {
      debugPrint('[ApiService] Failed to record legal consent: $e');
      return false;
    }
  }

  // Device Token & Push Registration
  static Future<bool> registerDeviceToken({
    required String deviceToken,
    required String platform,
    String? deviceUuid,
    String? deviceModel,
    String? deviceManufacturer,
    String? osVersion,
    String? appVersion,
    String? locale,
    String? timezone,
  }) async {
    try {
      final payload = <String, dynamic>{
        'deviceToken': deviceToken,
        'platform': platform,
      };
      if (deviceUuid != null) payload['deviceUuid'] = deviceUuid;
      if (deviceModel != null) payload['deviceModel'] = deviceModel;
      if (deviceManufacturer != null) payload['deviceManufacturer'] = deviceManufacturer;
      if (osVersion != null) payload['osVersion'] = osVersion;
      if (appVersion != null) payload['appVersion'] = appVersion;
      if (locale != null) payload['locale'] = locale;
      if (timezone != null) payload['timezone'] = timezone;

      await post('/communication/device-token', payload, requireAuth: true);
      return true;
    } catch (e) {
      debugPrint('[ApiService] Failed to register device token: $e');
      return false;
    }
  }

  static Future<bool> removeDeviceToken(String deviceToken) async {
    try {
      await post('/communication/device-token/remove', {'deviceToken': deviceToken}, requireAuth: true);
      return true;
    } catch (e) {
      debugPrint('[ApiService] Failed to remove device token: $e');
      return false;
    }
  }
}
