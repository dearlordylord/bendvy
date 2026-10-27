# Browser demonstration

The interactive adapter uses the same declaration-driven generalized Root as
[the health-decay application](../README.md). It retains the actual application
and passive inspector between clicks. JavaScript displays component observations;
Bend performs the health updates and deferred spawning.

From the repository root:

```sh
bash examples/health-decay/demo/build.sh
python3 -m http.server 8000 --directory examples/health-decay
```

Open `http://localhost:8000/demo/`. Tick runs one decay update. Reset registers
fresh owners and publishes three real spawn commands before rendering. The
third entity remains visible with health 30 and no HealthDecay.

The emitted module exports `start(Unit)` and `step(State)` as compiled IO
computations. [run-io.mjs](run-io.mjs) executes their generated continuation and
foreign-effect records, including the canonical execution driver. The browser
retains only each returned affine State.
This synchronous bridge follows the compiler-emitted `io_run` continuation
protocol for this module's driver effect. It does not schedule asynchronous IO.

Generated modules in `dist/` are ignored. No browser framework is required.
The emitted start and one Tick were executed after migration with their complete
three-entity JSON observations. Real-browser interaction has not been rerun.
The preserved smoke files describe the earlier synchronous API and are historical
verification infrastructure, not evidence for the replacement runtime.
