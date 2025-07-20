class AppUser {
  final String id;
  final String fullName;
  final String email;
  final String role; // caregiver or receiver
  final DateTime createdAt;
  final String? linkedUserId; // ✅ New field

  AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.createdAt,
    this.linkedUserId, // ✅ Optional because not all users will have this
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      fullName: json['full_name'],
      email: json['email'],
      role: json['role'],
      createdAt: DateTime.parse(json['created_at']),
      linkedUserId: json['linked_user_id'], // ✅ Parse if available
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      if (linkedUserId != null) 'linked_user_id': linkedUserId, // ✅ Optional in JSON
    };
  }
}


class UserModel {
  final String id;
  final String? fullName;
  final String? email;
  final String? role;
  final String? linkedUserId;

  UserModel({
    required this.id,
    this.fullName,
    this.email,
    this.role,
    this.linkedUserId,
  });

  // Factory constructor to create a UserModel from a JSON map (from Supabase)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      fullName: json['full_name'],
      email: json['email'],
      role: json['role'],
      linkedUserId: json['linked_user_id'],
    );
  }
}

