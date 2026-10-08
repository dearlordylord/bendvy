# Complete decoding candidate

`decode.bend` preserves the canonical typed decoder's nominal Raw/Codec types
and affine owner receipt. `decode_owner` projects the actual owner once, derives
fuel from that same Codec and Raw, then uses the existing validation and
canonicalization functions. It supplies no inverse from Raw to arbitrary Type
payloads and adds no fixed item/depth limit or error-policy change.

The structural budget is `4 * C * (R + 1)`: C counts codec constructors plus each
NamedCodec entry; R counts every Raw constructor, including all array/object
values. Each codec occurrence can be applied across actual Raw occurrences or
synthetic Missing. Struct counting reconstructs its list tail: the empty tail
counts the original Struct node once, and each nonempty step counts one
NamedCodec entry plus its child codec. The factor four conservatively covers
validation work and canonical container-tail traversal. `1n++more` consumes
one successor and marks `more` reusable; it does not consume two successors. This is design reasoning,
not an approved universal theorem or proof. Counts use direct structurally
recursive nested patterns; reconstructed container tails are accepted by the
installed checker. No unsafe definitions or forward semantic laws are used.

`controls.bend` describes eight complete application observations with actual
affine owners, original descriptions and full sentinel arrays. It covers
arrays of 3/128/256, an invalid item at 127, a 64-field struct plus an unknown
extra field, nullable null, nested valid arrays and a missing nested integer.
`bounded-controls.bend` uses the identical scenarios with the old fuel128
entrypoint. Independent complete oracles and actually observed TS behavior are
owned by `oracle-v1`; exact representation differences remain explicit.

The older `bounded-counterexamples.bend` includes a duplicate Raw field as a
separate historical diagnostic. It is not a public TS-object parity scenario
and selects no new duplicate-key contract.

`source-history` preserves failed counting approaches, parser mistakes and the
successful structural-count/full-application checks. Unsaved source snapshots
are absent, not reconstructed or assigned to old observations. These are
five-second development checks with telemetry disabled and child-only shared
lock, not a full frozen tool/environment qualification. The check banner does
not prove every ECS behavior.

`development-run.py` is the direct paired JS application seam using central
Runner, complete oracles, immutable sources/installed Base/tool binaries,
private environment, raw logs, post-lock guards and unconditional final receipt.
Its checks grant development semantics only. Full source/current controls,
Native, portable delivery, regression and feature-specific equivalent-work
performance qualification remain separate acceptance conditions. Existing
historical packets and `src/ecs` are not changed by this candidate.
