/// Model to hold sitter registration data across steps
class SitterRegistrationData {
  // Step 1: Personal Information
  String? fullName;
  String? email;
  String? gender;
  String? phone;
  String? location;
  String? password;

  // Step 2: Work Preferences
  List<String>? availableDays;
  String? hourlyRate;
  String? currency;
  List<String>? languages;
  String? paymentMethod;

  // Step 3: Documents
  String? profilePicturePath;
  String? nationalIdPath;
  String? lciLetterPath;
  String? resumeCvPath;

  SitterRegistrationData();

  // Step 1 validation
  bool isStep1Valid() {
    return fullName != null &&
        fullName!.isNotEmpty &&
        email != null &&
        email!.isNotEmpty &&
        gender != null &&
        gender!.isNotEmpty &&
        phone != null &&
        phone!.isNotEmpty &&
        location != null &&
        location!.isNotEmpty &&
        password != null &&
        password!.isNotEmpty;
  }
}
