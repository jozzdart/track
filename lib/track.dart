/// ## 📦 `track` Package
///
/// Persistent, plug-and-play tools for tracking streaks, counters, histories,
/// activity, and records — all with zero boilerplate.
///
/// This package provides ready-to-use services for common time-based
/// progress patterns, including:
///
/// - 🔥 **StreakTracker** — track streaks over aligned periods (e.g. daily, weekly)
/// - 🧾 **HistoryTracker** — store recent items with optional deduplication
/// - 📈 **PeriodicCounter** — count events per fixed time window (e.g. daily, hourly)
/// - ⏳ **RolloverCounter** — sliding window counters that reset after inactivity
/// - 📆 **ActivityCounter** — detailed time-based analytics over hours, days, months, years
///
/// All tools are:
/// - Async-safe and isolate-friendly
/// - Automatically persisted across app restarts
/// - Optimized with optional caching
///
/// ### Usage Example
/// ```dart
/// import 'package:track/track.dart';
///
/// final streak = StreakTracker('daily_streak', period: TimePeriod.daily);
/// await streak.bump();
/// final count = await streak.currentStreak();
/// ```
/// For complete documentation and examples, see the package README.
library;

export 'src/track.dart';
