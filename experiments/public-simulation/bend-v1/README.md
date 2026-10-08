# Fixed-step public ECS simulation

The fixed seed0 scenario runs fourteen checkpoints for each of Workshop and
Garden. It registers independent readers, queues three spawns, applies explicit
barriers, moves entities toward goal2, damages/removes them, and reports hit and
death events. Reader B fails once and retries without advancing its unread
cursor on failure. Affine component arrays include sentinels and are observed
in full, including dead/reserved slots. No gameplay mutation uses a replacement
custom state loop.

From this workspace checkout:

```sh
BEND_NO_TELEMETRY=1 scripts/bend-check experiments/public-simulation/bend-v1/main.bend
BEND_NO_TELEMETRY=1 bend experiments/public-simulation/bend-v1/main.bend -o /tmp/bendvy-simulation.js
node /tmp/bendvy-simulation.js
```

The pure Data output contains every checkpoint. It can be parsed without losing
constructor fields, integer/Nat distinctions, array lengths or journals:

```sh
node /tmp/bendvy-simulation.js > /tmp/bendvy-simulation.stdout
python3 experiments/public-simulation/bend-v1/parse-report.py /tmp/bendvy-simulation.stdout
```

The development fixture imports this workspace's source-current `src/ecs` by
absolute path; portable executable packaging remains a delivery requirement.
Consumers run the entrypoint and need no provider implementation details.

See RESULT.md for the actual JS/Native/TS evidence and remaining qualification
gates. Development command durations include compilation/startup/printing and
are not comparative performance measurements. The unchanged #28 regression
gate and feature-specific equal-work timing remain required before final
qualification. A successful source check is not a universal ECS proof.
