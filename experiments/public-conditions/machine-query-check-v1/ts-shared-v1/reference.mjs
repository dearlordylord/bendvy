import { Descriptor as D, Schema } from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';

const clone = value => JSON.parse(JSON.stringify(value));
const pair = value => [value, value + 1];

export function run() {
  const output = [];
  for (const schema of ['Workshop', 'Garden']) {
    const Primary = D.Component()(schema + '/Primary');
    const Bonus = D.Component()(schema + '/Bonus');
    const Active = D.Tag(schema + '/Active');
    const Hidden = D.Tag(schema + '/Hidden');
    const Counter = D.Resource()(schema + '/Counter');
    const Threshold = D.Resource()(schema + '/Threshold');
    const Sentinel = D.Resource()(schema + '/Sentinel');
    const G = Schema.bind(Schema.fragment({
      components: { Primary, Bonus, Active, Hidden },
      resources: { Counter, Threshold, Sentinel }
    }), Schema.defineRoot(schema));

    const Flow = G.StateMachine(schema + '/Mode', [0, 1]);
    const joined = G.Query({
      selection: { primary: G.Query.read(Primary), bonus: G.Query.optional(Bonus) },
      with: [Active], without: [Hidden]
    });
    for (const missingMachine of [false, true]) {
      const trace = [];
      const resources = { Counter: pair(10), Threshold: pair(5), Sentinel: pair(900) };
      const machines = missingMachine ? G.Runtime.machines() : G.Runtime.machines(G.Runtime.machine(Flow, 0));
      const runtime = G.Runtime.make({ services: G.Runtime.services(), resources, machines, debug: true });
      // TS exposes a required machine read. This is not an optional CurrentView:
      // the absent-machine session records schedule preflight before callbacks.
      const anyMachine = G.Condition.check('machine-presence', {
        machines: { flow: G.System.machine(Flow) }
      }, ({ machines }) => {
        const current = machines.flow.get();
        trace.push({ check: 'machine-presence', current });
        return current !== undefined;
      });
      const positive = G.Condition.check('query-threshold-mode', {
        queries: { joined }, resources: { threshold: G.System.readResource(Threshold) },
        machines: { flow: G.System.machine(Flow) }
      }, ({ queries, resources, machines }) => {
        const rows = queries.joined.each().map(row => ({
          id: row.entity.id,
          primary: clone(row.data.primary.get()),
          bonus: row.data.bonus.present ? { present: true, value: clone(row.data.bonus.get()) } : { present: false }
        }));
        const threshold = clone(resources.threshold.get());
        const current = machines.flow.get();
        trace.push({ check: 'query-threshold-mode', rows, threshold, current });
        return rows.length > 0 && threshold[0] < rows[0].primary[0] && current === 0;
      });
      const writer = G.System('increment', {
        resources: { counter: G.System.writeResource(Counter) }
      }, ({ resources }) => {
        const before = resources.counter.get()[0];
        resources.counter.set(pair(before + 1));
        trace.push({ system: 'increment', before });
      });
      const guarded = G.Schedule.when([G.Condition.and(anyMachine, positive)], writer);
      const spawn = G.System('populate-five', {}, ({ commands }) => {
        for (let index = 1; index <= 5; index++) {
          const entries = [];
          if (index !== 4) entries.push([Primary, pair(index * 10)]);
          if (index !== 2 && index !== 5) entries.push([Bonus, pair(index * 100)]);
          if (index !== 5) entries.push([Active, {}]);
          if (index === 3) entries.push([Hidden, {}]);
          commands.spawn(G.Command.spawn(...entries));
        }
        trace.push({ system: 'populate-five' });
      });
      const queue = value => G.System('queue-mode-' + value, {
        machines: { flow: G.System.machine(Flow) },
        nextMachines: { flow: G.System.nextState(Flow) }
      }, ({ machines, nextMachines }) => {
        const current = machines.flow.get();
        const before = nextMachines.flow.getPending();
        nextMachines.flow.set(value);
        const after = nextMachines.flow.getPending();
        trace.push({ system: 'queue-mode', current, beforePending: before === undefined ? null : before, afterPending: after, requested: value });
      });
      const point = label => ({ label, world: clone(runtime.debug.dump()), streams: clone(runtime.debug.streams()), trace: clone(trace) });
      const rows = [point('empty')];
      const execute = (label, schedule) => {
        const result = runtime.tryTick(schedule);
        rows.push({ ...point(label), result: clone(result) });
      };
      execute('populate-pending', G.Schedule(spawn));
      execute('populate-visible', G.Schedule(G.Schedule.applyDeferred()));
      if (missingMachine) {
        // Defined Flow is deliberately unprovided via public Runtime.machines().
        // TS rejects its schedule requirement union before either Check callback.
        execute('populated-missing-machine', guarded);
      } else {
        execute('mode0-true', guarded);
        execute('queued1-current0', G.Schedule(queue(1)));
        execute('queued1-still-true', guarded);
        execute('mode1-applied', G.Schedule(G.Schedule.applyStateTransitions()));
        execute('mode1-false', guarded);
        execute('queued0-current1', G.Schedule(queue(0)));
        execute('mode0-applied', G.Schedule(G.Schedule.applyStateTransitions()));
        execute('mode0-true-again', guarded);
      }
      output.push({ schema, missingMachine, rows });
    }
  }
  return output;
}

console.log(JSON.stringify(run()));
