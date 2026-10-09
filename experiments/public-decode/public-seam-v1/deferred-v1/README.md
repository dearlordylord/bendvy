# Deferred Decode / established abort ownership — source prototype

`request.bend` joins the actual retained constructed declaration to existing
`bundle-batch.insert/spawn`: validation runs first; a accepted packet owns original
arbitrary Type P plus canonical Data. Validation/entity refusal returns the same
P through the owned capability; no prepared entry is added on refusal. Actual
Batch handles reservation visibility, queue positions and finish ordering.
There is no generic Raw→P inverse or normalization before acceptance.

`finish` delegates to existing Batch.finish. Its failure returns original prepared
packets and rolls back through existing command/transaction machinery; success
requires a schema-authored delivery and explicit late-refusal recovery callback.
No global recovery destination, finalizer or #50/#53 policy is introduced.

`local-abort-consumer.bend` is an explicit application choice: its registered
Local retains operation outcomes and abort-returned packets. Local.Failed carries
the ordinary error while preserving that Local under approved #36 semantics.
The new route is reached through actual Local.run, opaque-H OwnedRequest and
validation before deferred spawn. Both nominal schemas source-check. Four
controls reject undeclared World access, read-grant mutation, cross-schema input
and duplication of this actual Local instance. CPU5/shared lock/cap5; raw output
retained. No backend/runtime execution or completion is claimed.

The fixture is **abort-only**: its delivery adapter deliberately refuses and is
not reached after the fixed failure. It does not qualify successful installation,
a queue commit, foreign-world behavior or a partial-write mutation. The exported
resource grant reuses Resource.tx_replace on the same Batch transaction but is
not used by this fixture; it currently has helper-source coverage only.

Existing failure obligations: #46 preserves incoming P plus world/queue at an
operation rejection. Sys.Failed does not return arbitrary Type output; explicit
Local recovery avoids changing that error contract. Resource.tx_replace journals
the old resource; rollback restores that old owner and drops the displaced
replacement. Returning the restored owner separately would duplicate it and is
not proposed. Accepted-then-aborted packets already have an explicit return path
in Batch.Failed, distinct from publication cleanup policies.

Next: supply successful typed component delivery with reversible packet recovery,
join this operational descriptor with ordinary declaration-derived registration,
compose the actual resource grant with declared resource identity, and exercise
resource rollback plus complete 32+12-extension observations and reached mutants.
Independent whole models and reviewed backend admission follow that full assembly.
