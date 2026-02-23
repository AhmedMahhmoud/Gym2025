/// Model for Google Login API request
class GoogleLoginRequest {
  GoogleLoginRequest({
    required this.email,
    required this.googleUserId,
    required this.inAppName,
    required this.gender,
    this.profilePictureUrl,
  });

  final String email;
  final String googleUserId;
  final String inAppName;
  final String gender;
  final String? profilePictureUrl;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'googleUserId': googleUserId,
      'inAppName': inAppName,
      'gender': gender,
      if (profilePictureUrl != null) 'profilePictureUrl': profilePictureUrl,
    };
  }
}
