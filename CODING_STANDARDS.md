# Review criteria

Use these criteria for reviewer judgement. [SPEC](docs/SPEC.md) and the governing issue supply contracts and acceptance gates; command-based checks belong in their linked workflows.

- **Authority:** API boundaries must carry the intended Bend types, affine owners and runtime authority. Evaluate arbitrary `Type` payloads as well as `Data`; justify restrictions against the contract. Review undeclared access, cross-schema misuse, writes through read and abstract-handle escape as separate failure paths.
- **Evidence:** Match each claim to the actual subject and scope checked. Distinguish model proofs, executable-function proofs, finite trace comparisons and universal runtime refinement. A report or elementary checker canary cannot stand in for an unmet capability or law-approval gate.
- **Simplifications:** Identify the capability sacrificed and its follow-up. A bounded slice must leave the remaining full-core obligations visible.
- **Performance:** Compare equivalent work and judge qualification against the governing contract. Prototype timings and a passing protected workload establish only their stated scope.

These criteria consolidate project instructions; files under `docs/reviews/` are historical review results, not additional normative standards.
