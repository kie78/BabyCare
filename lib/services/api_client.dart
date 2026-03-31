import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

typedef TokenProvider = Future<String?> Function();

class ApiException implements Exception {
  ApiException({required this.statusCode, required this.message, this.body});

  final int statusCode;
  final String message;
  final Map<String, dynamic>? body;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  ApiClient({
    required this.baseUrl,
    this.tokenProvider,
    http.Client? client,
    Duration? timeout,
  }) : _client = client ?? http.Client(),
       _timeout = timeout ?? const Duration(seconds: 20);

  final String baseUrl;
  final TokenProvider? tokenProvider;
  final http.Client _client;
  final Duration _timeout;

  Future<Map<String, String>> _buildHeaders({
    bool requiresAuth = true,
    Map<String, String>? headers,
  }) async {
    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      ...?headers,
    };

    if (!requiresAuth) {
      return requestHeaders;
    }

    final token = await tokenProvider?.call();
    if (token == null || token.isEmpty) {
      throw ApiException(statusCode: 401, message: 'Missing auth token');
    }

    requestHeaders['Authorization'] = 'Bearer $token';
    return requestHeaders;
  }

  Uri _buildUri(String path) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$normalizedPath');
  }

  Future<dynamic> _performRequest(
    Future<http.Response> Function() request,
  ) async {
    try {
      final response = await request().timeout(_timeout);
      return _decodeResponse(response);
    } on TimeoutException {
      throw ApiException(
        statusCode: 408,
        message:
            'The request timed out. Please check your connection and try again.',
      );
    } on SocketException {
      throw ApiException(
        statusCode: 503,
        message:
            'Unable to reach the server. Please check your internet connection and try again.',
      );
    } on http.ClientException {
      throw ApiException(
        statusCode: 503,
        message: 'A network error occurred while contacting the server.',
      );
    }
  }

  Future<dynamic> _performMultipartRequest(
    Future<http.StreamedResponse> Function() request,
  ) async {
    try {
      final streamedResponse = await request().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);
      return _decodeResponse(response);
    } on TimeoutException {
      throw ApiException(
        statusCode: 408,
        message:
            'The upload took too long. Please try again with a stable connection.',
      );
    } on SocketException {
      throw ApiException(
        statusCode: 503,
        message:
            'Unable to reach the server. Please check your internet connection and try again.',
      );
    } on http.ClientException {
      throw ApiException(
        statusCode: 503,
        message: 'A network error occurred while sending the request.',
      );
    }
  }

  Future<dynamic> get(String path, {bool requiresAuth = true}) async {
    return _performRequest(
      () async => _client.get(
        _buildUri(path),
        headers: await _buildHeaders(requiresAuth: requiresAuth),
      ),
    );
  }

  Future<dynamic> post(
    String path, {
    bool requiresAuth = true,
    Map<String, dynamic>? body,
  }) async {
    return _performRequest(
      () async => _client.post(
        _buildUri(path),
        headers: await _buildHeaders(requiresAuth: requiresAuth),
        body: jsonEncode(body ?? <String, dynamic>{}),
      ),
    );
  }

  Future<dynamic> put(
    String path, {
    bool requiresAuth = true,
    Map<String, dynamic>? body,
  }) async {
    return _performRequest(
      () async => _client.put(
        _buildUri(path),
        headers: await _buildHeaders(requiresAuth: requiresAuth),
        body: jsonEncode(body ?? <String, dynamic>{}),
      ),
    );
  }

  Future<dynamic> delete(String path, {bool requiresAuth = true}) async {
    return _performRequest(
      () async => _client.delete(
        _buildUri(path),
        headers: await _buildHeaders(requiresAuth: requiresAuth),
      ),
    );
  }

  Future<dynamic> postMultipart(
    String path, {
    bool requiresAuth = true,
    required Map<String, String> fields,
    required Map<String, String> files,
  }) async {
    final request = http.MultipartRequest('POST', _buildUri(path));
    final headers = await _buildHeaders(
      requiresAuth: requiresAuth,
      headers: {'Accept': 'application/json'},
    );
    headers.remove('Content-Type');
    request.headers.addAll(headers);
    request.fields.addAll(fields);

    for (final entry in files.entries) {
      final filePath = entry.value.trim();
      if (filePath.isEmpty) {
        continue;
      }
      request.files.add(await http.MultipartFile.fromPath(entry.key, filePath));
    }

    return _performMultipartRequest(() => _client.send(request));
  }

  Future<dynamic> putMultipart(
    String path, {
    bool requiresAuth = true,
    required Map<String, String> fields,
    Map<String, String> files = const <String, String>{},
  }) async {
    final request = http.MultipartRequest('PUT', _buildUri(path));
    final headers = await _buildHeaders(
      requiresAuth: requiresAuth,
      headers: {'Accept': 'application/json'},
    );
    headers.remove('Content-Type');
    request.headers.addAll(headers);
    request.fields.addAll(fields);

    for (final entry in files.entries) {
      final filePath = entry.value.trim();
      if (filePath.isEmpty) {
        continue;
      }
      request.files.add(await http.MultipartFile.fromPath(entry.key, filePath));
    }

    return _performMultipartRequest(() => _client.send(request));
  }

  dynamic _decodeResponse(http.Response response) {
    final bodyText = response.body;
    dynamic decoded;

    if (bodyText.isNotEmpty) {
      try {
        decoded = jsonDecode(bodyText);
      } catch (_) {
        decoded = bodyText;
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    String message = 'Request failed';
    if (decoded is Map<String, dynamic>) {
      message = (decoded['error'] ?? decoded['message'] ?? message).toString();
    }

    throw ApiException(
      statusCode: response.statusCode,
      message: message,
      body: decoded is Map<String, dynamic> ? decoded : null,
    );
  }
}
