# Canonical condition registry IO

The condition registry owns its actual guards. A leaf dispatch checks the
requested registration ID, then delegates to the same `Sys.run` used by ordinary
systems. The returned IO value includes the actual System owner and World before
its completion is translated to `Completed`, `BodyError`, or `AdmissionRefused`.
This adapter does not rewind Local, cursors, World writes, or the captured tick.
The System kernel owns namespace, registration, supported-compilation admission,
clock entry, opaque permit qualification, and issuer service.

`execution-condition-registry.Registry<World,Owners,Error,dispatch>` stores
`owners`, the derived `nodes`, and `invalid`. Its dispatch has type
`Owners -> World -> U32 -> IO(Owners & (World & Invocation<Error,Bool>))`.
`Selection` exposes only actual typed System leaves, product joins, and empty
registries. It provides no callback accepting arbitrary World mutation or caller
metadata. Compilation derives requirements and read-only condition admission from
one actual closed framework Compilation per leaf. Unsupported compilation marks
the condition invalid. Product dispatch retains the unselected affine sibling.

`compile` interprets that selection. `leaf`, `paired`, and `empty` are its public
selection helpers. `System` brands the actual owner with the closed
`FrameworkProgram`; ordinary factories still accept a user Program and supply
only the trusted framework lift. The token-aware framework witness is not an
ordinary user declaration parameter.

The generic pure `dependency-registration` remains for legacy Data dispatch.
Its System-backed leaf and condition adapters were removed. The matching generic
registry/composer selection now embeds an already constructed pure registry or
joins/empties it. It has no System, partition, or root-cut adapter. Existing
canonical runtime adapters must not pretend an IO dispatch is pure.

## Integration status

The three generic pure modules pass normal source checking. The new IO module
has no parser, type, or affinity diagnostic; the checker reports its known
foreign-dependent driver/System chain. This is not a universal proof, executable
backend result, or complete GH87 acceptance.

The executor owner migrates RootApp to `Scheduled<State>` and consumes this
registry through the same IO Ready/Deferred scheduler. Conditions callbacks must
be awaited before classifying enabled/disabled/error status. False conditions do
not dispatch the system body. Whole-application Finished maintenance remains
outside this adapter.

Unmigrated callers at this checkpoint include execution-parallel-application,
execution-parallel-root-application, execution-composer-app and the existing
parallel captures, commands visibility, composition, events, and machine guard
examples. The machine files remain owned by their caller-migration agent.
Historical dependency schedule fixtures and negative admission subjects still
refer to the retired System-backed pure APIs and do not qualify this runtime.
