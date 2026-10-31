class DailyStatus {
  final String date; // YYYY-MM-DD
  final String status; // 'in_progress', 'reviewed'
  final String? reviewedAt;

  const DailyStatus({
    required this.date,
    required this.status,
    this.reviewedAt,
  });

  bool get isReviewed => status == 'reviewed';

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'status': status,
      'reviewed_at': reviewedAt,
    };
  }

  factory DailyStatus.fromMap(Map<String, dynamic> map) {
    return DailyStatus(
      date: map['date'] as String,
      status: map['status'] as String? ?? 'in_progress',
      reviewedAt: map['reviewed_at'] as String?,
    );
  }
}

class DailyScoreSnapshot {
  final int? id;
  final String date; // YYYY-MM-DD
  final double score;
  final String snapshotJson; // JSON snapshot of weights and targets used
  final String createdAt;

  const DailyScoreSnapshot({
    this.id,
    required this.date,
    required this.score,
    required this.snapshotJson,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'date': date,
      'score': score,
      'snapshot_json': snapshotJson,
      'created_at': createdAt,
    };
  }

  factory DailyScoreSnapshot.fromMap(Map<String, dynamic> map) {
    return DailyScoreSnapshot(
      id: map['id'] as int?,
      date: map['date'] as String,
      score: (map['score'] as num).toDouble(),
      snapshotJson: map['snapshot_json'] as String,
      createdAt: map['created_at'] as String,
    );
  }
}
