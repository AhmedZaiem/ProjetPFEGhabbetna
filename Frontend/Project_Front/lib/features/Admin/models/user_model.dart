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
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      cin: json['cin'],
      username: json['username'],
      email: json['email'],
      age: json['age'],
      role_name: json['role_name'],
      isVerified: json['is_verified'],
      isBlocked: json['is_blocked'],
      region: json['region'],
    );
  }
}
