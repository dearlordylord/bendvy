# Allocator oracle correction

The first whole consumer failed because the recovery oracle expected entity 2. Pinned `Command.ts` lines 497–508 calls allocateId when queuing spawn, before execution; `internal/world.ts` lines 316–319 increments nextEntity. Expected failure and thrown defect discard their queued commands but do not refund these reserved IDs. Therefore the successful recovery spawn is 4: initial success reserves 1, failed system 2, defect 3, recovery 4. Only the recovery spawn effect and dump ID changed, each 2→4. No expected value was generated from the consumer output.

The entire failed receipt, raw output/error and original five input files remain under history/initial-allocator-oracle. A focused whole-consumer rerun tests the corrected oracle; the earlier failure remains INCOMPLETE. This documents the TS reference, not a new Bend ownership/rollback contract.
