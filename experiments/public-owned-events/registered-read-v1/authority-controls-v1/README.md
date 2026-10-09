# Registered owned-reader authority controls (#53)

Source-current controls invoke the actual `../log.bend` `Log.read`, integrated scoped-read provider and canonical capability module. The positive control consumes an Array-containing payload log and returns an independently owned `Array<U32>` observation through that entry.

Four intended source refusals are retained verbatim: duplicate opaque owner (consumed more than once), read Request supplied where ValueWrite is required, opaque H capability escaping as fixed Payload capability at the actual Log.read callback argument, and nominal OtherSchema Reader supplied to canonical Ev.skip for F.Schema. The cross-schema case checks static schema identity, not independent runtime namespace creation. All imports parse; refusals identify these exact owner/type boundaries.

The controls ran once each using existing source5 helper and shared child lock; results.json records actual exits and diagnostics. Positive exit0; four negatives exit1. No backend run, public signature change, law/proof, new policy or universal provider-immutability claim. `source-pins.json` binds the actual module closure for installed-host source evidence, not clean-checkout qualification.

The existing registered-read README records the remaining declared-access integration gap: trusted at operations are not automatically proved immutable or checked against system access declarations by Log.read. Public World integration/authority and retirement/disposal choices remain open.
