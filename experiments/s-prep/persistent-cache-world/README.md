# Persistent cached World — bounded two-tick integration probe

Private world Main/Ledger parameters are genuine Cache<Raw:Type,View:Data> wrappers
that remain in the actual indexed columns and Ledger across two explicit transaction
ticks. Both original byte-identical callbacks run through opaque X.Tx token-specific
point providers. Cache initialization calls complete original getters inside fixture
construction, before the observed initial checkpoint; no initialization cost is
excluded or performance measured.

Tick1 commits original Main/Ledger swaps, pending Flag command, ping11 and actual
Main mark at9. Tick2 interleaves further Main/Ledger writes, stages Despawn/ping12,
and fails: actual X.tx_finish_failure/unwind restores raw and cached11/101 together,
preserving tick1's pending command/mark and discarding failed publication. The
same Type wrappers persist; they are not rebuilt at query entry.

Every initial/post-tick full world checkpoint is observed through cached getters
and independently through original uncached raw getters. Both schemas compare all
four Main/Ledger cells, component metadata, Type Aux, flags and effects with fresh
pinned bevy-ts. Bend authority/high-water/added/changed/pending positions are checked
independently; no equal TS epoch is invented. These are explicit X.Tx lifecycle
ticks, not a completed dispatcher/schedule/reader integration.

Stale cache/raw-cell3 corruption must compile and fail observations on NativeO3
and JS. Intended affine/access controls must reject. Public forged Cache and
arbitrary raw transform controls falsify unconditional cache claims separately;
LAWS-DRAFT.md states unapproved candidates with exact trusted preconditions.

Growth, raw command/bundle wrapping, optional branches, general transform refresh,
reader policy, query traversal and actual applyDeferred remain unresolved follow-ups.
Fixture creation uses actual rows_place with trusted complete cache initialization;
it is not a new general world factory. No proofs, approved laws, numerical threshold,
performance, cache correctness theorem or production adoption is claimed.

Replay committed inputs with existing tools/references and a fresh artifact path:
`BENDVY_CPU=5 BENDVY_PERSISTENT_ARTIFACT=/tmp/fresh-persistent-cache python3
experiments/s-prep/persistent-cache-world/run.py`. Limits remain5/30/120 seconds.
The time cutoff is the assigned experiment window, not a relaxed subprocess limit.
