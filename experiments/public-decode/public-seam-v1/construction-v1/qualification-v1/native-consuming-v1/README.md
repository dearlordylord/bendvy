# Native handle-consuming coverage — #46

Source-frozen candidate only; no JS/C emission or Native run. Canonical core is imported from root src/ecs; no library implementation changes, contracts, laws or dependencies.

Correction to preceding NATIVE-COMPLETION assessment: canonical92 already observes nested successful insert and failed insert. `canonical-v1/source/materialization-v1/fixture.bend` uses Input.nested() in both factory and retained frame declaration; its Insert/FailedInsert modes are already qualified. Do not replay or duplicate those cases.

This additive candidate has22 complete reports: eight component modes per nominal schema (spawn, insert, failure, failed insert, wrong-namespace insert, wrong-namespace spawn, late target missing, skip), plus three resource cases per schema (replace, wrong-namespace refusal, replace then rollback). Codec HandleValue{1} accepts Raw.Handle{1,4} and refuses Handle{2,4}. These payloads are codec observations, not fabricated live entity handles; there is no new identity/liveness policy. Real target handles still originate from World.create/reserve/activate.

The materialization observer is copied unchanged from the previously qualified canonical fixture except import rebinding, retained codec/raw input and additional invalid-spawn mode. It preserves complete before/committed/barrier metadata, physical slots/lifecycle stamps, Mail owners/errors, pending queue and registered Local recovery. Resource cases reuse canonical fixture's actual abstract-H grant and complete before/after/resource/result/outcome/undoCount observers, preserving existing replacement-drop rollback semantics. The preseeded component is deliberately the same old nested owner: successful insert replaces it with a Handle payload, preserving the retired owner observation.

`mutant-handle-fixture.bend` changes only the two retained component codecs from namespace1 to namespace2. It compiles and changes reached namespace validation through actual grants; resources remain unchanged. Qualification requires an independently authored entire counterfactual, not arbitrary output mismatch. This supplements existing skipped-validator/partial-write mutants, not replacement evidence for them.

Source receipt: main/mutant exit0; six negatives exit1 with intended affine/schema/access diagnostics, pinned Bend2.0.35, CPU5, shared lock and five-second cap. These source checks print evaluated source observations; they have not been supplied as oracle expectations. Exact raw source results are retained, including the initial unsupported `check` subcommand diagnostic. No backend plan yet exists.

Persistence join: canonical snapshot-leaf.bend:37–38 and45–46 return the exact transient owner with empty fields; snapshot-schema provides transient schema constructors. Snapshot-gate separately retains omitted keys. Existing #58/#59 own public save acceptance; historical full-assembly selector12 alone is not a current canonical save gate. No duplicated save fixture is added here, and no new Plain serialization policy is inferred from TS selectors.

Next: independent pre-output full22 and complete reached-mutant oracle; exact existing-collector JS/C plans and independent admission; artifact-only Native admission after successful C; source-current integrated acceptance and unchanged #28 controlled by root. Feature-specific equivalent timing/scaling remains distinct. Historical92 is reused without replay.

## Frozen launch preparation

Independent oracle `84e0c2c10cf3b30934ddf184c792fd04702ab4bc` supplies normal whole22 (`ac333817…`) and namespace-mutant whole22 (`c75c7b62…`) before backend output. Existing spine collector has one additive `native-consuming` role; all historical role paths and default behavior remain. The closed transport reuses complete field inventories and renders both models without normalization/projection. Controls retain historical default normal/input-codec raw identity and reject missing fields, wrong tags and Bool/numeric corruption.

`prepared-v1/manifest.json` freezes positive JS, positive C emission and namespace-mutant JS. Caps remain emit30/runtime5 CPU5, pinned2.0.35/Node24.20.0. C emission alone is not Native evidence. Mutant uses its independently authored entire counterfactual, not arbitrary mismatch acceptance; no production API implementation changed. All prepared raw/generated directories are empty and no actual child launched. Native continuation requires actual guarded C/receipt hashes and separately reviewed artifact-only existing Clang19 build120/run5 recipe.
