# Rendering DAG observation after the order diagnostic

The order diagnostic did not complete emit30. It provides no pass count or evidence that dependency ordering helped. No further compiler experiment is proposed.

The unchanged qualified scan-projector generated JS is 2,430,204 bytes, SHA 40b9b0f1c06c0713cfef050872bb7d5c9dcf0e78e2a6f3ec7aa2796891d1549a. Counting actual top-level emitted functions (not textual call occurrences) gives 28 each of format.snapshot, single, single_optional, row, get and lookup; 57 each of format.list and tail. The 14 concrete value formatters each occur once. This is concrete repeated envelope/list/error rendering specialization around the real typed values, rather than duplication of value formatters.

Source format.bend row/lookup/single/get/snapshot all carry erased S/V/format; execution.bend29 serialized passes the typed snapshot into that chain. check-execution.bend34 compared reaches the same formatter through the Check boundary. The schema index is needed for typed handles, while output rendering only extracts their numeric ids. Compatibility and observation APIs must keep those indexes.

A distinct future source-local discriminator could render each typed row once into String, then construct an internal detached rendering record of List<String> and rendered result strings. A non-generic envelope/list worker would preserve byte punctuation, errors, order and all47 work while reducing repeated envelope specializations. Public Consumer.Snapshot/real Value/query grants remain untouched. This introduces no serialization contract outside the fixture. It is not authorized or implemented here; exact inverse and whole-oracle applicability would be required before any run.

These are JS emitted-function counts, not measured Native costs. Prior Native cost top samples do not establish this rendering chain as dominant. Therefore this is a defensible smaller-DAG hypothesis, not an established resolution or causal explanation. No new source/compiler/backend child was launched.
