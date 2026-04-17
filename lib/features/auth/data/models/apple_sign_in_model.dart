/// Model representing Sign in with Apple account information
class AppleSignInModel {
  AppleSignInModel({
    required this.email,
    required this.displayName,
    required this.id,
    this.photoUrl,
  });

  /// May be empty on repeat Apple sign-ins (Apple only shares email on first authorization).
  final String email;
  final String displayName;
  final String id;
  final String? photoUrl;
}
