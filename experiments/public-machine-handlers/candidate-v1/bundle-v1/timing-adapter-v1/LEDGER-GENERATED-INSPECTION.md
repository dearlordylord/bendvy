# Actual complete IO correctness JS dependency inspection

Generated ledger.js SHA256 `31d6af333660d7623d1aa7a20104ffb82cd66be23e950051b5bdf00385c17288`, plan22d346db, actual full physical/common42 PASS. This is finite emitted-code inspection; no timing call or Native whole-driver claim.

-193–216: actual main and print_A invoke schema A/B Ledger.run with the literal Correctness constructor and finite correctness cardinality1.
-328–335: now(Correctness) returns IO.pure zero; only the separate uninvoked Clocked branch references IO.now.
-594–604 and912–922: timed(Correctness) builds IO.pure Timed with actual synchronous Batch.step returned owner and zero timestamps. This actual root does not select the Clocked branch.
-487–523 and682–718: operations consumes the next original operation and threads the result through operation_returned into the recursive remaining operations.
-606–614 and924–932: operation_returned extracts returned batch/timestamps, records the exact operation sample and applies checkpoint before invoking the next continuation. Checkpoint observation occurs after returned work, outside any hypothetical clock interval.
-777ff/1189ff: checkpoint preserves unchanged owner for None; Some observes the actual batch and returns its owners.
-243ff: final schema owners are rendered only after all scenarios complete;10393 invokes actual io_exit(main), not pure library rows.

Clocked code remains present in the generated dependency closure but is not selected by this correctness main. Existing prior clock-step inspection remains evidence only for its finite call path. Whole Native IO ledger correctness and future equal outside-interval capture placement still require separate qualification.
