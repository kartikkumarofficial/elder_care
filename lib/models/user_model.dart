class UserModel {
  final String id;
  final String? fullName;
  final String? email;
  final String? role;
  final String? linkedUserId;
  final String? careId;
  final DateTime? createdAt;

  final String? profileImage;

  UserModel({
    required this.id,
    this.fullName,
    this.email,
    this.role,
    this.linkedUserId,
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
      linkedUserId: json['linked_user_id'],
      careId: json['care_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      profileImage: json['profile_image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'role': role,
      'linked_user_id': linkedUserId,
      'care_id': careId,
      'created_at': createdAt?.toIso8601String(),
      'profile_image': profileImage,
    };
  }
}
