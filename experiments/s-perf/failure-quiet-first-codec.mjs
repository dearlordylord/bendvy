// Lossless actual record codec, matching failure-quiet-codec.bend field order.
import assert from 'node:assert/strict';
export const fold=(values,acc=0)=>{for(const value of values){assert.ok(Number.isInteger(value)&&value>=0&&value<=0xffffffff);acc=(Math.imul(acc,33)+value)>>>0;}return acc;};
const text=s=>{const cs=Array.from(s,c=>c.codePointAt(0));return [cs.length,...cs];};
const four=x=>[x.a,x.b,x.c,x.d];
const main=(s,x)=>s==='Motion'?[...four(x.coordinates),x.frame]:[...four(x.levels),x.reserve,x.class];
const aux=(s,x)=>s==='Motion'?[...four(x.rates),Number(x.moving)]:[...four(x.layers),x.grade];
const ledger=x=>[...four(x.totals),x.epoch];
const optional=(x,f)=>x===null?[0]:[1,...f(x)];
const access=(x,f)=>x.kind==='Missing'?[0]:x.kind==='Mismatch'?[1]:[2,...f(x.value)];
const handle=x=>[x.namespace,x.id];
const row=(s,x)=>[...handle(x.handle),...main(s,x.main),...optional(x.aux,y=>aux(s,y)),...optional(x.flag,y=>[y.group])];
const bundle=(s,x)=>[...optional(x.main,y=>main(s,y)),...optional(x.aux,y=>aux(s,y)),...optional(x.flag,y=>[y.group])];
const list=(xs,f)=>{const values=[xs.length];for(const x of xs)values.push(...f(x));return values;};
const lookup=(s,x)=>[...text(x.label),...handle(x.handle),...access(x.result,y=>row(s,y))];
const mainView=x=>x.kind==='MotionMain'?[0,...main('Motion',x.position)]:[1,...main('Health',x.vitals)];
const own=x=>x.kind==='Main'?[0,...access(x.value,mainView)]:x.kind==='Ledger'?[1,...optional(x.value,ledger)]:[2,...access(x.value,mainView)];
const outcome=x=>x.kind==='Complete'?[0]:x.kind==='SystemFailure'?[1,...text(x.system),x.code]:x.kind==='SetupRejected'?[2,...text(x.reason)]:[3,...text(JSON.stringify(x))];
export function encodeEvent(schema,x){
 switch(x.kind){
  case 'FailureObserved':return [].concat([0],text(x.schema),[x.iteration],text(x.phase),list(x.rows,y=>row(schema,y)),optional(x.ledger,ledger),list(x.lookups,y=>lookup(schema,y)));
  case 'FailureRead':return [].concat([1,x.iteration],text(x.system),[x.count],list(x.messages,y=>[y.code]),[Number(x.lag),x.tick,x.frame]);
  case 'FailureResult':return [2,...text(x.label),...outcome(x.outcome)];
  case 'Reserved':return [3,...text(x.step),...text(x.worldName),...text(x.label),...handle(x.handle),...bundle(schema,x.components)];
  case 'OwnWrites':return [4,...text(x.step),...text(x.system),...list(x.views,own)];
  default:return [5,...text(JSON.stringify(x))];
 }
}
export const encode=(schema,events,effects)=>[].concat(list(events,x=>encodeEvent(schema,x)),list(effects,text));
export function decode(schema,values){
 let index=0;const n=()=>{assert.ok(index<values.length,'truncated actual tuple');return values[index++];};
 const str=()=>{let s='';for(let count=n();count>0;count--)s+=String.fromCodePoint(n());return s;};
 const fs=()=>({a:n(),b:n(),c:n(),d:n()});
 const m=s=>s==='Motion'?{coordinates:fs(),frame:n()}:{levels:fs(),reserve:n(),class:n()};
 const a=s=>s==='Motion'?{rates:fs(),moving:Boolean(n())}:{layers:fs(),grade:n()};
 const l=()=>({totals:fs(),epoch:n()});const opt=f=>n()===0?null:f();
 const ac=f=>{const tag=n();assert.ok(tag<=2);return tag===0?{kind:'Missing'}:tag===1?{kind:'Mismatch'}:{kind:'Found',value:f()};};
 const h=()=>({namespace:n(),id:n()});const r=()=>({handle:h(),main:m(schema),aux:opt(()=>a(schema)),flag:opt(()=>({group:n()}))});
 const b=()=>({main:opt(()=>m(schema)),aux:opt(()=>a(schema)),flag:opt(()=>({group:n()}))});
 const ls=f=>Array.from({length:n()},f);const look=()=>({label:str(),handle:h(),result:ac(r)});
 const mv=()=>n()===0?{kind:'MotionMain',position:m('Motion')}:{kind:'HealthMain',vitals:m('Health')};
 const ow=()=>{const tag=n();return tag===0?{kind:'Main',value:ac(mv)}:tag===1?{kind:'Ledger',value:opt(l)}:{kind:'ReservedLookup',value:ac(mv)};};
 const out=()=>{const tag=n();return tag===0?{kind:'Complete'}:tag===1?{kind:'SystemFailure',system:str(),code:n()}:tag===2?{kind:'SetupRejected',reason:str()}:JSON.parse(str());};
 const event=()=>{switch(n()){
  case 0:return {kind:'FailureObserved',schema:str(),iteration:n(),phase:str(),rows:ls(r),ledger:opt(l),lookups:ls(look)};
  case 1:return {kind:'FailureRead',iteration:n(),system:str(),count:n(),messages:ls(()=>({code:n()})),lag:Boolean(n()),tick:n(),frame:n()};
  case 2:return {kind:'FailureResult',label:str(),outcome:out()};
  case 3:return {kind:'Reserved',step:str(),worldName:str(),label:str(),handle:h(),components:b()};
  case 4:return {kind:'OwnWrites',step:str(),system:str(),views:ls(ow)};
  case 5:return JSON.parse(str());default:throw Error('invalid actual record tag');
 }};
 const result={events:ls(event),effects:ls(str)};assert.equal(index,values.length,'unconsumed actual tuple fields');return result;
}
