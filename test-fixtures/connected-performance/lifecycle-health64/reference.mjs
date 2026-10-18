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
function tickRecord(runtime,result){const dump=runtime.debug.dump({limit:0});return {frame:dump.frame,tick:dump.tick,outcome:result.ok?{ok:true,value:{kind:'Undefined'}}:structuredClone(result)};}
function projected(row,actor){return {actor,main:{kind:'Found',value:structuredClone(row.main)},aux:row.aux===null?{kind:'Absent'}:{kind:'Found',value:structuredClone(row.aux)},flag:row.flag===null?{kind:'Absent'}:{kind:'Found',value:structuredClone(row.flag)}};}
function foreignRow(row,map){const entry=map.find(x=>x.rawId===row.rawId);assert.ok(entry,'unmapped foreign actor');return projected(row,entry.actor);}
const lookupResult=(value,row)=>value.ok?{kind:'Found',row:row(value.value)}:{kind:value.error._tag};
const lookupKind=value=>value.ok?2:value.error._tag==='MissingEntity'?0:value.error._tag==='QueryMismatch'?1:(()=>{throw Error('unexpected lookup');})();
const resultKind=value=>value.kind==='Found'?2:value.kind==='MissingEntity'?0:value.kind==='QueryMismatch'?1:(()=>{throw Error('unexpected result');})();
class Method{
 constructor(){this.ids=new Map();this.rawActorMap=[];this.foreignActorMap=[];this.records=[];this.foreignRecords=[];this.reservations=[];this.rawTickOutcomes=[];this.foreignTicks=[];this.observations=[];this.foreignSetup=null;}
 reserve(id){assert.ok(!this.ids.has(id.value),'duplicate actor');const actor=this.rawActorMap.length+1;this.ids.set(id.value,actor);this.rawActorMap.push({actor,rawId:id.value});}
 actor(raw){assert.ok(this.ids.has(raw),'unmapped actor');return this.ids.get(raw);}
 row(value){return projected(value,this.actor(value.rawId));}
 record(value){this.records.push(JSON.stringify(value));}
 stage(iteration,stage,result){this.record({kind:'Stage',iteration,stage,outcome:{kind:result.ok?'Success':'Failure'}});}
}
function encode(records){const out=[];const natural=value=>{for(const ch of String(value))out.push(ch.codePointAt(0));out.push(0);};natural(records.length);for(const record of records){const scalars=Array.from(record,ch=>ch.codePointAt(0));natural(scalars.length);for(const scalar of scalars)out.push(scalar);}return out;}
function fold32(values){let acc=0;for(const value of values)acc=(Math.imul(acc,33)+value)>>>0;return acc;}
function lifecycle(schema,count,clockPath,rssPath){
  const method=new Method();let current=null,selected=null,iteration=0,phase=0,lastRows=null,lastLedger=null,lastStale=null,lastCurrent=null,lastTarget=null,lastResult=null;
  const Main=Descriptor.Component()(schema==='Motion'?'Position':'Vitals'),Aux=Descriptor.Component()(schema==='Motion'?'Velocity':'Armor'),Flag=Descriptor.Component()(schema==='Motion'?'Selected':'Tracked'),Ledger=Descriptor.Resource()(schema+'Ledger');
  const G=Schema.bind(Schema.fragment({components:{Main,Aux,Flag},resources:{[Ledger.name]:Ledger}}));
  const make=()=>G.Runtime.make({resources:{[Ledger.name]:{totals:[0,101,102,103],epoch:4}},services:G.Runtime.services(),debug:true});
  const runtime=make(),foreign=make(),ids=[],expected=new Map(),audit=[];
  const Q=G.Query({selection:{main:G.Query.read(Main),aux:G.Query.optional(Aux),flag:G.Query.optional(Flag)}});
  const row=r=>({rawId:r.entity.id.value,main:structuredClone(r.data.main.get()),aux:r.data.aux.present?structuredClone(r.data.aux.get()):null,flag:r.data.flag.present?structuredClone(r.data.flag.get()):null});
  const tick=(...steps)=>{const result=runtime.tick(G.Schedule(...steps));method.rawTickOutcomes.push(tickRecord(runtime,result));lastResult=result;assert.equal(result.ok,true);return result;};
  const Seed=G.System('Seed',{},({commands})=>{for(let j=0;j<count;j++){
    const entries=[[Main,main(schema,j)]];if(j%3===0)entries.push([Aux,aux(schema)]);if(j%3===1)entries.push([Flag,{group:8}]);
    const id=commands.spawn(G.Command.spawn(...entries));ids.push(id);method.reserve(id);expected.set(id.value,{rawId:id.value,main:main(schema,j),aux:j%3===0?aux(schema):null,flag:j%3===1?{group:8}:null});
  }});tick(Seed,G.Schedule.applyDeferred());
  let foreignId;
  const SeedForeign=G.System('SeedForeign',{},({commands})=>{foreignId=commands.spawn(G.Command.spawn([Main,main(schema,999)]));});
  const foreignSeed=foreign.tick(G.Schedule(SeedForeign,G.Schedule.applyDeferred()));assert.equal(foreignSeed.ok,true);assert.equal(foreignId.value,1);method.foreignActorMap.push({actor:1,rawId:foreignId.value});method.foreignTicks.push(tickRecord(foreign,foreignSeed));
  let foreignSetup=null;
  const ForeignRead=G.System('Method/ForeignSetup',{queries:{q:Q},resources:{ledger:G.System.readResource(Ledger)}},({queries,resources})=>{foreignSetup={rows:queries.q.each().map(row),ledger:structuredClone(resources.ledger.get())};});
  const foreignRead=foreign.tick(G.Schedule(ForeignRead));assert.equal(foreignRead.ok,true);method.foreignTicks.push(tickRecord(foreign,foreignRead));assert.notEqual(foreignSetup,null);
  const stale=[];let pending=null,label='';
  const Observe=G.System('Observe',{queries:{q:Q},resources:{ledger:G.System.readResource(Ledger)}},({queries,resources,lookup})=>{
    const rows=queries.q.each().map(row),want=[...expected.values()].sort((a,b)=>a.rawId-b.rawId);assert.deepEqual(rows,want,label+'.all-fields');
    assert.deepEqual(resources.ledger.get(),{totals:[0,101,102,103],epoch:4});
    if(pending!==null)assert.equal(lookup.getHandle(G.Entity.handle(pending),Q).error._tag,'MissingEntity');
    for(const id of stale)assert.equal(lookup.getHandle(G.Entity.handle(id),Q).error._tag,'MissingEntity');
    // Intentional pinned-TS foreign lookup behavior: the receiver resolves local raw ID.
    const f=lookup.getHandle(G.Entity.handle(foreignId),Q);
    if(expected.has(foreignId.value)){assert.equal(f.ok,true);assert.deepEqual(row(f.value),expected.get(foreignId.value));}else assert.equal(f.error._tag,'MissingEntity');
    audit.push({label,count:rows.length,sha256:sha(JSON.stringify(rows)),pending:pending?.value??null,staleCount:stale.length,lastStale:stale.at(-1)?.value??null,foreign: f.ok?'receiver-local-collision':'MissingEntity'});
    const currentResult=lookup.getHandle(G.Entity.handle(current),Q),targetResult=lookup.getHandle(G.Entity.handle(selected),Q),staleResults=stale.map(id=>({rawId:id.value,result:lookupResult(lookup.getHandle(G.Entity.handle(id),Q),row)})),ledger=structuredClone(resources.ledger.get());
    method.observations.push({iteration,phase,rows:structuredClone(rows),ledger,current:{rawId:current.value,result:lookupResult(currentResult,row)},target:{rawId:selected.value,result:lookupResult(targetResult,row)},stale:staleResults,foreign:lookupResult(f,row)});
    method.record({kind:'Boundary',iteration,phase,target:method.actor(selected.value),current:method.actor(current.value),reservations:method.reservations.slice(),rows:rows.map(value=>method.row(value)),ledger,currentKind:lookupKind(currentResult),targetKind:lookupKind(targetResult),stale:staleResults.map(value=>({actor:method.actor(value.rawId),kind:resultKind(value.result)}))});
    method.foreignRecords.push(JSON.stringify({kind:'ForeignProbe',iteration,phase,foreign:{world:'foreign',actor:method.foreignActorMap.find(x=>x.rawId===foreignId.value).actor,rawId:foreignId.value},result:lookupResult(f,row)}));lastRows=structuredClone(rows);lastLedger=ledger;lastStale=staleResults;lastCurrent=current;lastTarget=selected;
  });
  method.foreignSetup=foreignSetup;
  const start=process.hrtime.bigint();
  method.record({kind:'Seed',count,actors:ids.map(id=>method.actor(id.value)),foreign:{actor:method.foreignActorMap.find(x=>x.rawId===foreignId.value).actor,rows:foreignSetup.rows.map(value=>foreignRow(value,method.foreignActorMap)),ledger:foreignSetup.ledger}});
  for(let i=0;i<iterations;i++){
    iteration=i;
    const live=[...expected.keys()].sort((a,b)=>a-b),offset=i%3===0?0:i%3===1?Math.floor(live.length/2):live.length-1,target=ids.find(id=>id.value===live[offset]);
    assert.notEqual(target,undefined);selected=target;
    const Reserve=G.System('Reserve',{},({commands})=>{pending=commands.spawn(G.Command.spawn([Main,main(schema,i)]));ids.push(pending);method.reserve(pending);current=pending;method.reservations.push(method.actor(pending.value));});
    tick(Reserve);method.stage(i,0,lastResult);assert.equal(pending.value,count+i+1);label=i+':pending';phase=0;tick(Observe);method.stage(i,1,lastResult);
    const fresh=pending;tick(G.Schedule.applyDeferred());method.stage(i,2,lastResult);expected.set(fresh.value,{rawId:fresh.value,main:main(schema,i),aux:null,flag:null});pending=null;label=i+':live';phase=1;tick(Observe);method.stage(i,3,lastResult);
    const Dispose=G.System('Dispose',{},({commands})=>{commands.remove(target,Main);commands.despawn(target);});
    tick(Dispose,G.Schedule.applyDeferred());method.stage(i,4,lastResult);expected.delete(target.value);stale.push(target);label=i+':disposed';phase=2;tick(Observe);method.stage(i,5,lastResult);
  }
  method.record({kind:'Final',rows:lastRows.map(value=>method.row(value)),ledger:lastLedger,current:method.actor(lastCurrent.value),target:method.actor(lastTarget.value),reservations:method.reservations.slice(),stale:lastStale.map(value=>({actor:method.actor(value.rawId),kind:resultKind(value.result)})),status:{kind:lastResult.ok?'Complete':'BodyFailed'}});
  const tuple=encode(method.records),foreignTuple=encode(method.foreignRecords);writeAll('FORCE:'+fold32(tuple)+'\n');writeAll('FOREIGN-FORCE:'+fold32(foreignTuple)+'\n');const end=process.hrtime.bigint();
  writeFileSync(clockPath,String(end-start)+'\n',{flag:'wx'});writeFileSync(rssPath,JSON.stringify({peakRssKiB:process.resourceUsage().maxRSS,platform:process.platform,units:'KiB',scope:'whole-process-highwater-including-warmup'})+'\n',{flag:'wx'});
  const full={schema,workload:'lifecycle',count,iterations,status:'PASS',fullBoundaryChecks:audit.length,retainedLiveCount:expected.size,rawReservationRange:[1,ids.at(-1).value],
    finalSha256:sha(JSON.stringify([...expected.values()].sort((a,b)=>a.rawId-b.rawId))),audit,
    scope:'Correctness only; no timings. Actual reserve, pending lookup/query, barriers, rotating first/middle/last remove/despawn, full surviving fields, stale and foreign lookup.',
    foreignLookup:'Pinned TS raw-ID collision behavior retained separately; Bend MissingEntity divergence is approved, not a TS parity expectation.',method:{rawActorMap:method.rawActorMap,foreignActorMap:method.foreignActorMap,foreignSetup:method.foreignSetup,foreignTicks:method.foreignTicks,rawTickOutcomes:method.rawTickOutcomes,observations:method.observations,finalRows:lastRows}};
  writeAll('TUPLE:'+JSON.stringify(tuple)+'\nFOREIGN-TUPLE:'+JSON.stringify(foreignTuple)+'\nACTORS:'+JSON.stringify(method.rawActorMap)+'\nFULL:'+JSON.stringify(full)+'\n');
}
const [countArg,iterationsArg,warmupClock,sampleClock,warmupRss,sampleRss]=process.argv.slice(2);assert.ok(counts.includes(Number(countArg)));assert.equal(Number(iterationsArg),64);for(const path of [warmupClock,sampleClock,warmupRss,sampleRss])assert.equal(typeof path,'string');writeAll('WARMUP\n');lifecycle('Health',Number(countArg),warmupClock,warmupRss);writeAll('SAMPLE\n');lifecycle('Health',Number(countArg),sampleClock,sampleRss);
