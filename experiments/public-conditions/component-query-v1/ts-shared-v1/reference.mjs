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

    const joined = G.Query({
      selection: { primary: G.Query.read(Primary), bonus: G.Query.optional(Bonus) },
      with: [Active], without: [Hidden]
    });
    // Empty selection is intentional: With<Active> is row membership, not a
    // selected payload and not an added/changed cursor filter.
    const presence = G.Query({ selection: {}, with: [Active] });

    for (const missingThreshold of [false, true]) {
      const trace = [];
      const resources = { Counter: pair(10), Sentinel: pair(900) };
      if (!missingThreshold) resources.Threshold = pair(5);
      const runtime = G.Runtime.make({ services: G.Runtime.services(), resources, debug: true });
      const anyActive = G.Condition.check('any_with_Active', {
        queries: { presence }
      }, ({ queries }) => {
        const rows = queries.presence.each().map(row => ({ id: row.entity.id, value: 'Unit' }));
        trace.push({ check: 'presence', rows: clone(rows) });
        return rows.length > 0;
      });
      const positive = G.Condition.check('joined-positive', {
        queries: { joined }, resources: { threshold: G.System.readResource(Threshold) }
      }, ({ queries, resources }) => {
        const rows = queries.joined.each().map(row => ({
          id: row.entity.id,
          primary: clone(row.data.primary.get()),
          bonus: row.data.bonus.present ? { present: true, value: clone(row.data.bonus.get()) } : { present: false }
        }));
        const threshold = clone(resources.threshold.get());
        trace.push({ check: 'joined', rows, threshold });
        return rows.length > 0 && threshold[0] < rows[0].primary[0];
      });
      const writer = G.System('increment', {
        resources: { counter: G.System.writeResource(Counter) }
      }, ({ resources }) => {
        const before = resources.counter.get()[0];
        resources.counter.set(pair(before + 1));
        trace.push({ system: 'increment', before });
      });
      const guarded = G.Schedule.when([G.Condition.and(anyActive, positive)], writer);
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
      const thresholdWriter = value => G.System('threshold-' + value, {
        resources: { threshold: G.System.writeResource(Threshold) }
      }, ({ resources }) => {
        const before = clone(resources.threshold.get());
        resources.threshold.set(pair(value));
        trace.push({ system: 'threshold', before, value: pair(value) });
      });
      const point = label => ({ label, world: clone(runtime.debug.dump()), streams: clone(runtime.debug.streams()), trace: clone(trace) });
      const rows = [point('empty')];
      const execute = (label, schedule) => {
        const result = runtime.tryTick(schedule);
        rows.push({ ...point(label), result: clone(result) });
      };
      if (!missingThreshold) {
        execute('empty-guarded', guarded);
        execute('threshold-high', G.Schedule(thresholdWriter(50)));
      }
      execute('populate-pending', G.Schedule(spawn));
      execute('populate-visible', G.Schedule(G.Schedule.applyDeferred()));
      if (missingThreshold) {
        // Public TS has no resource-removal counterpart to the Bend Slot
        // exchange. A fresh populated absent-threshold world records the
        // reference's schedule-union refusal without private mutation.
        execute('populated-missing-threshold', guarded);
      } else {
        execute('threshold-false', guarded);
        execute('threshold-five', G.Schedule(thresholdWriter(5)));
        execute('threshold-true', guarded);
        execute('threshold-true-repeat', guarded);
      }
      output.push({ schema, missingThreshold, rows });
    }
  }
  return output;
}

console.log(JSON.stringify(run()));
