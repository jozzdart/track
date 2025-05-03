## 0.0.6

- Added `PeriodicCounter` - A persistent counter that automatically resets at the start of each aligned time period designed to track integer counters that reset periodically based on a specified `TrackerPeriod`.

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

- Imported `BaseCounterTracker` - An abstract class for tracking integer counters with expiration logic. It extends the `BaseTracker` to specifically handle integer counters. It provides methods to increment the counter, check if the counter is non-zero, and reset the counter value while maintaining the last update timestamp.

## 0.0.1

- Added `TrackerPeriod` - Represents different time periods for tracking purposes.
- Added `BaseTracker` - An abstract base class for tracking values with expiration logic.
- Added testing tools and utilities

> Notes: Originally was part of the prf package. Extracted into a standalone package for modularity, lighter dependencies, and focused use. Ideal for apps needing easy-to-integrate time-based limits without extra logic.
