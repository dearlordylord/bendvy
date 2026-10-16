# Independent family successor oracle

Application freeze `aed70b746`; core dependencies `21ddb0860`. All 45 Bend
and two CNI source entries in the application's manifest were checked against
committed blobs and materialized in this isolated worktree. `bindings.json`
retains their complete hashes. Only this new oracle directory is committed.

The author is independent of core, application and observer authors. No backend
output, emitted backend source, or other author's oracle was consulted. This is
finite source derivation, not execution evidence or proof. The model reuses its
own earlier formatting helpers and scenario logic after inspecting the new
family call chain; it does not consume earlier expected output bytes.

`derive.py` models resource Product.Owner(sentinel, Log), leaf Stream, shared
FR.State journal, unit family owner, family frameStart and Route runtime tick.
Unlike the earlier single runtime observation, every snapshot now emits the
complete family stream and shared journal separately. Stream provisioning derives
the cargo:manifest domain from Setup.leaf. under_resource only changes the log
lens; the sentinel remains intact. Both registry and reader identities are
checked against the same fresh World namespace 1; registry cursors stay zero.

The standalone publisher stages an action. Success appends the single owner and
its ID through the resource lens; failure returns manifest 22 without changing
the log. with_world increments Route.tick and synchronizes newly published IDs
into both Stream and shared journal. Reads increment tick and preserve returned
Args on semantic failure, while reconciliation restores the old selected-stream
positions plus lazy activation. Reads emit no IDs, so synchronization adds no
journal entries. Fast retry sees A twice across failed/successful attempts;
slow sees A then C, with prepended history C,A.

Frames update both stream and family frameStart without incrementing runtime
tick. Stream's previous frameStart becomes boundary; active reader cursors hold
retention. leaf_retain filters the shared journal by droppedThrough. First frame
keeps A; second retires A and keeps C; third retires C. Retirement preserves
Log.next. Shutdown returns D, clears log rows, stream batches, shared journal and
World events, while preserving every reader position, next ID, frame field,
droppedThrough and tick. FR.State owners is exactly Unit throughout.

`python3 selftest.py` verifies separately stated tick/frame/owner/cursor matrices,
shared journal conservation and literal formatting. `python3 derive.py`
regenerates all 13 snapshots, state trace and deterministic gzip. Report LF plus
single IO.print LF yields two terminal LFs, as primary Base C/JS effects specify.

Raw: 10,193 bytes, SHA-256
`ea241c813038c75124f8492f31cc18445a572b2ff607f511bbfea4f562982e17`.
Gzip: 807 bytes, SHA-256
`d993601940c943684ef30b046412f51581d9a97cd02eb7106612625d7873dd35`.
