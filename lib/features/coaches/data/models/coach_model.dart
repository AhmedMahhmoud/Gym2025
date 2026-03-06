import 'package:trackletics/core/constants/constants.dart';

class CoachModel {
  final String id;
  final String? name;
  final String? bio;
  final String? experience;
  final String? profilePictureUrl;

  CoachModel({
    required this.id,
    this.name,
    this.bio,
    this.experience,
    this.profilePictureUrl,
  });

  factory CoachModel.fromJson(Map<String, dynamic> json) {
    return CoachModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? json['inAppName'] as String?,
      bio: json['bio'] as String?,
      experience: json['experience'] as String?,
      profilePictureUrl:
          AppConstants.baseUrl + json['profilePictureUrl'] as String? ??
              json['profilePicture'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bio': bio,
      'experience': experience,
      'profilePictureUrl': profilePictureUrl,
    };
  }
}
