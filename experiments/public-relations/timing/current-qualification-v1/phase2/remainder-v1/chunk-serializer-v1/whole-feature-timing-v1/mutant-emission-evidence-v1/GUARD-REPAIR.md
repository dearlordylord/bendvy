# Future failure guard recipe

The original movedwalk Native emit retains a childdeadline with pre/acquired/final named guards only. It remains incomplete. Runner itself performed source/log guards before raising, but this does not supply the missing named artifact postguard. No retroactive postguard or retry is claimed.

Future stages use existing evidence_boundary.GuardBoundary for named post and ReceiptBoundary for final/unconditional receipt. Place regular partial artifact capture in finally INSIDE GuardBoundary, so capture precedes post on successful and failed child paths. test-failure-guard-control.py patches only Runner.execute_result to a no-child partial-artifact/deadline stub: actual Runner records raw and raises TimeoutError; post/final both execute, partial hash is checked and INCOMPLETE receipt remains. This is focused metadata control, not a compiler/run or repaired historical acceptance.
