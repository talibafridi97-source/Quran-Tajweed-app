import 'package:flutter/material.dart';

enum CategoryType { productive, maintenance }

class ActivityCategory {
  final int? id;
  final String name;
  final int colorValue;
  final String iconName;
  final CategoryType type;
  final int? dailyTargetMinutes;
  final double weight; // points, 0 if not scored
  final bool countsForScore;
  final bool isArchived;
  final int sortOrder;
  final String createdAt;

  const ActivityCategory({
    this.id,
    required this.name,
    required this.colorValue,
    required this.iconName,
    required this.type,
    this.dailyTargetMinutes,
    this.weight = 0.0,
    this.countsForScore = false,
    this.isArchived = false,
    this.sortOrder = 0,
    required this.createdAt,
  });

  Color get color => Color(colorValue);

  IconData get iconData {
    switch (iconName) {
      case 'code':
        return Icons.code_rounded;
      case 'menu_book':
        return Icons.menu_book_rounded;
      case 'access_time':
        return Icons.access_time_rounded;
      case 'school':
        return Icons.school_rounded;
      case 'fitness_center':
        return Icons.fitness_center_rounded;
      case 'bed':
        return Icons.bed_rounded;
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'people':
        return Icons.people_alt_rounded;
      case 'weekend':
        return Icons.weekend_rounded;
      case 'spa':
        return Icons.spa_rounded;
      case 'help_outline':
        return Icons.help_outline_rounded;
      case 'work':
        return Icons.work_rounded;
      case 'computer':
        return Icons.computer_rounded;
      case 'sports_soccer':
        return Icons.sports_soccer_rounded;
      case 'music_note':
        return Icons.music_note_rounded;
      case 'mosque':
        return Icons.mosque_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'color_value': colorValue,
      'icon_name': iconName,
      'type': type == CategoryType.productive ? 'Productive' : 'Maintenance',
      'daily_target_minutes': dailyTargetMinutes,
      'weight': weight,
      'counts_for_score': countsForScore ? 1 : 0,
      'is_archived': isArchived ? 1 : 0,
      'sort_order': sortOrder,
      'created_at': createdAt,
    };
  }

  factory ActivityCategory.fromMap(Map<String, dynamic> map) {
    return ActivityCategory(
      id: map['id'] as int?,
      name: map['name'] as String,
      colorValue: map['color_value'] as int,
      iconName: map['icon_name'] as String? ?? 'category',
      type: (map['type'] as String? ?? 'Productive') == 'Productive'
          ? CategoryType.productive
          : CategoryType.maintenance,
      dailyTargetMinutes: map['daily_target_minutes'] as int?,
      weight: (map['weight'] as num?)?.toDouble() ?? 0.0,
      countsForScore: (map['counts_for_score'] as int? ?? 0) == 1,
      isArchived: (map['is_archived'] as int? ?? 0) == 1,
      sortOrder: map['sort_order'] as int? ?? 0,
      createdAt: map['created_at'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  ActivityCategory copyWith({
    int? id,
    String? name,
    int? colorValue,
    String? iconName,
    CategoryType? type,
    int? dailyTargetMinutes,
    double? weight,
    bool? countsForScore,
    bool? isArchived,
    int? sortOrder,
    String? createdAt,
  }) {
    return ActivityCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      iconName: iconName ?? this.iconName,
      type: type ?? this.type,
      dailyTargetMinutes: dailyTargetMinutes ?? this.dailyTargetMinutes,
      weight: weight ?? this.weight,
      countsForScore: countsForScore ?? this.countsForScore,
      isArchived: isArchived ?? this.isArchived,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
