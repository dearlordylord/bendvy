# Runtime continuation boundary: source-only proposal

The frozen subject is `../pair-scan-v1/stage`: complete 47-source consumer, arbitrary affine H, generic nine Check wrappers, real Value fields, matching-tree pair membership, and pair-return enumeration. Its source and complete JS passed; Native emission reached the unchanged 30-second deadline. No new child was launched for this study.

## Concrete duplication

`stage/full-consumer.bend` carries `~caps:Consumer.Reads<H,S,V>` through `after_each`, `after_gets`, `after_single`, `fetch_all`, and `fetch_target`, in addition to `body`. `Reads` contains the complete ComposedReadQuery, whose grant closes over the selection and WorldRead callbacks. The first three helpers are one-shot continuations: each destructures an observed owner/result, then starts the next query operation using the same closed caps. They do not select a different declaration or manufacture authority. `consumer-witness.bend` has the same three-stage pattern (`after_each`, `after_get`, `after_single`).

Installed CLI `def_inst` (lines 2916 onward of `../native-phase-v1/compiler/installed-cli-unmodified.mjs`) type-checks erased arguments before cache lookup, lowers and serializes each of them into the specialization key, and checks a new body when the key is absent. Thus these helper signatures explicitly repeat the closed grant in separate specialization keys. This is a source-level mechanism, not a measurement of its contribution to Native emission. No full47 diagnostic has reported a key exceeding 32768; the #56 key-limit result must not be attributed to this subject.

The prior `generic-check-wrapper-v1/callback-forwarding-v1` experiment changed four **pair composition** helpers to runtime match/project callbacks. Original 24434 failed stock source5 with empty streams and unchanged guards. It did not change the consumer continuation boundary described here. Its failure remains evidence against assuming that runtime callbacks automatically improve checking.

## One distinct candidate

Change only the consumer's three one-shot staging helpers to accept a fresh runtime continuation whose type mentions H, S, V and the detached intermediate values, rather than `~caps`. Keep `body` as the existing erased grant boundary, constructing the continuations there. Each continuation is consumed once. Keep recursive `fetch_all`/`fetch_target` unchanged, so no affine callback is duplicated or renewed across recursive enumeration.

For example, `after_each` receives `next:H -> List<&2,Q.ProjectedRow<S,V>> -> H & Result<&2,&2,Unit,Snapshot<S,V>>` and the observed pair, destructures it, and calls `next(owner,rows)`. The next operation's callback is supplied at runtime by `body`. Apply the same forwarding shape to `after_gets` and `after_single`; preserve the final snapshot constructor. If the executable closure reaches the analogous witness body, apply the identical three-helper transformation there, without changing its public body/plan signatures.

This removes caps from those three helper specialization keys while leaving its authority and operations at the existing body boundary. Runtime closure capture may still be expensive; H and V still specialize; recursive lookup and query core remain unchanged. It is a hypothesis, not a promised Native remedy.

## Exact scope and next plan

Retain all 47 source modules, public pair/selection/scan compatibility APIs, query grant, typed Plan/Ops/body templates, arbitrary affine H, nominal schema distinctions, left-to-right ownership and matching short circuit. Retain each -> reverse-recursive exact get traversal -> single -> optional order, repeated observations, errors, and complete owner/World observations. No compiler, runner, resource cap, dependency, law, constructor policy or shared source change is proposed.

Before any child: freeze the literal source delta/inverse and all 47 hashes, bind the existing independent whole 5077477-byte oracle (SHA 810259f78227f2b3d158c02644978b6c7ecf58b40a4b2fb398a816005b2867e2), and prepare existing unchanged collector plans with current tools/environment/guards. Obtain the requested review of that concrete changed experiment. Execute source5, then conditional whole stock JS emit30/runtime5, then conditional Native emit30/build120/runtime5 under the collector's internal shared lock. Preserve each original failure and stop; no identical retry. Current reader/authority controls remain unexecuted until their exact successor bindings are separately established. Source-only findings confer no backend acceptance or causal/performance attribution.

## Frozen candidate

The candidate stage copies pair-scan-v1 exactly except four literal replacements in full-consumer.bend: the three helper signatures/bodies and body’s continuation construction. All three next callbacks are consumed once by their helper. The recursive fetch worker, consumer-witness compatibility example and every core module are byte-identical. DELTA.json includes the exact old/new blocks and 47 joins; applying the inverse in reverse order reconstructs the parent byte-for-byte, including whitespace. No source check or backend has run.

Printer applicability: entry remains stage/output-io-main.bend; every stage-relative module path and import is identical. No Data type declaration, constructor, formatter, name/rank, output adapter, observer, fixture, schema or scenario changes. In particular full-consumer.Snapshot and Get constructors remain in the same defining relative module with identical fields. Only internal Type-valued continuations change. Accordingly the existing full independent 5077477-byte oracle is reused unchanged, with its raw digest bound by both backend plans; this is a source-derived applicability argument, not actual output equality.

SEQUENCE.json names the original source/JS/Native plans and exact digests. Invoke its unchanged collector as /usr/bin/python3.11 COLLECTOR run PLAN DIGEST. No outer same-file flock; the collector serializes each child internally. Source defaults to5; JS30/5 and Native30/120/5 on CPU11 remain unchanged. A review of these frozen bytes is required before any child under the current task.
