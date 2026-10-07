# Staged World equality adoption — preparation

`world.patch` adds one helper import and changes exactly two World string-equality
calls: registration name and ordered access names. Existing IDs, ordering,
registrations, owners and public semantics are unchanged by the proposed diff.
The helper remains the independently tested codepoint-equality candidate.
No live `src/ecs` file is changed.

A copied full component-state application dependency closure passes the five-second
checker with the staged World and helper. Initial use of nonexistent `--check`
failed; original logs remain separate from the successful `--check-only` receipt.
The checker verdict is type/termination evidence, not approval of new ECS laws.

Next: guarded actual full application JS/Native and affected registration/owner
controls, matching before/after profiles, equivalent complete timing and unchanged
#28 gate before shared-core delivery. Checker-only evidence qualifies none of
those executable, proof or performance gates.
