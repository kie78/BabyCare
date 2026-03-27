import '../models/babysitter_profile.dart';
import 'api_client.dart';

class BabysitterService {
  BabysitterService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<BabysitterProfile> getMyProfile() async {
    final response = await _apiClient.get('/api/v1/babysitters/profile');
    if (response is! Map<String, dynamic>) {
      throw ApiException(statusCode: 500, message: 'Invalid profile response');
    }
    return BabysitterProfile.fromJson(response);
  }

  Future<Map<String, dynamic>> getProfileViews() async {
    final response = await _apiClient.get('/api/v1/babysitters/profile/views');
    if (response is Map<String, dynamic>) {
      return response;
    }
    return <String, dynamic>{};
  }

  Future<Map<String, dynamic>> getWeeklyProfileViews() async {
    final response = await _apiClient.get(
      '/api/v1/babysitters/profile/weekly-views',
    );
    if (response is Map<String, dynamic>) {
      return response;
    }
    return <String, dynamic>{};
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
  }) async {
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
    );
  }
}
