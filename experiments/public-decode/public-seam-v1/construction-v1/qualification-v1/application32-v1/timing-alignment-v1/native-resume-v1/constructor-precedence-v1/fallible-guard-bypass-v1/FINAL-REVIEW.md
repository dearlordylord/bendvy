PASS — bounded #46 constructor-precedence packet review

Reviewed commit `ad6ace78d6e8ce8328575eb8ff8f0e4983bf6d60`. Its 120 committed paths exactly match the owned-path manifest. The owner-handoff source is excluded as a standalone staged path but preserved byte-exact in the portable archive: its 6475-byte object is SHA-256 `91f7e7f40877da928bb64e64a87ffd218a15e982afbc24199b8778cd4e7effec`, and the source-copy map, actual manifest, and delivery record bind it to the pinned source.

The archive passes ZIP integrity and all content-addressed joins: 156 objects, 217 logical rows. Oracle joins cover four reports across First/Second schemas, each with invalid and accepted cases. The historical 4682-byte normal stdout is retained unchanged; structural QName rebasing yields the 2990-byte private normal term (125 constructor nodes, 36 rewritten names). The 2940-byte counter term differs only in the two invalid error fields: `Validation(Invalid)` becomes `Constructor(Denied(403))`; both accepted reports and all other fields match.

JS and Native receipts, plan hashes, raw outputs, guards, and counter-oracle hashes join exactly; both outputs match the counter and reject the private normal oracle. This is finite evidence for the private copied-source mutant, not a universal proof, issue-wide closure, or performance result.
