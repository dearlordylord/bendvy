import assert from 'node:assert/strict';
import Game from './dist/game.mjs';
import Fixture from './dist/fixtures.mjs';
function read(packet) {
  assert.equal(packet.$,'Packet',packet.error);
  return {state:packet.state,frame:JSON.parse(packet.frame)};
}
const player=frame=>frame.bodies.find(body=>body[2]===0);
const enemy=(frame,id)=>frame.bodies.find(body=>body[2]===1&&body[5]===id);
const ofKind=(frame,kind)=>frame.bodies.filter(body=>body[2]===kind);
// Scaling uses real logarithms and preserves speed assigned at birth.
assert.equal(Game.bounce_budget(100),7);
assert.equal(Game.bounce_budget(1),0);
assert.equal(Game.bounce_budget(512),9);
assert.ok(Game.spawn_speed(100)>Game.spawn_speed(512));
assert.ok(Game.spawn_speed(512)>Game.spawn_speed(1024));
assert.ok(Game.spawn_speed(1024)>0);
assert.ok(Game.shot_rate(512)>Game.shot_rate(100));
let game=read(Game.start());
assert.equal(game.frame.enemies,512);
assert.equal(game.frame.projectiles,0);
assert.equal(ofKind(game.frame,1).length,512);
assert.equal(ofKind(game.frame,2).length,10);
assert.deepEqual(player(game.frame).slice(0,3),[400,250,0]);
const speed=enemy(game.frame,1)[4];
for(let i=0;i<24;i++) game=read(Game.advance(game.state,1,0));
assert.ok(Math.abs(player(game.frame)[0]-(400+24*2.8))<0.01);
assert.equal(enemy(game.frame,1)[4],speed);
assert.ok(game.frame.projectiles>=40,'the swarm must produce many actual projectile entities');
assert.equal(game.frame.projectiles,game.frame.bodies.filter(body=>body[2]>=3).length);
assert.equal(game.frame.enemies,ofKind(game.frame,1).length);
assert.ok(enemy(game.frame,513)[4]<=Game.spawn_speed(512)+0.00001);
// Closest-target bolt, exactly one quarter of maximum health.
let packet=Fixture.advance(Fixture.regular());
let frame=JSON.parse(packet.frame);
assert.equal(enemy(frame,1)[3],3);
assert.equal(enemy(frame,2)[3],4);
assert.equal(frame.projectiles,0,'the impacting bolt must actually despawn');
assert.equal(Fixture.live_count(packet),3,'only player and two enemies remain live');
// Half-health AoE, range boundary, fixed interval independent of mob scaling.
packet=Fixture.advance(Fixture.aoe());frame=JSON.parse(packet.frame);
assert.equal(enemy(frame,1)[3],2);
assert.equal(enemy(frame,2)[3],4);
assert.equal(ofKind(frame,5).length,1);
assert.equal(packet.state.pulseClock,180);
assert.equal(packet.state.chainClock,359);
// Three-enemy chain: initial impact plus two distinct bounces, never revisit.
packet=Fixture.chain();
for(let i=1;i<=3;i++) {
  packet=Fixture.advance(packet);frame=JSON.parse(packet.frame);
  assert.equal(enemy(frame,i)[3],3);
  const chain=ofKind(frame,4)[0];
  if(i<3) assert.equal(chain[8],i,'each impact adds one unique visited enemy');
  else assert.equal(ofKind(frame,4).length,0);
}
assert.equal(packet.state.chainClock,358); // firing reset to 360, then two ticks
assert.equal(Fixture.live_count(packet),4,'expired chain leaves no live phantom projectile');
// Explicit no-revisit boundary: even a preferred/closest old target is excluded.
const list=values=>values.reduceRight((tail,head)=>({$: 'Con',head,tail}),{$:'Nil'});
const body=(x,seed)=>({$: 'Body',x,y:250,kind:1,seed,hp:4,speed:0,target:0,visited:list([]),age:0});
const impact=Game.projectile_step({$: 'Body',x:400,y:250,kind:4,seed:1000000,hp:8,speed:12,target:1,visited:list([1]),age:1},list([body(401,1),body(410,2)]));
assert.equal(impact.enemy,2,'chain must skip the already-hit enemy even if it remains closest and preferred');
assert.equal(impact.body.visited.head,2);
assert.equal(impact.body.visited.tail.head,1);
// Lethal impact clears the actual entity and component at the barrier.
packet=Fixture.advance(Fixture.lethal());frame=JSON.parse(packet.frame);
assert.equal(enemy(frame,1),undefined);
assert.equal(frame.kills,1);
assert.equal(Fixture.live_count(packet),2);
function replay(){let game=read(Game.start());for(let i=0;i<8;i++)game=read(Game.advance(game.state,1,0));return game.frame;}
assert.deepEqual(replay(),replay());
assert.equal(read(Game.start()).frame.hp,5);
console.log('Swarm checks pass: 512 enemies, 40+ real projectiles, logarithmic scaling, closest-target quarter hits, half-health fixed AoE, distinct chain bounces, deferred despawn, live counts and replay.');
