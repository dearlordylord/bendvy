# Closed declaration descriptor and runtime state

The specialized eight-row driver fails before runtime. The preserved e59 receipt and stderr identify `invoke_owner~0` passing local `plan` to `I.run(~plan,...)`. The earlier f3df import-only source check did not instantiate that call and cannot qualify this coupling.

The pinned guide (`.references/bend2/guide/GUIDE.md:259–276`) says a template receives syntax at compile time and its argument must be closed, mentioning top-level definitions rather than caller locals. `bend2/bend.ts:3739–3751` checks template arguments in an empty context and reports this exact local-variable refusal. Base's `List.map` (Base.bend:808), fold helpers (961–970), and Array.map (2437) follow closed `~f` specialization. The guide (83–85) separately states closures are affine and callable at most once. Erasure is not a way to borrow a runtime closure repeatedly.

The existing Inspector is deliberately static: `inspect.bend:18–19` bundles operations in Plan; `run:80`, `initialized:72–73`, and `Cap.invoke` (src/ecs/capabilities.bend:77–78) specialize both plan/caps and body. The callback accepts universal erased H and caps. `Cap.value_read:54–55` also specializes its cap. The delivered consumer invokes a top-level closed `plan()` (consumer.bend:122). Thus changing only the outer Plan argument to runtime would still hit erased caps inside the callback. `value_read_field:45–47` can extract a runtime affine function, but consuming it is a different callback/executor model and does not preserve the existing repeatable erased-cap contract automatically.

## Preferred bounded alternative

Use one closed schema-exported declaration descriptor as an erased index, and keep arbitrary affine state separately at runtime. A proposed experimental `BoundState<-S,-Descriptor,-Extra>` would own the two Arrays and Extra only; Descriptor denotes the complete closed canonical definition with its declaration-derived requirements and actual Plan. Metadata observation specializes the same Descriptor to extract Data metadata, returning the exact state owner. Projection specializes that SAME Descriptor to extract its actual Plan and invokes existing I.run with the existing universal-H callback. World and Instance are passed and returned at runtime without alteration. There is no runtime Plan to unpack, clone, replace, or rebuild, and no manually constructed Frame in the driver.

The canonical declaration input must occur once in the closed descriptor constructor: existing Bind.bind/split/fixture finish derive metadata and grants together. A closed extractor may evaluate the descriptor in template syntax, but must not introduce a second independently authored requirement list or a separately chosen lens bundle. Definition name and canonical token/name/lens remain the already reviewed trusted schema boundary; arbitrary caller truth is still unproven. Runtime mutable names, runtime-selected lenses, or affine callback captures are outside this proposal.

This changes the experimental runtime-owner shape: Plan is a static erased declaration index rather than an affine field preserved at runtime. It does not change existing Inspector.run, Cap.invoke, access authority, cursor/World behavior, Extra ownership, service policy, or public core. Existing generic Definition wrappers and their evidence remain unchanged. Source tests must instantiate the concrete callback, not merely import the bridge. The full eight-row oracle remains independently authored; owner assertions concern actual runtime Arrays/Extra and static descriptor identity, not a runtime Plan owner.

## Other alternative, not recommended for this seam

A genuine runtime-cap executor could thread consumed caps back with H and results, with runtime callback capability arguments. That would require a new executor/callback signature and quantity/retention design: today cap.get is affine, existing readers specialize erased caps, and repeated use is supported through compile-time syntax. Returning or recreating consumed functions is not established by the current interface. A finite one-shot runtime reader may be expressible in the language, but is not a demonstrated replacement for current generic Inspector authority/repeated execution. Do not implement it without separate contract review. No inference that all runtime-cap consumers are impossible is made.

## Review gates before implementation

Root/reviewer should approve the static descriptor separation as an experimental representation adjustment under the existing declaration-coupling requirement. Then author the concrete indexed constructor and complete consumer; source5 must reach both schemas' actual invocation. Cross-schema, undeclared/readwrite authority, owner duplication/escape, and wrong descriptor index source controls need matched positives. Lens-routing and metadata-order mutations must alter the single closed descriptor construction and independently predict full outputs. Runtime CLI/JS/Native evidence requires separately reviewed guarded plans. No source feasibility, unspecialized import PASS, or trusted constructor implies universal metadata truth, proof, or full #54 closure.

## Concrete experimental interface for review

For each schema, use the existing Plan and canonical definition types:

```bend
# D.Ops and D.canonical_definition are the existing schema exports.
type State<-descriptor:Meta.Definition<A.Schema,I.Plan<A.Schema,A.Store,D.Resources,U32,D.Ops>>,-Extra:Type> is Type:
  State{left:Array<U32>,right:Array<U32>,extra:Extra}
```

Proposed template operations (signatures before implementation):

- `attach(~descriptor:<canonical definition type>,~Extra:Type,left:Array<U32>,right:Array<U32>,extra:Extra) -> State<descriptor,Extra>`: runtime construction owns only those three arguments.
- `descriptor_metadata(~descriptor:<canonical definition type>) -> Meta.Metadata<A.Schema>`: closed Meta.read evaluation, discard the closed returned definition only at setup specialization, return Data metadata. No runtime callback/World operation.
- `descriptor_plan(~descriptor:<canonical definition type>) -> I.Plan<...>`: closed Meta.into_plan evaluation, no runtime-owned input.
- `read(~descriptor:...,~Extra:Type,state:State<descriptor,Extra>) -> State<descriptor,Extra> & Meta.Metadata<A.Schema>`: same state returned once plus metadata from the identical descriptor index.
- `invoke(~descriptor:...,~Extra:Type,state:State<descriptor,Extra>,instance:I.Instance<A.Schema>,world:World.World<...>) -> State<descriptor,Extra> & I.Observed<...,Fields,Fields>`: invoke existing `I.run(~...,~descriptor_plan(~descriptor),~body,instance,Unit{},world)`; state passes through unchanged. Body remains universal H and three actual closed grants; no state capture.

Each schema's caller supplies exactly `~D.canonical_definition()` to attach/read/invoke. A value produced by runtime `D.define(runtimeName,...)` is intentionally not accepted as a template descriptor. The descriptor type-index equality ties metadata selection and invocation selection; canonical constructor implementation remains trusted. No new opacity claim: raw constructors remain forgeable as before. Whether the compiler accepts this dependent erased value index and the closed extractor expression is a source-feasibility question, not assumed acceptance.

The old Owner field `plan:P` is absent in State. The runtime-owner test must explicitly stop asserting runtime Plan threadback. It still asserts full left/right/Extra contents and exact owner type indexed by the closed descriptor after repeated metadata reads and projections. Diagnostic world and instance output remain actual returned values. This matches the static-registration direction of existing closed Sys/Inspector consumers while preserving the original requirement to derive metadata and grants from one declaration.
