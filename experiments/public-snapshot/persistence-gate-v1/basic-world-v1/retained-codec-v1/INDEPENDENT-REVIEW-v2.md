# Supported retained-codec oracle v2

The original 04bc oracle assumed structural equality for Literal(Array). That
assumption was wrong. Preserve its JSON and the actual direct-JS failure.
Canonical typed.bend `equal` handles scalar, text and numeric representations;
arrays yield NotNumber and do not compare equal, even with matching elements.
Pinned bevy-ts Decode.ts:113 restricts literal alternatives to string, number,
boolean or null. Deep array literal equality is not required by #46's TS parity
contract. This is an invalid fixture assumption, not evidence to silently change
the shared decoder. The historical low-level Raw-valued Literal permits an array
syntactically but provides no structural equality promise.

Before changing candidate sources or running their backend, v2 independently
specifies a supported codec: ArrayValue<LiteralValues([Number31,Number33])>.
The entire array payload and complete two-schema workload remain. Earlier resource
[27,29] rejects at `$[0]` with expected `literal` and actual 27; after [31,33]
accepts both elements. Owner and actual Gate metadata show the complete nested
codec. All prior owner, stamps, allocation, resource, snapshot and component
observations remain in the full oracle. This changes the fixture codec explicitly;
it does not correct/rebind the original failed execution.

Oracle v2 JSON SHA256:
`9682fe82bd7aa2cc54c9b6feb731616497231a6e8a8065fc7a40f1c68d4d9bcf`.
No backend execution performed by the independent author. Old review's claim that
Literal(Array[31,33]) accepts [31,33] is superseded by this source-backed finding.
