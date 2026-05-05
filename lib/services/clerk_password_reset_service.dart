import 'package:clerk_auth/clerk_auth.dart' as clerk;

import '../config/clerk.dart';

class ClerkPasswordResetService {
  ClerkPasswordResetService({String? publishableKey})
    : _publishableKey = publishableKey ?? _resolvePublishableKey();

  static const _upperPublishableKey = String.fromEnvironment(
    'CLERK_PUBLISHABLE_KEY',
  );
  static const _lowerPublishableKey = String.fromEnvironment('publishable_key');

  final String _publishableKey;
  clerk.Auth? _auth;

  Future<void> initiateEmailPasswordReset(String email) async {
    final auth = await _ensureAuth();

    try {
      await auth.resetClient();
      await auth.initiatePasswordReset(
        identifier: email.trim(),
        strategy: clerk.Strategy.resetPasswordEmailCode,
      );
    } catch (error) {
      throw ClerkPasswordResetException(_messageFor(error));
    }
  }

  Future<void> resendEmailPasswordReset(String email) async {
    final auth = await _ensureAuth();

    try {
      if (auth.signIn == null) {
        await initiateEmailPasswordReset(email);
        return;
      }

      await auth.resendCode(clerk.Strategy.resetPasswordEmailCode);
    } catch (error) {
      throw ClerkPasswordResetException(_messageFor(error));
    }
  }

  Future<void> completeEmailPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final auth = await _ensureAuth();

    try {
      if (auth.signIn == null) {
        await auth.initiatePasswordReset(
          identifier: email.trim(),
          strategy: clerk.Strategy.resetPasswordEmailCode,
        );
      }

      await auth.attemptSignIn(
        strategy: clerk.Strategy.resetPasswordEmailCode,
        identifier: email.trim(),
        code: code.trim(),
        password: newPassword,
      );

      if (!auth.isSignedIn) {
        throw const ClerkPasswordResetException(
          'Password reset could not be completed. Request a new code and try again.',
        );
      }
    } catch (error) {
      if (error is ClerkPasswordResetException) {
        rethrow;
      }

      throw ClerkPasswordResetException(_messageFor(error));
    }
  }

  void dispose() {
    _auth?.terminate();
    _auth = null;
  }

  Future<clerk.Auth> _ensureAuth() async {
    if (_publishableKey.isEmpty) {
      throw const ClerkPasswordResetException(
        'Clerk is not configured. Start the app with --dart-define=CLERK_PUBLISHABLE_KEY=pk_... to enable password reset.',
      );
    }

    if (_auth != null) {
      return _auth!;
    }

    final auth = clerk.Auth(
      config: clerk.AuthConfig(
        publishableKey: _publishableKey,
        persistor: const _InMemoryPersistor(),
        sessionTokenPolling: false,
        clientRefreshPeriod: Duration.zero,
        telemetryPeriod: Duration.zero,
      ),
    );
    await auth.initialize();
    _auth = auth;
    return auth;
  }

  static String _resolvePublishableKey() {
    if (_upperPublishableKey.isNotEmpty) {
      return _upperPublishableKey;
    }

    if (_lowerPublishableKey.isNotEmpty) {
      return _lowerPublishableKey;
    }

    return BabyCareClerkConfig.publishableKey;
  }

  static String _messageFor(Object error) {
    if (error is clerk.ClerkError) {
      return error.message;
    }

    return 'Unable to process password reset right now. Please try again.';
  }
}

class ClerkPasswordResetException implements Exception {
  const ClerkPasswordResetException(this.message);

  final String message;
}

class _InMemoryPersistor implements clerk.Persistor {
  const _InMemoryPersistor();

  static final Map<String, Object?> _cache = <String, Object?>{};

  @override
  Future<void> initialize() async {}

  @override
  void terminate() {}

  @override
  Future<T?> read<T>(String key) async {
    return _cache[key] as T?;
  }

  @override
  Future<void> write<T>(String key, T value) async {
    _cache[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _cache.remove(key);
  }
}
