class Entry {
  final int? id;
  final int? projectId;
  final String date; // 'YYYY-MM-DD'
  final String startTime; // 'HH:MM'
  final String endTime; // 'HH:MM'
  final int pauseMinutes;
  final String? note;
  final String createdAt;

  const Entry({
    this.id,
    this.projectId,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.pauseMinutes = 0,
    this.note,
    required this.createdAt,
  });

  /// Total working hours: (endTime - startTime) - pauseMinutes, in hours.
  double get totalHours {
    return workDuration.inSeconds / 3600.0;
  }

  /// Duration of actual work (gross minus pause).
  Duration get workDuration {
    final startParts = startTime.split(':');
    final endParts = endTime.split(':');

    final startMinutes =
        int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
    var endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

    // Handle overnight entries
    if (endMinutes < startMinutes) {
      endMinutes += 24 * 60;
    }

    final grossMinutes = endMinutes - startMinutes;
    final netMinutes = (grossMinutes - pauseMinutes).clamp(0, grossMinutes);
    return Duration(minutes: netMinutes);
  }

  /// Returns formatted duration as "Xh YYm".
  String get formattedDuration {
    final d = workDuration;
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    if (hours == 0) {
      return '${minutes}m';
    }
    if (minutes == 0) {
      return '${hours}h';
    }
    return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
  }

  Entry copyWith({
    int? id,
    int? projectId,
    String? date,
    String? startTime,
    String? endTime,
    int? pauseMinutes,
    String? note,
    String? createdAt,
  }) {
    return Entry(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      pauseMinutes: pauseMinutes ?? this.pauseMinutes,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'project_id': projectId,
      'date': date,
      'start_time': startTime,
      'end_time': endTime,
      'pause_minutes': pauseMinutes,
      'note': note,
      'created_at': createdAt,
    };
  }

  factory Entry.fromMap(Map<String, dynamic> map) {
    return Entry(
      id: map['id'] as int?,
      projectId: map['project_id'] as int?,
      date: map['date'] as String,
      startTime: map['start_time'] as String,
      endTime: map['end_time'] as String,
      pauseMinutes: (map['pause_minutes'] as int?) ?? 0,
      note: map['note'] as String?,
      createdAt: map['created_at'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Entry && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Entry(id: $id, date: $date, $startTime-$endTime)';
}
