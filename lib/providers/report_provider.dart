import 'package:flutter/foundation.dart';

import '../services/api_client.dart';
import '../services/report_service.dart';

class ReportProvider extends ChangeNotifier {
  ReportProvider({required ReportService reportService})
    : _reportService = reportService;

  final ReportService _reportService;

  bool _isSubmitting = false;
  String? _errorMessage;
  int? _lastStatusCode;

  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  int? get lastStatusCode => _lastStatusCode;

  Future<bool> submitReport({
    required String reportedUserId,
    required String reportType,
    String? description,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    _lastStatusCode = null;
    notifyListeners();

    try {
      await _reportService.submitReport(
        reportedUserId: reportedUserId,
        reportType: reportType,
        description: description,
      );
      return true;
    } on ApiException catch (error) {
      _lastStatusCode = error.statusCode;
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _lastStatusCode = null;
      _errorMessage = 'Unable to submit your report right now.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
