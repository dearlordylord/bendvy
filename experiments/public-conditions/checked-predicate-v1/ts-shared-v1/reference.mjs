import { Descriptor as D, Schema } from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const clone = value => JSON.parse(JSON.stringify(value));
export function run() {
  const output = [];
  for (const schema of ['Workshop', 'Garden']) {
    const Input = D.Resource()(schema + '/Input');
    const Counter = D.Resource()(schema + '/Counter');
    const Sentinel = D.Resource()(schema + '/Sentinel');
    const G = Schema.bind(Schema.fragment({ resources: { Input, Counter, Sentinel } }), Schema.defineRoot(schema));
    for (const [label, input, bypass] of [['missing-skipped', null, false], ['zero', 0, false], ['positive', 5, false], ['missing-reached', null, true]]) {
      const trace = [];
      const resources = { Counter: [10, 11], Sentinel: [900, 901] };
      if (input !== null) resources.Input = [input, input + 1];
      const runtime = G.Runtime.make({ services: G.Runtime.services(), resources, debug: true });
      // TS has only required resource declarations here. Missing Input is therefore
      // rejected at the schedule boundary, unlike Bend's optional left Check.
      const exists = G.Condition.check('exists-or-bypass', { resources: { input: G.System.readResource(Input) } }, ({ resources }) => {
        trace.push('left');
        return bypass || resources.input.get() !== undefined;
      });
      const required = G.Condition.check('positive', { resources: { input: G.System.readResource(Input) } }, ({ resources }) => {
        trace.push('right');
        return resources.input.get()[0] > 0;
      });
      const constant = value => G.Condition.check('constant-' + value, {}, () => {
        trace.push('constant:' + value);
        return value;
      });
      const guarded = G.Condition.and(constant(true), G.Condition.and(exists, required));
      const counter = G.System('guarded-counter', { resources: { counter: G.System.writeResource(Counter) } }, ({ resources }) => {
        trace.push('counter');
        const value = resources.counter.get()[0];
        resources.counter.set([value + 1, value + 2]);
      });
      const schedule = G.Schedule.when([guarded], counter);
      const probes = [
        ['not(exists)', G.Condition.not(exists)],
        ['true.or(required)', G.Condition.or(constant(true), required)],
        ['false.or(required)', G.Condition.or(constant(false), required)]
      ].map(([name, condition]) => [name, G.Schedule.when([condition], G.System('probe/' + name, {}, () => { trace.push('probe:' + name); }))]);
      const point = () => ({ world: clone(runtime.debug.dump()), streams: clone(runtime.debug.streams()), trace: [...trace] });
      const rows = [{ label: 'initial', ...point() }];
      const execute = (name, selected) => {
        const result = runtime.tryTick(selected);
        rows.push({ label: name, result: clone(result), ...point() });
      };
      const probe = stage => { for (const [name, selected] of probes) execute(stage + '/' + name, selected); };
      probe('initial-probe');
      execute('run1', schedule);
      probe('after-run1-probe');
      execute('run2', schedule);
      probe('final-probe');
      output.push({ schema, label, input, bypass, rows });
    }
  }
  return output;
}
console.log(JSON.stringify(run()));
