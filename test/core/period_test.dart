import 'package:flutter_test/flutter_test.dart';
import 'package:prf/prf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:track/track.dart';

import '../utils/fake_prefs.dart';

void main() {
  (SharedPreferencesAsync, FakeSharedPreferencesAsync) getPreferences() {
    final FakeSharedPreferencesAsync store = FakeSharedPreferencesAsync();
    SharedPreferencesAsyncPlatform.instance = store;
    final SharedPreferencesAsync preferences = SharedPreferencesAsync();
    return (preferences, store);
  }

  group('TimePeriod', () {
    setUp(() {
      PrfService.resetOverride();
      final (preferences, _) = getPreferences();
      PrfService.overrideWith(preferences);
    });

    test('duration returns expected values', () {
      expect(TimePeriod.seconds10.duration, Duration(seconds: 10));
      expect(TimePeriod.minutes5.duration, Duration(minutes: 5));
      expect(TimePeriod.hourly.duration, Duration(hours: 1));
      expect(TimePeriod.daily.duration, Duration(days: 1));
      expect(TimePeriod.weekly.duration, Duration(days: 7));
      expect(TimePeriod.monthly.duration, Duration(days: 31));
    });

    test('alignedStart aligns correctly for fixed periods', () {
      final now = DateTime(2024, 3, 10, 13, 47, 56);

      expect(
        TimePeriod.daily.alignedStart(now),
        DateTime(2024, 3, 10),
      );

      expect(
        TimePeriod.weekly.alignedStart(now),
        DateTime(2024, 3, 4),
      );

      expect(
        TimePeriod.monthly.alignedStart(now),
        DateTime(2024, 3),
      );
    });

    test('alignedStart aligns correctly for short periods', () {
      final now = DateTime(2024, 3, 10, 13, 47, 56).toUtc();

      final aligned10s = TimePeriod.seconds10.alignedStart(now);
      expect(aligned10s.second % 10, 0);
      expect(
          aligned10s.isBefore(now) || aligned10s.isAtSameMomentAs(now), isTrue);

      final aligned5m = TimePeriod.minutes5.alignedStart(now);
      expect(aligned5m.minute % 5, 0);
      expect(aligned5m.second, 0);
      expect(
          aligned5m.isBefore(now) || aligned5m.isAtSameMomentAs(now), isTrue);

      final aligned3h = TimePeriod.every3Hours.alignedStart(now).toUtc();
      expect(aligned3h.hour % 3, 0);
      expect(aligned3h.minute, 0);
      expect(aligned3h.second, 0);
    });

    test('alignedStart is consistent within same period', () {
      for (final period in TimePeriod.values) {
        final base = DateTime(2024, 4, 30, 13, 24, 45);
        final a = period.alignedStart(base);
        final b = period.alignedStart(base.add(Duration(milliseconds: 100)));
        expect(a, b, reason: 'Expected consistent alignment for $period');
      }
    });
  });
}
