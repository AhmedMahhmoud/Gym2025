/// Model for Apple Login API request
class AppleLoginRequest {
  AppleLoginRequest({
    required this.email,
    required this.appleUserId,
    required this.inAppName,
    required this.gender,
    this.profilePictureUrl,
  });

  final String email;
  final String appleUserId;
  final String inAppName;
  final String gender;
  final String? profilePictureUrl;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'appleUserId': appleUserId,
      'inAppName': inAppName,
      'gender': gender,
      if (profilePictureUrl != null) 'profilePictureUrl': profilePictureUrl,
    };
  }
}
