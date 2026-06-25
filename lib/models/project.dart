import 'package:flutter/material.dart';

class Project {
  final int? id;
  final String name;
  final String? clientName;
  final String? clientAddress;
  final String? clientEmail;
  final double hourlyRate;
  final String color; // hex e.g. '#FF6B35'
  final String createdAt;

  const Project({
    this.id,
    required this.name,
    this.clientName,
    this.clientAddress,
    this.clientEmail,
    this.hourlyRate = 0.0,
    this.color = '#FF6B35',
    required this.createdAt,
  });

  static const List<String> presetColors = [
    '#FF6B35',
    '#4CAF50',
    '#2196F3',
    '#9C27B0',
    '#FF9800',
    '#E91E63',
    '#00BCD4',
    '#795548',
  ];

  /// Parses the hex color string and returns a Flutter [Color].
  Color get colorValue {
    final hex = color.replaceFirst('#', '');
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    } else if (hex.length == 8) {
      return Color(int.parse(hex, radix: 16));
    }
    return const Color(0xFFFF6B35);
  }

  Project copyWith({
    int? id,
    String? name,
    String? clientName,
    String? clientAddress,
    String? clientEmail,
    double? hourlyRate,
    String? color,
    String? createdAt,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      clientName: clientName ?? this.clientName,
      clientAddress: clientAddress ?? this.clientAddress,
      clientEmail: clientEmail ?? this.clientEmail,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'client_name': clientName,
      'client_address': clientAddress,
      'client_email': clientEmail,
      'hourly_rate': hourlyRate,
      'color': color,
      'created_at': createdAt,
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] as int?,
      name: map['name'] as String,
      clientName: map['client_name'] as String?,
      clientAddress: map['client_address'] as String?,
      clientEmail: map['client_email'] as String?,
      hourlyRate: (map['hourly_rate'] as num?)?.toDouble() ?? 0.0,
      color: map['color'] as String? ?? '#FF6B35',
      createdAt: map['created_at'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Project && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Project(id: $id, name: $name)';
}
