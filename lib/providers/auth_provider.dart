import 'package:flutter/foundation.dart';

import '../models/auth_session.dart';
import '../models/auth_user.dart';
import '../models/sitter_registration.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({required AuthService authService}) : _authService = authService;

  final AuthService _authService;

  AuthSession? _session;
  bool _isLoading = false;
  bool _isInitializing = false;
  String? _errorMessage;
  int? _lastStatusCode;

  AuthSession? get session => _session;
  AuthUser? get currentUser => _session?.user;
  UserRole get currentRole => _session?.user.role ?? UserRole.unknown;
  bool get isAuthenticated => _session != null;
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  String? get errorMessage => _errorMessage;
  int? get lastStatusCode => _lastStatusCode;

  Future<void> initialize() async {
    _isInitializing = true;
    _errorMessage = null;
    _lastStatusCode = null;
    notifyListeners();

    try {
      _session = await _authService.restoreSession();
    } catch (_) {
      _session = null;
      _errorMessage = 'Unable to restore your session.';
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    _lastStatusCode = null;
    notifyListeners();

    try {
      _session = await _authService.login(email: email, password: password);
      _lastStatusCode = null;
      return true;
    } on ApiException catch (error) {
      _lastStatusCode = error.statusCode;
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _lastStatusCode = null;
      _errorMessage = 'Login failed. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registerParent({
    required String fullName,
    required String email,
    required String phone,
    required String location,
    required String occupation,
    required String preferredHours,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _lastStatusCode = null;
    notifyListeners();

    try {
      await _authService.registerParent(
        fullName: fullName,
        email: email,
        phone: phone,
        location: location,
        occupation: occupation,
        preferredHours: preferredHours,
        password: password,
      );
      return true;
    } on ApiException catch (error) {
      _lastStatusCode = error.statusCode;
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _lastStatusCode = null;
      _errorMessage = 'Registration failed. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registerBabysitter({
    required SitterRegistrationData data,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _lastStatusCode = null;
    notifyListeners();

    try {
      await _authService.registerBabysitter(data: data);
      return true;
    } on ApiException catch (error) {
      _lastStatusCode = error.statusCode;
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _lastStatusCode = null;
      _errorMessage = 'Registration failed. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    _errorMessage = null;
    _lastStatusCode = null;
    notifyListeners();

    try {
      await _authService.logout();
    } finally {
      _session = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> handleUnauthorized() async {
    await _authService.clearLocalSession();
    _session = null;
    _lastStatusCode = 401;
    notifyListeners();
  }
}
