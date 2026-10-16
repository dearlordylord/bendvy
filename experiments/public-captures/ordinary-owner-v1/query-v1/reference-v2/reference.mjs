import { Descriptor as D, Schema, Fx } from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';

const observations = [];
const clone = value => JSON.parse(JSON.stringify(value));
for (const root of ['CapturesQueryAlpha', 'CapturesQueryBeta']) {
  const Value = D.Component()('Value');
  const G = Schema.bind(Schema.fragment({ components: { Value } }), Schema.defineRoot(root));
  const runtime = G.Runtime.make({ debug: true });
  const state = { left: [1, 2], right: [3, 4], calls: 0, entered: 0,
    delta: 1, failValue: 0, readings: [] };
  const selected = G.Query({ selection: { value: G.Query.write(Value) }, filters: [G.Query.changed(Value)] });
  const Captured = G.System('captured-query', { queries: { rows: selected } }, ({ queries }) => {
    state.calls += 1;
    const reading = [];
    state.readings.push(reading);
    for (const row of queries.rows.each()) {
      const old = row.data.value.get();
      reading.push(old);
      row.data.value.set(old + state.delta);
      // This is deliberately inside actual query iteration: both captured
      // Arrays change for every entered row, including the failing later row.
      state.entered += 1;
      state.left = state.left.map(value => value + state.delta);
      state.right = state.right.map(value => value + state.delta * 10);
      if (old === state.failValue) return Fx.fail({ failedAt: old });
    }
  });
  let first;
  const Populate = G.System('populate', {}, ({ commands }) => {
    first = commands.spawn(G.Command.spawn([Value, 10]));
    commands.spawn(G.Command.spawn([Value, 20]));
    commands.spawn(G.Command.spawn());
  });
  const External = G.System('external', {}, ({ commands }) => { commands.insert(first, [Value, 30]); });
  const never = G.Condition.check('never', {}, () => false);
  const record = (phase, result = null) => observations.push({ root, phase, result: clone(result),
    capture: clone(state), world: clone(runtime.debug.dump()),
    population: clone(runtime.debug.population()), streams: clone(runtime.debug.streams()) });
  const run = (phase, delta, failValue = 0) => {
    state.delta = delta; state.failValue = failValue;
    const result = runtime.tick(G.Schedule(Captured));
    if (result.ok !== (failValue === 0)) throw new Error('Unexpected query outcome');
    record(phase, result);
  };
  record('initial');
  run('empty', 1);
  record('populated', runtime.tick(G.Schedule(Populate, G.Schedule.applyDeferred())));
  run('late-failure', 1, 20);
  run('retry', 2);
  run('no-changes', 9);
  record('external', runtime.tick(G.Schedule(External, G.Schedule.applyDeferred())));
  run('changed-one', 3);
  record('skip', runtime.tick(G.Schedule.when([never], Captured)));
}
console.log(JSON.stringify(observations));
