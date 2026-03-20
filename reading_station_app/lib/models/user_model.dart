class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? fullName;
  final String? avatarUrl;
  final String role;
  final String status;
  final bool isVerified;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.fullName,
    this.avatarUrl,
    this.role = 'user',
    this.status = 'active',
    this.isVerified = false,
  });

  /// Tên hiển thị ưu tiên full_name > name
  String get displayName => fullName ?? name ?? 'Người dùng';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      name: json['name'] as String?,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: json['role'] as String? ?? 'user',
      status: json['status'] as String? ?? 'active',
      isVerified: json['is_verified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'role': role,
      'status': status,
      'is_verified': isVerified,
    };
  }

  bool get isAdmin => role == 'admin';
  bool get isBanned => status == 'banned';
}
