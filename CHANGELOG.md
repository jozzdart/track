## 0.0.2

- Imported `BaseCounterTracker` - An abstract class for tracking integer counters with expiration logic. It extends the `BaseTracker` to specifically handle integer counters. It provides methods to increment the counter, check if the counter is non-zero, and reset the counter value while maintaining the last update timestamp.

## 0.0.1

- Added `TrackerPeriod` - Represents different time periods for tracking purposes.
- Added `BaseTracker` - An abstract base class for tracking values with expiration logic.
- Added testing tools and utilities

> Notes: Originally was part of the prf package. Extracted into a standalone package for modularity, lighter dependencies, and focused use. Ideal for apps needing easy-to-integrate time-based limits without extra logic.
