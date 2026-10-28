# JavaScript owner transport: pinned language/compiler findings

Scope: read-only investigation of Bend2 commit `a950fd683c0d76f09794078e6174fe98a1492876`; `git -C .references/bend2 rev-parse HEAD` matched. No source/compiler edits, checker runs, proofs, measurements, or dependencies. Findings concern emitted code, not JavaScript engine allocation elimination or performance acceptance.

## Current language

There is no documented general record borrow, field-update, or alias-pattern facility that lets a function inspect a `Type` record and retain its original owner binding. `Type` variables are affine; reusable `+` variables require `Data` ([ownership rules](https://github.com/bendlang/bend/blob/a950fd683c0d76f09794078e6174fe98a1492876/guide/GUIDE.md?plain=1#L55), [quantities](https://github.com/bendlang/bend/blob/a950fd683c0d76f09794078e6174fe98a1492876/guide/GUIDE.md?plain=1#L219)). The syntax inventory lists constructors, destructuring, matching, and array updates, but no general record borrowing/update syntax ([terms](https://github.com/bendlang/bend/blob/a950fd683c0d76f09794078e6174fe98a1492876/guide/GUIDE.md?plain=1#L604), [statements](https://github.com/bendlang/bend/blob/a950fd683c0d76f09794078e6174fe98a1492876/guide/GUIDE.md?plain=1#L616)). This is a source inspection conclusion, not a proved language impossibility theorem.

An ordinary affine alias `other = owner` transfers ownership; it cannot make both `owner` and `other` usable. Conversely, returning an untouched owner parameter uses it once and is valid in principle. Reading `cached` by destructuring `Cache{raw,+cached}` consumes the record binding and leaves its fields, so that pattern requires rebuilding the record when returning its owner. Only the cached `Data` field may be duplicated ([actual cache declaration/getter](../../experiments/fivehour-candidate/JS/experiments/s-integrate/cache.bend#L3)).

Arrays have a special ownership-preserving API: reads return the array beside a `Data` element, and writes return the same mutable array ([array contract](https://github.com/bendlang/bend/blob/a950fd683c0d76f09794078e6174fe98a1492876/guide/GUIDE.md?plain=1#L185)). The `a[i] <- v` syntax lowers specifically to `Array.set`, and `a[i]` to `Array.get`; it is not a generic record update ([parser](https://github.com/bendlang/bend/blob/a950fd683c0d76f09794078e6174fe98a1492876/bend2/bend.ts#L2054)). This does not permit copying arbitrary affine payloads or reading a raw owner as `Data`.

## Current JavaScript compiler

Generic constructor emission returns a fresh object literal with a tag and live fields: `js_expr`, `case "Ctr"`, lines 2962–2976 ([emitter](https://github.com/bendlang/bend/blob/a950fd683c0d76f09794078e6174fe98a1492876/bend2/comp.ts#L2962)). `js_match` obtains fields through property expressions and passes them to the branch; it does not register the original record as a reusable constructor destination ([match emission](https://github.com/bendlang/bend/blob/a950fd683c0d76f09794078e6174fe98a1492876/bend2/comp.ts#L3038)). Returning an untouched variable emits the variable directly ([variable emission](https://github.com/bendlang/bend/blob/a950fd683c0d76f09794078e6174fe98a1492876/bend2/comp.ts#L2942)).

Thus the generic JavaScript path has no constructor-identity reuse optimization for destruct/rebuild of `Held`, `Cache`, `Tx`, `World`, or `MetadataColumns`. Special native representations exist for primitives, arrays and strings; none of those five project records belongs to that table ([native representations](https://github.com/bendlang/bend/blob/a950fd683c0d76f09794078e6174fe98a1492876/bend2/comp.ts#L253)). Internal `emit_alias` in `js_match` names a JavaScript scrutinee; it is not a source-level borrow or alias-pattern capability.

The native emitter does have allocation-block reuse: `node_fields` retains a consumed node in `fl.spares` on eligible tail paths, and `ctr_build` selects a spare of a matching allocation class ([retention](https://github.com/bendlang/bend/blob/a950fd683c0d76f09794078e6174fe98a1492876/bend2/comp.ts#L1561), [reuse](https://github.com/bendlang/bend/blob/a950fd683c0d76f09794078e6174fe98a1492876/bend2/comp.ts#L1047)). That mechanism is distinct from the `js_expr`/`js_match` path and is not evidence of JavaScript record identity reuse.

## Concrete source-level opportunities

1. **Fuse validation with the consumer of decomposed fields.** `motion_row` reconstructs `Tx`, `World`, and `Handle` before `motion_checked` immediately matches them again ([producer](../../experiments/fivehour-candidate/JS/experiments/s-integrate/held-adapter.bend#L54), [consumer](../../experiments/fivehour-candidate/JS/experiments/s-integrate/held-adapter.bend#L50)). Pass the separated affine fields plus the namespace comparison into an internal helper. The successful path can call `motion_taken` without that intermediate reconstruction. Rebuild only where a complete owner is actually needed, including the fallback callback. Keep schema/token validation and ownership transfer intact.

2. **Amortize `Held` and cache reconstruction across a trusted internal session.** Current `motion_get` and `motion_ledger` each rebuild `Held` plus the relevant `Cache` ([getters](../../experiments/fivehour-candidate/JS/experiments/s-integrate/held-adapter.bend#L9)). A source redesign can unpack once, run an internal sequence on affine fields and separate cached `Data`, and repack at the boundary. Alternatively, expose an authorized cached `Data` snapshot beside an opaque `Type` owner to a specialized read sequence: getters can return the untouched owner plus that separate snapshot without opening the owner. Mutating steps must refresh the snapshot before another read. Keep raw payloads inside the trusted adapter and preserve the abstract-owner callback boundary. This is a design candidate, not a checked implementation; it changes internal/client plumbing and needs the governing access, schema, write-through-read and confinement controls. Merely adding another outer record or pair leaves reconstruction allocations elsewhere.

3. **Carry metadata fields to the consuming operation.** `metadata_live` reads one array and immediately rebuilds `MetadataColumns` in `metadata_live_done` ([implementation](../../experiments/fivehour-candidate/JS/experiments/s-integrate/storage.bend#L65)). Let the trusted caller continue with the returned live array, flag/timestamp arrays, and boolean, then rebuild metadata once at its final boundary. This eliminates an intermediate metadata wrapper where the caller would immediately destructure it; it does not eliminate array/result transport or guarantee a speedup. A larger redesign could keep an authoritative live-membership `Data` index separately, but its synchronization obligation is additional work, not an accepted simplification.

These directions retain `Raw: Type`, affine arrays, and opaque callback owners. They do not require a Data-only component restriction, a general borrowed raw-owner API, or a new package. The smallest first candidate is the validation/field-continuation fusion; session/snapshot changes need stale-cache and negative-control evidence before adoption.

## Historical static-provider findings

The retired static-provider prototype recorded these bounded observations under
Bend 2.0.35; they require fresh checking before transfer to another compiler or
API:

- Closed template specialization retained an arbitrary affine `Owner: Type`.
  It did not make runtime closures reusable. Capturing a local affine owner in a
  template and duplicating that owner were rejected in the tested definitions.
- The corrected callback type used erased provider binders such as `@-get` and
  `@-set`, with ordinary calls in the body. Its two-callback and registration
  examples supplied finite source evidence, not a generic confinement theorem.
- The tested abstract-owner boundaries rejected concrete destructuring,
  cross-schema setters, writes through read providers and wrong ledger authority.
  These observations do not qualify the current execution API's controls.

The full measurement entry failed its historical checking deadline; the
prototype did not establish a complete gate pass, performance acceptance or a
production API. No old attempt counter or execution window applies to new work.
The original sources and receipts remain in local Git at
`82faab6ce5f266175847475dc63a2c2be3d91a5a:docs/research/static-provider-dispatch/`. Inspect the original entry
with:

```sh
git show 82faab6ce5f266175847475dc63a2c2be3d91a5a:docs/research/static-provider-dispatch/README.md
```

## Lessons from retired optimization drafts

The retired drafts were proposals and bounded experiments, not approved APIs or
performance results. Their reusable cautions are:

- Projection may return a changed affine owner. Preserve that returned owner;
  replacing a projecting presence check with pure membership can change behavior.
  A cached Data view must travel with its raw payload and be refreshed before a
  read after mutation or replacement. Fallbacks must return the actual complete
  context rather than reattach stale owners.
- Inspect the emitted ABI before choosing boxing or concrete owner carriers.
  Allocation classes, extra boxes, transport and drop work can offset fewer
  source fields. Reusing a Data token does not authorize copying an affine owner,
  and constructor counts alone do not establish runtime improvement.
- Live entity membership differs from component presence and from temporary
  extraction. Include membership validation and preflight work in measurements;
  moving field forcing outside one backend's timed region changes the comparison.
- The historical mark-transport source probe under Bend 2.0.35 at `a950fd6`
  failed checking on computed match scrutinees and unfilled helper cycles.
  It supplied no compiling candidate or speed result. Inspect the current
  compiler before retrying rather than treating those failures as timeless.

These cautions do not import the retired transaction rollback contract into the
current execution API. The original proposals remain recoverable, for example:

```sh
git show 82faab6ce5f266175847475dc63a2c2be3d91a5a:docs/design/persistent-owned-cache-plan.md
```

## Separate compiler work and limits

Recognizing unchanged destruct/rebuild constructors and returning the original JavaScript object, or reusing an exclusively owned object while updating fields, would require a compiler change outside source-level adapter work. It needs separate task authorization, careful affine/Data alias reasoning, and regression tests; editing the read-only Bend2 reference is not authorized. JavaScript runtime escape analysis may remove some literal allocations, but was not inspected or measured here.

Commands used: `git -C .references/bend2 rev-parse HEAD`; focused `rg` searches for ownership, syntax, constructor/match emission, native representations and spare allocation; `nl -ba ... | sed -n ...` to inspect cited primary-source lines. Source links point to the local pinned reference and current experimental files. No claims of universal refinement, proof completion, numerical acceptance, or observed allocation counts follow from this report.
