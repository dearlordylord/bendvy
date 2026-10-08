// Lightweight DOM/canvas harness for the actual browser module and Bend build.
// This checks host wiring; it is not a real-browser rendering test.
import assert from 'node:assert/strict';
const events=new Map(), documentEvents=new Map(), buttons=new Map();
let raf;
const ctx={
  circles:[],
  clearRect(){this.circles=[];},
  beginPath(){},moveTo(){},lineTo(){},stroke(){},closePath(){},fill(){},fillRect(){},fillText(){},
  arc(x,y,r){this.circles.push({x,y,r});}
};
const status={textContent:''},error={hidden:true,textContent:''};
const canvas={getContext:()=>ctx,focus(){}};
const restart={addEventListener:(name,callback)=>buttons.set(name,callback)};
const elements={'#arena':canvas,'#status':status,'#error':error,'#restart':restart};
globalThis.document={hidden:false,querySelector:key=>elements[key],addEventListener:(name,callback)=>documentEvents.set(name,callback)};
globalThis.window={addEventListener:(name,callback)=>events.set(name,callback)};
globalThis.requestAnimationFrame=callback=>{raf=callback;};
await import('./browser.mjs');
assert.equal(error.hidden,true);
assert.ok(status.textContent.includes('Health 5/5'));
assert.equal(ctx.circles.length,7); // six enemies and the player; gold uses paths
function player(){return ctx.circles.find(circle=>circle.r===11);}
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
