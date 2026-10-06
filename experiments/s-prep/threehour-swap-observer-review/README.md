# Bounded observer review

No concrete variable, role-order or source/artifact join blocker was found in the three archived observer snapshots. This is a read-only code review, not approval of generated-JS transformations, measured performance, runtime correctness or product acceptance.

`review-pins.json` identifies the exact root bytes. The copied scripts are review snapshots, not runnable entry points: their repository-relative imports would resolve differently here. Python AST parsing passed for all three. Both composition freeze files were read and every one of their 16 path hashes matched the live frozen bytes. No observer, benchmark, correctness control or malformed-input control was executed by this review.

| Observer | Roles | Prospective order coverage |
| --- | --- | --- |
| Swap first argument | TS, Native, parent JS, legacy JS, positioned JS | Five cyclic positions, then their reverse orders: rotations 0–9 |
| Current Slot Host baseline | TS, Native, current first-stage JS | Three cyclic positions, then reverse: rotations 0–5 |
| Selective-store composition | TS, Native, first-stage JS, selective JS, positioned JS, composed JS | Six cyclic positions, then reverse: rotations 0–11 |

The inspected guards require Native; join its exact four-artifact build to the same 29 source files and row→pool→Tuple first-stage chain; pin the reference HEAD and clean core; retain measurement source, validator, supervisor and Node executable hashes; compare all 65 observations to fresh TS full fields; reject non-finite, negative and boolean clocks; and rehash consumed inputs after execution. Parent receipts are pinned from the bytes initially parsed, avoiding the earlier late-pin gap. No stale candidate/legacy/freeze variables were found in the baseline adaptation.

The composition observer reconstructs the selective-parent and first-stage joins from actual receipts and input catalogues, checks the seven-store/ten-stable-field transport certificate and binds the standalone positioned comparison to the same original input/source. Its root freeze contains exactly the 16 required paths. `parent-joins.json` is hash-bound, but its contents are not consumed as an additional semantic assertion; the actual joins are independently reconstructed. Treat that file as producer documentation, not an extra executed gate. The non-hot edge shape checks are less detailed than in the first-argument observer; the exact frozen recipe/output joins remain required. Neither observation establishes a current malformed cohort or incorrect program.

Previously reported review gaps—optional Native, incomplete artifact membership, missing measurement/reference pins, absent post-run hashing, non-finite clock acceptance and late parent-receipt pinning—are corrected in these snapshots. Their runtime rejection behavior was not replayed here. Any subsequent script change requires a new SHA-bound review; other agents’ timing or control receipts are not this review’s acceptance evidence.
