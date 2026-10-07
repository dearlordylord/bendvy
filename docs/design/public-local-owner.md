# Public affine Local execution policy (#36)

Explicit user confirmation received: “Да, Local сохраняет изменения при ошибке”.
This confirms per-instance affine Local persistence after failed system execution,
independent transactional World rollback, unchanged Local on skip and owner disposal.
This approval covers the executable Local contract, not new ECS proof laws.

Implementation policy selected under the user's explicit blanket task preapproval
("делайте таски я пре-аппрувлю всё") and the requested simple Bevy-like approach.
This authorizes the executable policy, not exact ECS laws or new proofs. The earlier pending question is historical; the selected contract is recorded in
[public-local-policy.md](public-local-policy.md).

Each actual registered instance owns one affine Local value, even when multiple
instances share the same closed runner. Success and failure return that owner;
returned Local changes persist after failure. A conditional skip invokes nothing
and preserves Local. World transactions continue to roll back their own writes,
commands and publications independently. Local state is instance-owned, distinct
from lexical captures and host IO; arbitrary destructive Type/IO recovery is not
promised. Foreign-world refusal returns World, instance/Local and affine arguments
without invoking the runner. Successful disposal unregisters and consumes Local
once; rejected disposal returns the instance owner for a valid-world retry.

Pinned Bevy Local is per-instance mutable SystemParam state. This supplies the
lifetime/identity analogy, not parity with Bendvy's World transaction protocol.
Pinned bevy-ts has no dedicated Local API: the oracle explicitly uses two
per-instance state arrays in a documented adapter around actual registered TS
systems. No API parity, Local rollback theorem or universal refinement is claimed.

A closed gameplay Local provider uses a universally quantified owner type and
explicit read/replace operations. Registry/World transport and transaction
orchestration remain trusted, as with the existing public System runner seam.
Application callbacks cannot treat the abstract provider owner as a public
concrete Local cell or acquire another declared instance's owner from it.

Local.run validates actual registration/namespace and threads Local through the
closed runner. It does not magically roll back arbitrary raw runner mutations
or host IO. The admitted runner uses the existing World transaction journal and
finish operation for actual resource writes and rollback; gameplay Local access
is supplied through the rank-2 provider. The TS adapter's active-registration
map and disposal are explicitly adapter behavior, because upstream exposes no
matching Local/disposal API; resource failure rollback is actual TS execution.
