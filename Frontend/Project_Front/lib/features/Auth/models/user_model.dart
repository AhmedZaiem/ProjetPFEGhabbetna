class UserModel {
  final int id;
  final String username;
  final String email;
  final int age;
  final String role;
  final bool isVerified;
  final bool isBlocked;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.age,
    required this.role,
    required this.isVerified,
    required this.isBlocked,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      age: json['age'],
      role: json['role'],
      isVerified: json['is_verified'],
      isBlocked: json['is_blocked'],
    );
  }
}
