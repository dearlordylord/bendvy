# Source-only TS JSON observation correction

The initial TS oracle incorrectly treated the top-level `target` like the selected
nested fields passed through `clone()`. Original models, plans and the failed
execution receipt remain immutable. This additive successor changes only the TS
serialized observation; Bend common/Whole models and all ECS contracts are unchanged.

Frozen `reference.mjs` initializes `spawnedId` without a value and assigns it only
after successful `Command.entryRaw`. It returns `target: spawnedId?.value` for
Spawn directly, without `clone()`. `observation-reference.mjs` keeps that trace
inside the full supplement. Frozen `trace-entry.mjs` then uses plain
`JSON.stringify(run())`, with no replacer. Consequently unsuccessful Spawn retains
an own JavaScript property with value undefined before serialization, but that
property is absent in the JSON wire object. This follows
[SerializeJSONProperty](https://tc39.es/ecma262/multipage/structured-data.html#sec-serializejsonproperty)
and [SerializeJSONObject](https://tc39.es/ecma262/multipage/structured-data.html#sec-serializejsonobject):
an undefined property serialization does not contribute an object member.

By contrast, `clone(checked)`, `clone(incoming)`, debug snapshots and explicit
receipt clones use the local replacer that converts undefined to `{undefined:true}`.
Those markers remain fully represented, including the nestedMissing validation
error's actual value. Resource target is explicitly null; Insert target is1;
successful Spawn target is2. None of those properties is omitted.

The v2 neutral model represents the exact JSON observation rather than inventing
an unavailable JSON property. Only the two `value.ts.target` keys at full32 indexes
11 (Workshop Spawn lateInvalid) and15 (Workshop Spawn nestedMissing) are absent.
Restoring those two historical marker values makes the entire successor model
equal to the old complete model. No other field/value/type/order changes; all32
public views remain equal to the complete common oracle. The exact byte reduction
is derived from the two removed JSON members, not measured subject stdout.

`ts-serialization-v2.py` derives the successor from pinned prior independent model
source. It never reads execution/checker output. `ts-source-basis-v2.json` binds the
same frozen subject/reference/core sources and final plain-stringify entry, the
historical model files, successor files and exact source delta. Three portable
Python full-model/presence/byte-delta tests PASS. The portable built-in-only Node
control PASS under CPU5/sharedlock/cap5 distinguishes plain omission, cloned marker,
null, number and array behavior; it imports and executes no ECS/subject code.

The original Node exit and collector failure are not retargeted or changed to PASS.
This correction does not authorize a replay. A separately guarded comparison may
join retained raw to the frozen successor; any fresh plan requires coordinator
admission. No source optimization, initialization/ownership policy, timing credit
or Native/Bend qualification follows from this TS serialization correction.
