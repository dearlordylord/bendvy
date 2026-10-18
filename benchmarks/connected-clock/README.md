# Connected elapsed clock

Harness-only IO effects `begin` and `end` use CLOCK_MONOTONIC on Native and process.hrtime.bigint on JS. Begin returns zero; end returns only the elapsed nanoseconds after checking0..2^48−1. Absolute host time never crosses Bend's48-bit immediate-Nat boundary. Nested begin, unmatched end, clock failure/backwards movement and overflow fail explicitly. The implementation reuses the existing feature timer's monotonic start/end approach, without capture, hashing, buffering or flushing output.

The Dense64 fixture consumes this clock. Its full forcing IO stays inside the interval; final transport stays outside. Nanosecond units do not claim one-nanosecond effective accuracy. A20ms IO.sleep control checks units; unmatched-end/double-begin controls check the state guard. Source checks do not qualify the new foreign implementation: all actual execution waits for the frozen batch review.
