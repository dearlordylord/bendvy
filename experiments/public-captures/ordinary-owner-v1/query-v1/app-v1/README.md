# Automatic App query capture registration

`ordinary-app-capture-query-fields.register` derives component clauses and modes
from the same query declaration, retains the actual capture owner and cursor,
and composes the ordinary App fold internally. Application authors supply the
ordinary declaration/body, name and capture; debug requires only enabling the
existing App flag. No application-authored metadata projection is supplied.

The consumer registers two instances in one World for each of Workshop/Garden.
Three live entities contain Value on IDs 1/2 only. It observes disabled debug,
enables debug, runs A (+1), B (+10), A (+1), and A again with no changed rows,
then unregisters both and observes the actual returned packs. Independent cursors
and complete metadata are visible alongside every payload/stamp, live tree,
World field and both capture trees. Debug bindings preserve both Write/Changed
clauses. DTO formatting is a display function, not a metadata adapter.

The fixture destructures/rebuilds the existing App product solely to thread
its actual owners through ordinary query execution and observation; it does not
forge registrations or supply fold callbacks. Schema/world and opaque-payload
observations reuse the frozen first query fixture. No underlying query behavior,
original core module or first consumer was changed.

SOURCE-FREEZE records 58 literal Bend sources plus the two namespace sidecars.
Library and scenario checks pass; main reports only five foreign-dependent IO
definitions. JS and Native now both match the complete independent 4,961-byte oracle
(`60c6234dc`, SHA256 `e1133b87a38f06cb5c6e9aaae0782dd3470eb8f86f91f35593421fffb623b3aa`).
All five commands exited zero under the existing limits; all 17 guards were
unchanged. The [joined review](../FINAL-REVIEW.md) accepts #50 semantic delivery.
