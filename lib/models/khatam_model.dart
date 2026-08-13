class KhatamPlan {
  final int id;
  final String title;
  final DateTime startDate;
  final int totalDays;
  final int currentAyah;
  final int currentSurah;
  final bool isCompleted;

  KhatamPlan({
    required this.id,
    required this.title,
    required this.startDate,
    required this.totalDays,
    this.currentAyah = 1,
    this.currentSurah = 1,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'startDate': startDate.toIso8601String(),
      'totalDays': totalDays,
      'currentAyah': currentAyah,
      'currentSurah': currentSurah,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory KhatamPlan.fromMap(Map<String, dynamic> map) {
    return KhatamPlan(
      id: map['id'],
      title: map['title'],
      startDate: DateTime.parse(map['startDate']),
      totalDays: map['totalDays'],
      currentAyah: map['currentAyah'],
      currentSurah: map['currentSurah'],
      isCompleted: map['isCompleted'] == 1,
    );
  }
}
