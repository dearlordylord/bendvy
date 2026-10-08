# Independent complete decoder controls

Authored full eight-case Bend oracle before inspecting any Bend runtime output.
`expected-complete.json` SHA256:
`13607718be581d8b76de1db1cc0e6439e0c60a7f5641a9dfd1eb4f7578cc83c2`.
It retains every original Raw cell/field, affine sentinel [111,222], complete
Accepted/Rejected value and nested path. Valid arrays contain 128 and 256 cells;
late invalid cell is index 127. Struct has 64 declared unique fields plus one
unknown extra: accepted output contains exactly 64 declaration-ordered fields.
Nested nullable array/struct tests include null, valid values and a missing late
field. No duplicate Raw-object policy or structural array-literal equality is
introduced. Existing duplicate-containing bounded counterexample remains separate.

Actual pinned bevy-ts Decode Node development trace passed the independently
specified eight records under central task_runner, CPU5, five-second cap,
child-only shared lock, exact source/oracle/binary pre/post/final pins. Raw stdout
SHA256 `f5971f2df662780e036cadd45adfc18733021641224261f3dda14cc289544d13`.
Expected TS JSON SHA256
`16a2bb4a9545bedaee8be91f8e5cc0f62d6a1b029897ff4e9d6e7bc7af7e4280`.
Receipt/raw/plan are in actual-reference-v1. This is direct development evidence,
not complete installed-tool/resolver or #46 delivery qualification.

Pinned Decode.ts array traverses all entries; struct constructs a fresh object
using all declaration keys and drops unknown input fields. Integer means safe
integer. Exact missing nested path is $.items[1].value. TS actual undefined is
recorded explicitly as {undefined:true}; Bend typed Raw uses Missing{}, a
representation difference retained in the oracle, not erased by JSON omission.
Bend oracle constructor-neutral representation requires an explicit complete
formatter or constructor join before any runtime claim. No Bend backend or
mathematical proof was executed by this independent author.
