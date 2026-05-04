import 'api_client.dart';

class ReportService {
  ReportService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<void> submitReport({
    required String reportedUserId,
    required String reportType,
    String? description,
  }) async {
    final response = await _apiClient.post(
      '/api/v1/reports',
      body: {
        'reported_user_id': reportedUserId.trim(),
        'report_type': reportType.trim(),
        if ((description ?? '').trim().isNotEmpty)
          'description': description!.trim(),
      },
    );

    if (response != null && response is! Map<String, dynamic>) {
      throw ApiException(
        statusCode: 500,
        message: 'Invalid report submission response',
      );
    }
  }
}