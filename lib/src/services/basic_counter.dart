import 'package:prf/prf.dart';
import 'package:synchronized/synchronized.dart';

import '../core/base_counter.dart';

/// A simple persistent counter with no expiration or periodic reset.
///
/// `BasicCounter` lets you increment, reset, and query a counter value
/// without worrying about time windows, periods, or rollover logic.
///
/// Example:
/// ```dart
/// final counter = BasicCounter('my_counter');
/// await counter.increment();
/// final value = await counter.get();
/// print('Current count: $value');
/// ```
class BasicCounter extends BaseCounterService {
  final Lock _lock = Lock();

  /// Creates a [BasicCounter] with the specified [key].
  ///
  /// Optionally, enable [useCache] for in-memory caching (non-isolate-safe).
  BasicCounter(super.key, {super.useCache}) : super(suffix: 'basic');

  /// BasicCounter never expires.
  @override
  bool isExpired(DateTime now, DateTime? last) => false;

  /// Resets the counter value to zero.
  @override
  Future<void> reset() => _lock.synchronized(() async {
        await Future.wait([
          value.set(fallbackValue()),
          lastUpdate.set(DateTime.now()),
        ]);
      });
}
