enum ActivityStatus { draft, saved, reviewed }

class ActivityRecord {
  final int? id;
  final String date; // YYYY-MM-DD
  final int categoryId;
  final String categoryNameSnapshot;
  final String activityName;
  final int durationMinutes;
  final String? startTime; // HH:mm
  final String? endTime; // HH:mm
  final String? notes;
  final ActivityStatus status;
  final String createdAt;
  final String updatedAt;

  const ActivityRecord({
    this.id,
    required this.date,
    required this.categoryId,
    required this.categoryNameSnapshot,
    required this.activityName,
    required this.durationMinutes,
    this.startTime,
    this.endTime,
    this.notes,
    this.status = ActivityStatus.saved,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'date': date,
      'category_id': categoryId,
      'category_name_snapshot': categoryNameSnapshot,
      'activity_name': activityName,
      'duration_minutes': durationMinutes,
      'start_time': startTime,
      'end_time': endTime,
      'notes': notes,
      'status': status.name,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory ActivityRecord.fromMap(Map<String, dynamic> map) {
    return ActivityRecord(
      id: map['id'] as int?,
      date: map['date'] as String,
      categoryId: map['category_id'] as int,
      categoryNameSnapshot: map['category_name_snapshot'] as String,
      activityName: map['activity_name'] as String,
      durationMinutes: map['duration_minutes'] as int,
      startTime: map['start_time'] as String?,
      endTime: map['end_time'] as String?,
      notes: map['notes'] as String?,
      status: ActivityStatus.values.firstWhere(
        (e) => e.name == (map['status'] as String? ?? 'saved'),
        orElse: () => ActivityStatus.saved,
      ),
      createdAt: map['created_at'] as String? ?? DateTime.now().toIso8601String(),
      updatedAt: map['updated_at'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  ActivityRecord copyWith({
    int? id,
    String? date,
    int? categoryId,
    String? categoryNameSnapshot,
    String? activityName,
    int? durationMinutes,
    String? startTime,
    String? endTime,
    String? notes,
    ActivityStatus? status,
    String? createdAt,
    String? updatedAt,
  }) {
    return ActivityRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      categoryId: categoryId ?? this.categoryId,
      categoryNameSnapshot: categoryNameSnapshot ?? this.categoryNameSnapshot,
      activityName: activityName ?? this.activityName,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
