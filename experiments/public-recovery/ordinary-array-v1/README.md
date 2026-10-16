# Ordinary recoverable Array resource operations — #52

First source candidate; complete backend qualification remains pending. The ordinary
constructor takes a resource identity and rank-2 body, derives its canonical World
resource split and typed recovery collector internally, and registers normal ECS
access metadata. Gameplay sees only replacement and bounded element-exchange grants.
It cannot author an inverse, obtain the journal, or supply a destructive mutation
callback. Raw Frame, journal records and Product.Lens helpers remain trusted engine
administration, as with raw World constructors; no language-wide constructor secrecy
is claimed.

Each canonical action keeps the original affine owner. Every action executes on
commit or rollback: success returns displaced originals, failure restores originals
and returns displaced replacements, in authored operation order. The semantic error
and typed recovered owners travel outside the transport's discarded-error output.
Ordinary refusal returns the original Args without invoking gameplay. The caller
observes each actual returned owner and explicitly releases it afterwards; no
implicit finalizer or physical-memory identity claim is made.

Two nominal schemas use `Array<Array<U32>>`: elements are affine Type owners.
The body performs complete replacement, index-1 element exchange, another replacement,
and refused index-99 exchange. The full trace covers earlier commit, failure, failed
retry, successful retry and an independently created foreign World with a genuine
colliding registration. Every input, output, recovered record and current resource
cell is observed, along with complete World metadata/live fields and actual registries.
There are no pending commands here; count zero is not a deferred-effect witness.

Reference basis: pinned Bend a950fd68 Base Array.swap accepts arbitrary Type and
returns the displaced owner; its masked index is guarded by the ordinary operation's
size check. Rust Bevy ad678262 ComponentEntry.take returns actual component ownership;
this does not imply automatic transaction rollback in Bevy. Existing #70 replacement
rollback drops displaced owners, so it cannot substitute for this return-all journal.

Only declared pure ECS exchanges are recovered. Host IO, arbitrary destructive
callbacks and automatic effectful finalizers are outside this API. Normal #50 capture
persistence is unchanged. Component operations, explicit opt-in captured recovery,
authority controls, reached mutation and joined #52 acceptance remain within #52;
this first resource consumer does not close or narrow the issue. No new law is asserted.
