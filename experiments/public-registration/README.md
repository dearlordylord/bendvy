# Exact registration disposal canary

Run `python3 experiments/public-registration/run.py --output <fresh-directory>`.
The current-source checker is capped at5s, emission30s, approved private Clang19
compilation120s and compiled execution5s. No compiler/kernel/dependency changes.

Six actual observations per JS/Native backend demonstrate: foreign namespace
removal refused; original first registration retained; exact first removal
accepted; first metadata absent; repeated removal refused; second registration
retained. This supplies a disposal seam for actual Local/reader instances;
it does not complete #31/#32/#36 or establish universal authority/proofs.

First source-bound run is retained locally under
`.artifacts/public-registration-first/receipt.json`. Full selected issue delivery
still requires its public runtime scenarios, mutations, negative controls,
independent review and frozen #28 regression gate.
