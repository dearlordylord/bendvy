# Shared #70 numeric comparison

Actual TS reference all four cases passed exact whole3940B oracle in actual-01/receipt.json. Actual Bend first A writer JS passed complete1979B oracle (author original34945; `/tmp/bendvy70-normal-a-js01/normal-js/receipt.json` + `consumer.stdout`, owned lossless `70-resource-confinement/experiments/public-resource-fields/runtime-v1/actual-normal-a-js01/ACTUAL.json`). Remaining9 cohort original53662 now passed: all four normal A/B writer/read cases each completed JS and Native with exact source-derived complete models. These compare selected resource contents/outcomes, not representation or ownership.

| A writer observation | TS actual | Bend A writer JS / Native actual |
|---|---|---|
| initial First / Second | [10,11,12,13] / [100,101,102,103] | same |
| commit First / Second | [12,13,14,15] / [110,111,112,113] | same |
| body commit observations | [10,100,11,12] | same |
| failed body observations | [12,110,13,14] | same selected prior/intermediate values; Data error retains12/110/13 |
| failure restored First / Second | [12,13,14,15] / [110,111,112,113] | same |
| retry First / Second | [14,15,16,17] / [120,121,122,123] | same |
| retry body observations | [12,110,13,14] | same |

TS failure host-call log retains four observed numeric entries, while Bend existing Failed result carries typed error three entries and drops affine Output. This is an explicit transport difference, not output parity. No IO/finalizer recovery contract inferred. Both actual implementations restore selected resource contents after expected failure using their actual transaction mechanisms. Rust Bevy selected resource access remains architectural authority; neither TS transaction implementation nor this comparison establishes generic Rust system rollback.

TS Other writer also passed Primary30..33/Secondary300..303→32..35/310..313→rollback→34..37/320..323, untouched values700/701 and flagsTrue/False. TS A/Other true Read passed all three invocations including failure input, output[first,second,first,second], no resource mutation. Corresponding Bend B writer and A/B Read JS/Native now matched their full source-derived models exactly. The two writer/read schemas therefore share selected numeric contents and operation order with actual TS; no model was changed using output. Wrong-field and incomplete-inverse JS controls also matched their independent countermodels and rejected the actual normal baseline; these are detected negative controls, not TS normal equivalence. All nine raw receipt/stdout hashes are bound in COMPARISON-BASIS.json, owned lossless archive runtime-v1/actual-remaining-v1.

TS nominal schemas are separately bound descriptor Symbols with ordinary JS arrays. Bend schemas are distinct Data types, equal payload Types are identity-indexed grants, and B physically nests affine sibling owners. TS untouched Sentinel is a separate descriptor payload, not an affine nested product. TS descriptor access metadata does not establish Bend cross-schema/wrongbinding/undeclared/readwrite/ownerduplication boundaries. Complete Bend World/registry/queue/clock observations and TS Inspector/metadata structures differ; only selected contents and shared operation order are compared. TS ticks/readers/symbol IDs are not normalized into Bend clocks/namespaces.
