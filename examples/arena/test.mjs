import assert from 'node:assert/strict';
import Game from './dist/game.mjs';
function read(packet) {
  assert.equal(packet.$, 'Packet');
  return {state: packet.state, frame: JSON.parse(packet.frame)};
}
function player(frame) { return frame.bodies.find(body => body[2] === 0); }
let game = read(Game.start());
assert.equal(game.frame.bodies.length, 17);
assert.equal(game.frame.bodies.filter(body => body[2] === 1).length, 6);
assert.equal(game.frame.bodies.filter(body => body[2] === 2).length, 10);
assert.deepEqual(player(game.frame), [400,250,0]);
game = read(Game.advance(game.state,1,0));
assert.equal(game.frame.tick,1);
assert.ok(Math.abs(player(game.frame)[0] - 402.8) < 0.001);
assert.equal(player(game.frame)[1],250);
// Steer toward an actual pickup through the same public query used by the UI.
for (let i=0; i<90 && !game.frame.score && game.frame.hp; i++) {
  const [x,y] = player(game.frame);
  const [tx,ty] = game.frame.bodies.find(body => body[2] === 2 && body[0] === 319);
  const dx=tx-x, dy=ty-y, length=Math.hypot(dx,dy)||1;
  game=read(Game.advance(game.state,dx/length,dy/length));
}
assert.ok(game.frame.score > 0, 'pickup must increase score through the ECS query');
const updatedPlayer=player(game.frame);
assert.ok(game.frame.bodies.every(([x,y])=>Number.isFinite(x)&&Number.isFinite(y)));
// Stationary survival exercises chase, collision, health, invulnerability and game-over.
game=read(Game.start());
let damage=0;
for (let i=0; i<2400 && game.frame.hp; i++) {
  const previous=game.frame;
  game=read(Game.advance(game.state,0,0));
  assert.ok(game.frame.hp <= previous.hp && game.frame.hp >= previous.hp-1);
  assert.equal(game.frame.bodies.length,17);
  if (previous.cooldown>1) assert.equal(game.frame.hp,previous.hp);
  if (game.frame.hp<previous.hp) { damage++; assert.equal(game.frame.cooldown,60); }
}
assert.equal(damage,5);
assert.equal(game.frame.hp,0);
const stopped=game.frame;
game=read(Game.advance(game.state,1,1));
assert.deepEqual(game.frame,stopped,'game over freezes ECS gameplay');
// Bounds are checked at the same boundary used by keyboard input.
game=read(Game.start());
for(let i=0;i<180;i++) game=read(Game.advance(game.state,1,0));
assert.equal(player(game.frame)[0],780);
assert.equal(player(game.frame)[1],250);
function replay() {
  let game=read(Game.start());
  for(let i=0;i<200;i++) game=read(Game.advance(game.state, i%80<40 ? 1 : -1,0));
  return game.frame;
}
assert.deepEqual(replay(),replay(),'fixed input sequence must replay deterministically');
assert.equal(read(Game.start()).frame.hp,5);
console.log('Arena controls pass: bootstrap, movement, pickups, health/cooldown, game-over, bounds, replay and restart.');
