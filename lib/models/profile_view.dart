class ProfileView {
  const ProfileView({
    required this.id,
    required this.viewerName,
    this.occupation,
    this.location,
    this.phone,
    this.preferredHours,
    this.profileImageUrl,
    this.viewedAt,
  });

  final String id;
  final String viewerName;
  final String? occupation;
  final String? location;
  final String? phone;
  final String? preferredHours;
  final String? profileImageUrl;
  final DateTime? viewedAt;

    ProfileView copyWith({
        String? id,
        String? viewerName,
        String? occupation,
        String? location,
        String? phone,
        String? preferredHours,
        String? profileImageUrl,
        DateTime? viewedAt,
    }) {
        return ProfileView(
            id: id ?? this.id,
            viewerName: viewerName ?? this.viewerName,
            occupation: occupation ?? this.occupation,
            location: location ?? this.location,
            phone: phone ?? this.phone,
            preferredHours: preferredHours ?? this.preferredHours,
            profileImageUrl: profileImageUrl ?? this.profileImageUrl,
            viewedAt: viewedAt ?? this.viewedAt,
        );
    }

  factory ProfileView.fromJson(Map<String, dynamic> json) {
    final profileMap = json['parent'] is Map<String, dynamic>
        ? json['parent'] as Map<String, dynamic>
        : json['viewer'] is Map<String, dynamic>
        ? json['viewer'] as Map<String, dynamic>
        : json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : json['profile'] is Map<String, dynamic>
        ? json['profile'] as Map<String, dynamic>
        : json['parent_profile'] is Map<String, dynamic>
        ? json['parent_profile'] as Map<String, dynamic>
        : const <String, dynamic>{};

    final userProfileMap = profileMap['profile'] is Map<String, dynamic>
        ? profileMap['profile'] as Map<String, dynamic>
        : const <String, dynamic>{};

    return ProfileView(
          id: (json['viewer_id'] ??
              json['parent_id'] ??
              json['user_id'] ??
              json['id'] ??
              profileMap['viewer_id'] ??
              profileMap['parent_id'] ??
              profileMap['id'] ??
              profileMap['user_id'] ??
              '')
          .toString(),
      viewerName: (json['full_name'] ??
              json['viewer_name'] ??
              json['parent_name'] ??
              profileMap['full_name'] ??
              profileMap['viewer_name'] ??
              'Parent')
          .toString(),
      occupation:
          (json['occupation'] ?? profileMap['occupation'] ?? profileMap['job'])
              ?.toString(),
      location: (json['location'] ?? profileMap['location'])?.toString(),
      phone: (json['phone'] ?? profileMap['phone'])?.toString(),
      preferredHours:
          (json['preferred_hours'] ??
                  json['hours'] ??
                  json['preferred_time'] ??
                  profileMap['preferred_hours'] ??
                  profileMap['hours'])
              ?.toString(),
      profileImageUrl:
          (json['profile_picture'] ??
                  json['profile_picture_url'] ??
                  json['viewer_profile_picture'] ??
                  json['viewer_profile_picture_url'] ??
                  json['parent_profile_picture'] ??
                  json['parent_profile_picture_url'] ??
                  json['profile_image'] ??
              json['image_url'] ??
              json['image'] ??
              json['photo_url'] ??
              json['photo'] ??
                  json['avatar_url'] ??
              json['avatar'] ??
                  profileMap['profile_picture'] ??
                  profileMap['profile_picture_url'] ??
                  profileMap['viewer_profile_picture'] ??
                  profileMap['viewer_profile_picture_url'] ??
                  profileMap['parent_profile_picture'] ??
                  profileMap['parent_profile_picture_url'] ??
                  profileMap['profile_image'] ??
              profileMap['image_url'] ??
              profileMap['image'] ??
              profileMap['photo_url'] ??
              profileMap['photo'] ??
                  profileMap['avatar_url'] ??
                  profileMap['avatar'] ??
                  userProfileMap['profile_picture'] ??
                  userProfileMap['profile_picture_url'] ??
                  userProfileMap['profile_image'] ??
                  userProfileMap['image_url'] ??
                  userProfileMap['photo_url'] ??
                  userProfileMap['avatar_url'] ??
                  userProfileMap['avatar'])
              ?.toString(),
      viewedAt: DateTime.tryParse(
        (json['viewed_at'] ??
                json['created_at'] ??
                json['timestamp'] ??
                profileMap['viewed_at'] ??
                '')
            .toString(),
      ),
    );
  }
}
