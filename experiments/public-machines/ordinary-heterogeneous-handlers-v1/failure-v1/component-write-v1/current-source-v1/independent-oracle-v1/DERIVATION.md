Independent historical-oracle adoption for producer 137f83971, FirstTransition
component-write fixture only. Complete 29 literal Bend bodies were independently
traversed and checked against SOURCE-FREEZE.json before immutable copying. The
six original fixture bodies were checked against the historical tracked-cursors-v2
SOURCE-BASIS hashes, then all six successor bodies compared with them. Main,
application, lenses and types are import-only changes. Systems adds exhaustive
InitialEnter arms, observer adds Initial rendering plus Stream.snapshot lowering.
No candidate/backend/generated output was consulted and no backend was run.

The historical pure Python model is retained exactly and independently executed;
its expected() reproduces all 24422 old golden bytes, SHA256
dfa63c0ed3b258d70c6622b4befd51a6ed1f1b319e718cf96f68b080fc2ff66d.
Historical oracle path is recorded in source-freeze.json. This leaf retains the
complete rederived bytes and gzip, not only a checksum or normalized projection.

Actual main executes before, queue, first marker failure, first reader before
retry, first retry, second marker, first reader, second reader, later first
marker, later second marker, then Factory:2. Construction uses actual factory
namespace 1 and preserves both typed machine owners and concrete affine arrays.
The queued first Cold→Warm and second Idle→Active7 are normal pending intents;
H.prepare constructs Transition, never Initial. Consequently all new Initial,
InitialReady and InitialEnter branches are unreachable here. Existing normal
phases, handler membership, order, committed prefixes and failure requeue arms
remain unchanged. This does not claim initialization behavior or two schemas.

All callbacks call actual Component.tx_set on the first column and entity1,
writing machine*10+phase to its affine payload; sibling column/resource remain
observed. First Exit commits cell11/stamp1/clock1, resource22 and one pending
closure. First Transition touches its Local then tentatively writes cell12 at
stamp2/clock2 and captures the complete tentative column. Transaction failure
undo restores cell11/stamp1/resource/trace while clock2 and Local survive; no
transition publication, command or event from the failed callback is committed.
Its registry cursor remains0. Retry commits Exit/Transition/Enter at clocks3/4/5,
then the second machine at clocks6/7/8, final column23/stamp8. The complete model
retains actual registration cursors, readers, ordered streams, delivered payloads,
Local arrays, World/component/resource/metadata, statuses, pending/applied closures
and sibling state. Later markers flush the eight successful deferred closures.

Shared changed core files are machine/handlers/handler-bundle/handler-phases
(additive Initial paths), World (tail accumulator preserves pending order/count),
and Stream plus new private queue. This fixture never invokes Stream.frame,
skip or initial: publish/read/open/finish semantics and snapshot chronological
front++reverse(back) lowering reproduce the old complete logical stream exactly.
Ordinary-machine-handler-bundle, Component.tx_set and its transaction/lifecycle
bases retain their historical body hashes. No component undo behavior is inferred
from unrelated resource/event/pending mutation controls.

The entry returns List<String>. Pinned Base List.show and compiler show_val emit
the same bracketed quoted strings with comma-space separators and one CLI LF;
there is no IO.print in this entry. selftest.py checks full source pins, reached
operation anchors, failure rollback/clock distinction, final column/stamp and
pending/application state, all ordered labels and exact historical full bytes.
This is bounded source applicability, not universal proof or backend acceptance.
