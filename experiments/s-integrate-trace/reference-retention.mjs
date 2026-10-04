// E11 public reference lanes. Each child process is bounded to five seconds.
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {readFileSync,writeFileSync} from 'node:fs';
import {execFileSync} from 'node:child_process';
import {fileURLToPath} from 'node:url';
import {Descriptor,Fx,Schema} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const root='/workspace/formal-proofs/bendvy/.references/bevy-ts';
const pinned='3040a3b2a3f28fa8554d856f9ccb6bf5433fa334';
const self=fileURLToPath(import.meta.url), C=65536;
const manifestPath='/workspace/formal-proofs/bendvy/.references/sources.json';
assert.equal(JSON.parse(readFileSync(manifestPath,'utf8')).sources['bevy-ts'].commit,pinned);
const sha=p=>createHash('sha256').update(readFileSync(p)).digest('hex');
assert.equal(execFileSync('git',['-C',root,'rev-parse','HEAD'],{encoding:'utf8',timeout:5000}).trim(),pinned);
const cases=['message','removed','despawned','unheld','marks'];
if(process.argv[2]==='--all'){
  const results=[];
  for(const schema of ['Motion','Health']) for(const lane of cases){
    const started=performance.now();
    try {const output=execFileSync(process.execPath,[self,schema,lane],{encoding:'utf8',timeout:5000,maxBuffer:20*1024*1024});results.push({...JSON.parse(output),wallMilliseconds:performance.now()-started});}
    catch(error){results.push({schema,lane,status:error.code==='ETIMEDOUT'?'UNRESOLVED_TIMEOUT':'FAILED_EXECUTION',wallMilliseconds:performance.now()-started,error:String(error),stdout:String(error.stdout??''),stderr:String(error.stderr??'')});}
  }
  const files=['Runtime.ts','System.ts','Query.ts','Command.ts','internal/world.ts','internal/streams.ts'];
  const evidence={reference:{commit:pinned,manifestSha256:sha(manifestPath),files:Object.fromEntries(files.map(f=>[f,sha(root+'/packages/core/src/'+f)]))},node:process.version,adapterSha256:sha(self),traceSha256:sha(new URL('../../docs/design/s-integrate-trace.md',import.meta.url)),limitSecondsPerInvocation:5,results};
  writeFileSync(new URL('retention-evidence.json',import.meta.url),JSON.stringify(evidence,null,2)+'\n');
  console.log(JSON.stringify(results.map(({schema,lane,status,wallMilliseconds,firstDifference})=>({schema,lane,status,wallMilliseconds,firstDifference:firstDifference?{name:firstDifference.name}:null})),null,2));
  process.exit(results.every(x=>x.status==='PASS')?0:1);
}
const schema=process.argv[2],lane=process.argv[3];
assert.ok(['Motion','Health'].includes(schema));assert.ok(cases.includes(lane));
const Main=Descriptor.Component()(schema==='Motion'?'Position':'Vitals');
const Aux=Descriptor.Component()(schema==='Motion'?'Velocity':'Armor');
const Flag=Descriptor.Component()(schema==='Motion'?'Selected':'Tracked');
const Ping=Descriptor.Event()(schema+'Ping');
const G=Schema.bind(Schema.fragment({components:{Main,Aux,Flag},events:{Ping}}));
const runtime=G.Runtime.make({services:G.Runtime.services(),debug:true});
const ids=[], observations=[],dispatches=[],systemTraces=[],invocations=new Map();
runtime.debug.observe(event=>{if(event.type==='system'&&['Fast','B','Late'].includes(event.system))systemTraces.push({system:event.system,frame:event.frame,tick:event.tick,outcome:event.outcome,missed:event.missed});});
let failing=false,label='',firstDifference=null;
const payload=x=>schema==='Motion'?{coordinates:[x,x+1,x+2,x+3],frame:7}:{levels:[x,x+1,x+2,x+3],reserve:9,class:2};
const aux=()=>schema==='Motion'?{rates:[1,2,3,4],moving:true}:{layers:[1,2,3,4],grade:3};
const query=filters=>G.Query({selection:{main:G.Query.read(Main),aux:G.Query.optional(Aux),flag:G.Query.optional(Flag)},...(filters?{filters}:{})});
const Q=query(),Added=query([G.Query.added(Main)]),Changed=query([G.Query.changed(Main)]);
function check(name,actual,expected){try{assert.deepEqual(actual,expected);}catch{if(!firstDifference)firstDifference={name,actual,expected};}}
// Exact-sequence range encoding occurs only after checking EVERY public element.
function sequence(name,actual,expected){check(name,actual,expected);if(actual.length===0)return [];if(actual.every((x,i)=>Number.isInteger(x)&&x===actual[0]+i))return {encoding:'inclusive-contiguous-range',first:actual[0],last:actual.at(-1),count:actual.length};return actual;}
function rows(name,rs,expectedIds,xOf){
  const actualIds=rs.map(r=>r.entity.id.value);
  check(name+'.ids',actualIds,expectedIds);
  for(let i=0;i<rs.length;i++){
    const want=payload(xOf(i,rs[i].entity.id.value));
    if(expected.currentSlot0!==undefined)(schema==='Motion'?want.coordinates:want.levels)[0]=expected.currentSlot0;
    check(name+'.main['+i+']',rs[i].data.main.get(),want);
    check(name+'.flag['+i+']',rs[i].data.flag?.get()??null,{group:8});
    const a=rs[i].data.aux;
    check(name+'.aux['+i+']',a===undefined?null:a.get(),aux());
  }
  return {payloadParameterX:sequence(name+'.x-encoding',rs.map(r=>(schema==='Motion'?r.data.main.get().coordinates:r.data.main.get().levels)[1]-1),expectedIds.map((id,i)=>xOf(i,id))),flag:{group:8},ids:sequence(name+'.ids-encoding',actualIds,expectedIds),allMainAndAuxFieldsCompared:rs.length,currentSlot0:expected.currentSlot0??null,payload: schema==='Motion'?{coordinates:'[x,x+1,x+2,x+3]',frame:7}:{levels:'[x,x+1,x+2,x+3]',reserve:9,class:2},aux:aux()};
}
let expected={q:[],added:[],changed:[],removed:[],despawned:[],messages:[],removedLag:false,despawnedLag:false,messageLag:false,xOf:()=>10};
function reader(name){return G.System(name,{queries:{q:Q,added:Added,changed:Changed},removed:{main:G.System.readRemoved(Main)},despawned:{entity:G.System.readDespawned()},events:{ping:G.System.readEvent(Ping)}},({queries,removed,despawned,events})=>{
  const invocation=(invocations.get(name)??0)+1;invocations.set(name,invocation);
  const observed={name,label,invocation,attemptFails:name==='B'&&failing,
    q:rows(label+'.q',queries.q.each(),expected.q,expected.xOf),
    added:rows(label+'.added',queries.added.each(),expected.added,expected.xOf),
    changed:rows(label+'.changed',queries.changed.each(),expected.changed,expected.xOf),
    removed:sequence(label+'.removed',removed.main.all().map(x=>x.value),expected.removed),
    despawned:sequence(label+'.despawned',despawned.entity.all().map(x=>x.value),expected.despawned),
    messages:sequence(label+'.messages',events.ping.all().map(x=>x.code),expected.messages),
    lag:{removed:null,despawned:null,messages:events.ping.lagged()},expectedLag:{removed:expected.removedLag,despawned:expected.despawnedLag,messages:expected.messageLag}};
  observations.push(observed);if(name==='B'&&failing)return Fx.fail({code:7});
});}
const Fast=reader('Fast'),B=reader('B'),Late=reader('Late');
function tick(name,...steps){label=name;const result=runtime.tick(G.Schedule(...steps));dispatches.push({name,result});
  for(const o of observations.filter(x=>x.label===name)){const trace=systemTraces.findLast(x=>x.system===o.name);o.publicDispatcherTrace=trace;o.lag.removed=trace.missed.some(x=>x.kind==='removed');o.lag.despawned=trace.missed.some(x=>x.kind==='despawned');check(name+'.lag',o.lag,o.expectedLag);}
  check(name+'.dispatch',result,steps.includes(B)&&failing?{ok:false,error:{kind:'SystemFailure',system:'B',error:{code:7}}}:{ok:true,value:undefined});return result;}
