import '../models/babysitter_profile.dart';
import '../models/parent_public_profile.dart';
import 'api_client.dart';

class BabysitterService {
  BabysitterService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Map<String, dynamic>? _extractProfileMap(dynamic response) {
    if (response is Map<String, dynamic>) {
      final nested = response['data'] ?? response['item'] ?? response['babysitter'];
      if (nested is Map<String, dynamic>) {
        return nested;
      }
      return response;
    }
    return null;
  }

  List<BabysitterProfile> _parseBabysitters(dynamic response) {
    final rawList = response is List
        ? response
        : response is Map<String, dynamic>
        ? (response['data'] ?? response['items'] ?? response['babysitters'])
        : null;

    if (rawList is! List) {
      return const <BabysitterProfile>[];
    }

    return rawList
        .whereType<Map<String, dynamic>>()
        .map(BabysitterProfile.fromJson)
        .toList();
  }

  Future<List<BabysitterProfile>> getBabysitters() async {
    final response = await _apiClient.get(
      '/api/v1/babysitters',
      requiresAuth: false,
    );
    return _parseBabysitters(response);
  }

  Future<BabysitterProfile> getBabysitterById(String id) async {
    final response = await _apiClient.get('/api/v1/babysitters/$id');
    final profileJson = _extractProfileMap(response);
    if (profileJson == null) {
      throw ApiException(
        statusCode: 500,
        message: 'Invalid babysitter profile response',
      );
    }
    return BabysitterProfile.fromJson(profileJson);
  }

  Future<BabysitterProfile> getMyProfile() async {
    final response = await _apiClient.get('/api/v1/babysitters/profile');
    final profileJson = _extractProfileMap(response);
    if (profileJson == null) {
      throw ApiException(statusCode: 500, message: 'Invalid profile response');
    }
    return BabysitterProfile.fromJson(profileJson);
  }

  Future<ParentPublicProfile> getParentPublicProfile(String parentId) async {
    final response = await _apiClient.get('/api/v1/parents/$parentId');
    if (response is! Map<String, dynamic>) {
      throw ApiException(
        statusCode: 500,
        message: 'Invalid parent profile response',
      );
    }

    return ParentPublicProfile.fromJson(response);
  }

  Future<dynamic> getProfileViews() async {
    return _apiClient.get('/api/v1/babysitters/profile/views');
  }

  Future<dynamic> getWeeklyProfileViews() async {
    return _apiClient.get('/api/v1/babysitters/profile/weekly-views');
  }

  Future<void> updateWorkStatus({required bool isAvailable}) async {
    await _apiClient.put(
      '/api/v1/babysitters/work-status',
      body: {'is_available': isAvailable},
    );
  }

  Future<void> updateProfile({
    required String location,
    required String rateType,
    required String rateAmount,
    required String currency,
    required String paymentMethod,
    required List<String> availability,
    String? profilePicturePath,
  }) async {
    final normalizedImagePath = (profilePicturePath ?? '').trim();

    await _apiClient.putMultipart(
      '/api/v1/babysitters/profile',
      fields: <String, String>{
        'location': location,
        'rate_type': rateType,
        'rate_amount': rateAmount,
        'currency': currency,
        'payment_method': paymentMethod,
        'availability': availability.join(','),
      },
      files: normalizedImagePath.isEmpty
          ? const <String, String>{}
          : <String, String>{'profile_picture': normalizedImagePath},
    );
  }
}
