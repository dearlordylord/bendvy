# Corrected fixed128 oracle

The original c1d52 oracle incorrectly parsed `1n++more` as two successors. Bend
GUIDE.md Quantities declares `+x` reusable; successor syntax is `1n+p`.
Thus `1n++more` binds reusable `+more` under ONE successor, permitting the two
canonical recursive calls to consume the same predecessor independently. It does
not subtract two from fuel. typed.bend canonical struct64 reaches its empty
schema case after 64 tail steps with fuel64, returning exactly 64 declared fields
and dropping the extra input field. No accepted canonical truncation is observed
or claimed for this fixture.

Validation is separate: array root plus127 child expansions uses fixed128 fuel,
leaving child127 pending and returning FuelExhausted($[127]). These three bounded
array outcomes retain the original independent predictions. All other complete
fixture outcomes, original Raw cells/fields and affine sentinel remain intact.

Original expected-bounded.py/json, SHA c1d52b58395c8d3a6d5f08180695f690a9fe1a90dd557b2b47fee27df6b8b0ad,
and failed receipts are immutable. Corrected expected-bounded-v2.py/json are
separate artifacts; compare already retained runtime output without a backend
replay. Complete136077 oracle is unchanged. This corrects an oracle syntax error;
it does not change a decoder contract or conceal a backend failure.