const D=G.Schedule.applyDeferred();
function emit(values){return G.System('Emit',{events:{ping:G.System.writeEvent(Ping)}},({events})=>{for(const code of values)events.ping.emit({code});});}
function spawn(count){return G.System('Spawn',{},({commands})=>{for(let i=0;i<count;i++)ids.push(commands.spawn(G.Command.spawn([Main,payload(10+i)],[Aux,aux()],[Flag,{group:8}])));});}
function del(kind){return G.System('Delete',{},({commands})=>{for(const id of ids)if(kind==='removed')commands.remove(id,Main);else commands.despawn(id);});}
const reset=()=>{expected={q:[],added:[],changed:[],removed:[],despawned:[],messages:[],removedLag:false,despawnedLag:false,messageLag:false,xOf:()=>10};};
const range=(start,count)=>Array.from({length:count},(_,i)=>start+i);
try{
  if(lane==='message'){
    tick('seed-payload',spawn(1),D);expected.q=ids.map(x=>x.value);expected.added=expected.q;expected.changed=expected.q;
    tick('prime-fast',Fast);tick('prime-B',B);expected.added=[];expected.changed=[];
    tick('publish-full',emit(range(0,C)));expected.messages=range(0,C);tick('fast-full',Fast);
    tick('publish-one',emit([C]));tick('trim-full');expected.messages=[C];expected.messageLag=true;failing=true;tick('B-first-post-drop-fails',B);failing=false;tick('B-same-instance-retry',B);
    expected.messageLag=false;tick('independent-fast',Fast);
    tick('publish-oversized',emit(range(C+1,C+1)));tick('trim-oversized');expected.messages=[];expected.messageLag=true;tick('B-oversized-empty-lag',B);tick('Fast-oversized-empty-lag',Fast);
    expected.messageLag=false;expected.added=expected.q;expected.changed=expected.q;tick('late-registration-no-historical-lag',Late);
  }else if(lane==='removed'||lane==='despawned'){
    tick('prime-fast',Fast);tick('prime-B',B);tick('spawn-capacity-plus-one',spawn(C+1),D);
    const all=ids.map(x=>x.value);expected.q=all;expected.added=all;expected.changed=all;expected.xOf=i=>10+i;
    tick('Fast-all-added-full-fields',Fast);tick('B-all-added-full-fields',B);
    expected.q=[];expected.added=[];expected.changed=[];expected.removed=all;expected.despawned=lane==='despawned'?all:[];
    tick('Fast-removals-before-trim',del(lane),D,Fast);tick('capacity-trim');expected.removed=all.slice(1);expected.removedLag=true;expected.despawned=lane==='despawned'?all.slice(1):[];expected.despawnedLag=lane==='despawned';
    expected.removedLag=false;expected.despawnedLag=false;tick('late-registration-retained-records-no-historical-lag',Late);expected.removedLag=true;expected.despawnedLag=lane==='despawned';
    failing=true;tick('B-first-post-drop-fails',B);failing=false;tick('B-same-instance-retry',B);
    reset();tick('independent-fast-empty-not-lagged',Fast);
  }else if(lane==='unheld'){
    tick('spawn-unheld',spawn(2),D);
    const RemoveDespawn=G.System('RemoveDespawn',{},({commands})=>{commands.remove(ids[0],Main);commands.despawn(ids[1]);});
    tick('delete-unheld',RemoveDespawn,D);tick('empty1');tick('empty2');tick('empty3');tick('first-Fast-no-history-or-lag',Fast);
  }else{
    tick('prime-fast',Fast);tick('spawn',spawn(1),D);expected.q=[ids[0].value];expected.added=expected.q;expected.changed=expected.q;tick('Fast-seed',Fast);
    const Write=G.Query({selection:{main:G.Query.write(Main)}});
    const Update=G.System('Update',{queries:{rows:Write}},({queries})=>{for(const row of queries.rows.each()){const old=row.data.main.get();row.data.main.set(schema==='Motion'?{...old,coordinates:[11,...old.coordinates.slice(1)]}:{...old,levels:[11,...old.levels.slice(1)]});}});
    tick('write-slot0',Update);tick('empty1');tick('empty2');tick('empty3');
    // Current value differs from V(11): slots1..3 remain 11,12,13.
    expected.xOf=()=>10;
    // Reader's complete-value comparator has an explicit current slot0 override.
    expected.currentSlot0=11;
    tick('first-B-old-surviving-marks',B);
  }
}catch(error){if(!firstDifference)firstDifference={name:'execution',error:String(error),stack:error.stack};}
const expectedInvocations=lane==='message'?{Fast:4,B:4,Late:1}:lane==='removed'||lane==='despawned'?{Fast:4,B:4,Late:1}:lane==='marks'?{Fast:2,B:1}:{Fast:1};
check('same-base-instance-invocations',Object.fromEntries(invocations),expectedInvocations);
console.log(JSON.stringify({schema,lane,invocations:Object.fromEntries(invocations),rawReservationIds:sequence('reservations',ids.map(x=>x.value),range(1,ids.length)),status:firstDifference?'FAIL':'PASS',firstDifference,capacity:C,publicOnly:true,dispatches,observations,
  limits:'TS public reference prerequisite only; no integrated Bend/runtime-refinement claim. Range encoding checks every element before compression.'}));
