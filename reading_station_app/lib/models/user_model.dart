class UserModel {
  final String id;
  final String email;
  final String? name;
  final String role;
  
  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.role = 'user',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      role: json['role'] as String? ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
    };
  }

  bool get isAdmin => role == 'admin';
}
