import '../models/auth_session.dart';
import '../models/sitter_registration.dart';
import 'api_client.dart';
import 'secure_storage_service.dart';

class AuthService {
  AuthService({
    required ApiClient apiClient,
    required SecureStorageService storage,
  }) : _apiClient = apiClient,
       _storage = storage;

  final ApiClient _apiClient;
  final SecureStorageService _storage;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/api/v1/auth/login',
      requiresAuth: false,
      body: {'email': email, 'password': password},
    );

    if (response is! Map<String, dynamic>) {
      throw ApiException(statusCode: 500, message: 'Invalid login response');
    }

    final session = AuthSession.fromJson(response);
    await _storage.saveSession(session);
    return session;
  }

  Future<void> logout() async {
    try {
      await _apiClient.post('/api/v1/auth/logout', body: <String, dynamic>{});
    } catch (_) {
      // Clear local session even if server-side logout fails.
    }
    await _storage.clearSession();
  }

  Future<AuthSession?> restoreSession() async {
    final session = await _storage.readSession();
    if (session == null) {
      return null;
    }

    if (session.isExpired) {
      await _storage.clearSession();
      return null;
    }

    return session;
  }

  Future<void> clearLocalSession() {
    return _storage.clearSession();
  }

  Future<Map<String, dynamic>> registerParent({
    required String fullName,
    required String email,
    required String phone,
    required String location,
    required String occupation,
    required String preferredHours,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/api/v1/auth/register/parent',
      requiresAuth: false,
      body: {
        'full_name': fullName.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'location': location.trim(),
        'primary_location': location.trim(),
        'occupation': occupation.trim(),
        'preferred_hours': preferredHours.trim(),
        'password': password,
      },
    );

    if (response is! Map<String, dynamic>) {
      throw ApiException(
        statusCode: 500,
        message: 'Invalid parent registration response',
      );
    }

    return response;
  }

  Future<Map<String, dynamic>> registerBabysitter({
    required SitterRegistrationData data,
  }) async {
    final requiredFiles = <String, String>{
      'national_id': data.nationalIdPath ?? '',
      'lci_letter': data.lciLetterPath ?? '',
      'cv': data.resumeCvPath ?? '',
      'profile_picture': data.profilePicturePath ?? '',
    };

    if (requiredFiles.values.any((path) => path.trim().isEmpty)) {
      throw ApiException(
        statusCode: 400,
        message: 'All required documents must be uploaded.',
      );
    }

    final normalizedRateAmount = (data.hourlyRate ?? '').trim().replaceAll(
      RegExp(r'[^0-9.]'),
      '',
    );

    final fields = <String, String>{
      'full_name': (data.fullName ?? '').trim(),
      'email': (data.email ?? '').trim(),
      'location': (data.location ?? '').trim(),
      'languages': (data.languages ?? const <String>[]).join(','),
      'password': data.password ?? '',
      'gender': (data.gender ?? '').toLowerCase(),
      'availability': (data.availableDays ?? const <String>[]).join(','),
      'rate_type': (data.rateType ?? 'hourly').toLowerCase(),
      'rate_amount': normalizedRateAmount,
      'currency': (data.currency ?? 'UGX').trim(),
    };

    final phone = (data.phone ?? '').trim();
    if (phone.isNotEmpty) {
      fields['phone'] = phone;
    }

    final paymentMethod = (data.paymentMethod ?? '').trim();
    if (paymentMethod.isNotEmpty) {
      fields['payment_method'] = paymentMethod;
    }

    final response = await _apiClient.postMultipart(
      '/api/v1/auth/register/babysitter',
      requiresAuth: false,
      fields: fields,
      files: requiredFiles,
    );

    if (response is! Map<String, dynamic>) {
      throw ApiException(
        statusCode: 500,
        message: 'Invalid registration response',
      );
    }

    return response;
  }
}
