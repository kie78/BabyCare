class BabysitterProfile {
  const BabysitterProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.status,
    this.phone,
    this.location,
    this.gender,
    this.languages = const <String>[],
    this.availability = const <String>[],
    this.rateType,
    this.rateAmount,
    this.currency,
    this.paymentMethod,
    this.isAvailable,
    this.profilePictureUrl,
  });

  final String id;
  final String fullName;
  final String email;
  final String status;
  final String? phone;
  final String? location;
  final String? gender;
  final List<String> languages;
  final List<String> availability;
  final String? rateType;
  final double? rateAmount;
  final String? currency;
  final String? paymentMethod;
  final bool? isAvailable;
  final String? profilePictureUrl;

  factory BabysitterProfile.fromJson(Map<String, dynamic> json) {
    List<String> parseList(dynamic value) {
      if (value is List) {
        return value.map((item) => item.toString()).toList();
      }
      if (value is String && value.trim().isNotEmpty) {
        return value
            .split(',')
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toList();
      }
      return <String>[];
    }

    return BabysitterProfile(
      id: (json['id'] ?? '').toString(),
      fullName: (json['full_name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      status: (json['status'] ?? 'unknown').toString(),
      phone: json['phone']?.toString(),
      location: json['location']?.toString(),
      gender: json['gender']?.toString(),
      languages: parseList(json['languages']),
      availability: parseList(json['availability']),
      rateType: json['rate_type']?.toString(),
      rateAmount: double.tryParse((json['rate_amount'] ?? '').toString()),
      currency: json['currency']?.toString(),
      paymentMethod: json['payment_method']?.toString(),
      isAvailable: json['is_available'] as bool?,
      profilePictureUrl: json['profile_picture']?.toString(),
    );
  }
}
