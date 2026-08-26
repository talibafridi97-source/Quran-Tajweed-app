class TasbeehHistoryModel {
  final int? id;
  final String dhikrName;
  final String? arabicText;
  final int count;
  final int target;
  final DateTime timestamp;

  const TasbeehHistoryModel({
    this.id,
    required this.dhikrName,
    this.arabicText,
    required this.count,
    required this.target,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'dhikr_name': dhikrName,
      'arabic_text': arabicText ?? '',
      'count': count,
      'target': target,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory TasbeehHistoryModel.fromMap(Map<String, dynamic> map) {
    return TasbeehHistoryModel(
      id: map['id'] as int?,
      dhikrName: map['dhikr_name'] as String? ?? 'Dhikr',
      arabicText: map['arabic_text'] as String?,
      count: map['count'] as int? ?? 0,
      target: map['target'] as int? ?? 33,
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
