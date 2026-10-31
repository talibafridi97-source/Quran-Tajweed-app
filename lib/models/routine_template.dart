class RoutineTemplateItem {
  final int? id;
  final int? templateId;
  final int categoryId;
  final String categoryNameSnapshot;
  final String activityName;
  final int durationMinutes;
  final String? startTime;
  final String? endTime;
  final int sortOrder;

  const RoutineTemplateItem({
    this.id,
    this.templateId,
    required this.categoryId,
    required this.categoryNameSnapshot,
    required this.activityName,
    required this.durationMinutes,
    this.startTime,
    this.endTime,
    this.sortOrder = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (templateId != null) 'template_id': templateId,
      'category_id': categoryId,
      'category_name_snapshot': categoryNameSnapshot,
      'activity_name': activityName,
      'duration_minutes': durationMinutes,
      'start_time': startTime,
      'end_time': endTime,
      'sort_order': sortOrder,
    };
  }

  factory RoutineTemplateItem.fromMap(Map<String, dynamic> map) {
    return RoutineTemplateItem(
      id: map['id'] as int?,
      templateId: map['template_id'] as int?,
      categoryId: map['category_id'] as int,
      categoryNameSnapshot: map['category_name_snapshot'] as String,
      activityName: map['activity_name'] as String,
      durationMinutes: map['duration_minutes'] as int,
      startTime: map['start_time'] as String?,
      endTime: map['end_time'] as String?,
      sortOrder: map['sort_order'] as int? ?? 0,
    );
  }

  RoutineTemplateItem copyWith({
    int? id,
    int? templateId,
    int? categoryId,
    String? categoryNameSnapshot,
    String? activityName,
    int? durationMinutes,
    String? startTime,
    String? endTime,
    int? sortOrder,
  }) {
    return RoutineTemplateItem(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      categoryId: categoryId ?? this.categoryId,
      categoryNameSnapshot: categoryNameSnapshot ?? this.categoryNameSnapshot,
      activityName: activityName ?? this.activityName,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class RoutineTemplate {
  final int? id;
  final String name;
  final String description;
  final String createdAt;
  final List<RoutineTemplateItem> items;

  const RoutineTemplate({
    this.id,
    required this.name,
    this.description = '',
    required this.createdAt,
    this.items = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt,
    };
  }

  factory RoutineTemplate.fromMap(Map<String, dynamic> map, [List<RoutineTemplateItem> items = const []]) {
    return RoutineTemplate(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      createdAt: map['created_at'] as String? ?? DateTime.now().toIso8601String(),
      items: items,
    );
  }

  RoutineTemplate copyWith({
    int? id,
    String? name,
    String? description,
    String? createdAt,
    List<RoutineTemplateItem>? items,
  }) {
    return RoutineTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
    );
  }
}
