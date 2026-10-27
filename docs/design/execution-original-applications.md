# Original application migration

GH94 migrates two existing, independently authored applications. Their source is
preserved in Git at `94fc35a9616e7b2f561935dc9667d13a332d07e5`, before
`f615c2948` removed the experiment archive. The source directories are
`experiments/public-audit61/app-a-current-carrier-v1` and
`experiments/public-audit61/app-b-current-carrier-v1`.

The archived README binds those applications to core `81316652e`. That source and
its historical observations do not establish behavior of the replacement core.
The current migration uses Bend source only. It does not restore archived host
models, tests, runners, or execution packets.

## AppA retains its owned-payload handoff

`main.bend` installs one optional array/scalar bundle with values `[7,9]` and `11`,
observes the pending installation, explicitly flushes, and registers three systems.
`handoff.bend` then executes the following sequence.

| Original operation | Retained application behavior | Replacement dependency |
| --- | --- | --- |
| Register query, resource, and Counter field systems | Distinct affine capture packs and registrations | GH82 query/resource execution and GH83 retained capture owners |
| Fail explicit array replacement with `[70,90]` | Return the actual incoming payload in a recovery record | Explicit named recovery facility, separate from ordinary scheduling |
| Withdraw the failed replacement and retry successfully | Install that same returned payload and retain the displaced `[7,9]` owner | Recovery adapter over modern component owners |
| Withdraw the displaced original and publish it | Move the actual `[7,9]` array into an owned event | GH84 owned event publication |
| Read the event through the scalar-writing reader | Project sum `16`, update the actual scalar, retain scratch and reader owners | GH84 owned reader/query integration |
| Run the captured schedule three times | Counter write `[21,22]`, scalar query adds `4`, resource capture reads Counter | GH82/GH83 and ordinary Root execution |
| Set the query condition true, false, true | Only the scalar query skips the middle run | GH83 stateful condition owner transport |
| Inspect twice after each run | Observe array, scalar, Counter, and preserved actual owners | GH93 passive component/resource adapters |

The query capture starts with `calls=[0]` and `values=[30,40]`. Each entered query
increments calls and adds the observed scalar to both values. The resource capture
starts `[100,200]` and adds one plus the Counter sum on every entered call.
Counter starts `[10,11]`, and the unrelated sibling remains `[100,101]`.

The original recovery call has a live application consumer. Retaining that named
facility does not authorize the old `transaction.bend` failure-prefix machinery
to determine the replacement ordinary schedule. Recoverable component operations
remain separate from the three scheduled systems.

## AppB retains a distinct graph application

AppB has no registered gameplay system. `main.bend` installs three bundles, queues
two relationships, reparents one entity, and observes the result.

| Original operation | Retained application behavior | Replacement dependency |
| --- | --- | --- |
| Install three array/scalar bundles | Three genuine reservation results, each carrying `[7,9]` and `11` | GH86/GH87 structural materialization and returned owners |
| Observe before and after the explicit flush | Pending installation remains visible separately from published components | Ordinary command boundaries and complete receipts |
| Queue `Parent(child,root)` and `Link(child,other)` | Independent hierarchy and ordinary descriptors with IDs `1` and `2` | GH89 protected Store declarations and the same command queue |
| Flush and inspect child | Observe Parent, Children, Link, scalar, and current machine state | GH89 publication and GH93 passive projections |
| Queue `Parent(child,other)` and flush | Replace the old hierarchy edge and update its inverse | GH89 canonical hierarchy interpreter |
| Inspect twice after reparent | Preserve graph, machine queue, readers, and affine payloads | GH93 passive observation |

The Phase resource starts with current value `1` and queued next value `2`.
AppB never applies that pending transition. Migration must preserve the queue
through inspection rather than add a transition to resemble another application.
Its sibling resource starts `[100,101]`.

## Current source and remaining work

`examples/parallel-applications/app-a-payloads.bend` carries the original affine
query capture and payload constructors. `app-b-schema.bend` builds canonical chunk
component layouts and two protected relation resources, the modern Phase Cell,
Sibling, and an arbitrary affine receipt owner. Schema creation uses the actual
Factory namespace for both graph stores and the Phase Cell. The receipt owner is
supplied by the application and returned on schema refusal.

`app-b.bend` executes the original AppB operation sequence through the replacement
ordinary App. Its command author obtains one structural grant and two relation
grants from the same declaration book. Three real reservation requests enqueue
the original bundles. Explicit flushes use the schedule's actual unapplied IDs
and canonical publication; they preserve the remaining IDs and retained state.
The registered command author and empty boundary peer replace the old direct
transaction enqueue transport. They do not add a machine transition or a gameplay
system to AppB's domain behavior.

`app-b-inspection.bend` uses the current passive Inspector adapters for component
queries and cached graph/machine resource views. `app-b-owners.bend` reports every
pending command and receipt while returning each affine owner. Its diagnostic
raw-column read validates each captured handle against the actual World namespace
and live handles before converting to a physical offset. It reads each array
owner twice, returns it to the same column, and preserves the existing cached view
and lifecycle stamps. This diagnostic is separate from the public passive
Inspector capability.

The ordinary Bend entry executes successfully with three `[7,9]` array owners and
three scalar values `11`. Before each explicit flush, its authored operations
remain pending. The first relation flush produces Parent `3:0 -> 1:0` and Link
`3:0 -> 2:0`; reparenting replaces Parent with `3:0 -> 2:0` and updates its inverse.
Every printed Phase view remains current `1`, next `2`, revision `0`.
The repeated final Inspector projections agree, and all three actual array owners
produce `[7,9]` on both diagnostic reads. These are finite interpreter observations,
not a formal proof or native backend concurrency evidence.

AppA's complete execution, its explicit recovery adapter, owned event handoff,
and final source cleanup remain incomplete. GH94 also retains its complete
JavaScript/native delivery, applicable authority controls, and independent review
requirements. No new law is approved or proved by this application run.
