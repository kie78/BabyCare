class ParentProfile {
  const ParentProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.occupation,
    required this.preferredHours,
    this.phone,
    this.location,
    this.primaryLocation,
    this.profilePictureUrl,
    this.status,
  });

  final String id;
  final String fullName;
  final String email;
  final String occupation;
  final String preferredHours;
  final String? phone;
  final String? location;
  final String? primaryLocation;
  final String? profilePictureUrl;
  final String? status;

  ParentProfile copyWith({
    String? id,
    String? fullName,
    String? email,
    String? occupation,
    String? preferredHours,
    String? phone,
    String? location,
    String? primaryLocation,
    String? profilePictureUrl,
    String? status,
  }) {
    return ParentProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      occupation: occupation ?? this.occupation,
      preferredHours: preferredHours ?? this.preferredHours,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      primaryLocation: primaryLocation ?? this.primaryLocation,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      status: status ?? this.status,
    );
  }

  factory ParentProfile.fromJson(Map<String, dynamic> json) {
    return ParentProfile(
      id: (json['id'] ?? '').toString(),
      fullName: (json['full_name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      occupation: (json['occupation'] ?? '').toString(),
      preferredHours: (json['preferred_hours'] ?? '').toString(),
      phone: json['phone']?.toString(),
      location: json['location']?.toString(),
      primaryLocation: json['primary_location']?.toString(),
      profilePictureUrl:
          (json['profile_picture'] ?? json['profile_picture_url'])?.toString(),
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toRequestJson() {
    return {
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'location': location,
      'primary_location': primaryLocation,
      'occupation': occupation,
      'preferred_hours': preferredHours,
    };
  }
}
