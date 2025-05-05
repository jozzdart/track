## 1.1.0

### **New services added**:

- 🏅 **BestRecord** — track the best (max or min) performance or value over time, with a full history and fallback support. Example use cases: high scores, fastest times, highest streaks

- 🔢 **BasicCounter** — a simple persistent counter with no expiration or alignment. Example use cases: total taps, visits, or actions

### **Enhancements**:

- 🔥 **StreakTracker now integrates BestRecord**
  - Automatically tracks and saves the highest streak ever achieved
  - Supports history length, fallback records, and customizable record mode (`max` or `min`)

### Fixed:

- **Synchronized `clearValueOnly()` in BaseCounterService**  
  Now uses `_lock.synchronized()` to prevent race conditions, ensuring thread safety like `increment()` and `reset()`.

## 1.0.0

### ✨ **`track` initial release**

Persistent, plug-and-play tools for tracking streaks, counters, histories, and records across sessions, isolates, and app restarts — no boilerplate, no manual timers, no storage code.

**Features included:**

- 🔥 **StreakTracker** — track streaks that reset when a period is missed (e.g. daily habits, login streaks)
- 🧾 **HistoryTracker** — maintain a rolling list of recent items with max length and optional deduplication
- 📈 **PeriodicCounter** — count events within aligned time periods (e.g. daily tasks, hourly goals)
- ⏳ **RolloverCounter** — track counts over a sliding window that resets after inactivity (e.g. attempts per hour)
- 📆 **ActivityCounter** — capture detailed activity stats over hours, days, months, and years
  > 🏅 _(coming soon)_ **BestRecord** — track best performances or highscores

**Highlights:**

- One-line setup (`StreakTracker`, `HistoryTracker`, `PeriodicCounter`, `RolloverCounter`, `ActivityCounter`)
- Automatic persistence across app restarts
- Async-safe, isolate-friendly behavior
- Built-in reset, summary, and analytics methods
- Optional caching for extra performance

> **Notes**: Originally part of the **prf** package. Extracted into a standalone package for modularity, lighter dependencies, and focused use. Perfect for apps that need easy-to-integrate progress tracking without extra complexity.

## 0.0.7

- Added `RolloverCounter` - a persistent counter designed to automatically reset after a specified duration from the last update. This is particularly useful for tracking rolling activity windows, such as "submissions per hour" or "attempts every 10 minutes".

## 0.0.6

- Added `PeriodicCounter` - A persistent counter that automatically resets at the start of each aligned time period designed to track integer counters that reset periodically based on a specified `TimePeriod`.

## 0.0.5

- Added `ActivityCounter` - A utility class for tracking user activity over time across various spans such as hour, day, month, and year. It provides persistent storage and retrieval of activity data, making it suitable for usage statistics, trend analysis, and generating long-term activity reports.
- Added `.historyTracker` extension for building a persisted history tracker from any adapter

```dart
    final history = adapter.historyTracker(
     'my_history',
     maxLength: 100,
     deduplicate: true,
   );
```

## 0.0.4

- Added `HistoryTracker` - A persisted, FIFO history tracker

## 0.0.3

- Added tests for all core components to ensure reliability and correctness.

## 0.0.2

- Imported `BaseCounterService` - An abstract class for tracking integer counters with expiration logic. It extends the `BaseTrackerService` to specifically handle integer counters. It provides methods to increment the counter, check if the counter is non-zero, and reset the counter value while maintaining the last update timestamp.

## 0.0.1

- Added `TimePeriod` - Represents different time periods for tracking purposes.
- Added `BaseTrackerService` - An abstract base class for tracking values with expiration logic.
- Added testing tools and utilities

> Notes: Originally was part of the prf package. Extracted into a standalone package for modularity, lighter dependencies, and focused use. Ideal for apps needing easy-to-integrate time-based limits without extra logic.
