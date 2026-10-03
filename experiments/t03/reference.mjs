import { Descriptor, Schema } from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
function replay(name, initial, delta, armor) {
  const Value = Descriptor.Component()(name + '/Value');
  const Delta = Descriptor.Component()(name + '/Delta');
  const Armor = Descriptor.Component()(name + '/Armor');
  const components = armor === undefined ? { Value, Delta } : { Value, Delta, Armor };
  const G = Schema.bind(Schema.fragment({ components }));
  const rt = G.Runtime.make({ services: G.Runtime.services(), resources: {} });
  const Spawn = G.System(name + '/Spawn', {}, ({commands}) => {
    const bundle = [[Value, initial], [Delta, delta]];
    if (armor !== undefined) bundle.push([Armor, armor]);
    commands.spawn(G.Command.spawn(...bundle));
  });
  const q = G.Query({selection:{value:G.Query.write(Value),delta:G.Query.read(Delta)}});
  const Step = G.System(name + '/Step', {queries:{q}}, ({queries}) => {
    for (const m of queries.q.each()) m.data.value.update(v => name === 'Motion' ? v + m.data.delta.get() : v - m.data.delta.get());
  });
  const selection = {value:G.Query.read(Value),delta:G.Query.read(Delta)};
  if (armor !== undefined) selection.armor = G.Query.read(Armor);
  const Observe = G.System(name + '/Observe', {queries:{q:G.Query({selection})}}, ({queries}) => {
    for (const m of queries.q.each()) console.log(Object.values(m.data).map(c => c.get()).join(','));
  });
  rt.tick(G.Schedule(Spawn, G.Schedule.applyDeferred()));
  const step = G.Schedule(Step);
  for (let i=0;i<3;i++) rt.tick(step);
  rt.tick(G.Schedule(Observe));
}
replay('Motion',0,2);
replay('Health',20,3,1);
