import 'package:flutter/widgets.dart';
import 'package:track/track.dart';

Future<void> main() async {
  // ✅ Create a daily streak tracker
  final streak = StreakTracker(
    'daily_exercise',
    period: TimePeriod.daily,
    recordsHistory: 3,
  );

  // ⚡ Bump the streak (mark today as completed)
  await streak.bump();
  debugPrint('Streak bumped!');

  // 📊 Get the current streak count
  final current = await streak.currentStreak();
  debugPrint('Current streak: $current');

  // ❓ Check if the streak is broken
  final isBroken = await streak.isStreakBroken();
  debugPrint('Is streak broken? $isBroken');

  // 📅 Check when the streak will break next
  final nextReset = await streak.nextResetTime();
  debugPrint('Next reset time: $nextReset');

  // 📈 Get percent of time remaining before streak breaks
  final percentLeft = await streak.percentRemaining();
  debugPrint(
      'Percent of time remaining: ${(percentLeft! * 100).toStringAsFixed(2)}%');

  // ⏱ Check how long ago the last bump happened
  final age = await streak.streakAge();
  debugPrint('Time since last bump: ${age?.inHours} hours');

  // 🏆 Get best streak ever
  final best = await streak.records.getBestRecord();
  debugPrint('Best streak ever: $best');

  // 🧯 Reset the streak
  await streak.reset();
  debugPrint('Streak reset!');

  // 🧪 Debug helpers
  final hasData = await streak.hasState();
  debugPrint('Has saved state? $hasData');

  await streak.clear();
  debugPrint('State cleared!');
}
