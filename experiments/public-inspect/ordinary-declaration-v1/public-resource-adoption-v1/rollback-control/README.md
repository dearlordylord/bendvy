# Reached rollback negative control

The consumer body is identical to the public normal consumer. Its provider body is identical to the previously qualified private rollback mutant, with only imports relocated to the current canonical modules. On Failure the transaction's undo journal is omitted before the existing finish operation; all other outcomes use the original finish path. The public module and normal consumer are preserved.

`SOURCE-JOIN.json`, `module-semantic.patch` and `consumer-import.patch` record the exact changes and inverses. Complete backend outputs must match the independent rollback model and reject the entire normal model. This control is private evidence, not a proposed public behavior.
