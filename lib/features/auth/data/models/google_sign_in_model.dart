/// Model representing Google Sign-In account information
class GoogleSignInModel {
  GoogleSignInModel({
    required this.email,
    required this.displayName,
    required this.id,
    this.photoUrl,
  });

  final String email;
  final String displayName;
  final String id;
  final String? photoUrl;
}
