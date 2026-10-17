import { Schema, Descriptor as D, Decode } from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';

const clone = value => JSON.parse(JSON.stringify(value, (_key, item) => item === undefined ? { undefined: true } : item));
const result = value => value.ok ? { ok: true } : { ok: false, error: clone(value.error) };
const failure = value => ({ operation: value.operation, relation: value.relation.name, source: value.source.value, target: value.target.value, error: clone(value.error) });
function run(root) {
  const Name = D.ConstructedComponent(Decode.string)('Name');
  const Score = D.ConstructedResource(Decode.integer)('Score');
  const Spare = D.ConstructedResource(Decode.integer)('Spare');
  const Cache = D.TransientResource()('Cache');
  const Ping = D.Event()('Ping');
  const { relation: Link } = D.Relation('Link', 'LinkedBy');
  const { relation: Parent } = D.Hierarchy('Parent', 'Children');
  const G = Schema.bind(Schema.fragment({ components: { Name }, resources: { Score, Spare, Cache }, events: { Ping }, relations: { Link, Parent } }), Schema.defineRoot(root));
  const Mode = G.StateMachine('Mode', [0, 1, 2]);
  const Weather = G.StateMachine('Weather', [7, 8, 9]);
  const made = G.Runtime.make({ resources: { Score: 5, Spare: 7, Cache: 9 }, machines: G.Runtime.machines(G.Runtime.machine(Mode, 0), G.Runtime.machine(Weather, 9)), debug: true });
  if (!made.ok) throw Error('fixture construction failed');
  const runtime = made.value, ids = [], history = [], trace = [];
  const reader = name => G.System(name, { events: { ping: G.System.readEvent(Ping) }, transitionEvents: { mode: G.System.readTransitionEvent(Mode), weather: G.System.readTransitionEvent(Weather) }, relationFailures: { link: G.System.readRelationFailures(Link) } }, ({ events, transitionEvents, relationFailures }) => {
    history.push(clone({ reader: name, ping: events.ping.all(), mode: transitionEvents.mode.all(), weather: transitionEvents.weather.all(), failures: relationFailures.link.all().map(failure) }));
  });
  const fast = reader('fast'), slow = reader('slow');
  const state = label => clone({ label, snapshot: runtime.snapshot(), dump: runtime.debug.dump(), streams: runtime.debug.streams(), history, trace });
  const rows = [state('fresh')];
  const tick = (...steps) => { const value = runtime.tick(...steps.map(step => G.Schedule(step))); if (!value.ok) throw Error('fixture tick failed'); };
  const seed = G.System('seed', { events: { ping: G.System.writeEvent(Ping) }, nextMachines: { mode: G.System.nextState(Mode), weather: G.System.nextState(Weather) } }, ({ commands, events, nextMachines }) => {
    for (const name of ['a', 'b', 'c']) ids.push(commands.spawn(G.Command.spawn([Name, name])));
    commands.relate(ids[2], Link, ids[0]); commands.relate(ids[1], Link, ids[0]);
    commands.relate(ids[1], Parent, ids[0]); commands.relate(ids[0], Link, ids[0]);
    events.ping.emit(17); nextMachines.mode.set(1); nextMachines.weather.set(8); trace.push({ system: 'seed', ids: ids.map(id => id.value) });
  });
  const queued = G.System('queued', { events: { ping: G.System.writeEvent(Ping) }, nextMachines: { mode: G.System.nextState(Mode), weather: G.System.nextState(Weather) } }, ({ commands, events, nextMachines }) => {
    const pending = commands.spawn(G.Command.spawn([Name, 'pending']));
    events.ping.emit(23); nextMachines.mode.set(2); nextMachines.weather.set(7); trace.push({ system: 'queued', pending: pending.value });
  });
  tick(fast, slow, seed, G.Schedule.applyStateTransitions(), fast, queued);
  rows.push(state('populated-pending'));
  const entities = [{ id: 1, components: { Name: 'x' } }, { id: 2, components: { Name: 'y' } }, { id: 3, components: { Name: 'z' } }];
  const saved = { version: 1, nextEntity: 4, entities, relations: { Link: [[2, [3, 1]]], Parent: [[1, [2, 3]]] }, resources: { Score: 42 }, machines: { Mode: 2 } };
  const restored = result(runtime.restore(saved)); rows.push({ ...state('restored'), result: restored });
  tick(fast, slow); rows.push(state('readers-after-restore'));
  const omitted = { version: 1, nextEntity: 4, entities, relations: {}, resources: {}, machines: {} };
  const partial = result(runtime.restore(omitted)); rows.push({ ...state('omitted-machines-resources'), result: partial });
  tick(slow); rows.push(state('retained-slow-reader'));
  return { root, rows };
}
process.stdout.write(JSON.stringify(['Workshop', 'Garden'].map(run)) + '\n');
