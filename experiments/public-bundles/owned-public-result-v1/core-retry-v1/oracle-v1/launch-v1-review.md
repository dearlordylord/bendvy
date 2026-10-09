# Core retry launch v1 independent review

Reviewed b0bb40e9 plans JS c56d83d8c0fe74cb0063487ea9a7fdc64b1b3b8661a0f53f2eebb8e477c2ba77 and Native45b9aeb85951eccd52e462562880df78fee9921d750d37c68695e55db5a60229. **Blocked: no launch admission.** No backend ran in review.

All44/47 current pins match, Native resource inventories70/272/7 match, generated outputs are absent; complete29-source inventory and exact413-byte String/a90c oracle remain intact. Normalizer is identity and strict_equal requires entire String equality, without trimming. Three portable bootstrap and three literal/deep/source transport tests independently pass. Caps/tool/source routing and additive scope remain unchanged.

Concrete failure-order defect in BOTH collectors: after execute_result returns, streams are written and hashed before record.commands.append(row). A second-stream publication failure therefore leaves the completed exit/failure and complete returned stdout/stderr absent from the receipt. Emit partial-artifact capture is also after publication and is skipped on that exception, so post/final guards may omit the partial generated artifact. Calling execute_result directly means the shared Runner's exception.result preservation cannot repair this adapter path.

Repair by recording the exact returned result before publication and capturing partial generated C/JS/binary in finally while retaining the primary exception. Add focused actual-adapter no-child second-stream and partial-emit/build failure controls, then freeze fresh exact plans; preserve v1 unused plans. Existing six tests do not exercise these publication/capture paths. No change to String expectation or source ownership semantics is required.
