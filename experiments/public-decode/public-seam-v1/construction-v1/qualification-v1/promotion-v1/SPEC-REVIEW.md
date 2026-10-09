# Independent Spec/API review

Scoped PASS for experimental integration of the six proposed canonical modules. This is a source/API assessment against `docs/parity/validation.md` (issue46), `docs/SPEC.md`, the promotion manifest, frozen input-codec source `dd375d8a`, and independent pre-output model `5a41088d`. It grants no execution or full-issue completion credit. Standards review `2148e6c9` is separate.

## Source correspondence

Independently checked all six manifest origin/candidate hashes and root-staged candidate bytes. Reversing the declared import rewrites restores each complete original source exactly. Five implementations are import-only promotions. `decode-construction` additionally retains an input codec and offers explicit input-codec factories; default factories select the stored declaration codec. The unchanged default 44/20/16 model hashes are respectively `00861956e85d85847cf8b842e1c83e6fa94978377adbc66cf51e3041a8b1216c`, `df04e7ce326103508415ea37e568891613adf3be485c0aaea303ae762304d912`, and `58a988e27a968373b958f5d0da87d1ab1fc28136b3f70ef2d74eded09e4c513c`. Their historical execution evidence remains antecedent evidence; canonical-import execution requires its own current joins.

## Contract and ownership

Factories retain the nominal saved declaration, arbitrary affine `I:Type` and `P:Type`, projector, incoming-value projection and reversible builder. Input decoding happens before construction. Default factories preserve the previous input shape; explicit factories support String input and a different stored Object shape. Pure construction does not itself admit the cooked payload to World: the downstream request/resource grant validates the saved payload against its retained declaration before mutation.

The two request modules compose construction with the actual owned request grant through opaque-H capability invocation. Construction refusal returns the incoming owner. Downstream refusal returns the actual cooked owner through its supplied undo, restoring the incoming owner; custom constructor errors remain distinct from operation errors. Saved validation precedes reservation/enqueue. Accepted spawn/insert remains deferred through the existing Batch/barrier/Local route rather than implying immediate materialization.

The three resource modules validate or construct before the actual frame resource write. Refusal returns the incoming replacement and frame. Successful construction retains its undo. Resource rollback uses existing owned-journal semantics: displaced replacements are not automatically returned, and Pending recovery remains explicitly incomplete. These modules introduce no global recovery-sink policy.

Schema/payload identities and read/write grant types remain in the typed routes. Trusted declaration/projector/builder/undo provisioning and low-level grant constructors remain application boundaries; this review makes no claim that metadata strings enforce runtime permission or that constructors are a security barrier.

The independent new twelve-report oracle preserves both nominal schemas, all physical slots/stamps/liveness, World/queue, Mail, Local recovery, errors and affine arrays. It distinguishes custom parse refusal from wrong input-kind Validation, saved-P downstream rejection with exact incoming restoration, deferred success, body failure recovery and skip. Expected JSON is 169,914 bytes, SHA `395d1c1f7e0337d7f67194f2527eb1b425bd5147074ea13681b514e4933484d4`. No runtime output was used to derive it; no execution claim follows from this model.

## Remaining issue46 gates

Current canonical-import default80 and new12 consumers need complete JS/Native qualification and current intended authority negatives. Historical default receipts do not establish execution of the additive constructor layout. Full descriptor/primitive/combinator, Plain/Transient, precedence and Handle inventory; reached skipped-validator/partial-write controls; and actual TS shared-application joins remain owning issue46 gates beyond these six APIs.

Qualified Standard Schema host conversion remains separate from generated ECS callback interoperability. Unchanged default #28 regression, matched feature timing/scaling and consequential optimization profiles remain required under the existing gates; no thresholds or performance credit change here. Root integration, independent completion reporting and remaining public-delivery checks are separate. No new law, approval policy or dependency is introduced by this source review.

No backend, compiler, sourcechecker or runtime child was launched for this review. Only source/manifest/model joins were inspected; no shared files were edited.
