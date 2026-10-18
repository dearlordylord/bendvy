// Pinned public bevy-ts measurement reference. No Bend or performance acceptance.
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {readFileSync,writeFileSync,writeSync} from 'node:fs';
import {execFileSync} from 'node:child_process';
import {fileURLToPath} from 'node:url';
import {Descriptor,Schema,Fx} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const reference='/workspace/formal-proofs/bendvy/.references/bevy-ts';
const pin='3040a3b2a3f28fa8554d856f9ccb6bf5433fa334';
const self=fileURLToPath(import.meta.url), iterations=64;
const sha=x=>createHash('sha256').update(x).digest('hex');
const hashFile=p=>sha(readFileSync(p));
assert.equal(execFileSync('git',['-C',reference,'rev-parse','HEAD'],{encoding:'utf8',timeout:5000}).trim(),pin);
assert.equal(JSON.parse(readFileSync('/workspace/formal-proofs/bendvy/.references/sources.json')).sources['bevy-ts'].commit,pin);
const schemas=['Motion','Health'],workloads=['dense','sparse','lifecycle','readers','failed-transaction'],counts=[64,256,1024];
const main=(schema,j,delta=0)=>schema==='Motion'?{coordinates:[j+delta,j+1,j+2,j+3],frame:7}:{levels:[j+delta,j+1,j+2,j+3],reserve:9,class:2};
const aux=schema=>schema==='Motion'?{rates:[1,2,3,4],moving:true}:{layers:[1,2,3,4],grade:3};
const cells=(schema,value)=>schema==='Motion'?value.coordinates:value.levels;
// An integer checksum supplements exact full-field comparisons. Inputs stay below 2^53.
function fold(acc,values){for(const value of values)acc=(acc*33+Number(value))%2147483647;return acc;}
function rowValues(schema,row){return [row.rawId,...cells(schema,row.main),...(schema==='Motion'?[row.main.frame]:[row.main.reserve,row.main.class]),row.aux!==null,...(row.aux===null?[]:schema==='Motion'?[...row.aux.rates,row.aux.moving]:[...row.aux.layers,row.aux.grade]),row.flag!==null,...(row.flag===null?[]:[row.flag.group])];}

