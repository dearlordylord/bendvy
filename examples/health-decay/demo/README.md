# Browser demonstration

This directory contains only display/host code. The ECS example lives one level above; its sources do not import the demo.

From the repository root:

```sh
bash examples/health-decay/demo/build.sh
node examples/health-decay/demo/smoke.mjs
python3 -m http.server 8000 --directory examples/health-decay
```

Open `http://localhost:8000/demo/`. Click **Tick** to execute the real Bend query or **Reset** to create the initial world again. The adapter reads all three entities from the world, including the unselected one. JS draws those observations; it does not compute the health updates.

Generated modules in `dist/` are ignored. No browser framework or additional package is required.

An optional UI smoke check can reuse an installed Playwright via
`PLAYWRIGHT_MODULE=/absolute/path/to/playwright/index.mjs node examples/health-decay/demo/browser-smoke.mjs`.
The standard build and Node check need no Playwright.
