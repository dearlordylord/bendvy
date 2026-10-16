import { Descriptor as D, Schema, Fx } from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const observations = [];
const clone = value => JSON.parse(JSON.stringify(value));
for (const root of ['CapturedScheduleAlpha', 'CapturedScheduleBeta']) {
  const Value = D.Component()('Value');
  const Counter = D.Resource()('Counter');
  const G = Schema.bind(Schema.fragment({ components: { Value }, resources: { Counter } }), Schema.defineRoot(root));
  const runtime = G.Runtime.make({ resources: { Counter: 10 }, debug: true });
  const queryCapture = { left: [1, 2], right: [3, 4], calls: 0, readings: [] };
  const resourceCapture = { values: [100, 101], calls: 0, readings: [] };
  const args = { queryDelta: 1, resourceDelta: 10, resourceFail: false, resourceEnabled: true };
  let order = [];
  const query = G.Query({ selection: { value: G.Query.write(Value) }, filters: [G.Query.changed(Value)] });
  const Query = G.System('captured-query', { queries: { rows: query } }, ({ queries }) => {
    order.push('query'); queryCapture.calls++;
    const seen = []; queryCapture.readings.push(seen);
    for (const row of queries.rows.each()) {
      const old = row.data.value.get(); seen.push(old);
      row.data.value.set(old + args.queryDelta);
      queryCapture.left = queryCapture.left.map(x => x + args.queryDelta);
      queryCapture.right = queryCapture.right.map(x => x + args.queryDelta * 10);
    }
  });
  const Resource = G.System('resource-counter', { resources: { counter: G.System.writeResource(Counter) } }, ({ resources }) => {
    order.push('resource'); resourceCapture.calls++;
    const old = resources.counter.get(); resourceCapture.readings.push(old);
    resources.counter.set(old + args.resourceDelta);
    resourceCapture.values = resourceCapture.values.map(x => x + args.resourceDelta);
    if (args.resourceFail) return Fx.fail('ResourceFailed');
  });
  const enabled = G.Condition.check('resource-enabled', {}, () => { order.push('condition'); return args.resourceEnabled; });
  const outer = G.System('outer', {}, () => { order.push('outer'); });
  const inner = G.System('inner', {}, () => { order.push('inner'); });
  const nested = G.Schedule(outer, G.Schedule(G.Schedule(Query, inner), G.Schedule(G.Schedule.when([enabled], Resource), G.Schedule.applyDeferred())));
  const Populate = G.System('populate', {}, ({ commands }) => {
    commands.spawn(G.Command.spawn([Value, 10]));
    commands.spawn(G.Command.spawn([Value, 20]));
    commands.spawn(G.Command.spawn());
  });
  const record = (phase, result) => observations.push({ root, phase, result: clone(result), args: clone(args),
    order: [...order], queryCapture: clone(queryCapture), resourceCapture: clone(resourceCapture),
    world: clone(runtime.debug.dump()), population: clone(runtime.debug.population()), streams: clone(runtime.debug.streams()) });
  record('populated', runtime.tick(G.Schedule(Populate, G.Schedule.applyDeferred())));
  for (const [phase, delta, fail, allow] of [['first', 10, false, true], ['resource-skip', 999, false, false], ['resource-failure', 2, true, true], ['retry', 3, false, true]]) {
    args.resourceDelta = delta; args.resourceFail = fail; args.resourceEnabled = allow; order = [];
    const result = runtime.tick(nested);
    if (result.ok === fail) throw new Error('Unexpected nested outcome');
    record(phase, result);
  }
}
console.log(JSON.stringify(observations));
