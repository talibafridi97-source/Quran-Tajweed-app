import '../models/activity_record.dart';

class OverlapResult {
  final int rawTotalMinutes;
  final int mergedAccountedMinutes;
  final bool hasOverlap;
  final List<String> overlapWarnings;
  final bool isDurationOnly;

  const OverlapResult({
    required this.rawTotalMinutes,
    required this.mergedAccountedMinutes,
    required this.hasOverlap,
    required this.overlapWarnings,
    required this.isDurationOnly,
  });
}

class IntervalSlot {
  final int startMinutes; // 0..1439
  final int endMinutes;   // 1..2880
  final String label;

  const IntervalSlot({
    required this.startMinutes,
    required this.endMinutes,
    required this.label,
  });
}

class OverlapDetector {
  /// Parses HH:mm string to minutes from 00:00 (e.g. "01:30" -> 90)
  static int? parseTimeToMinutes(String? timeStr) {
    if (timeStr == null || timeStr.trim().isEmpty) return null;
    final parts = timeStr.trim().split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return (h * 60) + m;
  }

  /// Calculates duration handling midnight crossing.
  /// e.g. 22:30 (1350) to 05:00 (300) -> (300 - 1350) + 1440 = 390 min.
  static int calculateDurationMinutes(String startTime, String endTime) {
    final start = parseTimeToMinutes(startTime);
    final end = parseTimeToMinutes(endTime);
    if (start == null || end == null) return 0;
    if (end >= start) {
      return end - start;
    } else {
      // Midnight crossing
      return (end + 1440) - start;
    }
  }

  /// Analyze a list of activity records for overlaps and distinct accounted minutes.
  static OverlapResult analyzeIntervals(List<ActivityRecord> records) {
    if (records.isEmpty) {
      return const OverlapResult(
        rawTotalMinutes: 0,
        mergedAccountedMinutes: 0,
        hasOverlap: false,
        overlapWarnings: [],
        isDurationOnly: true,
      );
    }

    int rawTotal = 0;
    bool anyInterval = false;

    for (final r in records) {
      rawTotal += r.durationMinutes;
      if (r.startTime != null && r.endTime != null && r.startTime!.isNotEmpty && r.endTime!.isNotEmpty) {
        anyInterval = true;
      }
    }

    if (!anyInterval) {
      return OverlapResult(
        rawTotalMinutes: rawTotal,
        mergedAccountedMinutes: rawTotal,
        hasOverlap: false,
        overlapWarnings: const [],
        isDurationOnly: true, // "duration-based, overlap not verified"
      );
    }

    // Convert timed records to slots
    final List<IntervalSlot> timedSlots = [];
    int untimedDuration = 0;
    final List<String> warnings = [];

    for (final r in records) {
      final s = parseTimeToMinutes(r.startTime);
      final e = parseTimeToMinutes(r.endTime);
      if (s != null && e != null) {
        int endMin = e;
        if (endMin <= s) {
          endMin += 1440; // midnight crossing
        }
        timedSlots.add(IntervalSlot(
          startMinutes: s,
          endMinutes: endMin,
          label: '${r.categoryNameSnapshot}: ${r.activityName}',
        ));
      } else {
        untimedDuration += r.durationMinutes;
      }
    }

    // Detect pairwise overlaps
    bool hasOverlap = false;
    for (int i = 0; i < timedSlots.length; i++) {
      for (int j = i + 1; j < timedSlots.length; j++) {
        final a = timedSlots[i];
        final b = timedSlots[j];

        // Check overlap: max(startA, startB) < min(endA, endB)
        final overlapStart = a.startMinutes > b.startMinutes ? a.startMinutes : b.startMinutes;
        final overlapEnd = a.endMinutes < b.endMinutes ? a.endMinutes : b.endMinutes;
        if (overlapEnd > overlapStart) {
          hasOverlap = true;
          warnings.add('Overlap (${overlapEnd - overlapStart}m): "${a.label}" and "${b.label}"');
        }
      }
    }

    // Merge intervals to calculate distinct accounted minutes
    timedSlots.sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
    List<List<int>> merged = [];
    for (final slot in timedSlots) {
      if (merged.isEmpty) {
        merged.add([slot.startMinutes, slot.endMinutes]);
      } else {
        final last = merged.last;
        if (slot.startMinutes <= last[1]) {
          if (slot.endMinutes > last[1]) {
            last[1] = slot.endMinutes;
          }
        } else {
          merged.add([slot.startMinutes, slot.endMinutes]);
        }
      }
    }

    int mergedTimedMinutes = 0;
    for (final m in merged) {
      mergedTimedMinutes += (m[1] - m[0]);
    }

    final totalAccounted = mergedTimedMinutes + untimedDuration;

    return OverlapResult(
      rawTotalMinutes: rawTotal,
      mergedAccountedMinutes: totalAccounted,
      hasOverlap: hasOverlap,
      overlapWarnings: warnings,
      isDurationOnly: !anyInterval,
    );
  }
}
