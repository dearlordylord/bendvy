# Basic restore: pinned TS development reference

Actual Node24.20.0, pinned bevy-ts3040a3b2, two nominal schema roots. This reuses
#58's constructed/transient descriptor fixture style and pinned core entry.
The independent Python source model generated `expected.json` **before** Node
execution; it imports no TS implementation and reads no observed output.

The first Node invocation passed whole type-sensitive output comparison:
47,826 raw stdout bytes, SHA256
`f1cdcad71dac9cb4331c0e330cf6c97854a8c0f088a31ab35ad206edac502f56`;
empty stderr. Pre-execution expected SHA256:
`0261d40fbde06a75e32287fefc45f06b9533650286daf32bfd76730d2271678f`.
Raw streams were recorded before comparison. The receipt binds the fixture,
model/expected, actual Node/taskset/runner/helpers, complete pinned core source
membership/bytes, relevant configuration and the explicit environment.
The actual child alone held the shared lock, CPU5/cap5, with post-acquisition and
unconditional source/config/raw postguards. A missing parent output directory
was repaired before any Node child; there was no failed Node execution or cap raise.

Twenty rejection cases per root cover root/version, required fields, IDs,
component/relation/resource/machine paths, duplicate entity precedence,
first unknown name versus later duplicates, name/value authored order,
transient/unknown descriptors, and late resource validation after valid staging.
Every rejection includes the complete snapshot, Debug dump, pending commands,
stream/reader status, and prior watch/slow histories, equal to the initial state.
Duplicate object keys are not a new policy here: inputs are ordinary unique-key
objects. “Name precedence” means ordered distinct descriptor entries.

A watcher subsequently sees the event that rejection did not consume; the slow
reader remains behind. Successful restore clears four pending reserved spawns
and the event backlog, retains transient Cache and omitted Spare, replaces Score,
and removes transient Scratch from rebuilt entities. Existing watchers observe
ordinary added/despawned records; histories and registrations persist. The prior
allocator is7, saved next is2, and next successful spawn is7. The old same-world
id1 handle resolves the restored entity; id2 and canceled reserved ids3–6 are
MissingEntity. **This TS observation does not approve Bend stale-handle semantics.**

Scope is source-current TS development reference. No Bend implementation, #59
closure, runtime Local/capture preservation, actual failed-system retry, arbitrary
Type construction, graph/machine restore, intended negative or reached restore
mutant, Native, full installed-tool or performance qualification follows. The
current four-field Bend snapshot envelope/factory/identity gaps remain recorded
in the existing #59 document. The receipt contains original absolute paths; this
is not a portable clean-checkout or relocated source qualification packet.

The retained run used `run.py evidence/attempt-1`; do not overwrite that evidence
or rerun unchanged merely to review it. No-child review can compare the retained
raw and independently generated expected via `run.strict` after checking receipt
hashes. Any fresh development run requires a new output directory.
