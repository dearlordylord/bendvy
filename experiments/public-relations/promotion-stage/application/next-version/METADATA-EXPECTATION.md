# Retained initial oracle failure

The admitted V3 run `application-1791375139683468576` failed after the normal JS process exited successfully. All 22 public application objects matched the actual TS/model objects, but the scalar physical expectation assumed unchanged clock 0 and stamp `3:0:0`. The observed queued-1 World has clock 1 and stamp `3:0:1`; no Native or mutation subject ran in this attempt.

Current `Cmp.tx_set` dispatches through `stamped_allowed` to `stamped_world`. The latter calculates `stamped_tick(clock,True) = clock+1` and applies `Col.mark` to the owning component column. Existing presence retains added 0 and records changed 1. Subsequent graph operations preserve this clock; cleanup removes the stamp when component 3 is cleared. The actual setter-omission mutation does not advance it or create a stamp.

V4 therefore fixes only those exact physical expectations. Retrospective parsing of the retained JS output matches all 22 corrected records. This is not a new execution result. `tx_written` records the previous payload and stamp; its inverse restores both while World clock remains monotonic, consistent with the World source comment that failure can leave unused positions. This source trace does not replace the mandatory forthcoming actual failed-system rollback checkpoints.
