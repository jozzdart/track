import 'package:flutter_test/flutter_test.dart';
import 'package:prf/prf.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:track/track.dart';

import '../utils/fake_prefs.dart';

void main() {
  const testKey = 'test_basic_counter';

  group('BasicCounter', () {
    (SharedPreferencesAsync, FakeSharedPreferencesAsync) getPreferences() {
      final store = FakeSharedPreferencesAsync();
      SharedPreferencesAsyncPlatform.instance = store;
      final preferences = SharedPreferencesAsync();
      return (preferences, store);
    }

    setUp(() async {
      PrfService.resetOverride();
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);
      final counter = BasicCounter(testKey);
      await counter.clear();
    });

    test('starts at 0 on first use', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final counter = BasicCounter(testKey);
      expect(await counter.get(), 0);
    });

    test('increments correctly with default amount', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final counter = BasicCounter(testKey);
      expect(await counter.increment(), 1);
      expect(await counter.increment(), 2);
    });

    test('increments correctly with custom amount', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final counter = BasicCounter(testKey);
      expect(await counter.increment(5), 5);
      expect(await counter.increment(3), 8);
    });

    test('reset sets value to zero', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final counter = BasicCounter(testKey);
      await counter.increment(10);
      await counter.reset();
      expect(await counter.get(), 0);
    });

    test('clearValueOnly sets value to zero without changing lastUpdate',
        () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final counter = BasicCounter(testKey);
      await counter.increment(5);
      final lastUpdateBefore = await counter.getLastUpdateTime();
      await counter.clearValueOnly();
      final lastUpdateAfter = await counter.getLastUpdateTime();

      expect(await counter.get(), 0);
      expect(lastUpdateBefore, equals(lastUpdateAfter));
    });

    test('isNonZero returns true if value > 0', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final counter = BasicCounter(testKey);
      expect(await counter.isNonZero(), isFalse);
      await counter.increment();
      expect(await counter.isNonZero(), isTrue);
    });

    test('raw returns current value without expiration check', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final counter = BasicCounter(testKey);
      await counter.increment(7);
      expect(await counter.raw(), 7);
    });

    test('hasState returns true after increment', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final counter = BasicCounter(testKey);
      expect(await counter.hasState(), isFalse);
      await counter.increment();
      expect(await counter.hasState(), isTrue);
    });
  });
}
