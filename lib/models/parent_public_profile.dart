class ParentPublicProfile {
  const ParentPublicProfile({
    required this.id,
    required this.fullName,
    this.location,
    this.primaryLocation,
    this.occupation,
    this.preferredHours,
    this.profilePictureUrl,
  });

  final String id;
  final String fullName;
  final String? location;
  final String? primaryLocation;
  final String? occupation;
  final String? preferredHours;
  final String? profilePictureUrl;

  factory ParentPublicProfile.fromJson(Map<String, dynamic> json) {
    return ParentPublicProfile(
      id: (json['id'] ?? '').toString(),
      fullName: (json['full_name'] ?? '').toString(),
      location: json['location']?.toString(),
      primaryLocation: json['primary_location']?.toString(),
      occupation: json['occupation']?.toString(),
      preferredHours: json['preferred_hours']?.toString(),
      profilePictureUrl:
          (json['profile_picture_url'] ?? json['profile_picture'])?.toString(),
    );
  }
}