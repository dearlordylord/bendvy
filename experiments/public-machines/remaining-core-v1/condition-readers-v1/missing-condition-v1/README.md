# Missing-condition propagation preparation

This additive private checked-condition runner keeps public Sch.Schedule and Sch.RunResult, the actual skip/dispatch helpers, namespace rejection, barriers, and prior observations. Only the condition result expands from Bool to Result<Error,Bool>. Fail returns Sch.Failed with the returned World and unchanged affine owners before dispatch or skip; earlier successful steps stay committed exactly as in the existing scheduler. No rollback or continue policy is added.

The existing public Bool runner is unchanged. The consumer must use existing K.Checked missing-required failure and preserve its exact error category, with complete source-derived observations before backend execution. No initialization, stateChanged, or handler failure contract is selected here.

The concrete four-checkpoint consumer first executes the qualified readers-register step, removes only the Flow slot in an explicit missing-resource fixture, then reaches ordinary OD.required/K.run failure through the additive runner. K.MissingRuntimeRequirements retains its Flow requirement, rendered as ConditionMissing:[Flow]. Source A-source02 PASS; A-source01 computed-pair binder failure is preserved. All earlier owners, successful reader registration/delivery, and complete physical World remain observed. No runtime has executed this successor.

Selected successor A-source03 additionally enters condition-preflight before each condition, so the reached failure must preserve the earlier Entered observation while adding neither Ran nor Skipped for the failing system. A-source02 remains archived as a superseded successful preparation.

First complete JS and Native pair PASS against independent bdbc622e1 full3733 SHA82950a7dc9c6ab95f9f1eb1372e49b93d15c69db8861009ea687a6b4d4a657ae, root second sanity bound. Five commands17guards, unchanged stock caps/internal lock. Full raw plans, guards, diagnostics, emitted artifacts and binary are retained in runtime-evidence.zip (34 members). No public promotion or additional matrix is claimed.
