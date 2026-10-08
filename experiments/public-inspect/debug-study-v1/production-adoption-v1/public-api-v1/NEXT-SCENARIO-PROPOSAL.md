# Next independent application scenario — disabled Description projection

Source proposal only. No new timing run, core write, ownership policy, runtime toggle or full #56 claim.

Pinned bevy-ts `packages/core/src/Runtime.ts:1858` returns the ordinary runtime immediately when creation-time `debugEnabled` is false. Lines1862–2005 build debug names/hooks/handle only after that branch; line2005 attaches `debug: handle`. `describe` is called by the enabled handle at line1974. This is a creation option, not a live on/off toggle. Current detached dump16 already uses the approved functional disabled/no-projection direction, but its TS branch was adapter-disabled under `debug:true`; it is not evidence for an actual `debug:false` Runtime.

Proposed complete scenario: create two actual same-schema application worlds independently, one enabled and one disabled, using the current public canonical factory/client and the same three real registries/two Provisioned schedules. A closed owner-returning projection over their full affine context calls the existing registered/Description route. Its invocation count is kept separately from ECS owners. Disabled dispatch returns the entire context and no description without invoking that projection. Enabled dispatch produces the unchanged complete two-case Description DTOs; repeating it produces identical DTOs while returning all owners. No body execution, reader registration, queue flush, service capture or nonempty When is needed.

Independent oracle before output:

| Mode and observation | Projection calls | Description result | ECS invariants |
| --- | --- | --- | --- |
| Disabled, first request | 0 | None | Complete World, three Registry owners and both Provisioned owners equal their original snapshots. |
| Disabled, repeated request | 0 | None | Same full owner/namespace/cursor/clock/pending/marker observations. |
| Enabled, first request | 1 | Exactly current normal two-case DTOs | Same full owner observations; projection counter is separate instrumentation. |
| Enabled, repeated request | 2 | Identical complete DTOs | Same full owner observations and cursor values. |

Actual pinned TS reference must construct `Runtime.make({debug:false,...})`, assert no own `debug` property, and compare its provided resource/machine values before/after ordinary construction/control observations. The enabled reference constructs `debug:true`, performs complete repeated `describe()` calls and retains full normalized before/observed/after DTOs and real distinct identities. TS absence and Bend None are an explicit typed API mapping; no nonexistent disabled TS dump/describe invocation is invented. The before/after owner projections in Bend are harness observations, not hidden work inside disabled debug dispatch. This is functional no-description-work evidence, not a zero-allocation or performance claim.

Before implementation, the reviewer should confirm the exact closed gate shape against the existing no-projection direction. Then freeze literal complete output oracles and affected typing/authority controls; execute cheap actual TS/default IO preflight before JS/Native receipts. No output-derived expected values or reduced owner traces. Feature-specific overhead stays deferred under CPU contention, as issue56 requires.

Other concrete issue56 obligations remain independently visible: full population/dump format (version/frame/tick/entityCount/relations/machines/pending command origins), graph and transient/plain observations, naming aliases and identity replacement, reached filter/noninterference controls, and enabled overhead. Existing world tick, schedule name, queued-count or caller-authored label must not be guessed to equal a private TS runtime frame, object identity, pending-origin ledger or callable permission. #55 supplies machine integration; #50/#53 still own callable/capture policy. Nonempty When is not selected here because there is no adopted generic metadata+requirements condition facade. Advancing this scenario does not silently narrow or close #56.
