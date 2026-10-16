# Ordinary automatic recovery App — first mixed consumer

This #61 composition connects the existing #52 recoverable operations to #56's
ordinary enable-debug App owner fold. It adds no new rollback, capture failure,
cleanup, IO, identity or schedule policy. Candidate source and exact patches live
under `candidate-src/ecs/`; root alone materializes canonical `src/ecs` changes.
The normal consumer imports those actual canonical modules before source freeze.

`recovery-use` retains typed Component/Resource/Capture write descriptions.
Canonical declaration factories derive them from the same nominal identity and
Binding used by their operational grant. Capture has no fabricated ECS resource
key. The additive `D.Described` constructor leaves legacy `D.Declaration{empty,
access}` intact; both constructors retain existing empty/access behavior.
`D.both` combines known descriptions and carries an explicit opaque flag for
legacy/custom declarations. No category or mode is inferred from access strings.

`ordinary-app-recovery.register` rejects an opaque description before registration,
returning the actual unchanged prior App and incoming capture. Classic
`Recovery.System.define` remains available for trusted legacy/custom declarations.
Canonical described recovery owners append through the existing typed App product;
the library fold extracts the actual Registry identity/access/cursor and typed
component/resource uses. It supplies no caller Fields, clauses or metadata fold.
Run returns the actual updated App, semantic outcome, output and recovery records
through the same Completed/RegistrationRejected/TransportFailed distinctions as
the existing recovery runner. No replacement owner is manufactured.

The normal consumer composes one component, one selected resource field and an
explicit opt-in capture. The resource product also owns an untouched same-payload
sibling and an unlike affine owner. An already registered ordinary read-only
query App owner retains its own Array capture and reader cursor across recovery
registration, execution and repeated debug/access snapshots. The prior query is
registered but not executed; its preservation and metadata are the scope here.
Each recovery body replaces the component, replaces/swaps the selected resource,
then replaces/swaps its capture in one existing globally ordered journal.

The sequence observes disabled metadata, enables ordinary debug, repeats snapshots,
commits, fails, retries using the actual returned rollback payloads, repeats the
final snapshot and disables debug again. It retains complete actual owner state,
all physical Array/Column trees and metadata, sibling/capture owners, registered
identities/cursors, input/output/recovery records and actual derived DTO/access
views. Returned records are observed before reuse or explicit release. Debug
views come from actual App snapshot/index calls; the raw observer is supplementary
owner evidence. No decorative Plan, phase or schedule description is supplied:
these are direct ordinary registered invocations, not scheduled dispatch.

Pure source checks retain CPU5 and the existing five-second pinned wrapper.
The IO host's expected existing foreign-code boundary is reported separately;
source checks are not backend qualification or universal proofs. Independent
source-oracle, normal backend pair, compatibility, affected authority/mutation
controls and final review are separate delivery gates. The protected 23-source
#28 workload remains outside these new imports. Full comparative timing/scaling
and final JS <= TS / Native <= 0.5 * TS remain #21/#23/#24; #61 is incomplete.

The frozen normal entry imports 76 non-Base modules and pins 147 source inputs
including Base and existing foreign sidecars. `SOURCE-CHECK.json` binds actual
CPU5 commands, pre/post source hashes and full raw stdout/stderr. Fixture, observer
and complete pure scenario pass. The concrete IO main reports only its five
expected existing unsafe/foreign IO definitions, with no parser/type/affine error;
no whole-entry checker PASS is claimed. Source checks do not execute the backend.

The prior owner is an actual ordinary captured read-only Payload registration,
not a fabricated record or caller fold. All app snapshots preserve its physical
capture600 and query cursor0. Metadata lists the prior read and recovery write
uses for Payload and the selected resource Target write; the capture operation
remains private local-like state. Empty observation rows here represent no optional
value formatter: actual physical values are independently observed in the complete
owner report. No world dumps or scheduled execution are inferred from metadata.
