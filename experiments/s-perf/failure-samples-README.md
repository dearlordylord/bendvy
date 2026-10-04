# FailedTxn diagnostic repetitions

No equivalent-work speed ratio or performance acceptance is claimed. CPU7 affinity does not reserve the machine. Each child has a five-second process-group limit. RSS is clean child wait4 via the C launcher, includes retained full diagnostic journals and final serialization.

| Schema | Rows | Gate | Native/TS/JS samples passing |
|---|---:|---|---|
| Motion | 64 | DIAGNOSTIC_SAMPLES_COMPLETE | 7/7, 7/7, 7/7 |
| Motion | 256 | WARMUP_FAILED | 0/0, 0/0, 0/0 |
| Motion | 1024 | FULL_RUNTIME_GATE_FAILED_NO_SAMPLES | 0/0, 0/0, 0/0 |
| Health | 64 | DIAGNOSTIC_SAMPLES_COMPLETE | 7/7, 7/7, 7/7 |
| Health | 256 | REPETITION_FAILED | 2/7, 7/7, 0/7 |
| Health | 1024 | FULL_RUNTIME_GATE_FAILED_NO_SAMPLES | 0/0, 0/0, 0/0 |

Both64-row cases completed seven rotated repetitions for every backend with complete output validation. Motion256 failed its fresh warmup. Health256 completed attempts but had runtime-limit failures, so its repetition gate fails. All1024 cases failed the original full diagnostic runtime gate and have no accepted samples. The four schema/count256/1024 limitations remain visible instead of being omitted.

The TS lane preserves all original assertions, retains actual complete rows and defers SHA; its complete diagnostics equal the original for all six schema/count cases. Bend additionally checks service/reservation/reader-clock fields and records actual Audit Strings rather than TS objects. These are material operation/data differences. A compact-final-render companion is a separate feasibility subject and cannot replace missing full1024 observation acceptance.

The separate compact-final-render feasibility subject passes all twelve schema/count/backend invocations under five seconds, including1024. Its actual loop/ready/setup definitions are byte-identical to the full diagnostic subject and its complete per-field guards execute during the same inner interval. It returns actual event/Audit counts after the interval. This localizes the full diagnostic serialization cost, but counts do not validate every Audit payload or event; no1024 full diagnostic acceptance or fair ratio follows. A next compact sink must keep actual effect payload validation and a shared ordered full-field reduction on TS/Bend before accepted samples.
