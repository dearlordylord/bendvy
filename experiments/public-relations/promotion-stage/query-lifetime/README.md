# Relation Query lifetime adapter — development

This separate source is not part of the admitted twenty-query freeze. It retains
an immutable initial row snapshot, queues a source replacement, runs the same
registered read queries before a barrier, then applies the barrier and runs them
again. All original query/client bodies, generic component selection and nominal
schemas are retained. Trusted setup owns command queueing; read clients receive
only the opaque read-row capability.

Next: prospectively pin the new raw merged supervisor and shared CommandLogs,
full source/tools/stage/mutant inventories, independent chronological literals
and actual TS application. Coordinate a free CPU before checking or execution.
No live core module, prior receipt or cap is changed.
