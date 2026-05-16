import 'package:flutter/foundation.dart';

class SecurityEvent {
  final int id;
  final String email;
  final String event_type;
  final String attack_type;
  final String summary;
  final String recommendation;
  final String ip_adresse;
  final String risk_level;
  final DateTime timestamp;
  final int? attempts;

  SecurityEvent({
    required this.id,
    required this.email,
    required this.event_type,
    required this.attack_type,
    required this.summary,
    required this.recommendation,
    required this.ip_adresse,
    required this.risk_level,
    required this.timestamp,
    this.attempts,
  });

  factory SecurityEvent.fromJson(Map<String, dynamic> json) {
    return SecurityEvent(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      event_type: json['event_type'] ?? '',
      attack_type: json['attack_type'] ?? '',
      summary: json['summary'] ?? '',
      recommendation: json['recommendation'] ?? '',
      ip_adresse: json['ip_adresse'] ?? '',
      risk_level: json['risk_level'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      attempts: json['attempts'] ?? 0,
    );
  }
}
