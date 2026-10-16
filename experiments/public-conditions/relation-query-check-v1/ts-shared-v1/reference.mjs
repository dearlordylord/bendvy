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
    const { relation: Link } = D.Relation(schema + '/Link', schema + '/LinkedBy');
    const G = Schema.bind(Schema.fragment({
      components: { Primary, Bonus, Active, Hidden },
      resources: { Counter, Threshold, Sentinel }, relations: { Link }
    }), Schema.defineRoot(schema));

    const joined = G.Query({
      selection: { primary: G.Query.read(Primary), bonus: G.Query.optional(Bonus), targetAlias: G.Query.readRelation(Link) },
      with: [Active], without: [Hidden]
    });
    // Empty selection is intentional: With<Active> is row membership, not a
    // selected payload and not an added/changed cursor filter.
    const presence = G.Query({ selection: {}, with: [Active] });

    {
      const trace = [];
      const ids = [];
      const resources = { Counter: pair(10), Sentinel: pair(900) };
      resources.Threshold = pair(5);
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
          bonus: row.data.bonus.present ? { present: true, value: clone(row.data.bonus.get()) } : { present: false },
          targetAlias: clone(row.data.targetAlias.get())
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
          ids.push(commands.spawn(G.Command.spawn(...entries)));
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
      const relationWriter = relate => G.System(relate ? 'link-one-two' : 'unlink-one', {}, ({ commands }) => {
        if (relate) commands.relate(ids[0], Link, ids[1]);
        else commands.unrelate(ids[0], Link);
        trace.push({ system: relate ? 'link' : 'unlink', source: clone(ids[0]), ...(relate ? { target: clone(ids[1]) } : {}) });
      });
      const point = label => ({ label, world: clone(runtime.debug.dump()), streams: clone(runtime.debug.streams()), trace: clone(trace) });
      const rows = [point('empty')];
      const execute = (label, schedule) => {
        const result = runtime.tryTick(schedule);
        rows.push({ ...point(label), result: clone(result) });
      };
      execute('empty-guarded', guarded);
      execute('populate-pending', G.Schedule(spawn));
      execute('populate-visible', G.Schedule(G.Schedule.applyDeferred()));
      execute('no-edge-false', guarded);
      execute('link-pending', G.Schedule(relationWriter(true)));
      execute('link-still-false', guarded);
      execute('link-visible', G.Schedule(G.Schedule.applyDeferred()));
      execute('linked-true', guarded);
      execute('linked-true-repeat', guarded);
      execute('threshold-high', G.Schedule(thresholdWriter(50)));
      execute('threshold-false', guarded);
      execute('threshold-five', G.Schedule(thresholdWriter(5)));
      execute('threshold-true', guarded);
      execute('unlink-pending', G.Schedule(relationWriter(false)));
      execute('unlink-still-true', guarded);
      execute('unlink-visible', G.Schedule(G.Schedule.applyDeferred()));
      execute('unlinked-false', guarded);
      output.push({ schema, rows });
    }
  }
  return output;
}

console.log(JSON.stringify(run()));
