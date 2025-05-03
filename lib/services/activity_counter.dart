import 'package:prf/prf.dart';
import 'package:synchronized/synchronized.dart';
import 'package:track/track.dart';

/// A utility class for tracking user activity over time across various spans
/// such as hour, day, month, and year. It provides persistent storage and
/// retrieval of activity data, making it suitable for usage statistics,
/// trend analysis, and generating long-term activity reports.
///
/// The `ActivityCounter` is designed to be isolate-safe and supports
/// automatic time-based bucketing using the current date and time.
///
/// Example usage:
/// ```dart
/// final activityCounter = ActivityCounter('user_activity');
/// await activityCounter.add(5);
/// final todayCount = await activityCounter.today;
/// print('Activities today: $todayCount');
/// ```
class ActivityCounter extends BaseServiceObject {
  static const _keyPrefix = 'prf';
  static const int _baseYear = 2000;

  static const int _monthsInYear = 13; // index 1..12
  static const int _daysInMonth = 32; // index 1..31
  static const int _hoursInDay = 24;

  final Lock _lock = Lock();
  final DateTime Function() _clock;

  final Map<TimeSpan, Prf<List<int>>> _data;

  /// Creates a new instance of [ActivityCounter] with the given [key].
  ///
  /// The [useCache] parameter determines whether to use cached values for
  /// performance optimization. The [clock] parameter allows for custom
  /// time sources, defaulting to [DateTime.now].
  ActivityCounter(
    String key, {
    super.useCache,
    DateTime Function()? clock,
  })  : _clock = clock ?? DateTime.now,
        _data = {
          for (final span in TimeSpan.values)
            span: Prf<List<int>>('${_keyPrefix}_${key}_${span.keySuffix}')
        };

  // -------------------------------------------
  // Convenience Getters
  // -------------------------------------------

  /// Returns the activity count for the current hour.
  Future<int> get thisHour => amountThis(TimeSpan.hour);

  /// Returns the activity count for the current day.
  Future<int> get today => amountThis(TimeSpan.day);

  /// Returns the activity count for the current month.
  Future<int> get thisMonth => amountThis(TimeSpan.month);

  /// Returns the activity count for the current year.
  Future<int> get thisYear => amountThis(TimeSpan.year);

  // -------------------------------------------
  // Core Methods
  // -------------------------------------------

  /// Increments the activity count by 1 for the current time bucket.
  Future<void> increment() => add(1);

  /// Adds the specified [amount] to the current time bucket across all spans.
  Future<void> add(int amount) async {
    final now = _clock();
    await _lock.synchronized(() async {
      for (final span in TimeSpan.values) {
        final info = span.info(now);
        final prf = _data[span]!;
        final list = await _getListOrDefault(prf, info.minLength);
        list[info.index] += amount;
        await prf.set(list);
      }
    });
  }

  /// Returns the activity count for the current time in the specified [span].
  Future<int> amountThis(TimeSpan span) {
    final now = _clock();
    return _getSafe(_data[span]!, span.info(now).index);
  }

  /// Returns the activity count for the specified [date] in the given [span].
  Future<int> amountFor(TimeSpan span, DateTime date) {
    return _getSafe(_data[span]!, span.info(date).index);
  }

  /// Returns a summary map of activity counts for all spans at the current time.
  Future<Map<TimeSpan, int>> summary() async {
    return {
      for (final span in TimeSpan.values) span: await amountThis(span),
    };
  }

  // -------------------------------------------
  // Utilities
  // -------------------------------------------

  /// Returns the total sum of all recorded entries in the specified [span].
  Future<int> total(TimeSpan span) async {
    final list = await _getList(_data[span]!);
    return list.fold<int>(0, (sum, e) => sum + e);
  }

  /// Returns a map of non-zero entries for the specified [span].
  Future<Map<int, int>> all(TimeSpan span) async {
    final list = await _getList(_data[span]!);
    final result = <int, int>{};
    for (var i = 0; i < list.length; i++) {
      if (list[i] != 0) result[i] = list[i];
    }
    return result;
  }

  /// Returns the largest value ever recorded for the specified [span].
  Future<int> maxValue(TimeSpan span) async {
    final map = await all(span);
    return map.values.fold<int>(0, (max, e) => e > max ? e : max);
  }

  /// Returns `true` if any activity has ever been recorded.
  Future<bool> hasAnyData() async {
    for (final span in TimeSpan.values) {
      if (await total(span) > 0) return true;
    }
    return false;
  }

  /// Returns a list of `DateTime` objects where any activity was tracked for the specified [span].
  Future<List<DateTime>> activeDates(TimeSpan span) async {
    final keys = await all(span);
    final now = _clock();
    return [for (final i in keys.keys) span.dateFromIndex(now, i)];
  }

  // -------------------------------------------
  // Reset and Cleanup
  // -------------------------------------------

  /// Clears all data in the specified [span].
  Future<void> clear(TimeSpan span) => _data[span]!.set([]);

  /// Clears data for multiple spans specified in [spans].
  Future<void> clearAllKnown(List<TimeSpan> spans) async {
    await _lock.synchronized(() async {
      for (final span in spans) {
        await clear(span);
      }
    });
  }

  /// Clears all data across all spans.
  Future<void> reset() => clearAllKnown(TimeSpan.values);

  /// Permanently deletes all stored data for this counter.
  Future<void> removeAll() async {
    await _lock.synchronized(() async {
      for (final span in TimeSpan.values) {
        await _data[span]!.remove();
      }
    });
  }

  // -------------------------------------------
  // Internal Helpers
  // -------------------------------------------

  Future<int> _getSafe(Prf<List<int>> prf, int index) async {
    final list = await _getList(prf);
    if (index < 0 || index >= list.length) return 0;
    return list[index];
  }

  Future<List<int>> _getList(Prf<List<int>> prf) async {
    return await (useCache ? prf : prf.isolated).get() ?? const [];
  }

  Future<List<int>> _getListOrDefault(Prf<List<int>> prf, int minLength) async {
    final list = await _getList(prf);
    return list.length >= minLength
        ? list
        : [...list, ...List.filled(minLength - list.length, 0)];
  }
}

// -------------------------------------------
// Span Metadata
// -------------------------------------------

extension on TimeSpan {
  /// Returns the key suffix for the span.
  String get keySuffix => switch (this) {
        TimeSpan.year => 'year',
        TimeSpan.month => 'month',
        TimeSpan.day => 'day',
        TimeSpan.hour => 'hour',
      };

  /// Returns span information for the given [date].
  _SpanInfo info(DateTime date) => switch (this) {
        TimeSpan.year =>
          _SpanInfo(date.year - ActivityCounter._baseYear, date.year + 1),
        TimeSpan.month => _SpanInfo(date.month, ActivityCounter._monthsInYear),
        TimeSpan.day => _SpanInfo(date.day, ActivityCounter._daysInMonth),
        TimeSpan.hour => _SpanInfo(date.hour, ActivityCounter._hoursInDay),
      };

  /// Returns a `DateTime` object from the given [base] date and index [i].
  DateTime dateFromIndex(DateTime base, int i) => switch (this) {
        TimeSpan.year => DateTime(ActivityCounter._baseYear + i),
        TimeSpan.month => DateTime(base.year, i),
        TimeSpan.day => DateTime(base.year, base.month, i),
        TimeSpan.hour => DateTime(base.year, base.month, base.day, i),
      };
}

/// A helper class containing span information.
class _SpanInfo {
  final int index;
  final int minLength;

  const _SpanInfo(this.index, this.minLength);
}
