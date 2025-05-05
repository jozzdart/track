import 'package:flutter_test/flutter_test.dart';
import 'package:prf/prf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';
import 'package:track/track.dart';

import '../utils/fake_prefs.dart';

void main() {
  const testKey = 'test_best_record';

  group('BestRecord', () {
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
      final record = BestRecord(testKey);
      await record.reset();
    });

    test('starts empty', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final record = BestRecord(testKey);
      expect(await record.getBestEntry(), isNull);
      expect(await record.getBestRecord(), isNull);
      expect(await record.getBestDate(), isNull);
    });

    test('records best value in max mode', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final record = BestRecord(testKey, mode: RecordMode.max);
      await record.update(5);
      await record.update(10);
      await record.update(7);

      final best = await record.getBestEntry();
      expect(best!.value, 10);
    });

    test('records best value in min mode', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final record = BestRecord(testKey, mode: RecordMode.min);
      await record.update(5);
      await record.update(2);
      await record.update(7);

      final best = await record.getBestEntry();
      expect(best!.value, 2);
    });

    test('getBestOrFallback returns fallback if no data', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final fallback = RecordEntry(42, DateTime.now());
      final record = BestRecord(testKey, fallback: fallback);

      final result = await record.getBestOrFallback();
      expect(result, fallback);
    });

    test('getBestOrFallback throws without fallback', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final record = BestRecord(testKey);

      expect(() => record.getBestOrFallback(), throwsStateError);
    });

    test('manualSet adds record without comparison', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final record = BestRecord(testKey);
      await record.manualSet(99);

      final best = await record.getBestEntry();
      expect(best!.value, 99);
    });

    test('removeAt deletes entry', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final record = BestRecord(testKey, historyLength: 2);
      await record.manualSet(10);
      await record.manualSet(20);
      var history = await record.getHistory();
      expect(history.length, 2);

      await record.removeAt(0);
      history = await record.getHistory();
      expect(history.length, 1);
    });

    test('removeWhere deletes matching entries', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final record = BestRecord(testKey);
      await record.manualSet(10);
      await record.manualSet(20);
      await record.removeWhere((entry) => entry.value == 10);

      final history = await record.getHistory();
      expect(history.length, 1);
      expect(history.first.value, 20);
    });

    test('reset clears all records', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final record = BestRecord(testKey);
      await record.update(5);
      await record.reset();

      expect(await record.getBestEntry(), isNull);
    });

    test('removeKey deletes preferences key', () async {
      final (prefs, store) = getPreferences();
      PrfService.overrideWith(prefs);

      final record = BestRecord(testKey);
      await record.update(5);
      expect(await record.exists(), isTrue);

      await record.removeKey();
      expect(await record.exists(), isFalse);

      final keys = await store.getKeys(
        const GetPreferencesParameters(filter: PreferencesFilters()),
        const SharedPreferencesOptions(),
      );
      expect(keys.any((k) => k.contains(testKey)), isFalse);
    });

    test('state persists across instances', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      {
        final record = BestRecord(testKey);
        await record.update(10);
      }

      {
        final record = BestRecord(testKey);
        final best = await record.getBestEntry();
        expect(best!.value, 10);
      }
    });

    test('first() and last() return correct entries', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final record = BestRecord(testKey, historyLength: 3);
      await record.manualSet(1);
      await record.manualSet(2);
      await record.manualSet(3);

      final first = await record.first();
      final last = await record.last();

      expect(first!.value, 3); // most recent first
      expect(last!.value, 1); // oldest last
    });

    test('history length respects max history setting', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final record = BestRecord(testKey, historyLength: 2);
      await record.manualSet(1);
      await record.manualSet(2);
      await record.manualSet(3);

      final history = await record.getHistory();
      expect(history.length, 2);
    });

    test('update sets correct date', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final record = BestRecord(testKey);
      final before = DateTime.now();
      await record.update(100);
      final after = DateTime.now();

      final best = await record.getBestEntry();
      expect(best!.date.isAfter(before) || best.date.isAtSameMomentAs(before),
          isTrue);
      expect(best.date.isBefore(after) || best.date.isAtSameMomentAs(after),
          isTrue);
    });

    test('getBestOrFallback works after reset', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final fallback = RecordEntry(999, DateTime.now());
      final record = BestRecord(testKey, fallback: fallback);
      await record.manualSet(50);
      await record.reset();

      final result = await record.getBestOrFallback();
      expect(result, fallback);
    });

    test('getBestOrFallback throws after reset if no fallback', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final record = BestRecord(testKey);
      await record.manualSet(50);
      await record.reset();

      expect(() => record.getBestOrFallback(), throwsStateError);
    });

    test('min mode ignores larger values', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final record = BestRecord(testKey, mode: RecordMode.min);
      await record.update(5);
      await record.update(10); // should NOT overwrite best
      final best = await record.getBestEntry();
      expect(best!.value, 5);
    });

    test('max mode ignores smaller values', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final record = BestRecord(testKey, mode: RecordMode.max);
      await record.update(10);
      await record.update(5); // should NOT overwrite best
      final best = await record.getBestEntry();
      expect(best!.value, 10);
    });

    test('removeAt out of bounds does nothing', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final record = BestRecord(testKey);
      await record.manualSet(1);
      await record.removeAt(5); // invalid index
      final history = await record.getHistory();
      expect(history.length, 1);
    });

    test('removeWhere with no matches leaves history intact', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final record = BestRecord(testKey);
      await record.manualSet(1);
      await record.removeWhere((entry) => entry.value == 999); // no match
      final history = await record.getHistory();
      expect(history.length, 1);
    });

    test('exists returns correct state', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final record = BestRecord(testKey);
      expect(await record.exists(), isFalse);

      await record.manualSet(42);
      expect(await record.exists(), isTrue);

      await record.removeKey();
      expect(await record.exists(), isFalse);
    });

    test('history trims to max length', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final record = BestRecord(testKey, historyLength: 2);
      await record.manualSet(1);
      await record.manualSet(2);
      await record.manualSet(3);

      final history = await record.getHistory();
      expect(history.length, 2);
      expect(history.first.value, 3);
      expect(history.last.value, 2);
    });

    test('stress test with many updates', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final record =
          BestRecord(testKey, mode: RecordMode.max, historyLength: 10);

      for (int i = 0; i < 100; i++) {
        await record.update(i);
      }

      final best = await record.getBestEntry();
      final history = await record.getHistory();

      expect(best!.value, 99);
      expect(history.length, 10);
      expect(history.first.value, 99);
      expect(history.last.value, 90);
    });

    test('handles concurrent updates safely', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final record = BestRecord(testKey, mode: RecordMode.max);

      await Future.wait(List.generate(20, (i) => record.update(i)));

      final best = await record.getBestEntry();
      expect(best!.value, 19);
    });

    test('mixing manualSet and update keeps best value', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final record = BestRecord(testKey, mode: RecordMode.max);
      await record.manualSet(5);
      await record.update(10);
      await record.manualSet(8);
      await record.update(12);

      final best = await record.getBestEntry();
      expect(best!.value, 12);
    });

    test('history remains ordered after remove operations', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final record = BestRecord(testKey, historyLength: 5);
      await record.manualSet(1);
      await record.manualSet(2);
      await record.manualSet(3);

      await record.removeAt(1); // remove middle

      var history = await record.getHistory();
      expect(history.map((e) => e.value), [3, 1]);

      await record.removeWhere((e) => e.value == 1);

      history = await record.getHistory();
      expect(history.map((e) => e.value), [3]);
    });

    test('fallback works after clearing records with removeWhere', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final fallback = RecordEntry(999, DateTime.now());
      final record = BestRecord(testKey, fallback: fallback);

      await record.manualSet(10);
      await record.removeWhere((e) => e.value == 10);

      final result = await record.getBestOrFallback();
      expect(result, fallback);
    });

    test('multiple keys are isolated', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final recordA = BestRecord('recordA', mode: RecordMode.max);
      final recordB = BestRecord('recordB', mode: RecordMode.max);

      await recordA.update(10);
      await recordB.update(20);

      final bestA = await recordA.getBestEntry();
      final bestB = await recordB.getBestEntry();

      expect(bestA!.value, 10);
      expect(bestB!.value, 20);
    });

    test('switching mode reuses old data but applies new logic', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final recordMax = BestRecord(testKey, mode: RecordMode.max);
      await recordMax.update(10);
      await recordMax.update(5);

      final recordMin = BestRecord(testKey, mode: RecordMode.min);
      await recordMin.update(3);

      final bestMin = await recordMin.getBestEntry();
      expect(bestMin!.value, 3);
    });

    test('remove middle, add new, check order', () async {
      final (prefs, _) = getPreferences();
      PrfService.overrideWith(prefs);

      final record = BestRecord(testKey, historyLength: 3);
      await record.manualSet(1);
      await record.manualSet(2);
      await record.manualSet(3);

      await record.removeAt(1); // remove second item

      await record.manualSet(4);

      final history = await record.getHistory();
      expect(history.map((e) => e.value), [4, 3, 1]);
    });
  });
}
