# Canonical prerequisite readiness

The complete candidate imports these **unchanged, currently untracked** root
modules to preserve one nominal Raw/Codec identity with #58:

| Module | Executed SHA256 | Responsibility |
|---|---|---|
| `experiments/public-decode/typed.bend` | `bbba271bff35d94e564c0b33f994737c8698942c3d05f9ffc71697c5c8185d26` | Raw/Codec/Checked/Owned/Receipt, validation, numeric/literal checks, owner-preserving canonical decoding |
| `experiments/public-decode/utf16.bend` | `343820522ad7d9724154d48266a3b6c30626cc62f83ec85038c96242c9d96539` | Valid UTF-16 units, scalar-text conversion and exact equality, including lone surrogate representation |

Neither module was edited by this work. Both exact consumed sources are retained
in the development packet with JS/Native/mutant plan joins. The canonical
`typed.bend` hash also matches the earlier #58 Gate candidate prerequisite.
Installed Base remains a separately bound compiler prerequisite. Receipt/source
snapshots establish historical development observations, not a currently
qualified clean-checkout library or a new decoder contract.

Next action: independently review these exact two immutable source snapshots
against #46's existing contracts and prior controls. The root integrator can
then admit their exact existing bytes into Git at the canonical paths, after
checking live bytes still match. If the review requires behavior changes,
prepare a distinct source candidate and qualify those changes; never rewrite
old snapshots or assign their receipts to changed code. Public SDK adoption
and complete delivery remain separate after this prerequisite admission.

The lower-level caller-fuel API stays explicit; this candidate adds automatic
budget derivation without inventing a generic Raw-to-arbitrary-Type inverse,
changing duplicate-key policy, or deciding unresolved ownership contracts.
