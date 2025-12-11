class UserModel {
  final String id;
  String? fullName;
  String? email;
  String? role;
  String? careId;
  DateTime? createdAt;
  String? profileImage;

  UserModel({
    required this.id,
    this.fullName,
    this.email,
    this.role,
    this.careId,
    this.createdAt,
    this.profileImage,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      fullName: json['full_name'],
      email: json['email'],
      role: json['role'],
      careId: json['care_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      profileImage: json['profile_image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "full_name": fullName,
      "email": email,
      "role": role,
      "care_id": careId,
      "created_at": createdAt?.toIso8601String(),
      "profile_image": profileImage,
    };
  }
}
