// Development reference only: subscription identity and lifecycle, not full #57.
import assert from 'node:assert/strict';
import { Descriptor, Schema } from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
import { readFileSync } from 'node:fs';

const Counter = Descriptor.Resource()('Trace/Counter');
const Game = Schema.bind(Schema.fragment({ resources: { Counter } }));
const runtime = Game.Runtime.make({ resources: { Counter: 9 }, debug: true });
const disabled = Game.Runtime.make({ resources: { Counter: 9 } });
const empty = Game.Schedule();
runtime.debug.nameSchedules({ empty });
const a = [], b = [], phases = [];
function detached(event) {
  const value = structuredClone(event);
  if ('ms' in value) {
    assert.equal(typeof value.ms, 'number');
    assert.ok(Number.isFinite(value.ms) && value.ms >= 0);
    value.ms = 0; // Only nondeterministic elapsed duration is normalized.
  }
  return value;
}
const listenerA = event => a.push(detached(event));
const listenerB = event => b.push(detached(event));
function tick(label) {
  runtime.tick(empty);
  phases.push({ label, a: structuredClone(a), b: structuredClone(b), dump: runtime.debug.dump() });
}
const stopA1 = runtime.debug.observe(listenerA);
const stopA2 = runtime.debug.observe(listenerA);
const stopB = runtime.debug.observe(listenerB);
tick('duplicate-callback');
stopA1();
tick('first-stop-removes-shared-callback');
stopA2(); stopB();
tick('last-stop');
const stopAgain = runtime.debug.observe(listenerA);
tick('resubscribe');
a.length = 0; // Collector reset, not a nonexistent Debug.Handle.reset API.
tick('collector-reset');
stopAgain(); stopAgain();
tick('idempotent-stop');
const actual = {
  disabledHandle: 'debug' in disabled,
  handleKeys: Object.keys(runtime.debug).sort(),
  phases
};
console.log(JSON.stringify(actual));
assert.deepEqual(actual, JSON.parse(readFileSync(new URL('./expected.json', import.meta.url))));
