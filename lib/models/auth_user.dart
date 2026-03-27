enum UserRole { admin, parent, babysitter, unknown }

UserRole userRoleFromString(String? rawRole) {
  switch (rawRole?.toLowerCase()) {
    case 'admin':
      return UserRole.admin;
    case 'parent':
      return UserRole.parent;
    case 'babysitter':
      return UserRole.babysitter;
    default:
      return UserRole.unknown;
  }
}

class AuthUser {
  const AuthUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.status,
    this.phone,
    this.createdAt,
  });

  final String id;
  final String fullName;
  final String email;
  final UserRole role;
  final String status;
  final String? phone;
  final DateTime? createdAt;

  bool get isBabysitter => role == UserRole.babysitter;
  bool get isApproved => status.toLowerCase() == 'active';

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: (json['id'] ?? '').toString(),
      fullName: (json['full_name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      role: userRoleFromString(json['role']?.toString()),
      status: (json['status'] ?? 'unknown').toString(),
      phone: json['phone']?.toString(),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'role': role.name,
      'status': status,
      'phone': phone,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
