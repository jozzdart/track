import 'package:prf/prf.dart';
import 'package:synchronized/synchronized.dart';
import 'package:equatable/equatable.dart';
import 'package:track/track.dart';

/// Represents a record entry with a numerical value and a timestamp.
class RecordEntry extends Equatable {
  /// The numerical value associated with this record.
  final num value;

  /// The timestamp indicating when this record was created.
  final DateTime date;

  /// Constructs a [RecordEntry] with the specified [value] and [date].
  const RecordEntry(this.value, this.date);

  /// Serializes this [RecordEntry] to a JSON-compatible map.
  Map<String, dynamic> toJson() =>
      {'value': value, 'date': date.toIso8601String()};

  /// Deserializes a JSON map into a [RecordEntry] instance.
  factory RecordEntry.fromJson(Map<String, dynamic> json) => RecordEntry(
        json['value'],
        DateTime.parse(json['date']),
      );

  /// Creates a copy of this [RecordEntry] with optional new values.
  RecordEntry copyWith({num? value, DateTime? date}) =>
      RecordEntry(value ?? this.value, date ?? this.date);

  @override
  List<Object> get props => [value, date];

  @override
  String toString() => 'RecordEntry(value: $value, date: $date)';
}

/// Defines the mode of record tracking.
enum RecordMode {
  /// Track the maximum value.
  max,

  /// Track the minimum value.
  min
}

/// Manages records, allowing storage and retrieval of the best record.
class BestRecord extends BaseServiceObject {
  /// The history of recorded entries.
  final HistoryTracker<RecordEntry> _history;

  /// The mode of record tracking, either [RecordMode.max] or [RecordMode.min].
  final RecordMode mode;

  /// An optional fallback record entry to use if no records exist.
  final RecordEntry? fallback;

  /// A lock to ensure thread-safe operations.
  final _lock = Lock();

  /// Constructs a [BestRecord] with the specified parameters.
  ///
  /// [key] is the unique identifier for the record history.
  /// [mode] specifies whether to track the maximum or minimum value.
  /// [historyLength] defines the maximum length of the history.
  /// [fallback] is an optional fallback record entry.
  /// [useCache] determines whether to use caching.
  BestRecord(
    String key, {
    this.mode = RecordMode.max,
    int historyLength = 1,
    this.fallback,
    super.useCache = false,
  }) : _history = HistoryTracker.json<RecordEntry>(
          key,
          fromJson: (json) => RecordEntry.fromJson(json),
          toJson: (record) => record.toJson(),
          maxLength: historyLength,
          deduplicate: false,
          useCache: useCache,
        );

  /// Updates the tracker with a new value, recording it if it's the best.
  ///
  /// [newValue] is the new value to be considered for recording.
  Future<void> update(num newValue) async {
    await _lock.synchronized(() async {
      final currentBest = await getBest();
      final isBetter = currentBest == null ||
          (mode == RecordMode.max && newValue > currentBest.value) ||
          (mode == RecordMode.min && newValue < currentBest.value);
      if (isBetter) {
        await _history.add(RecordEntry(newValue, DateTime.now()));
      }
    });
  }

  /// Retrieves the best record entry.
  ///
  /// Returns the best [RecordEntry] or null if no records exist.
  Future<RecordEntry?> getBest() async {
    final records = await _history.getAll();
    return records.firstOrNull;
  }

  /// Retrieves the value of the best record entry.
  ///
  /// Returns the value of the best record or null if no records exist.
  Future<num?> getBestRecord() async {
    final best = await getBest();
    return best?.value;
  }

  /// Retrieves the date of the best record entry.
  ///
  /// Returns the date of the best record or null if no records exist.
  Future<DateTime?> getBestDate() async {
    final best = await getBest();
    return best?.date;
  }

  /// Retrieves the full history of records, with the most recent first.
  ///
  /// Returns a list of [RecordEntry] objects.
  Future<List<RecordEntry>> getHistory() async {
    return await _history.getAll();
  }

  /// Resets all records in the tracker.
  Future<void> reset() async {
    await _lock.synchronized(() => _history.clear());
  }

  /// Removes the persisted key from storage.
  Future<void> removeKey() async {
    await _lock.synchronized(() => _history.removeKey());
  }

  /// Checks if the record key exists in storage.
  ///
  /// Returns true if the key exists, false otherwise.
  Future<bool> exists() async {
    return await _history.exists();
  }

  /// Retrieves the best record entry or the fallback if no best exists.
  ///
  /// Returns the best [RecordEntry] or the fallback if no best exists.
  /// Throws a [StateError] if neither a best record nor a fallback is available.
  Future<RecordEntry> getBestOrFallback() async {
    final best = await getBest();
    if (best != null) return best;
    if (fallback != null) return fallback!;
    throw StateError('No record found and no fallback provided.');
  }

  /// Manually sets a new record entry with the given value.
  ///
  /// [value] is the value to be recorded.
  Future<void> manualSet(num value) async {
    await _lock.synchronized(() async {
      await _history.add(RecordEntry(value, DateTime.now()));
    });
  }

  /// Removes a record entry at the specified index.
  ///
  /// [index] is the position of the record to be removed.
  Future<void> removeAt(int index) async {
    await _lock.synchronized(() async {
      final records = await _history.getAll();
      if (index >= 0 && index < records.length) {
        records.removeAt(index);
        await _history.setAll(records);
      }
    });
  }

  /// Removes record entries that match the given predicate.
  ///
  /// [predicate] is a function that returns true for records to be removed.
  Future<void> removeWhere(bool Function(RecordEntry) predicate) async {
    await _lock.synchronized(() async {
      final records = await _history.getAll();
      records.removeWhere(predicate);
      await _history.setAll(records);
    });
  }

  /// Retrieves the first record entry in the history.
  ///
  /// Returns the first [RecordEntry] or null if no records exist.
  Future<RecordEntry?> first() async {
    final records = await _history.getAll();
    return records.firstOrNull;
  }

  /// Retrieves the last record entry in the history.
  ///
  /// Returns the last [RecordEntry] or null if no records exist.
  Future<RecordEntry?> last() async {
    final records = await _history.getAll();
    return records.lastOrNull;
  }
}
