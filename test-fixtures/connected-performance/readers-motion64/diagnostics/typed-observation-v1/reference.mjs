// Pinned public bevy-ts measurement reference. No Bend or performance acceptance.
import assert from 'node:assert/strict';
import {readFileSync,writeFileSync,writeSync} from 'node:fs';
import {execFileSync} from 'node:child_process';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {Descriptor,Schema,Fx} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const reference='/workspace/formal-proofs/bendvy/.references/bevy-ts';
const pin='3040a3b2a3f28fa8554d856f9ccb6bf5433fa334';
const self=fileURLToPath(import.meta.url), iterations=64;
assert.equal(execFileSync('git',['-C',reference,'rev-parse','HEAD'],{encoding:'utf8',timeout:5000}).trim(),pin);
assert.equal(JSON.parse(readFileSync('/workspace/formal-proofs/bendvy/.references/sources.json')).sources['bevy-ts'].commit,pin);
const schemas=['Motion','Health'],workloads=['dense','sparse','lifecycle','readers','failed-transaction'],counts=[64,256,1024];
const main=(schema,j,delta=0)=>schema==='Motion'?{coordinates:[j+delta,j+1,j+2,j+3],frame:7}:{levels:[j+delta,j+1,j+2,j+3],reserve:9,class:2};
const aux=schema=>schema==='Motion'?{rates:[1,2,3,4],moving:true}:{layers:[1,2,3,4],grade:3};
const cells=(schema,value)=>schema==='Motion'?value.coordinates:value.levels;
import {typedObservationFold} from '../../../lifecycle-motion64/diagnostics/typed-observation-prototype-v1/reference.mjs';
export {typedObservationFold};
export function freezeOwnedObservation(value){if(value!==null&&typeof value==='object'){for(const child of Object.values(value))freezeOwnedObservation(child);Object.freeze(value);}return value;}
function writeAll(text){const bytes=Buffer.from(text);let at=0;while(at<bytes.length)at+=writeSync(1,bytes,at,bytes.length-at);}
class Method{
 constructor(){this.ids=new Map();this.rawActorMap=[];this.records=[];this.pendingRead=null;}
 reserve(id){assert.ok(!this.ids.has(id.value),'duplicate actor');const actor=this.rawActorMap.length+1;this.ids.set(id.value,actor);this.rawActorMap.push({actor,rawId:id.value});}
 actor(raw){assert.ok(this.ids.has(raw),'unmapped actor');return this.ids.get(raw);}
 row(value){return {actor:this.actor(value.rawId),main:{kind:'Found',value:structuredClone(value.main)},aux:value.aux===null?{kind:'Absent'}:{kind:'Found',value:structuredClone(value.aux)},flag:value.flag===null?{kind:'Absent'}:{kind:'Found',value:structuredClone(value.flag)}};}
 record(value){this.records.push(value);}
 recordRead(value){assert.equal(this.pendingRead,null);this.pendingRead=value;this.record(value);}
 stage(stage,iteration,result){this.record({kind:'Stage',stage,iteration,outcome:{kind:result.ok?'Success':'Failure'}});}
 completeRecords(){return this.records.map(value=>{let out;if(value.kind==='SeedActors')out={kind:value.kind,actors:value.actors.map(x=>this.actor(x))};else if(value.kind==='Read')out={kind:value.kind,who:value.who,phase:value.phase,iteration:value.iteration,rows:value.rows.map(x=>this.row(x)),added:value.added.map(x=>this.row(x)),changed:value.changed.map(x=>this.row(x)),ping:value.ping,removed:{values:value.removed.values.map(x=>({actor:this.actor(x)}))},despawned:{values:value.despawned.values.map(x=>({actor:this.actor(x)}))},status:value.status};else if(value.kind==='Final')out={kind:value.kind,rows:value.rows.map(x=>this.row(x)),ledger:value.ledger,status:value.status};else out=value;return freezeOwnedObservation(out);});}
}
function encode(records){const out=[];const natural=n=>{for(const c of String(n))out.push(c.codePointAt(0));out.push(0);};natural(records.length);for(const text of records){const scalars=Array.from(text,c=>c.codePointAt(0));natural(scalars.length);for(const value of scalars)out.push(value);}return out;}
function fold32(values){let acc=0;for(const value of values)acc=(Math.imul(acc,33)+value)>>>0;return acc;}
function readers(schema,count,clockPath){
  const method=new Method();let lastResult=null;
  const Main=Descriptor.Component()(schema==='Motion'?'Position':'Vitals'),Aux=Descriptor.Component()(schema==='Motion'?'Velocity':'Armor'),Flag=Descriptor.Component()(schema==='Motion'?'Selected':'Tracked'),Ledger=Descriptor.Resource()(schema+'Ledger'),Ping=Descriptor.Event()(schema+'Ping');
  const G=Schema.bind(Schema.fragment({components:{Main,Aux,Flag},resources:{[Ledger.name]:Ledger},events:{Ping}}));
  const runtime=G.Runtime.make({resources:{[Ledger.name]:{totals:[0,101,102,103],epoch:4}},services:G.Runtime.services(),debug:true});
  const query=filters=>G.Query({selection:{main:G.Query.read(Main),aux:G.Query.optional(Aux),flag:G.Query.optional(Flag)},...(filters?{filters}:{})});
  const Q=query(),Added=query([G.Query.added(Main)]),Changed=query([G.Query.changed(Main)]),Write=G.Query({selection:{main:G.Query.write(Main)}});
  const ids=[],transients=[],publicTicks=[],publicUpdates=[];
  let phase='prime',iteration=-1,transient=null;
  const tick=(...steps)=>{const result=runtime.tick(G.Schedule(...steps));publicTicks.push(result.ok?{ok:true,value:result.value===undefined?{kind:'Undefined'}:structuredClone(result.value)}:structuredClone(result));lastResult=result;assert.equal(result.ok,true);return result;};
  const row=r=>({rawId:r.entity.id.value,main:structuredClone(r.data.main.get()),aux:r.data.aux.present?structuredClone(r.data.aux.get()):null,flag:r.data.flag.present?structuredClone(r.data.flag.get()):null});
  const Seed=G.System('Seed',{},({commands})=>{for(let j=0;j<count;j++){
    const entries=[[Main,main(schema,j)]];if(j%3===0)entries.push([Aux,aux(schema)]);if(j%3===1)entries.push([Flag,{group:8}]);
    const id=commands.spawn(G.Command.spawn(...entries));ids.push(id);method.reserve(id);
  }});tick(Seed,G.Schedule.applyDeferred());method.record({kind:"SeedActors",actors:ids.map(id=>id.value)});
  runtime.debug.observe(event=>{if(event.type==='system'&&['Fast','Slow'].includes(event.system)){
    assert.notEqual(method.pendingRead,null);method.pendingRead.status={kind:event.outcome==='ok'?'Success':'Failed'};method.pendingRead=null;
  }});
  function reader(who){return G.System(who,{queries:{q:Q,added:Added,changed:Changed},removed:{main:G.System.readRemoved(Main)},despawned:{entities:G.System.readDespawned()},events:{ping:G.System.readEvent(Ping)}},({queries,removed,despawned,events})=>{
    const rows=queries.q.each().map(row);
    const actualAdded=queries.added.each().map(row),actualChanged=queries.changed.each().map(row);
    const actualRemoved=removed.main.all().map(id=>id.value),actualDespawned=despawned.entities.all().map(id=>id.value);
    const messages=events.ping.all(),lagged=events.ping.lagged();
    method.recordRead({kind:'Read',who,phase:phase==='prime'?'Prime':phase==='drain'?'Drain':'Read',iteration:phase==='read'?iteration:null,rows:structuredClone(rows),added:structuredClone(actualAdded),changed:structuredClone(actualChanged),ping:{values:structuredClone(messages),lagged},removed:{values:actualRemoved.slice()},despawned:{values:actualDespawned.slice()},status:null});
  });}
  const Fast=reader('Fast'),Slow=reader('Slow');tick(Fast,Slow);method.stage('Prime',null,lastResult);
  const start=process.hrtime.bigint();
  for(iteration=0;iteration<iterations;iteration++){
    phase='read';
    const Spawn=G.System('Spawn',{},({commands})=>{transient=commands.spawn(G.Command.spawn([Main,main(schema,iteration)]));method.reserve(transient);});
    tick(Spawn,G.Schedule.applyDeferred());method.stage("SpawnBarrier",iteration,lastResult);transients.push(transient);
    const Update=G.System('Update',{queries:{write:Write},events:{ping:G.System.writeEvent(Ping)}},({queries,events})=>{
      const r=queries.write.get(transient);assert.equal(r.ok,true);const old=r.value.data.main.get(),xs=cells(schema,old);
      publicUpdates.push({iteration,access:{kind:'Found',value:structuredClone(old)}});const next=[xs[0]+1,xs[1],xs[2],xs[3]];
      r.value.data.main.set(schema==='Motion'?{coordinates:next,frame:old.frame}:{levels:next,reserve:old.reserve,class:old.class});events.ping.emit({code:iteration});
    });tick(Update,Fast,...(iteration%4===3?[Slow]:[]));method.stage("UpdateReaders",iteration,lastResult);
    const Dispose=G.System('Dispose',{},({commands})=>{commands.remove(transient,Main);commands.despawn(transient);});tick(Dispose,G.Schedule.applyDeferred());method.stage("DisposeBarrier",iteration,lastResult);
  }
  iteration=iterations-1;phase='drain';tick(Fast,Slow);method.stage('Drain',null,lastResult);
  let final;const Dump=G.System('Dump',{queries:{q:Q},resources:{ledger:G.System.readResource(Ledger)}},({queries,resources})=>{final={rows:queries.q.each().map(row),ledger:structuredClone(resources.ledger.get())};});tick(Dump);
  method.record({kind:'Final',rows:structuredClone(final.rows),ledger:structuredClone(final.ledger),status:{kind:lastResult.ok?'Complete':'BodyFailed'}});
  const records=Object.freeze(method.completeRecords()),publicRecords=freezeOwnedObservation([{ticks:publicTicks,updates:publicUpdates}]);
  writeAll('FORCE:'+typedObservationFold(records)+'\n');writeAll('PUBLIC-FORCE:'+typedObservationFold(publicRecords)+'\n');const end=process.hrtime.bigint();
  writeFileSync(clockPath,String(end-start)+'\n',{flag:'wx'});
  const tuple=encode(records.map(value=>JSON.stringify(value))),publicTuple=encode(publicRecords.map(value=>JSON.stringify(value)));
  writeAll('TUPLE:'+JSON.stringify(tuple)+'\nPUBLIC-TUPLE:'+JSON.stringify(publicTuple)+'\nACTORS:'+JSON.stringify(method.rawActorMap)+'\n');
}
if(process.argv[1]&&import.meta.url===pathToFileURL(process.argv[1]).href){
const [countArg,iterationsArg,warmupClock,sampleClock]=process.argv.slice(2);assert.ok(counts.includes(Number(countArg)));assert.equal(Number(iterationsArg),64);for(const path of [warmupClock,sampleClock])assert.equal(typeof path,'string');writeAll('TYPED-OBSERVATION:v1:json-fields\nWARMUP\n');readers('Motion',Number(countArg),warmupClock);writeAll('SAMPLE\n');readers('Motion',Number(countArg),sampleClock);
}
