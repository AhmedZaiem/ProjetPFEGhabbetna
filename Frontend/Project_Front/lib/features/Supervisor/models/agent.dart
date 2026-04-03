class Agent {
  final int id;
  final String name;
  final String email;

  Agent({required this.id, required this.name, required this.email});

  factory Agent.fromJson(Map<String, dynamic> json) {
    return Agent(id: json['id'], name: json['name'], email: json['email']);
  }
}
