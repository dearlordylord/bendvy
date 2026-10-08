# Committed-machine Inspector adapter — interface proposal

Source-only isolated draft for root review. No production interface edits, laws, policy choices or executable acceptance.

`machine-current-adapter.bend` provides `Cap.ValueRead<I.Frame<S,Store,R,E>, M.CurrentView<S,K,V>>` from a trusted closed resource lens. It calls actual machine-world.take, projects actual machine.current_view, returns Frame with unchanged cursor and preserves arbitrary affine Store/R. `get` returns detached CurrentView; `matches` implements TS machine.is with the schema equality function. Bend `is` is a reserved keyword, so the initial attempted public name was rejected and preserved. Successful type feasibility grants no universal proof or backend/runtime qualification. Missing/Unavailable remains internal until provisioning validates the declared machine; this adapter does not invent a user error mapping.

## Proposed metadata/preflight seam (root-owned integration)

Keep category identity explicit: additive nominal `Machine<S,K>` declaration indexed by the schema machine token, trusted numeric key/name and closed projection binding. Broaden Inspector requirement metadata to a category sum with `Resource{id,name}` and `Machine{id,name}`; equality/normalization uses category plus id, not id alone. A machine requirement is not a resource alias. Existing resource metadata callers retain their resource variant/semantics. Root must review exact additive shape and naming before changing inspector-metadata/declaration or provision modules.

The caller holds a closed provisioning predicate `Requirement<S> -> Bool` or equivalently a category-aware available declaration set. Validate required machine kind/key before callback. When absent return the existing missing-requirement result shape with the Machine category and original World/Inspector instance/args preserved; no invocation, tick, reader position or resource mutation. `has_requirement` denotes this proposed closed preflight, not an existing exported primitive. Do not manufacture missing behavior from machine.CurrentView.Unavailable, hide it as Resource, or grant callbacks the predicate/World.

Provision declaration and current-machine read can share the machine token K; value type V remains Data as in adopted machine.Family while unrelated payload owners remain Type. Two schema tags and two machine tags with colliding numeric ids must remain distinct through capability authority; mixed Resource/Machine same id must not deduplicate. Availability preflight and callback grants are separate: a named available machine does not itself grant an undeclared read.

## Development evidence

Exact copied 12-module root import closure is in adapter-source-closure.json. Attempt1 rejected reserved name `is`; attempt2 renamed it to `matches` and exited0 with full `ALL PROOFS CHECK` / mathematical-validity disclaimer. Both raw stdout/stderr/source/exit are preserved under development; caps5, shared lock, no tool discovery/emission/runtime/profile. This is parser/type feasibility only. Fresh future source evidence must join current coordinator-root bytes; these isolated copies are not adopted sources.

## Next finite consumer to freeze for review

Author independent full TS/Bend observation oracle before children: two nominal schemas, two committed Data machines each and arbitrary affine owners; get/matches true/false; repeated inspect, cursor-free check; queued next write before marker, structural barrier distinct from marker, actual marker, failed ECS write rollback; exact missing-machine preflight before body; system reader positions/retention/commands/owners unchanged. Include successful Inspector cursor/tick advancement versus check no advancement. Negatives: undeclared machine read, cross-schema/machine token, owner duplicate, write/pending access through read. Reached compiling defect: project pending instead of committed or mutate committed state on read. Preserve existing Inspector baseline consumers. Actual TS cheap full-oracle plan and checker/backend cohort require separate source/oracle freeze and review; none is prepared or run here.
