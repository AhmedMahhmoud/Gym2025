import 'dart:convert';
import 'dart:developer';

class JwtService {
  static final JwtService _instance = JwtService._internal();
  factory JwtService() => _instance;
  JwtService._internal();

  /// Decodes JWT token and returns the payload as a Map
  Map<String, dynamic>? decodeToken(String token) {
    try {
      // Remove 'Bearer ' prefix if present
      final cleanToken =
          token.startsWith('Bearer ') ? token.substring(7) : token;

      // Split the token into parts
      final parts = cleanToken.split('.');
      if (parts.length != 3) {
        throw Exception('Invalid JWT token format');
      }

      // Decode the payload (second part)
      final payload = parts[1];

      // Add padding if necessary
      final paddedPayload = _addPadding(payload);

      // Decode base64
      final decodedBytes = base64Url.decode(paddedPayload);
      final decodedString = utf8.decode(decodedBytes);

      // Parse JSON
      return json.decode(decodedString) as Map<String, dynamic>;
    } catch (e) {
      log('Error decoding JWT token: $e');
      return null;
    }
  }

  /// Extract user data from decoded token
  UserTokenData? extractUserData(String token) {
    final payload = decodeToken(token);
    if (payload == null) return null;

    try {
      return UserTokenData.fromJson(payload);
    } catch (e) {
      log('Error extracting user data: $e');
      return null;
    }
  }

  /// Add padding to base64 string if necessary
  String _addPadding(String base64String) {
    final paddingNeeded = 4 - (base64String.length % 4);
    if (paddingNeeded < 4) {
      return base64String + ('=' * paddingNeeded);
    }
    return base64String;
  }

  /// Check if token is expired
  bool isTokenExpired(String token) {
    final payload = decodeToken(token);
    if (payload == null) return true;

    final exp = payload['exp'];
    if (exp == null) return false;

    final expirationDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    return DateTime.now().isAfter(expirationDate);
  }
}

/// Model class for user data extracted from JWT token
class UserTokenData {
  final String userId;
  final String email;
  final String inAppName;
  final String? profilePictureUrl;
  final String issuer;
  final String audience;
  final List<String> roles;
  final String? gender;

  UserTokenData({
    required this.userId,
    required this.email,
    required this.inAppName,
    this.profilePictureUrl,
    required this.issuer,
    required this.audience,
    required this.roles,
    this.gender,
  });

  factory UserTokenData.fromJson(Map<String, dynamic> json) {
    // Extract roles from the JWT claims
    List<String> roles = [];
    final rolesClaim =
        json['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'];

    if (rolesClaim != null) {
      if (rolesClaim is List) {
        roles = rolesClaim.map((role) => role.toString()).toList();
      } else if (rolesClaim is String) {
        roles = [rolesClaim];
      }
    }

    // Gender claim is expected as 'Gender'
    final String? gender = json['Gender']?.toString();

    return UserTokenData(
      userId: json['UserId'] ?? '',
      email: json[
              'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress'] ??
          '',
      inAppName: json['InAppName'] ?? '',
      profilePictureUrl: json['ProfilePictureUrl'],
      issuer: json['iss'] ?? '',
      audience: json['aud'] ?? '',
      roles: roles,
      gender: gender,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'UserId': userId,
      'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress':
          email,
      'InAppName': inAppName,
      'ProfilePictureUrl': profilePictureUrl,
      'iss': issuer,
      'aud': audience,
      'http://schemas.microsoft.com/ws/2008/06/identity/claims/role': roles,
      if (gender != null) 'Gender': gender,
    };
  }

  /// Check if user has admin role
  bool get isAdmin => roles.contains('Admin');

  /// Check if user has a specific role
  bool hasRole(String role) => roles.contains(role);

  /// Get the full profile picture URL with base URL
  String? getFullProfilePictureUrl(String baseUrl) {
    if (profilePictureUrl == null || profilePictureUrl!.isEmpty) return null;

    // If URL is already complete, return as is
    if (profilePictureUrl!.startsWith('http')) {
      return profilePictureUrl;
    }

    // Remove leading slash if present and add base URL
    final cleanPath = profilePictureUrl!.startsWith('/')
        ? profilePictureUrl!.substring(1)
        : profilePictureUrl!;

    return '$baseUrl/$cleanPath';
  }
}
