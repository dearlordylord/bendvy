# General query capability mechanism

`src/ecs/capabilities.bend` provides closed typed operation records. `Read<H,V>`
returns `Component.Access<V>`; `Write<H,C,V>` additionally accepts the actual
owned `C: Type`. `Bundle<A,B>` nests without a family-count-specific executor.
Caller-defined records also work. Field projection occurs in closed template
arguments; operations never capture a runtime owner. Each application threads
one abstract affine H, permitting repeated reads and aliases of the same family.

`src/ecs/compose.bend` binds typed Family declarations with `read_family` and
`write_family`. A closed `Plan<S,Store,R,E,Ops>{caps,select}` keeps grants and
membership together as trusted schema provisioning. `family_match` supports
Required, Present, Absent and Optional; `both` composes conjunction, and `all`
is the empty selection. Optional matches live entities with either presence
state; MissingEntity is never an optional match. Family identity retains the
exact schema, token, component, views and lenses, rather than diagnostic names.

`each` accepts a rank2 callback:

```text
@-H: Type -> @-caps: Ops(H) -> A -> H -> H & (Outcome<U> & Out)
```

The caller supplies closed Plan and callback templates, Data args/error/output,
and its owned World. The engine snapshots ascending live handles, runs one
transaction, and returns `Executed{world,outcome,values}`. Success outputs retain
callback order. Any user/access failure aborts traversal, rolls back owned
replacement journals, discards staged commands/events and returns no outputs.
Deferred commands remain invisible until the existing explicit apply boundary.
Concrete Frame is trusted orchestration; gameplay never receives its type.
Caller-defined `Ops(H)` is trusted declaration code: its fields must describe
operations, not manufacture replacement owners. The generic executor does not
certify arbitrary type constructors or malicious closed adapters. Open runtime
owners cannot enter closed templates; confinement controls exercise the actual
operation-only public declarations. This is not global root authority proof.

Resource reads/replacements, handle and clock reads, event publication and
spawn/despawn/targeted insert commands are separate opt-in fields. They are not
ambient callback arguments. `command_insert` carries a schema-typed target and
an affine payload, checks current target liveness, and stages owned insertion.
No API here grants global world authority.

`each_since` adds a runtime reader cursor after args/world. Frame carries that
cursor; closed `lifecycle_match` composes Added/Changed selection through typed
column stamps. The plan can be reused while the cursor changes, without erased
runtime captures. `clock_read` returns the authoritative current World clock.

Run `python3 experiments/query-composition/mechanism/run.py`. All checker/build
and runtime commands have a five-second process-group timeout. Existing Bend
2.0.35, Node and native compiler only; no new package. Fresh source-instantiated
checker, JS and Native controls produced:

```text
positive: 19|2|ok|7@1,19@2,
failure: 7|0|failed|
```

The positive starts two live entities with resource Array [7], repeats the same
getter per row, performs full Array replacement [19], emits two events, and
observes ascending handles 1,2. Failure restores Array [7], publishes no event
and yields no output. These are mechanism controls, not the independent
Workshop acceptance, reference trace, performance gates or ECS proofs.

Kernel proof acceptance remains open: higherkind rank2 generic callback export
has an out-of-scope model (`execute~body` in the isolated diagnostic), and the
unchanged kernel reports a TypeScript/model mismatch. Existing provider.bend
reproduces generic model mismatch too. Ordinary source checking and freshly
compiled executions do not establish universal runtime refinement. No compiler
or kernel change, scoped checker-repair extension, new law or proof is included.
Template instantiation retains the compiler's 64-level limit; arity-independent
source composition is not a claim of unlimited runtime nesting.
