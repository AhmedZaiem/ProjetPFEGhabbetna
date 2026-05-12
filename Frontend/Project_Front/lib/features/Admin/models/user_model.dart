class UserModel {
  final int id;
  final String firstname;
  final String lastname;
  final String cin;
  final String username;
  final String email;
  final int age;
  final String role_name;
  final bool isVerified;
  final bool isBlocked;
  final String region;
  final String tel;

  UserModel({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.cin,
    required this.username,
    required this.email,
    required this.age,
    required this.role_name,
    required this.isVerified,
    required this.isBlocked,
    required this.region,
    required this.tel,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      firstname: json['firstname'] ?? '', // default empty string
      lastname: json['lastname'] ?? '',
      cin: json['cin'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      age: json['age'] ?? 0,
      role_name: json['role_name'] ?? '',
      isVerified: json['is_verified'] ?? false,
      isBlocked: json['is_blocked'] ?? false,
      region: json['region'] ?? '',
      tel: json['tel'] ?? '',
    );
  }
}
