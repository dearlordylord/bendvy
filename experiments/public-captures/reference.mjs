import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { Descriptor as D, Schema, Fx } from '../../.references/bevy-ts/packages/core/src/index.ts';

const observations = [];
for (const root of ['CapturesAlpha', 'CapturesBeta']) {
  const Ledger = D.Resource()(root + '/Ledger');
  const G = Schema.bind(Schema.fragment({ resources: { Ledger } }), Schema.defineRoot(root));
  const first = G.Runtime.make({ resources: { Ledger: { count: 0 } } });
  const second = G.Runtime.make({ resources: { Ledger: { count: 0 } } });
  const captures = [];
  function makeInstance(name, leftSeed, rightSeed) {
    const state = { left: [...leftSeed], right: [...rightSeed], runs: 0, fail: false };
    captures.push(state);
    const system = G.System(root + '/' + name, { resources: { ledger: G.System.writeResource(Ledger) } }, ({ resources }) => {
      state.runs += 1;
      state.left = state.left.map(value => value + 1);
      state.right = state.right.map(value => value + 10);
      resources.ledger.update(value => ({ count: value.count + 1 }));
      if (state.fail) return Fx.fail('CaptureFailure');
    });
    return { state, system };
  }
  const a = makeInstance('A', [11, 12], [21, 22]);
  const b = makeInstance('B', [101, 102], [201, 202]);
  const inspect = G.Inspector(root + '/LedgerView', { resources: { ledger: G.System.readResource(Ledger) } }, ({ resources }) => resources.ledger.get().count);
  const record = phase => observations.push({ root, phase,
    captures: captures.map(({ left, right, runs }) => ({ left: [...left], right: [...right], runs })),
    ledgers: [first.inspect(inspect), second.inspect(inspect)] });
  const execute = (runtime, system, ok = true) => {
    const result = runtime.tick(G.Schedule(system));
    assert.equal(result.ok, ok);
    if (!ok) assert.equal(result.error.error, 'CaptureFailure');
  };
  record('initial');
  execute(first, a.system); record('a-success');
  execute(first, a.system); record('a-repeat');
  const never = G.Condition.check(root + '/Never', {}, () => false);
  assert.equal(first.tick(G.Schedule.when([never], a.system)).ok, true); record('a-skipped');
  a.state.fail = true; execute(first, a.system, false); record('a-failed');
  execute(first, b.system); record('b-independent');
  a.state.fail = false; execute(first, a.system); record('a-retry');
  execute(second, a.system); record('same-definition-other-runtime');
}
assert.deepEqual(observations, JSON.parse(readFileSync(new URL('./expected.json', import.meta.url), 'utf8')));
console.log(JSON.stringify(observations));
