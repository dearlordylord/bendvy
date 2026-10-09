# Managed System factory — bounded core delivery

Core integration `d8e96eb3` is qualified for the retained factory/cleanup scenarios.
Current source hashes remain exactly those accepted by the
[independent source/API review](INDEPENDENT-SOURCE-REVIEW.md):

- `system-cleanup.bend`: `cb545db8883bde3c20b5fbed7422e543f99be0ec2a8d974762e1af0bc089b940`.
- `system-instance.bend`: `ed76737a409f719cfa2073adcac316648348e91c6e52ab54d29d460e0b2069b6`.

Complete canonical factory normal and reached-mutant scenes pass JS and Native:
post-consumption observes 36 world/22 instance records; failed-batch observes
32/16. Each mutant changes exactly six componentClock leaves and retains every
other field. Independent [Native actual review](native-readiness-v1/INDEPENDENT-ACTUAL-AND-JS-REVIEW.md)
and [JS actual review](native-readiness-v1/INDEPENDENT-JS-ACTUAL-v2.md)
cover the whole outputs, 752/728 archived members and 40/28 guards.

The unchanged #28 Workshop gate passes independent
[actual audit](native-readiness-v1/DEFAULT-REGRESSION-ACTUAL-REVIEW.md),
including all 275 archived members, 110 complete application outputs and
20 paired observations per backend. Decision: `NO_CONFIRMED_REGRESSION`;
paired median ratios to frozen Bend baseline are JS 0.9179427800 and
Native 0.9937757449. Host contention is recorded, not ruled out.

This records the generic factory/cleanup slice, not full #48/#49 delivery.
Trusted closed schema templates remain trusted; no universal preservation proof,
capture finalizer or new initialization/identity policy is established.
Initial provisioning, machine scheduling adaptations and equivalent full-feature
performance remain separate owning gates. Workshop does not exercise this factory;
the complete feature scenes establish semantics, not comparative performance.
