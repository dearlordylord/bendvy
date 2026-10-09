# UTF16 field names — source-backed proposal, not an adopted contract

Pinned `decode-utf16.bend` distinguishes scalar Bend String from JS UTF16.
`Raw.Utf16Text` already preserves lone surrogates; `Field.name`,
`NamedCodec.name`, `Work.path` and `Error.Invalid.path` still use String.
The unchanged host adapter accepts arbitrary JS strings in Text and field
names. Therefore exact transfer of lone-surrogate names is currently absent.
No invalid Chr, replacement character, renaming or new default refusal is used.

Smallest additive representation candidate:

- Retain `Field{name:String,value:Raw}`; add `Utf16Field{units:List<U32>,value:Raw}`.
- Retain `NamedCodec{name:String,codec:Codec}`; add a units-key alternative.
- Keep scalar lookup helpers and scalar error constructors. Add units lookup,
  work and error-path alternatives; never render lone surrogates into String.
- Compare keys through existing logical UTF16 units (`Utf16.text` for scalar
  keys). Preserve first-match lookup, original order and duplicate fields.
- Canonical scalar codecs still emit the old scalar Field shape; units codecs
  emit their original units. No eager normalization or key deduplication.

Evidence: `decode-data.bend:48` selects the first equal field;
`:132` appends `"." + name` to the path; `:205` canonicalizes in declared-codec
order. Existing `decode-utf16.bend` provides checked units/text equality.
These semantics must remain unchanged for old scalar declarations.

Required pre-output controls: scalar astral key versus equivalent surrogate
pair; lone-surrogate keys; duplicate logical keys across representations;
unknown nested properties; field order; exact original units in success and
error paths; unchanged scalar lookup/canonical/error output. Existing host
issues retain JS property/path objects separately and must not be fabricated
from a Bend path string.

Root owns any shared Raw/codec/error interface change. This packet establishes
the representability gap and proposed compatibility checks, not implementation,
new identity policy, approval or full-host acceptance.
