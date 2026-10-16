# Persisted changed-stamp omission countermodel

The single source mutation changes lifecycle.written for an already-present
component to retain its old changed tick. New insertion still initializes both
ticks; cleanup still resets both. Column's ordinary/indexed/prepared write routes
call lifecycle.after_write, which reaches this branch on gameplay replacement.
The observer and gameplay writes themselves are unchanged.

The independent metadata transition model retains all position/health payload
updates and World clock advances, but preserves each existing stamp. Thus every
nonzero stamp keeps changed=added until cleanup. All registry cursors, World
metadata, commands, hit/death events, failure/retry journals and outputs remain
normal. Comparing complete structured models shows exactly56 changed-stamp field
differences across both fourteen-phase schemas, no other differing field.
Removing new observations reproduces the full prior source model in both cases.
The counter is96,998 bytes; it differs from the97,054-byte normal full oracle.
Constructor paths are unchanged by the isolated source-root relocation.

No candidate runtime output was consulted. This model predicts the compiling
source defect, not an observer-output deletion. It does not itself establish
that the actual compiler reaches the mutation; complete runtime comparison and
normal-baseline rejection remain coordinator gates. Normal source and oracle
stay immutable. Private allocator-layout limitations remain as documented in the
normal derivation.
