# Independent event scenario oracle

This oracle was authored before the first scheduled consumer backend capture.
Each of the eight lines starts with a newly allocated primary log identity and
then a distinct foreign log identity. Allocation uses the existing monotonic
host allocator. The primary identities are 1, 3, 5, 7, 9, 11, 13, 15.

Setup publishes payload 90 as row 1. The retained reader starts at cursor 0.
The future reader starts at cursor 1. A third retained reader is held by admin.
The foreign token comes from actual creation of a second log and registration
there. World system IDs are publisher 1, fast reader 2, slow reader 3, admin 4,
peer 5, and slow-reader condition 6.

| Pass | Publisher | Fast reader | Slow reader | Admin |
| --- | --- | --- | --- | --- |
| 1 | Publish 101 and 102 as rows 2 and 3, then return error. | Yield row 1, return error, retain cursor 1. | Condition false, token stays at cursor 1. | Foreign removal refuses and returns token. First update retains rows 1 to 3. |
| 2 | Publish 103 as row 4. | Yield row 2, cursor 2. | Condition false, token stays at cursor 1. | Second update returns rows 1 to 3 as actual owners. |
| 3 | Idle. | Clamp cursor 2 to dropped row 3, report one missed, yield row 4. | Resume at cursor 1, report two missed, yield row 4, return error. | Remove third reader and retain the returned token. |
| 4 | Idle. | Empty at cursor 4, no missed rows. | Empty at cursor 4, no missed rows. | Shutdown returns row 4 and closes the log. |
| 5 | Publish 104 refuses and returns its actual owner. | Closed refusal retains cursor 4. | Closed refusal retains cursor 4. | Registration refuses because the log is closed. |

Publisher history has five entries and one refused payload 104. Fast reader has
five body invocations. Slow reader has three body invocations. The condition has
five invocations and peer has five invocations. Handler capture 701 survives
three returned body errors. Admin retains actual rows 1=90, 2=101, 3=102, 4=103,
the removed token, and the genuine foreign token. No row remains in either the
owner log or its canonical Data cache. The log's next ID is 5, next reader ID is
4, dropped-through is 4, and active readers are empty.

Observation consumes each actual returned payload through the schema projector
twice, threading its owner between reads. Thus `104/104` and each retired row's
two values describe reusable returned owners. They do not claim an IO finalizer.
Both nominal schemas and both payload categories have the same semantic trace.
The serial and native schedule entries admit the same complete canonical report
ordered by registered system ID. Body code performs no IO effects; the driver
prints exactly one line per independently executed scenario.

The metadata comes from the same canonical builder program. Publisher and admin
use the actual resource slot exclusively with Writable permission. Both readers
use its cached Data view with the current canonical Exclusive and ReadOnly
metadata. The physical family owner stays serialized, including overlapping
readers. This metadata expectation was corrected against the actual canonical
LayoutAccess.resource_read source after the first backend diagnostic exposed an
incorrect SharedView assumption. All semantic observations were already fixed
before capture. There is no second
event conflict catalog. Publication is observed before any structural barrier.
