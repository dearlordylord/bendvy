import assert from 'node:assert/strict';
import Demo from './dist/api.mjs';

function take(packet) {
  assert.equal(packet.$, 'Packet', packet.error);
  return {state: packet.state, frame: JSON.parse(packet.frame)};
}
let current = take(Demo.start());
assert.deepEqual(current.frame, {tick: 0, entities: [
  {id: 1, health: 10, decay: 0.5},
  {id: 2, health: 20, decay: 0.25},
  {id: 3, health: 30, decay: null},
]});
current = take(Demo.step(current.state));
assert.deepEqual(current.frame, {tick: 1, entities: [
  {id: 1, health: 5, decay: 0.5},
  {id: 2, health: 5, decay: 0.25},
  {id: 3, health: 30, decay: null},
]});
current = take(Demo.step(current.state));
assert.deepEqual(current.frame, {tick: 2, entities: [
  {id: 1, health: 2.5, decay: 0.5},
  {id: 2, health: 1.25, decay: 0.25},
  {id: 3, health: 30, decay: null},
]});
assert.deepEqual(take(Demo.start()).frame.entities.map(entity => entity.health), [10,20,30]);
console.log('Demo start, two ticks, skipped entity and reset: OK');
