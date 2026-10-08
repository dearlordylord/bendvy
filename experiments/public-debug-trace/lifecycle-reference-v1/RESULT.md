# Observed pinned TS subscriber lifecycle

Owning ticket: #57. The five-second development preflight passed on Node
24.20.0 / CPU5 against bevy-ts3040a3b2. The complete six-phase output matches
the independently preauthored oracle; stderr is empty. The original receipt,
stdout and stderr are retained in `evidence/`. Only elapsed `ms` is normalized.

Observed: duplicate registration of the same callback delivers once, the first
stop removes that shared callback while another listener stays active, the last
stop ends delivery, resubscription works, a collector reset clears only its own
journal, and repeated stop is idempotent. Both journals and complete world dumps
are checked after every frame; the Counter resource remains9 and the world tick
remains0 because these schedules contain no systems or barriers. The public
debug keys include no reset method. A runtime created without debug has no handle.

This uses the existing central runner and cheap development preflight. Its
source inventories, command, tools, environment hash and raw hashes are retained,
but the original environment and reference checkout are not a portable delivery
capsule. Re-execution creates a new development observation; it does not replace
this historical receipt. No ordinary resolver discovery or backend gate ran.

The empty-schedule consumer does not qualify system writes, skips, failures,
barriers, relation effects, transitions, restore, subscriber mutation during
delivery, listener exceptions, Bend callbacks, ECS reader noninterference or
enabled/disabled timing. Those remain under #57 and its existing prerequisites.
