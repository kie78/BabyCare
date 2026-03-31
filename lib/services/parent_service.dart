import '../models/babysitter_profile.dart';
import '../models/parent_profile.dart';
import 'api_client.dart';

class ParentService {
  ParentService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

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

  Future<ParentProfile> getProfile() async {
    final response = await _apiClient.get('/api/v1/parents/profile');
    if (response is! Map<String, dynamic>) {
      throw ApiException(
        statusCode: 500,
        message: 'Invalid parent profile response',
      );
    }

    return ParentProfile.fromJson(response);
  }

  Future<ParentProfile> updateProfile(ParentProfile profile) async {
    return updateProfileWithImage(profile: profile);
  }

  Future<ParentProfile> updateProfileWithImage({
    required ParentProfile profile,
    String? profilePicturePath,
  }) async {
    final normalizedImagePath = (profilePicturePath ?? '').trim();

    if (normalizedImagePath.isEmpty) {
      final response = await _apiClient.put(
        '/api/v1/parents/profile',
        body: profile.toRequestJson(),
      );

      if (response is Map<String, dynamic>) {
        return ParentProfile.fromJson(response);
      }

      return profile;
    }

    final response = await _apiClient.put(
      '/api/v1/parents/profile',
      body: profile.toRequestJson(),
    );

    final multipartResponse = await _apiClient.putMultipart(
      '/api/v1/parents/profile',
      fields: <String, String>{
        'location': (profile.location ?? '').trim(),
        'primary_location': (profile.primaryLocation ?? '').trim(),
        'occupation': profile.occupation.trim(),
        'preferred_hours': profile.preferredHours.trim(),
      },
      files: <String, String>{'profile_picture': normalizedImagePath},
    );

    if (multipartResponse is Map<String, dynamic>) {
      return ParentProfile.fromJson(multipartResponse);
    }

    if (response is Map<String, dynamic>) {
      return ParentProfile.fromJson(response);
    }

    return profile;
  }

  Future<List<BabysitterProfile>> getSavedBabysitters() async {
    final response = await _apiClient.get('/api/v1/parents/saved-babysitters');
    return _parseBabysitters(response);
  }

  Future<void> saveBabysitter(String babysitterId) async {
    await _apiClient.post(
      '/api/v1/parents/saved-babysitters',
      body: {'babysitter_id': babysitterId},
    );
  }

  Future<void> deleteSavedBabysitter(String babysitterId) async {
    await _apiClient.delete('/api/v1/parents/saved-babysitters/$babysitterId');
  }
}