function writeAll(text){const bytes=Buffer.from(text);let offset=0;while(offset<bytes.length)offset+=writeSync(1,bytes,offset,bytes.length-offset);}
const four=values=>({a:values[0],b:values[1],c:values[2],d:values[3]});
const mainView=value=>({levels:four(value.levels),reserve:value.reserve,class:value.class});
const auxView=value=>({layers:four(value.layers),grade:value.grade});
const ledgerView=value=>({totals:four(value.totals),epoch:value.epoch});
const found=value=>({kind:'Found',value});
const accessResult=result=>result.ok?found(mainView(result.value.data.main.get())):{kind:result.error._tag==='MissingEntity'?'Missing':result.error._tag==='ComponentAbsent'?'Absent':result.error._tag};
class Method{
 constructor(){this.ids=new Map();this.rawActorMap=[];this.records=[];this.rawTickOutcomes=[];}
 reserve(id){assert.ok(!this.ids.has(id.value),'duplicate raw actor');const actor=this.rawActorMap.length+1;this.ids.set(id.value,actor);this.rawActorMap.push({actor,rawId:id.value});}
 actor(raw){assert.ok(this.ids.has(raw),'unmapped raw actor');return this.ids.get(raw);}
 record(value){this.records.push(JSON.stringify(value));}
 callback(who,iteration,capture){return {kind:'Callback',who,mode:null,iteration:iteration===-1?null:iteration,capture,readerStatus:null,readerError:null,reading:null,outcome:null,reservation:null,payload:null,writes:[],ledger:null,rejected:null,error:null,pendingLookup:null};}
 phase(phase,iteration,result){this.record({kind:'Phase',phase,iteration:iteration===-1?null:iteration,outcome:{kind:result.ok?'Success':'Failure'}});}
 lookup(id,result){return {actor:this.actor(id.value),result:accessResult(result)};}
 row(row){return {actor:this.actor(row.rawId),main:found(mainView(row.main)),aux:row.aux===null?{kind:'Absent'}:found(auxView(row.aux)),flag:row.flag===null?{kind:'Absent'}:found(structuredClone(row.flag))};}
}
function natural(out,n){assert.ok(Number.isSafeInteger(n)&&n>=0);for(const c of String(n))out.push(c.codePointAt(0));out.push(0);}
function encode(records){const out=[];natural(out,records.length);for(const text of records){const scalars=Array.from(text,c=>c.codePointAt(0));natural(out,scalars.length);for(const scalar of scalars)out.push(scalar);}return out;}
function transactions(schema,count,clockPath,rssPath){
  const method=new Method();let callbackPending=null,publicationPending=null,lastTick=null,lastRows=null,lastLedger=null;
  const Main=Descriptor.Component()(schema==='Motion'?'Position':'Vitals'),Aux=Descriptor.Component()(schema==='Motion'?'Velocity':'Armor'),Flag=Descriptor.Component()(schema==='Motion'?'Selected':'Tracked'),Ledger=Descriptor.Resource()(schema+'Ledger'),Ping=Descriptor.Event()(schema+'Ping'),Audit=Descriptor.Service()('Audit');
  const G=Schema.bind(Schema.fragment({components:{Main,Aux,Flag},resources:{[Ledger.name]:Ledger},events:{Ping}}));
  const failedHandles=[],effects=[],runtime=G.Runtime.make({resources:{[Ledger.name]:{totals:[0,101,102,103],epoch:4}},services:G.Runtime.services(G.Runtime.service(Audit,{log:x=>effects.push(x)})),debug:true});
  const Q=G.Query({selection:{main:G.Query.read(Main),aux:G.Query.optional(Aux),flag:G.Query.optional(Flag)}}),Write=G.Query({selection:{main:G.Query.write(Main)}});
  const row=r=>({rawId:r.entity.id.value,main:structuredClone(r.data.main.get()),aux:r.data.aux.present?structuredClone(r.data.aux.get()):null,flag:r.data.flag.present?structuredClone(r.data.flag.get()):null});
  const expected=new Map(),ids=[],reads=[],audit=[],reservations=[],diagnostics=[];let iteration=-1,mode='prime',stage='prime',aSpawn=null,bFail=null,bRetry=null,ledgerFirst=0;
  const captures={A:0,B:0},tick=(...steps)=>{const result=runtime.tick(G.Schedule(...steps));method.rawTickOutcomes.push(result.ok?{ok:true,value:{kind:"Undefined"}}:structuredClone(result));lastTick=result;return result;},ok=(...steps)=>assert.equal(tick(...steps).ok,true);
  const seed=G.System('Seed',{},({commands})=>{for(let j=0;j<count;j++){
    const entries=[[Main,main(schema,j)]];if(j%3===0)entries.push([Aux,aux(schema)]);if(j%3===1)entries.push([Flag,{group:8}]);
    const id=commands.spawn(G.Command.spawn(...entries));ids.push(id);method.reserve(id);expected.set(id.value,{rawId:id.value,main:main(schema,j),aux:j%3===0?aux(schema):null,flag:j%3===1?{group:8}:null});
  }});ok(seed,G.Schedule.applyDeferred());method.record({kind:"SeedActors",actors:ids.map(id=>method.actor(id.value))});
  const replaceFirst=(old,x)=>schema==='Motion'?{coordinates:[x,...old.coordinates.slice(1)],frame:old.frame}:{levels:[x,...old.levels.slice(1)],reserve:old.reserve,class:old.class};
  const spawnValue=(i,b)=>schema==='Motion'?{coordinates:[i,...(b?[200,300,400]:[20,30,40])],frame:7}:{levels:[i,...(b?[200,300,400]:[20,30,40])],reserve:9,class:2};
  const A=G.System('A',{queries:{write:Write},resources:{ledger:G.System.writeResource(Ledger)},events:{out:G.System.writeEvent(Ping)},services:{audit:G.System.service(Audit)}},({queries,resources,events,commands,services,lookup})=>{
    captures.A++;callbackPending=method.callback("A",iteration,captures.A);const r=queries.write.get(ids[0]);assert.equal(r.ok,true);const old=r.value.data.main.get();r.value.data.main.set(replaceFirst(old,cells(schema,old)[0]+1));callbackPending.writes.push(found(mainView(r.value.data.main.get())));
    const l=resources.ledger.get();resources.ledger.set({totals:[l.totals[0]+1,...l.totals.slice(1)],epoch:l.epoch});callbackPending.ledger=ledgerView(resources.ledger.get());events.out.emit({code:2*iteration});
    const spawned=spawnValue(iteration,false);aSpawn=commands.spawn(G.Command.spawn([Main,spawned]));method.reserve(aSpawn);callbackPending.reservation={kind:'Reserved',actor:method.actor(aSpawn.value)};callbackPending.payload=mainView(spawned);const pending=lookup.getHandle(G.Entity.handle(aSpawn),Q);assert.equal(pending.error._tag,'MissingEntity');callbackPending.pendingLookup=accessResult(pending);services.audit.log({who:'A',iteration,capture:captures.A});
  });
  const B=G.System('B',{queries:{write:Write},resources:{ledger:G.System.writeResource(Ledger)},events:{input:G.System.readEvent(Ping),out:G.System.writeEvent(Ping)},services:{audit:G.System.service(Audit)}},({queries,resources,events,commands,services,lookup})=>{
    captures.B++;callbackPending=method.callback("B",iteration,captures.B);const messages=events.input.all(),want=mode==='prime'?[]:iteration===0?[{code:0}]:[{code:2*iteration-1},{code:2*iteration}];assert.deepEqual(messages,want);assert.equal(events.input.lagged(),false);
    reads.push({iteration,mode,capture:captures.B,messages,lagged:false});callbackPending.reading={messages:structuredClone(messages),lagged:events.input.lagged()};if(mode==='prime')return;
    const r=queries.write.get(ids[1]);assert.equal(r.ok,true);const old=r.value.data.main.get(),x=cells(schema,old)[0];
    r.value.data.main.set(replaceFirst(old,x+10));callbackPending.writes.push(found(mainView(r.value.data.main.get())));assert.deepEqual(r.value.data.main.get(),replaceFirst(old,x+10));r.value.data.main.set(replaceFirst(old,x+30));callbackPending.writes.push(found(mainView(r.value.data.main.get())));assert.deepEqual(r.value.data.main.get(),replaceFirst(old,x+30));
    const l=resources.ledger.get();resources.ledger.set({totals:[l.totals[0]+100,...l.totals.slice(1)],epoch:l.epoch});callbackPending.ledger=ledgerView(resources.ledger.get());
    const spawned=spawnValue(iteration,true),id=commands.spawn(G.Command.spawn([Main,spawned]));method.reserve(id);callbackPending.reservation={kind:"Reserved",actor:method.actor(id.value)};callbackPending.payload=mainView(spawned);if(mode==='fail')bFail=id;else bRetry=id;
    const pending=lookup.getHandle(G.Entity.handle(id),Q);assert.equal(pending.error._tag,'MissingEntity');callbackPending.pendingLookup=accessResult(pending);events.out.emit({code:2*iteration+1});services.audit.log({who:'B',iteration,capture:captures.B});
    if(mode==='fail')return Fx.fail({code:7});
  });
  runtime.debug.observe(event=>{if(event.type==='system'&&event.system==='B')diagnostics.push({iteration,mode,frame:event.frame,tick:event.tick,outcome:event.outcome,missed:event.missed});if(event.type==='system'&&(event.system==='A'||event.system==='B')){assert.ok(callbackPending);callbackPending.mode=iteration===-1?'Prime':event.outcome==='failed'?'Fail':event.system==='A'?'Commit':'Retry';callbackPending.readerStatus=event.system==='A'?null:event.outcome==='failed'?1:0;callbackPending.readerError=event.system==='A'||event.outcome!=='failed'?null:event.error.code;callbackPending.outcome=event.outcome==='ok'?{kind:'Success'}:{kind:'Failure',code:event.error.code};method.record(callbackPending);callbackPending=null;}if(event.type==='system'&&event.system==='PublicationObserver'){assert.ok(publicationPending);publicationPending.status=event.outcome==='ok'?0:1;method.record(publicationPending);publicationPending=null;}});
  let publicationWant=[];
  const Publications=G.System('PublicationObserver',{events:{input:G.System.readEvent(Ping)}},({events})=>{assert.deepEqual(events.input.all(),publicationWant);assert.equal(events.input.lagged(),false);publicationPending={kind:'Publications',mode:iteration===-1?'Prime':mode==='fail'?'AfterFailure':'AfterRetry',iteration:iteration===-1?null:iteration,status:null,messages:structuredClone(events.input.all()),lagged:events.input.lagged()};});
  ok(B,Publications);method.phase(0,iteration,lastTick); // Explicit same-instance registration before A's first publication.
  const Observe=G.System('Observe',{queries:{q:Q},resources:{ledger:G.System.readResource(Ledger)}},({queries,resources,lookup})=>{
    const rows=queries.q.each().map(row),want=[...expected.values()].sort((a,b)=>a.rawId-b.rawId);assert.deepEqual(rows,want,stage+'.full-fields');
    assert.deepEqual(resources.ledger.get(),{totals:[ledgerFirst,101,102,103],epoch:4});
    const handles=[aSpawn,bFail,bRetry].filter(Boolean),lookups=[],fullLookups=[],allFailed=[];for(const id of failedHandles){const result=lookup.getHandle(G.Entity.handle(id),Q);assert.equal(result.error._tag,'MissingEntity');allFailed.push(method.lookup(id,result));}for(const id of handles){const result=lookup.getHandle(G.Entity.handle(id),Q);if(expected.has(id.value)){assert.equal(result.ok,true);assert.deepEqual(row(result.value),expected.get(id.value));}else assert.equal(result.error._tag,'MissingEntity');lookups.push({rawId:id.value,result:result.ok?'Found':result.error._tag});fullLookups.push(method.lookup(id,result));}
    audit.push({iteration,stage,count:rows.length,rowsSha256:sha(JSON.stringify(rows)),ledger:structuredClone(resources.ledger.get()),lookups,captures:{...captures},rows:structuredClone(rows),fullLookups,allFailed});lastRows=structuredClone(rows);lastLedger=structuredClone(resources.ledger.get());method.record({kind:"Boundary",iteration,phase:stage,rows:rows.map(r=>method.row(r)),ledger:ledgerView(lastLedger),pendingA:fullLookups[0]??null,latestFailed:fullLookups[1]??null,retryB:fullLookups[2]??null,allFailed,captures:{...captures}});
  });
  const start=process.hrtime.bigint();
  for(iteration=0;iteration<iterations;iteration++){
    bRetry=null;mode='fail';const failure=tick(A,B);method.phase(1,iteration,failure);assert.deepEqual(failure,{ok:false,error:{kind:'SystemFailure',system:'B',error:{code:7}}});
    expected.get(ids[0].value).main=replaceFirst(expected.get(ids[0].value).main,iteration+1);ledgerFirst=iteration*101+1;
    failedHandles.push(bFail);stage='failed-before-barrier';ok(Observe);publicationWant=[{code:2*iteration}];ok(Publications);method.phase(2,iteration,lastTick);
    assert.deepEqual([aSpawn.value,bFail.value],[count+3*iteration+1,count+3*iteration+2]);
    mode='retry';ok(B);method.phase(3,iteration,lastTick);expected.get(ids[1].value).main=replaceFirst(expected.get(ids[1].value).main,1+30*(iteration+1));ledgerFirst=(iteration+1)*101;
    assert.equal(bRetry.value,count+3*iteration+3);assert.equal(captures.B,1+2*(iteration+1));stage='retry-before-barrier';ok(Observe);publicationWant=[{code:2*iteration+1}];ok(Publications);method.phase(4,iteration,lastTick);
    reservations.push({iteration,A:aSpawn.value,failedB:bFail.value,retryB:bRetry.value});
    ok(G.Schedule.applyDeferred());method.phase(5,iteration,lastTick);expected.set(aSpawn.value,{rawId:aSpawn.value,main:spawnValue(iteration,false),aux:null,flag:null});expected.set(bRetry.value,{rawId:bRetry.value,main:spawnValue(iteration,true),aux:null,flag:null});stage='applied-FIFO';ok(Observe);
    const Dispose=G.System('Dispose',{},({commands})=>{commands.despawn(aSpawn);commands.despawn(bRetry);});ok(Dispose,G.Schedule.applyDeferred());method.phase(6,iteration,lastTick);expected.delete(aSpawn.value);expected.delete(bRetry.value);stage='disposed';ok(Observe);
  }
  assert.equal(effects.length,3*iterations);for(let i=0;i<iterations;i++)assert.deepEqual(effects.slice(3*i,3*i+3),[{who:'A',iteration:i,capture:i+1},{who:'B',iteration:i,capture:2*i+2},{who:'B',iteration:i,capture:2*i+3}]);
  for(const d of diagnostics){assert.equal(d.outcome,d.mode==='fail'?'failed':'ok');assert.deepEqual(d.missed,[]);}
  method.record({kind:'Final',rows:lastRows.map(r=>method.row(r)),ledger:ledgerView(lastLedger),captures:{...captures},effects:effects.map(x=>JSON.stringify(x)),status:{kind:lastTick.ok?'Complete':'Stopped'}});
  const tuple=encode(method.records),forced=tuple.reduce((acc,x)=>(Math.imul(acc,33)+x)>>>0,0);writeAll('FORCE:'+forced+'\n');const end=process.hrtime.bigint();
  writeFileSync(clockPath,String(end-start)+'\n',{flag:'wx'});const rss=process.resourceUsage().maxRSS;writeFileSync(rssPath,JSON.stringify({peakRssKiB:rss,platform:process.platform,units:'KiB',scope:'whole-process-highwater-including-warmup'})+'\n',{flag:'wx'});
  const full={schema,workload:'failed-transaction',count,iterations,status:'PASS',capacity:65536,registration:'B and independent publication observer invoked after seed/barrier, before A publication; priming consumes one B capture',
    captures,reservations,reads,diagnostics,audit,effects,retainedLiveCount:expected.size,finalSha256:sha(JSON.stringify([...expected.values()])),ledger:{totals:[ledgerFirst,101,102,103],epoch:4},
    scope:'Correctness only; same actual B instance fails/retries, earlier A survives, full inverse restoration/publication discard/pending and allocation observations checked; no timing.',method:{rawActorMap:method.rawActorMap,records:method.records,rawTickOutcomes:method.rawTickOutcomes,finalRows:lastRows}};
  writeAll('TUPLE:'+JSON.stringify(tuple)+'\nFULL:'+JSON.stringify(full)+'\n');
}

const [countText,iterationText,warmupClock,sampleClock,warmupRss,sampleRss]=process.argv.slice(2);assert.equal(iterationText,'64');const count=Number(countText);assert.equal(count,64);for(const path of [warmupClock,sampleClock,warmupRss,sampleRss])assert.equal(typeof path,'string');
writeAll('WARMUP\n');transactions('Health',count,warmupClock,warmupRss);writeAll('SAMPLE\n');transactions('Health',count,sampleClock,sampleRss);
