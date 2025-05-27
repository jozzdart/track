/// Represents different time periods for tracking purposes.
enum TimePeriod {
  /// 10 seconds period.
  seconds10,

  /// 20 seconds period.
  seconds20,

  /// 30 seconds period.
  seconds30,

  /// 1 minute period.
  minutes1,

  /// 2 minutes period.
  minutes2,

  /// 3 minutes period.
  minutes3,

  /// 5 minutes period.
  minutes5,

  /// 10 minutes period.
  minutes10,

  /// 15 minutes period.
  minutes15,

  /// 20 minutes period.
  minutes20,

  /// 30 minutes period.
  minutes30,

  /// 1 hour period.
  hourly,

  /// 2 hours period.
  every2Hours,

  /// 3 hours period.
  every3Hours,

  /// 6 hours period.
  every6Hours,

  /// 12 hours period.
  every12Hours,

  /// 1 day period.
  daily,

  /// 1 week period.
  weekly,

  /// 1 month period (approximated as 31 days).
  monthly,
}

/// Extension on [TimePeriod] to provide additional functionality.
extension TimePeriodExt on TimePeriod {
  /// Returns the [Duration] corresponding to the [TimePeriod].
  ///
  /// This method provides the exact duration for each period type.
  Duration get duration {
    switch (this) {
      case TimePeriod.seconds10:
        return Duration(seconds: 10);
      case TimePeriod.seconds20:
        return Duration(seconds: 20);
      case TimePeriod.seconds30:
        return Duration(seconds: 30);
      case TimePeriod.minutes1:
        return Duration(minutes: 1);
      case TimePeriod.minutes2:
        return Duration(minutes: 2);
      case TimePeriod.minutes3:
        return Duration(minutes: 3);
      case TimePeriod.minutes5:
        return Duration(minutes: 5);
      case TimePeriod.minutes10:
        return Duration(minutes: 10);
      case TimePeriod.minutes15:
        return Duration(minutes: 15);
      case TimePeriod.minutes20:
        return Duration(minutes: 20);
      case TimePeriod.minutes30:
        return Duration(minutes: 30);
      case TimePeriod.hourly:
        return Duration(hours: 1);
      case TimePeriod.every2Hours:
        return Duration(hours: 2);
      case TimePeriod.every3Hours:
        return Duration(hours: 3);
      case TimePeriod.every6Hours:
        return Duration(hours: 6);
      case TimePeriod.every12Hours:
        return Duration(hours: 12);
      case TimePeriod.daily:
        return Duration(days: 1);
      case TimePeriod.weekly:
        return Duration(days: 7);
      case TimePeriod.monthly:
        return Duration(days: 31); // special case
    }
  }

  /// Calculates the aligned start of the current period based on [now].
  ///
  /// This method returns the start of the period that the given [now] falls into.
  /// For example, if the period is daily, it returns the start of the current day.
  DateTime alignedStart(DateTime now) {
    switch (this) {
      case TimePeriod.daily:
        return DateTime(now.year, now.month, now.day);
      case TimePeriod.weekly:
        final monday = now.subtract(Duration(days: now.weekday - 1));
        return DateTime(monday.year, monday.month, monday.day);
      case TimePeriod.monthly:
        return DateTime(now.year, now.month);
      default:
        final seconds = duration.inSeconds;
        final epochSeconds = now.toUtc().millisecondsSinceEpoch ~/ 1000;
        final alignedEpoch = (epochSeconds ~/ seconds) * seconds;
        return DateTime.fromMillisecondsSinceEpoch(alignedEpoch * 1000,
                isUtc: true)
            .toLocal();
    }
  }
}
