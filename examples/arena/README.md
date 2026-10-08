# Little arena

A small playable browser game using the public Bendvy ECS API. Collect gold,
dodge six chasers, and survive with five health points. WASD/arrows move,
Space pauses, and R restarts. Keyboard required.

From the repository root, using the existing Bend installation:

```sh
examples/arena/build.sh
node examples/arena/test.mjs
node examples/arena/host-smoke.mjs
python3 -m http.server 8000 --directory examples/arena
```

Open <http://localhost:8000>. No npm packages or external assets are needed.
The generated `dist/` is ignored; build it before serving.

`game.bend` owns the ECS world, typed Body component family, required query,
declared write capability, movement, chase, collisions, pickups and health.
Bootstrap queues 17 spawns and applies an explicit barrier. The query threads
an abstract affine context and commits component updates transactionally.
`browser.mjs` handles keys, a fixed 60 Hz clock and canvas drawing. It consumes
each returned State once; the previous owner must not be reused.

This deliberately small example uses one compound component, `Compose.each`
directly, and a single world. It does not demonstrate System registration,
schedules, resources,
events, relations or complete parity. Creation uses the existing trusted
single-world Factory setup; no handles escape to the host or survive restart.
Gameplay checks are finite executable controls, not new approved laws or proofs.
The example adds no ECS behavior or performance qualification; its compatibility
fix only gives internal world-scan constructors distinct names.

Optional browser smoke test, with an already installed Playwright:

```sh
node examples/arena/browser-smoke.mjs
```

If Playwright is installed elsewhere, set `PLAYWRIGHT_MODULE` to its module path.
Pass a screenshot filename as the first argument to save a browser preview.

Current validation and the browser-environment limitation: [CHECKS.md](CHECKS.md).
