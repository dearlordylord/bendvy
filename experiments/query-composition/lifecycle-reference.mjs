// Actual public TS lifecycle observations; immutable reference checkout.
import {Descriptor as D, Schema, Fx} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const A = D.Component()('A');
const W = Schema.bind(Schema.fragment({components: {A}}));
const rt = W.Runtime.make({services: W.Runtime.services()});
const rows = [], independent = [];
let fail = true;
const seed = W.System('seed', {}, ({commands}) => {
  commands.spawn(W.Command.spawn([A, {value: 1, owned: [10, 11, 12]}]));
});
const q = W.Query({selection: {a: W.Query.write(A)}, filters: [W.Query.changed(A)]});
const self = W.System('self', {queries: {q}}, ({queries}) => {
  const found = queries.q.each();
  rows.push({count: found.length, before: found.map(({data}) => structuredClone(data.a.get()))});
  for (const {data} of found) data.a.set({value: 2, owned: [20, 21, 22]});
  return fail ? Fx.fail('Rejected') : Fx.succeed(undefined);
});
const read = W.Query({selection: {a: W.Query.read(A)}, filters: [W.Query.changed(A)]});
const other = W.System('other', {queries: {read}}, ({queries}) => {
  independent.push(queries.read.each().map(({data}) => structuredClone(data.a.get())));
});
rt.tick(W.Schedule(seed, W.Schedule.applyDeferred()));
const failed = rt.tick(W.Schedule(self));
rt.tick(W.Schedule(other));
fail = false;
rt.tick(W.Schedule(self));
rt.tick(W.Schedule(self));
rt.tick(W.Schedule(other));
rt.tick(W.Schedule(other));
const result = {failed, rows, independent};
const expected = {
  failed: {ok: false, error: {kind: 'SystemFailure', system: 'self', error: 'Rejected'}},
  rows: [{count: 1, before: [{value: 1, owned: [10, 11, 12]}]},
         {count: 1, before: [{value: 1, owned: [10, 11, 12]}]},
         {count: 0, before: []}],
  independent: [[{value: 1, owned: [10, 11, 12]}], [{value: 2, owned: [20, 21, 22]}], []],
};
if (JSON.stringify(result) !== JSON.stringify(expected)) throw Error('Lifecycle reference mismatch');
console.log(JSON.stringify(result));
