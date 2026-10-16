# Reached new-adapter replacement owner-loss variant

This isolated module is a deliberate mutation of the new resource-field adapter,
not a change to the canonical root module or generic recovery library. Its
`replaced` helper still receives the actual `AO.replace` result for the selected
field, then wraps only the newest replacement journal action. On commit the
wrapper returns state/recovery unchanged, omitting the displaced-original record;
on failure it delegates the original action with False. Swap actions are unchanged.
The wrapper is reached through the same ordinary declaration, registered system,
replace operation and selected Binding route as the normal consumer.

The variant fixture imports this module. Scenario/main are byte-identical to the
normal consumer; observer body is identical, with only two reusable import paths
adjusted for directory depth. The World target/same-payload sibling/unlike owner,
capture, complete call sequence, failed rollback, returned-input reconstruction,
refused owners and retry input owners retain normal semantics. Complete initial
commit and successful-retry record observations lose their Replaced records;
normal swap records remain. This tests observable owner conservation, not
physical memory identity, freeing or external finalization.

`SOURCE-FREEZE.json` binds the actual 67-module import closure/138 pins including
Base and existing IO sidecars. `SOURCE-CHECK.json` records exact unchanged CPU5/
five-second source checks and pre/post pins. Pure variant adapter/fixture/observer/
scenario pass; IO main retains exactly five expected unsafe/foreign IO definitions.
It is not a full entry checker PASS. The separate oracle author derives a complete
counter-observation before root serializes any backend run. No backend result is
claimed by this preparation, and the full normal observation remains the detector.
