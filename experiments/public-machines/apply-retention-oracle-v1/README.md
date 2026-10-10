# Independent apply-retention expectations

Source-only finite normal/drop oracle for the author's frozen `apply-retention-v1` seven-file subject. No backend output was read. The prior independent marker model d3b45ee2f supplies the unchanged physical-owner and String serializers; this model derives the new applyQueueLevel ordering independently.

Each result contains all three complete observations: initial, marker1, marker2. Physical Array trees, both slots and previous/changed/pending fields, FIFO events, World allocation/registration/clock/pending fields, actual registered-system identity/access/cursor, captured cohort, affine owner tree and status are retained. The one structural callback advances clock17 to18. Tracked successful hooks observe18; publications do not advance clock.

Normal retains the Boot40 request queued between applyFlow and applyLevel. Marker2 applies it, leaving Level Boot40 with the next Boot40 still pending. Drop deletes that request during marker1 applyLevel; its marker2 captured Level is unscheduled, so Level remains Pause30 and the newly queued Boot40 survives. No initializer, failing preparation, missing-slot, arbitrary callback identity, universal ownership, or full issue48 acceptance claim is made.

Authority order remains pinned Bevy transition phases, approved Bend affine operations and this concrete source, then TS inventory. Bevy phase ordering is recorded as reference context; cross-state callback interleaving and this retention counterexample are derived from the frozen Bend subject, not asserted as a universal Rust trace.

`SOURCE-BASIS.json` pins both successful source captures and every admitted input (including Base/compiler), plus source/printer reference basis. `ORACLES.json` gives full raw/gzip identities. `verify.py` regenerates both reports and checks pins without running Bend or a backend.
