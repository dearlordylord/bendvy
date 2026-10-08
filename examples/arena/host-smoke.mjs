// Lightweight DOM/canvas harness for the actual browser module and Bend build.
// This checks host wiring; it is not a real-browser rendering test.
import assert from 'node:assert/strict';
const events=new Map(), documentEvents=new Map(), buttons=new Map();
let raf;
const ctx={
  circles:[],bars:[],
  clearRect(){this.circles=[];this.bars=[];},
  beginPath(){},moveTo(){},lineTo(){},stroke(){},closePath(){},fill(){},fillRect(x,y,w,h){this.bars.push({x,y,w,h,color:this.fillStyle});},fillText(){},
  arc(x,y,r){this.circles.push({x,y,r});}
};
const status={textContent:''},weapons={textContent:''},error={hidden:true,textContent:''};
const canvas={getContext:()=>ctx,focus(){}};
const restart={addEventListener:(name,callback)=>buttons.set(name,callback)};
const elements={'#arena':canvas,'#status':status,'#weapons':weapons,'#error':error,'#restart':restart};
globalThis.document={hidden:false,querySelector:key=>elements[key],addEventListener:(name,callback)=>documentEvents.set(name,callback)};
globalThis.window={addEventListener:(name,callback)=>events.set(name,callback)};
globalThis.requestAnimationFrame=callback=>{raf=callback;};
await import('./browser.mjs');
assert.equal(error.hidden,true);
assert.ok(status.textContent.includes('Health 5/5'));
assert.equal(ctx.circles.length,513); // 512 actual enemies and one player
assert.equal(ctx.bars.filter(bar=>bar.color==='#4ade80').length,512);
assert.ok(weapons.textContent.includes('Chain every 1s'));
function player(){return ctx.circles.find(circle=>circle.r===5);}
function key(code,type='keydown'){events.get(type)({code,repeat:false,preventDefault(){}});}
let now=0;
function frames(count){for(let i=0;i<count;i++){now+=1000/60;raf(now);}}
const startX=player().x;
key('ArrowRight');frames(20);key('ArrowRight','keyup');
assert.ok(player().x>startX+40);
key('Space');frames(1);
assert.ok(status.textContent.includes('Paused'));
const paused=status.textContent,pausedX=player().x;
frames(20);
assert.equal(status.textContent,paused);
assert.equal(player().x,pausedX);
key('Space');frames(1);
assert.ok(!status.textContent.includes('Paused'));
key('ArrowRight');events.get('blur')();frames(2);
assert.ok(status.textContent.includes('Paused'));
key('Space');frames(5);
assert.equal(player().x,pausedX,'blur must clear held movement keys');
buttons.get('click')();
assert.equal(player().x,400);
assert.ok(status.textContent.includes('Gold 0'));
key('ArrowLeft');frames(5);key('KeyR');
assert.equal(player().x,400);
assert.ok(status.textContent.includes('Health 5/5'));
document.hidden=true;documentEvents.get('visibilitychange')();frames(1);
assert.ok(status.textContent.includes('Paused'));
assert.equal(error.hidden,true);
console.log('Host harness passes: actual compiled Bend, draw calls, keyboard input, pause/resume, focus loss, tab hiding and both restart controls.');
// Exercise the real renderer against real controlled ECS combat scenarios.
const {default:Game}=await import('./dist/game.mjs');
const {default:Fixture}=await import('./dist/fixtures.mjs');
document.hidden=false;
// Keep each affine owner inside its emitting module: Bend 2.0.36 qualifies
// exported constructor tags differently for a direct entry and an importer.
function useFixture(create) {
  let packet;
  const forHost=p=>({$: 'Packet',state:p.state,frame:p.frame});
  Game.start=()=>{packet=create();return forHost(packet);};
  Game.advance=()=>{packet=Fixture.advance(packet);return forHost(packet);};
  buttons.get('click')();
}
useFixture(Fixture.regular);
const colors=new Set();
for(let i=0;i<18;i++){frames(1);for(const bar of ctx.bars)colors.add(bar.color);}
assert.ok(colors.has('#4ade80'),'full health must render green');
assert.ok(colors.has('#facc15'),'partial health must render yellow');
assert.ok(colors.has('#f87171'),'quarter health must render red');
useFixture(Fixture.aoe);frames(5);
assert.ok(ctx.circles.some(circle=>circle.r>5),'AoE projectile must render an expanding ring');
useFixture(Fixture.chain);frames(3);
assert.ok(ctx.circles.some(circle=>circle.r===2.2),'chain projectile must render');
console.log('Combat renderer passes: smaller sprites, green/yellow/red enemy bars, AoE ring and chain projectile.');
