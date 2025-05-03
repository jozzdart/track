![img](https://i.imgur.com/PWxvCxH.png)

<h3 align="center"><i>From streaks to records — all your progress, automated.</i></h3>
<p align="center">
        <img src="https://img.shields.io/codefactor/grade/github/jozzzzep/track?style=flat-square">
        <img src="https://img.shields.io/github/license/jozzzzep/track?style=flat-square">
        <img src="https://img.shields.io/pub/points/track?style=flat-square">
        <img src="https://img.shields.io/pub/v/track?style=flat-square">
</p>
<p align="center">
  <a href="https://buymeacoffee.com/yourname" target="_blank">
    <img src="https://img.shields.io/badge/Buy%20me%20a%20coffee-Support☕-blue?logo=buymeacoffee&style=flat-square" />
  </a>
</p>

One line. No boilerplate. No setup.
The **track** package gives you instant, persistent tracking for streaks, counters, histories, and records — across sessions, isolates, and app restarts.
Define once, track forever.

#### Table of Contents

- [🔥 **StreakTracker**](#-streaktracker-persistent-streak-tracker) — track streaks that reset when a period is missed (e.g. daily habits)
- [🧾 **HistoryTracker**](#-historytrackert--persistent-history-tracker) — maintain a rolling list of recent items with max length and deduplication
- [📈 **PeriodicCounter**](#-periodiccounter-aligned-timed-counter) — count events within aligned time periods (e.g. daily tasks, hourly goals)
- [⏳ **RolloverCounter**](#-rollovercounter-sliding-window-counter) — track counts over a sliding window that resets after inactivity
- [📆 **ActivityCounter**](#-activitycounter--persistent-activity-tracker) — capture detailed activity stats over hours, days, months, and years
  > 🏅 **BestRecord** - in progress

---

### 💥 Why Use `track`?

Working with streaks, counters, and history usually means:

- Manually managing resets
- Writing timestamp logic and period alignment
- Saving counters and records yourself
- Cleaning up old or expired data

**track** removes all that:
you just define, call, and trust it.

- ✅ Lets you **define, track, and forget** — the system handles everything in the background
- ✅ One-line setup, no manual timers or storage
- ✅ Persisted across app restarts and isolates
- ✅ Async-safe and cache-friendly
- ✅ Perfect for **streaks, habits, counters, leaderboards, activity stats**, and more

---

### 🚀 Choosing the Right Tool

Each service is tailored for a specific pattern of time-based control.

| Goal                               | Use                                                                  |
| ---------------------------------- | -------------------------------------------------------------------- |
| "Track a streak of daily activity" | [`StreakTracker`](#-streaktracker-persistent-streak-tracker)         |
| "Keep a list of recent values"     | [`HistoryTracker<T>`](#-historytrackert--persistent-history-tracker) |
| "Count per hour / day / week"      | [`PeriodicCounter`](#-periodiccounter-aligned-timed-counter)         |
| "Reset X minutes after last use"   | [`RolloverCounter`](#-rollovercounter-sliding-window-counter)        |
| "Track activity history over time" | [`ActivityCounter`](#-activitycounter--persistent-activity-tracker)  |

[**🔥 `StreakTracker`**](#-streaktracker-persistent-streak-tracker)

> _"Maintain a daily learning streak"_  
> → Aligned periods (`daily`, `weekly`, etc.)  
> → Resets if user misses a full period  
> → Ideal for habit chains, gamified streaks

[**🧾 `HistoryTracker<T>`**](#-historytrackert--persistent-history-tracker)

> _"Track recent searches, actions, or viewed items"_  
> → FIFO list stored in `Prf<List<T>>`  
> → Supports deduplication, max length, and type-safe adapters  
> → Perfect for autocomplete history, usage trails, or navigation stacks

[**📈 `PeriodicCounter`**](#-periodiccounter-aligned-timed-counter)

> _"How many times today?"_  
> → Auto-reset at the start of each period (e.g. midnight)  
> → Clean for tracking daily usage, hourly limits

[**⏳ `RolloverCounter`**](#-rollovercounter-sliding-window-counter)

> _"Max 5 actions per 10 minutes (sliding)"_  
> → Resets after duration from **last activity**  
> → Perfect for soft rate caps, retry attempt tracking

[**📆 `ActivityCounter`**](#-activitycounter--persistent-activity-tracker)

> _"Track usage over time by hour, day, month, year"_  
> → Persistent time-series counter  
> → Supports summaries, totals, active dates, and trimming  
> → Ideal for activity heatmaps, usage analytics, or historical stats

---

# 🔥 `StreakTracker` Persistent Streak Tracker

[⤴️ Back](#table-of-contents) -> Table of Contents

`StreakTracker` is a drop-in utility for managing **activity streaks** — like daily check-ins, learning streaks, or workout chains — with automatic expiration logic and aligned time periods. It resets automatically if a full period is missed, and persists streak progress across sessions and isolates.

It handles:

- Aligned period tracking (`daily`, `weekly`, etc.) via `TimePeriod`
- Persistent storage with `prf` using `PrfIso<int>` and `DateTime`
- Automatic streak expiration logic if a period is skipped
- Useful metadata like last update time, next reset estimate, and time remaining

---

### 🔧 How to Use

- `bump([amount])` — Marks the current period as completed and increases the streak
- `currentStreak()` — Returns the current streak value (auto-resets if expired)
- `isStreakBroken()` — Returns `true` if the streak has been broken (a period was missed)
- `isStreakActive()` — Returns `true` if the streak is still active
- `nextResetTime()` — Returns when the streak will break if not continued
- `percentRemaining()` — Progress indicator (0.0–1.0) until streak break
- `streakAge()` — Time passed since the last streak bump
- `reset()` — Fully resets the streak to 0 and clears last update
- `peek()` — Returns the current value without checking expiration
- `getLastUpdateTime()` — Returns the timestamp of the last streak update
- `timeSinceLastUpdate()` — Returns how long ago the last streak bump occurred
- `isCurrentlyExpired()` — Returns `true` if the streak is expired _right now_
- `hasState()` — Returns `true` if any streak data is saved
- `clear()` — Deletes all streak data (value + timestamp)

You can also access **period-related properties**:

- `currentPeriodStart` — Returns the `DateTime` representing the current aligned period start
- `nextPeriodStart` — Returns the `DateTime` when the next period will begin
- `timeUntilNextPeriod` — Returns a `Duration` until the next reset occurs
- `elapsedInCurrentPeriod` — How much time has passed since the period began
- `percentElapsed` — A progress indicator (0.0 to 1.0) showing how far into the period we are

---

### ⏱ Available Periods (`TimePeriod`)

You can choose from a wide range of aligned time intervals:

- Seconds:  
  `seconds10`, `seconds20`, `seconds30`

- Minutes:  
  `minutes1`, `minutes2`, `minutes3`, `minutes5`, `minutes10`,  
  `minutes15`, `minutes20`, `minutes30`

- Hours:  
  `hourly`, `every2Hours`, `every3Hours`, `every6Hours`, `every12Hours`

- Days and longer:  
  `daily`, `weekly`, `monthly`

Each period is aligned automatically — e.g., daily resets at midnight, weekly at the start of the week, monthly on the 1st.

---

#### ✅ Define a Streak Tracker

```dart
final streak = StreakTracker('daily_exercise', period: TimePeriod.daily);
```

This creates a persistent streak tracker that:

- Uses the key `'daily_exercise'`
- Tracks aligned daily periods (e.g. 00:00–00:00)
- Increases the streak when `bump()` is called
- Resets automatically if a full period is missed

---

#### ⚡ Mark a Period as Completed

```dart
await streak.bump();
```

This will:

- Reset the streak to 0 if the last bump was too long ago (missed period)
- Then increment the streak by 1
- Then update the internal timestamp to the current aligned time

---

#### 📊 Get Current Streak Count

```dart
final current = await streak.currentStreak();
```

Returns the current streak (resets first if broken).

---

#### 🧯 Manually Reset the Streak

```dart
await streak.reset();
```

Sets the value back to 0 and clears the last update timestamp.

---

#### ❓ Check if Streak Is Broken

```dart
final isBroken = await streak.isStreakBroken();
```

Returns `true` if the last streak bump is too old (i.e. period missed).

---

#### 📈 View Streak Age

```dart
final age = await streak.streakAge();
```

Returns how much time passed since the last bump (or `null` if never set).

---

#### ⏳ See When the Streak Will Break

```dart
final time = await streak.nextResetTime();
```

Returns the timestamp of the next break opportunity (end of allowed window).

---

#### 📉 Percent of Time Remaining

```dart
final percent = await streak.percentRemaining();
```

Returns a `double` between `0.0` and `1.0` indicating time left before the streak is considered broken.

---

#### 👁 Peek at the Current Value

```dart
final raw = await streak.peek();
```

Returns the current stored streak **without checking if it expired**.

---

#### 🧪 Debug or Clear State

```dart
await streak.clear();                    // Removes all saved state
final hasData = await streak.hasState(); // Checks if any value exists
```

---

#### ⚡ Optional `useCache` Parameter

Each utility accepts a `useCache` flag:

```dart
final streak = StreakTracker(
    'daily_exercise',
    period: TimePeriod.daily,
    useCache: true // false by default
);
```

- `useCache: false` (default):

  - Fully **isolate-safe**
  - Reads directly from storage every time
  - Best when multiple isolates might read/write the same data

- `useCache: true`:
  - Uses **memory caching** for faster access
  - **Not isolate-safe** — may lead to stale or out-of-sync data across isolates
  - Best when used in single-isolate environments (most apps)

> ⚠️ **Warning**: Enabling `useCache` disables isolate safety. Use only when you're sure no other isolate accesses the same key.

# 🧾 `HistoryTracker<T>` – Persistent History Tracker

[⤴️ Back](#table-of-contents) -> Table of Contents

`HistoryTracker<T>` makes it easy to store and manage **persistent, ordered lists** of items — like recent searches, viewed content, or activity logs. It automatically handles trimming, deduplication, and persistence, so you can focus on your app’s logic without worrying about list management.

It automatically:

- Keeps the most recent items first
- Limits the list to a maximum number of entries
- Optionally removes duplicates (so the newest version stays on top)
- Supports JSON, enum, and custom item types
- Works safely across isolates with optional caching

You can also plug it in easily using `.historyTracker()` on any `prf` adapter.

---

### 🧰 Core Features

- `add(value)` — Adds a new item to the front (most recent). Trims and deduplicates if needed
- `setAll(values)` — Replaces the entire history with a new list
- `remove(value)` — Removes a single matching item
- `removeWhere(predicate)` — Removes all matching items by condition
- `clear()` — Clears the entire list, resets to empty
- `removeKey()` — Deletes the key from persistent storage
- `getAll()` — Returns the full history (most recent first)
- `contains(value)` — Returns whether a given item exists
- `length()` — Number of items currently in the list
- `isEmpty()` — Whether the history is empty
- `first()` — Most recent item in the list, or `null`
- `last()` — Oldest item in the list, or `null`
- `exists()` — Whether this key exists in SharedPreferences

* _Fields_:
  - `key` — The full key name used for persistence
  - `useCache` — Toggles between cached `Prf` or isolate-safe `PrfIso`
  - `maxLength` — The maximum number of items to keep
  - `deduplicate` — If enabled, removes existing instances of an item before adding it

---

#### ✅ Define a History Tracker

```dart
final history = HistoryTracker<String>('recent_queries');
```

This creates a persistent history list for `'recent_queries'` with a default max length of 50 items. You can customize:

- `maxLength` — maximum number of items retained (default: 50)
- `deduplicate` — remove existing items before re-adding (default: false)
- `useCache` — if `true` will toggle off isolate safety (default: false)

HistoryTracker\<T> supports **out of the box** (with zero setup) these types:

> → `bool`, `int`, `double`, `num`, `String`, `Duration`, `DateTime`, `Uri`, `BigInt`, `Uint8List` (binary data) `List<bool>`, `List<int>`, `List<String>`, `List<double>`, `List<num>`, `List<DateTime>`, `List<Duration>`, `List<Uint8List>`, `List<Uri>`, `List<BigInt>`

---

For custom types, use one of the factory constructors:

#### 🧱 JSON Object History

```dart
final history = HistoryTracker.json<Book>(
  'books_set',
  fromJson: Book.fromJson,
  toJson: (b) => b.toJson(),
);
```

---

#### 🧭 Enum History

```dart
final history = HistoryTracker.enumerated<LogType>(
  'log_type_history',
  values: LogType.values,
  deduplicate: true,
);
```

---

#### ➕ Add a New Entry

```dart
await history.add('search_term');
```

Adds an item to the front of the list. If `deduplicate` is enabled, the item is moved to the front instead of duplicated.

---

#### 🧺 Replace the Entire List

```dart
await history.setAll(['one', 'two', 'three']);
```

Sets the full list. Will apply deduplication and trimming automatically if configured.

---

#### ❌ Remove a Value

```dart
await history.remove('two');
```

Removes a single item from the history by value.

---

#### 🧹 Remove Matching Items

```dart
await history.removeWhere((item) => item.length > 5);
```

Removes all items that match a custom condition.

---

#### 🧼 Clear or Delete the History

```dart
await history.clear();      // Clears all values
await history.removeKey();  // Removes the key from preferences entirely
```

Use `clear()` to reset the list but keep the key; `removeKey()` to fully delete the key from storage.

---

#### 🔍 Read & Inspect History

```dart
final items = await history.getAll();     // Full list, newest first
final exists = await history.exists();    // true if key exists
final hasItem = await history.contains('abc'); // true if present
```

---

#### 🔢 Get Meta Info

```dart
final total = await history.length(); // Number of items
final empty = await history.isEmpty(); // Whether the list is empty
```

---

#### 🎯 Get Specific Entries

```dart
final newest = await history.first(); // Most recent (or null)
final oldest = await history.last();  // Oldest (or null)
```

---

#### 📚 Store Recently Viewed Models (with Deduplication)

```dart
final productHistory = HistoryTracker.json<Product>(
  'recent_products',
  fromJson: Product.fromJson,
  toJson: (p) => p.toJson(),
  deduplicate: true,
  maxLength: 100,
);
```

---

#### 📘 Track Reading Progress by Enum

```dart
enum ReadStatus { unread, reading, finished }

final readingHistory = HistoryTracker.enumerated<ReadStatus>(
  'reading_statuses',
  values: ReadStatus.values,
  maxLength: 20,
);
```

---

#### 🔐 Store Recent Login Accounts

```dart
final logins = HistoryTracker<DateTime>(
  'recent_logins',
  deduplicate: true,
  maxLength: 5,
);
```

---

#### 🧪 Use a Custom Adapter for Byte-Chunks

```dart
final someCustomAdapter = SomeCustomAdapter(); // PrfAdapter<List<T>>

final hisory = someCustomAdapter.historyTracker(
  'special_data',
  maxLength: 20,
  deduplicate: false,
);
```

---

#### ⚡ Optional `useCache` Parameter

Each utility accepts a `useCache` flag:

```dart
final fastCache = HistoryTracker<int>(
  'cached_ints',
  useCache: true,
);
```

- `useCache: false` (default):

  - Fully **isolate-safe**
  - Reads directly from storage every time
  - Best when multiple isolates might read/write the same data

- `useCache: true`:
  - Uses **memory caching** for faster access
  - **Not isolate-safe** — may lead to stale or out-of-sync data across isolates
  - Best when used in single-isolate environments (most apps)

> ⚠️ **Warning**: Enabling `useCache` disables isolate safety. Use only when you're sure no other isolate accesses the same key.

# 📈 `PeriodicCounter` Aligned Timed Counter

[⤴️ Back](#table-of-contents) -> Table of Contents

`PeriodicCounter` is a persistent counter that **automatically resets at the start of each aligned time period**, such as _daily_, _hourly_, or every _10 minutes_. It’s perfect for tracking time-bound events like “daily logins,” “hourly uploads,” or “weekly tasks,” without writing custom reset logic.

It handles:

- Aligned period math (e.g. resets every day at 00:00)
- Persistent storage with isolate safety
- Auto-expiring values based on time alignment
- Counter tracking with optional increment amounts
- Period progress and time tracking

---

### 🔧 How to Use

- `get()` — Returns the current counter value (auto-resets if needed)
- `increment()` — Increments the counter, by a given amount (1 is the default)
- `reset()` — Manually resets the counter and aligns the timestamp to the current period start
- `peek()` — Returns the current value without checking or triggering expiration
- `raw()` — Alias for `peek()` (useful for debugging or display)
- `isNonZero()` — Returns `true` if the counter value is greater than zero
- `clearValueOnly()` — Resets only the counter, without modifying the timestamp
- `clear()` — Removes all stored values, including the timestamp
- `hasState()` — Returns `true` if any persistent state exists
- `isCurrentlyExpired()` — Returns `true` if the counter would reset right now
- `getLastUpdateTime()` — Returns the last reset-aligned timestamp
- `timeSinceLastUpdate()` — Returns how long it’s been since the last reset

You can also access **period-related properties**:

- `currentPeriodStart` — Returns the `DateTime` representing the current aligned period start
- `nextPeriodStart` — Returns the `DateTime` when the next period will begin
- `timeUntilNextPeriod` — Returns a `Duration` until the next reset occurs
- `elapsedInCurrentPeriod` — How much time has passed since the period began
- `percentElapsed` — A progress indicator (0.0 to 1.0) showing how far into the period we are

---

### ⏱ Available Periods (`TimePeriod`)

You can choose from a wide range of aligned time intervals:

- Seconds:  
  `seconds10`, `seconds20`, `seconds30`

- Minutes:  
  `minutes1`, `minutes2`, `minutes3`, `minutes5`, `minutes10`,  
  `minutes15`, `minutes20`, `minutes30`

- Hours:  
  `hourly`, `every2Hours`, `every3Hours`, `every6Hours`, `every12Hours`

- Days and longer:  
  `daily`, `weekly`, `monthly`

Each period is aligned automatically — e.g., daily resets at midnight, weekly at the start of the week, monthly on the 1st.

---

#### ✅ Define a Periodic Counter

```dart
final counter = PeriodicCounter('daily_uploads', period: TimePeriod.daily);
```

This creates a persistent counter that **automatically resets at the start of each aligned period** (e.g. daily at midnight).  
It uses the prefix `'daily_uploads'` to store:

- The counter value (`int`)
- The last reset timestamp (`DateTime` aligned to period start)

---

#### ➕ Increment the Counter

```dart
await counter.increment();           // adds 1
await counter.increment(3);         // adds 3
```

You can increment by any custom amount. The value will reset if expired before incrementing.

---

#### 🔢 Get the Current Value

```dart
final count = await counter.get();
```

This returns the current counter value, automatically resetting it if the period expired.

---

#### 👀 Peek at Current Value (Without Reset Check)

```dart
final raw = await counter.peek();
```

Returns the current stored value without checking expiration or updating anything.  
Useful for diagnostics, stats, or UI display.

---

#### ✅ Check If Counter Is Non-Zero

```dart
final hasUsage = await counter.isNonZero();
```

Returns `true` if the current value is greater than zero.

---

#### 🔄 Manually Reset the Counter

```dart
await counter.reset();
```

Resets the value to zero and stores the current aligned timestamp.

---

#### ✂️ Clear Stored Counter Only (Preserve Timestamp)

```dart
await counter.clearValueOnly();
```

Resets the counter but **keeps the current period alignment** intact.

---

#### 🗑️ Clear All Stored State

```dart
await counter.clear();
```

Removes both value and timestamp from persistent storage.

---

#### ❓ Check if Any State Exists

```dart
final exists = await counter.hasState();
```

Returns `true` if the counter or timestamp exist in SharedPreferences.

---

#### ⌛ Check if Current Period Is Expired

```dart
final expired = await counter.isCurrentlyExpired();
```

Returns `true` if the stored timestamp is from an earlier period than now.

---

#### 🕓 View Timing Info

```dart
final last = await counter.getLastUpdateTime();     // last reset-aligned timestamp
final since = await counter.timeSinceLastUpdate();  // Duration since last reset
```

---

#### 📆 Period Insight & Progress

```dart
final start = counter.currentPeriodStart;      // start of this period
final next = counter.nextPeriodStart;          // start of the next period
final left = counter.timeUntilNextPeriod;      // how long until reset
final elapsed = counter.elapsedInCurrentPeriod; // time passed in current period
final percent = counter.percentElapsed;        // progress [0.0–1.0]
```

---

#### ⚡ Optional `useCache` Parameter

Each utility accepts a `useCache` flag:

```dart
final counter = PeriodicCounter(
  'daily_uploads',
  period: TimePeriod.daily
  useCache: true,
);
```

- `useCache: false` (default):

  - Fully **isolate-safe**
  - Reads directly from storage every time
  - Best when multiple isolates might read/write the same data

- `useCache: true`:
  - Uses **memory caching** for faster access
  - **Not isolate-safe** — may lead to stale or out-of-sync data across isolates
  - Best when used in single-isolate environments (most apps)

> ⚠️ **Warning**: Enabling `useCache` disables isolate safety. Use only when you're sure no other isolate accesses the same key.

# ⏳ `RolloverCounter` Sliding Window Counter

[⤴️ Back](#table-of-contents) -> Table of Contents

`RolloverCounter` is a persistent counter that automatically resets itself after a fixed duration from the last update. Ideal for tracking **rolling activity windows**, such as "submissions per hour", "attempts every 10 minutes", or "usage in the past day".

It handles:

- Time-based expiration with a sliding duration window
- Persistent storage using with full isolate-safety
- Seamless session persistence and automatic reset logic
- Rich time utilities to support countdowns, progress indicators, and timer-based UI logic

---

### 🔧 How to Use

- `get()` — Returns the current counter value (auto-resets if expired)
- `increment([amount])` — Increases the count by `amount` (default: `1`)
- `reset()` — Manually resets the counter and sets a new expiration time
- `clear()` — Deletes all stored state from preferences
- `hasState()` — Returns `true` if any saved state exists
- `peek()` — Returns the current value without triggering a reset
- `getLastUpdateTime()` — Returns the last update timestamp, or `null` if never used
- `isCurrentlyExpired()` — Returns `true` if the current window has expired
- `timeSinceLastUpdate()` — Returns how much time has passed since last use
- `timeRemaining()` — Returns how much time remains before auto-reset
- `secondsRemaining()` — Same as above, in seconds
- `percentElapsed()` — Progress of the current window as a `0.0–1.0` value
- `getEndTime()` — Returns the `DateTime` when the current window ends
- `whenExpires()` — Completes when the reset window expires

---

#### ✅ Define a Rollover Counter

```dart
final counter = RolloverCounter('usage_counter', resetEvery: Duration(minutes: 10));
```

This creates a persistent counter that resets automatically 10 minutes after the last update. It uses the key `'usage_counter'` to store:

- Last update timestamp
- Rolling count value

---

#### ➕ Increment the Counter

```dart
await counter.increment();         // +1
await counter.increment(5);        // +5
```

This also refreshes the rollover timer.

---

#### 📈 Get the Current Value

```dart
final count = await counter.get(); // Auto-resets if expired
```

You can also check the value without affecting expiration:

```dart
final value = await counter.peek();
```

---

#### 🔄 Reset or Clear the Counter

```dart
await counter.reset(); // Sets count to 0 and updates timestamp
await counter.clear(); // Deletes all stored state
```

---

#### 🕓 Check Expiration Status

```dart
final expired = await counter.isCurrentlyExpired(); // true/false
```

You can also inspect metadata:

```dart
final lastUsed = await counter.getLastUpdateTime();
final since = await counter.timeSinceLastUpdate();
```

---

#### ⏳ Check Time Remaining

```dart
final duration = await counter.timeRemaining();
final seconds = await counter.secondsRemaining();
final percent = await counter.percentElapsed(); // 0.0–1.0
```

These can be used for progress bars, countdowns, etc.

---

#### 📅 Get the End Time

```dart
final end = await counter.getEndTime(); // DateTime when it auto-resets
```

---

#### 💤 Wait for Expiry

```dart
await counter.whenExpires(); // Completes when timer ends
```

Useful for polling, UI disable windows, etc.

---

#### 🧪 Test Utilities

```dart
await counter.clear();          // Removes all saved values
final exists = await counter.hasState(); // true if anything stored
```

---

#### ⚡ Optional `useCache` Parameter

Each utility accepts a `useCache` flag:

```dart
final counter = RolloverCounter(
    'usage_counter',
    resetEvery: Duration(minutes: 10),
    useCache: true // false by default
);
```

- `useCache: false` (default):

  - Fully **isolate-safe**
  - Reads directly from storage every time
  - Best when multiple isolates might read/write the same data

- `useCache: true`:
  - Uses **memory caching** for faster access
  - **Not isolate-safe** — may lead to stale or out-of-sync data across isolates
  - Best when used in single-isolate environments (most apps)

> ⚠️ **Warning**: Enabling `useCache` disables isolate safety. Use only when you're sure no other isolate accesses the same key.

# 📊 `ActivityCounter` – Persistent Activity Tracker

[⤴️ Back](#table-of-contents) -> Table of Contents

`ActivityCounter` is a powerful utility for **tracking user activity over time**, across `hour`, `day`, `month`, and `year` spans. It is designed for scenarios where you want to **record frequency**, **analyze trends**, or **generate statistics** over long periods, with full persistence across app restarts and isolates.

It handles:

- Span-based persistent counters (hourly, daily, monthly, yearly)
- Automatic time-based bucketing using `DateTime.now()`
- Per-span data access and aggregation
- Querying historical data without manual cleanup
- Infinite year tracking

---

### 🔧 How to Use

- `add(int amount)` — Adds to the current time bucket (across all spans)
- `increment()` — Shortcut for `add(1)`
- `amountThis(span)` — Gets current value for now’s `hour`, `day`, `month`, or `year`
- `amountFor(span, date)` — Gets the value for any given date and span
- `summary()` — Returns a map of all spans for the current time (`{year: X, month: Y, ...}`)
- `total(span)` — Total sum of all recorded entries in that span
- `all(span)` — Returns `{index: value}` map of non-zero entries for a span
- `maxValue(span)` — Returns the largest value ever recorded for the span
- `activeDates(span)` — Returns a list of `DateTime` objects where any activity was tracked
- `hasAnyData()` — Returns `true` if any activity has ever been recorded
- `thisHour`, `today`, `thisMonth`, `thisYear` — Shorthand for `amountThis(...)`
- `reset()` — Clears all data in sall spans
- `clear(span)` — Clears a single span
- `clearAllKnown([...])` — Clears multiple spans at once
- `removeAll()` — Permanently deletes all stored data for this counter

**ActivityCounter** tracks activity simultaneously across all of the following spans:

- `TimeSpan.hour` — hourly activity (rolling 24-hour window)
- `TimeSpan.day` — daily activity (up to 31 days)
- `TimeSpan.month` — monthly activity (up to 12 months)
- `TimeSpan.year` — yearly activity (from year 2000 onward, uncapped)

---

#### ✅ Define an Activity Counter

```dart
final counter = ActivityCounter('user_events');
```

This creates a persistent activity counter with a unique prefix. It automatically manages:

- Hourly counters
- Daily counters
- Monthly counters
- Yearly counters

---

#### ➕ Add or Increment Activity

```dart
await counter.add(5);    // Adds 5 to all time buckets
await counter.increment(); // Adds 1 (shortcut)
```

Each call will update the counter in all spans (`hour`, `day`, `month`, and `year`) based on `DateTime.now()`.

---

#### 📊 Get Current Time Span Counts

```dart
final currentHour = await counter.thisHour;
final today = await counter.today;
final thisMonth = await counter.thisMonth;
final thisYear = await counter.thisYear;
```

You can also use:

```dart
await counter.amountThis(TimeSpan.day);
await counter.amountThis(TimeSpan.month);
```

---

#### 📅 Read Specific Time Buckets

```dart
final value = await counter.amountFor(TimeSpan.year, DateTime(2022));
```

Works for any `TimeSpan` and `DateTime`.

---

#### 📈 Get Summary of All Current Spans

```dart
final summary = await counter.summary();
// {TimeSpan.year: 12, TimeSpan.month: 7, ...}
```

---

#### 🔢 Get Total Accumulated Value

```dart
final sum = await counter.total(TimeSpan.day); // Sum of all recorded days
```

---

#### 📍 View All Non-Zero Buckets

```dart
final map = await counter.all(TimeSpan.month); // {5: 3, 6: 10, 7: 1}
```

Returns a `{index: value}` map of all non-zero entries.

---

#### 🚩 View Active Dates

```dart
final days = await counter.activeDates(TimeSpan.day);
```

Returns a list of `DateTime` objects representing each tracked entry.

---

#### 📈 View Max Value in Span

```dart
final peak = await counter.maxValue(TimeSpan.hour);
```

Returns the highest value recorded in that span.

---

#### 🔍 Check If Any Data Exists

```dart
final exists = await counter.hasAnyData();
```

---

#### 🧼 Reset or Clear Data

```dart
await counter.reset(); // Clears all spans
await counter.clear(TimeSpan.month); // Clears only month data
await counter.clearAllKnown([TimeSpan.year, TimeSpan.hour]);
```

---

#### ❌ Permanently Remove Data

```dart
await counter.removeAll();
```

Deletes all stored values associated with this key. Use this in tests or during debug cleanup.

#### ⚡ Optional `useCache` Parameter

Each utility accepts a `useCache` flag:

```dart
final counter = ActivityCounter(
    'user_events',
    useCache: true // false by default
);
```

- `useCache: false` (default):

  - Fully **isolate-safe**
  - Reads directly from storage every time
  - Best when multiple isolates might read/write the same data

- `useCache: true`:
  - Uses **memory caching** for faster access
  - **Not isolate-safe** — may lead to stale or out-of-sync data across isolates
  - Best when used in single-isolate environments (most apps)

> ⚠️ **Warning**: Enabling `useCache` disables isolate safety. Use only when you're sure no other isolate accesses the same key.

---

## 🔗 License MIT © Jozz

<p align="center">
  <a href="https://buymeacoffee.com/yosefd99v" target="https://buymeacoffee.com/yosefd99v">
    ☕ Enjoying this package? You can support it here.
  </a>
</p>
