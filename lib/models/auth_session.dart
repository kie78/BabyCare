import 'auth_user.dart';

class AuthSession {
  const AuthSession({required this.token, required this.user, this.expiresAt});

  final String token;
  final AuthUser user;
  final DateTime? expiresAt;

  bool get isExpired {
    if (expiresAt == null) {
      return false;
    }
    return DateTime.now().isAfter(expiresAt!);
  }

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      token: (json['token'] ?? '').toString(),
      user: AuthUser.fromJson(
        (json['user'] as Map<String, dynamic>?) ?? <String, dynamic>{},
      ),
      expiresAt: DateTime.tryParse((json['expires_at'] ?? '').toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
      'expires_at': expiresAt?.toIso8601String(),
    };
  }
}
