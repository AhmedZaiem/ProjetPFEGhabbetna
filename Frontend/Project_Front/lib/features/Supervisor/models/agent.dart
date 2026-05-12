class Agent {
  final int id;
  final String name;
  final String email;
  final String tel;
  final String region;
  final int score;

  Agent({
    required this.id,
    required this.name,
    required this.email,
    required this.tel,
    required this.region,
    required this.score,
  });

  factory Agent.fromJson(Map<String, dynamic> json) {
    return Agent(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      tel: json['tel'],
      region: json['region'],
      score: json['score'],
    );
  }
}
