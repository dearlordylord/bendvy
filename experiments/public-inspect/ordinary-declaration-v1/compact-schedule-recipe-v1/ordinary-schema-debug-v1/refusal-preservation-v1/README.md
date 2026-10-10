# Setup-refusal ownership successor

Owning #56. The finite frontend now returns the complete previous App on each
existing registration refusal: `ResourceRejected{FirstApp}` or
`ComponentRejected{original empty App}`. World, owners, recipe and debug flag
remain in that result. No disposer or new outcome policy is introduced.

Full normal source (14280) and reached refusal source (6511) passed the stock
five-second checker with unchanged guards. Trusted administrative setup sets
`nextSystemId` to 4294967294, then the actual ordinary component registration
succeeds and actual field registration refuses at 4294967295. The test observer
consumes and returns the refused FirstApp while printing complete World and sole
actual component Fields; only the outer fixture finally consumes its result.

The preceding normal13505 JS/Native packet remains immutable. Independent
successful-body applicability and complete refusal oracle are pending before
any runtime reuse or execution claim. No generic arity/public/full #56 claim.
