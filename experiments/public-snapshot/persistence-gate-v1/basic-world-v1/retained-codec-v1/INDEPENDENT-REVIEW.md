# Independent pre-runtime oracle review

Authored before backend execution. `independent-oracle.py` reconstructs the complete
report from fixture operations; `independent-oracle.json` contains both schemas.
Neither reads runtime output. It extends the existing independent BasicWorld
model without projecting away any owner, snapshot or validation field.

Expected JSON SHA256: `04bc4311e5fa671cb6075c196d0aa08a94d4c87d3206d81dcd2b3a13069aaeb6`.

The first two saves and their owner observations are unchanged. Initial component
codec is Array<Integer>, resource codec Nullable<Array<FiniteNumber>>. Mutation
changes only saved row 1, saved resource, and their retained codecs. Earlier
snapshots remain detached. Both validation passes use the post-mutation factory
witness: earlier resource rejects at `$`, expected `literal`, actual [27,29];
after resource accepts [31,33]. Components remain accepted. Metadata records both
actual factory codec variants before and after mutation.

Source review: `runtime_view_taken` mirrors `Col.view_taken`: rejection/absence
returns the actual Column; present owner passes through Gate export then
`Col.viewed`. Plain Columns remove and restore the same owner through Array.swap,
retaining stamps. Indexed and prepared variants use the same public restoration
seams. This fixture constructs ordinary Columns, so prepared variant execution is
not claimed. No lifecycle/world-clock change is introduced by this transport.
Projection uses Array.get and returns the actual affine Array. Resource export
likewise returns saved and transient owners and retained codec. Diagnostic
validation extracts codec from the actual Gate witness, then returns World.

No blocker found for one development JS execution with whole-report equality.
This is not runtime evidence, Native qualification, full #58 delivery, arbitrary
codec/property coverage, or public save validation. Gate intentionally exports
without decoding. Existing mutation helper ignores a rejected replacement owner;
its use is limited here to an already ensured valid row 1, not a general mutation
API guarantee. Renderer is a closed fixture renderer, not a generic serializer.

Sources inspected: retained-codec-v1 consumer/save/validation/driver/output/format;
BasicWorld fixture/setup/model; current src/ecs/column.bend view/swap/restoration;
canonical public-decode/typed.bend literal and owned validation.
