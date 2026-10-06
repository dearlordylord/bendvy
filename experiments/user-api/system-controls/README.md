# Body-indexed registration canaries

Run the repository checker with `experiments/user-api/system-controls/cases.json`.

Eight finite controls cover repeated closed user runner execution (2), intended runner substitution rejection, affine Registry duplication rejection, detached incorrect ID/name rejection (996), a fabricated namespace mismatch (996), and two actual Worlds from one returned affine Factory lineage, both registered as system ID1 with matching name/access but distinct namespaces (998). The fabricated namespace case is separate from the actual two-World case.

Cursor/retry control outputs107: first runner failure preserves ID1/cursor0 despite proposed cursor99, then same-owner success sets cursor7. Ordinary run preserves cursor. Rejection returns the original World, Registry and Args.

Public constructors remain trusted provisioning, not secret authority. Fabricated perfectly matching metadata is not universally excluded. These finite controls do not complete connected providers, ownership authority, universal refinement or performance acceptance. No new laws/proofs/dependencies.
