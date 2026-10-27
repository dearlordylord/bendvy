# Canonical condition registry IO

The condition registry owns each actual guard and its retained Compilation in a
`Scope.CompiledBinding`. A leaf dispatch checks the requested registration ID,
then passes that Compilation and owner to `Sys.run_retained_compilation`. The
returned IO value includes the Compilation, actual System owner, and World before
its completion is translated to `Completed`, `BodyError`, or `AdmissionRefused`.
The adapter retains Local, cursors, World writes, and the captured tick. The
System kernel owns namespace, registration, supported-compilation admission,
clock entry, opaque permit qualification, and issuer service.

`execution-condition-registry.Registry<World,Owners,Error,dispatch>` stores
`owners`, the derived `nodes`, and `invalid`. Its dispatch has type
`Owners -> World -> U32 -> IO(Owners & (World & Invocation<Error,Bool>))`.
`Selection` exposes retained typed leaves, product joins, and empty registries.
`compile` interprets the selection with `compile_retained_leaf`. Admission derives
requirements and read-only permission from the actual retained Compilation.
Unsupported compilation marks the condition invalid. Product dispatch retains
the unselected affine sibling. Registry admission and dispatch do not recompile
the framework declaration.

`leaf`, `paired`, and `empty` are the public selection helpers. `leaf` accepts a
`RetainedSystem` and an erased construction Compilation. The factory supplies
that closed witness for the capability specialization. The actual runtime
Compilation remains inside the binding through success, body error, and refusal.
The witness is a trusted construction boundary, not a proved theorem that every
runtime Compilation equals the witness. `System` names the actual owner component
inside `RetainedSystem` and carries its closed `FrameworkProgram`.

`RetainedLeaf`, `RetainedSelection`, and `compile_retained` name the same retained
interpretation for existing callers. Empty selections keep their `Unit` inventory
and `empty_dispatch`. Root application parameters remain unchanged. The raw-owner
leaf compiler and dispatch adapters, and the separate parallel-registration
`condition_registry` adapter, have been removed.

The registry uses the same IO Ready/Deferred scheduler as ordinary applications.
The scheduler awaits conditions before classifying enabled, disabled, and error
status. False conditions do not dispatch the system body. Whole-application
Finished maintenance remains outside this adapter.

The generic pure `dependency-registration` remains for legacy Data dispatch.
Its registry/composer selection embeds an already constructed pure registry or
joins and empties it. It has no System, partition, or root-cut adapter. Historical
fixtures using those legacy modules do not qualify this condition registry.
