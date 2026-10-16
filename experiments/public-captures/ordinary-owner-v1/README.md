# Ordinary runtime capture owner — first consumer (#50)

Two nominal schemas each create two real IO Worlds and register two independently
owned capture packs. Each pack contains two affine two-leaf Arrays. Authored
rank-2 gameplay uses the ordinary Counter write declaration. Captures are returned
outside transaction Output, including failure; only the ECS resource is rolled back.

Nine complete checkpoints per schema cover successful calls, independent instances,
skip, failure/retry, foreign-world refusal, unregister/re-register and a subsequent
call using the returned capture. Both Worlds, every capture cell and instance
metadata are observed. Local's existing instance has no reader cursor. The fixture
has no entities/component stamps; empty Store, complete live array, allocator,
clock, events, pending count and complete registration metadata are explicit.
Pending is never changed by these operations. During the second instance's call,
the two owner positions are swapped in that checkpoint and restored afterwards.

Successful unregister records the returned capture and absence of its previous
registration before re-registering it with a fresh ID. This is owner recovery,
not an external-resource finalizer. Registration failure is a diagnostic empty
trace and cannot match the full independent oracle. Broader negative/disposal
coverage follows the first actual full backend pair; this fixture is not all #50.

SOURCE-FREEZE records 56 literal Bend sources and two namespace sidecars.
SOURCE-CHECK retains three pure source PASS results and the IO entry's six
foreign-dependent-definition diagnostics. The latter is not a checker PASS.
No runtime oracle/output was consulted while authoring these source files.
