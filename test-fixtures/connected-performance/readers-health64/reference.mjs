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

function writeAll(text){const bytes=Buffer.from(text);let at=0;while(at<bytes.length)at+=writeSync(1,bytes,at,bytes.length-at);}
class Method{
 constructor(){this.ids=new Map();this.rawActorMap=[];this.records=[];this.rawTickOutcomes=[];this.pendingRead=null;}
 reserve(id){assert.ok(!this.ids.has(id.value),'duplicate actor');const actor=this.rawActorMap.length+1;this.ids.set(id.value,actor);this.rawActorMap.push({actor,rawId:id.value});}
 actor(raw){assert.ok(this.ids.has(raw),'unmapped actor');return this.ids.get(raw);}
 row(value){return {actor:this.actor(value.rawId),main:{kind:'Found',value:structuredClone(value.main)},aux:value.aux===null?{kind:'Absent'}:{kind:'Found',value:structuredClone(value.aux)},flag:value.flag===null?{kind:'Absent'}:{kind:'Found',value:structuredClone(value.flag)}};}
 record(value){this.records.push(value);}
 recordRead(value){assert.equal(this.pendingRead,null);this.pendingRead=value;this.record(value);}
 stage(stage,iteration,result){this.record({kind:'Stage',stage,iteration,outcome:{kind:result.ok?'Success':'Failure'}});}
 completeRecords(){return this.records.map(value=>{let out;if(value.kind==='SeedActors')out={kind:value.kind,actors:value.actors.map(x=>this.actor(x))};else if(value.kind==='Read')out={kind:value.kind,who:value.who,phase:value.phase,iteration:value.iteration,rows:value.rows.map(x=>this.row(x)),added:value.added.map(x=>this.row(x)),changed:value.changed.map(x=>this.row(x)),ping:value.ping,removed:{values:value.removed.values.map(x=>({actor:this.actor(x)}))},despawned:{values:value.despawned.values.map(x=>({actor:this.actor(x)}))},status:value.status};else if(value.kind==='Final')out={kind:value.kind,rows:value.rows.map(x=>this.row(x)),ledger:value.ledger,status:value.status};else out=value;return JSON.stringify(out);});}
}
function encode(records){const out=[];const natural=n=>{for(const c of String(n))out.push(c.codePointAt(0));out.push(0);};natural(records.length);for(const text of records){const scalars=Array.from(text,c=>c.codePointAt(0));natural(scalars.length);for(const value of scalars)out.push(value);}return out;}
function fold32(values){let acc=0;for(const value of values)acc=(Math.imul(acc,33)+value)>>>0;return acc;}
function readers(schema,count,clockPath,rssPath){
  const method=new Method();let lastResult=null;
  const Main=Descriptor.Component()(schema==='Motion'?'Position':'Vitals'),Aux=Descriptor.Component()(schema==='Motion'?'Velocity':'Armor'),Flag=Descriptor.Component()(schema==='Motion'?'Selected':'Tracked'),Ledger=Descriptor.Resource()(schema+'Ledger'),Ping=Descriptor.Event()(schema+'Ping');
  const G=Schema.bind(Schema.fragment({components:{Main,Aux,Flag},resources:{[Ledger.name]:Ledger},events:{Ping}}));
  const runtime=G.Runtime.make({resources:{[Ledger.name]:{totals:[0,101,102,103],epoch:4}},services:G.Runtime.services(),debug:true});
  const query=filters=>G.Query({selection:{main:G.Query.read(Main),aux:G.Query.optional(Aux),flag:G.Query.optional(Flag)},...(filters?{filters}:{})});
  const Q=query(),Added=query([G.Query.added(Main)]),Changed=query([G.Query.changed(Main)]),Write=G.Query({selection:{main:G.Query.write(Main)}});
  const expected=new Map(),ids=[],transients=[],audit=[],diagnostics=[],cursor={Fast:{message:-1,removed:-1},Slow:{message:-1,removed:-1}};
  let phase='prime',iteration=-1,transient=null;
  const tick=(...steps)=>{const result=runtime.tick(G.Schedule(...steps));const dump=runtime.debug.dump({limit:0});method.rawTickOutcomes.push({frame:dump.frame,tick:dump.tick,outcome:result.ok?{ok:true,value:{kind:"Undefined"}}:structuredClone(result)});lastResult=result;assert.equal(result.ok,true);return result;};
  const row=r=>({rawId:r.entity.id.value,main:structuredClone(r.data.main.get()),aux:r.data.aux.present?structuredClone(r.data.aux.get()):null,flag:r.data.flag.present?structuredClone(r.data.flag.get()):null});
  const Seed=G.System('Seed',{},({commands})=>{for(let j=0;j<count;j++){
    const entries=[[Main,main(schema,j)]];if(j%3===0)entries.push([Aux,aux(schema)]);if(j%3===1)entries.push([Flag,{group:8}]);
    const id=commands.spawn(G.Command.spawn(...entries));ids.push(id);method.reserve(id);expected.set(id.value,{rawId:id.value,main:main(schema,j),aux:j%3===0?aux(schema):null,flag:j%3===1?{group:8}:null});
  }});tick(Seed,G.Schedule.applyDeferred());method.record({kind:"SeedActors",actors:ids.map(id=>id.value)});
  runtime.debug.observe(event=>{if(event.type==='system'&&['Fast','Slow'].includes(event.system)){
    diagnostics.push({who:event.system,phase,iteration,frame:event.frame,tick:event.tick,outcome:event.outcome,missed:event.missed});assert.notEqual(method.pendingRead,null);method.pendingRead.status={kind:event.outcome==='ok'?'Success':'Failed'};method.pendingRead=null;
  }});
  function reader(who){return G.System(who,{queries:{q:Q,added:Added,changed:Changed},removed:{main:G.System.readRemoved(Main)},despawned:{entities:G.System.readDespawned()},events:{ping:G.System.readEvent(Ping)}},({queries,removed,despawned,events})=>{
    const rows=queries.q.each().map(row),want=[...expected.values()].sort((a,b)=>a.rawId-b.rawId);assert.deepEqual(rows,want);
    const changed=phase==='prime'?want:phase==='drain'?[]:[expected.get(transient.value)];
    const actualAdded=queries.added.each().map(row),actualChanged=queries.changed.each().map(row);assert.deepEqual(actualAdded,changed);assert.deepEqual(actualChanged,changed);
    const upper=phase==='prime'?-1:phase==='drain'?iterations-1:iteration-1;
    const expectedRemoved=transients.slice(cursor[who].removed+1,upper+1).map(id=>id.value);
    const actualRemoved=removed.main.all().map(id=>id.value),actualDespawned=despawned.entities.all().map(id=>id.value);
    assert.deepEqual(actualRemoved,expectedRemoved);assert.deepEqual(actualDespawned,expectedRemoved);
    const messages=events.ping.all(),expectedMessages=Array.from({length:Math.max(0,iteration-cursor[who].message)},(_,j)=>({code:cursor[who].message+j+1}));
    assert.deepEqual(messages,expectedMessages);const lagged=events.ping.lagged();assert.equal(lagged,false);
    audit.push({who,phase,iteration,count:rows.length,rowsSha256:sha(JSON.stringify(rows)),added:changed.map(r=>r.rawId),changed:changed.map(r=>r.rawId),removed:actualRemoved,despawned:actualDespawned,messages,lagged:false});
    method.recordRead({kind:'Read',who,phase:phase==='prime'?'Prime':phase==='drain'?'Drain':'Read',iteration:phase==='read'?iteration:null,rows:structuredClone(rows),added:structuredClone(actualAdded),changed:structuredClone(actualChanged),ping:{values:structuredClone(messages),lagged},removed:{values:actualRemoved.slice()},despawned:{values:actualDespawned.slice()},status:null});
    cursor[who]={message:iteration,removed:upper};
  });}
  const Fast=reader('Fast'),Slow=reader('Slow');tick(Fast,Slow);method.stage('Prime',null,lastResult);
  const start=process.hrtime.bigint();
  for(iteration=0;iteration<iterations;iteration++){
    phase='read';
    const Spawn=G.System('Spawn',{},({commands})=>{transient=commands.spawn(G.Command.spawn([Main,main(schema,iteration)]));method.reserve(transient);});
    tick(Spawn,G.Schedule.applyDeferred());method.stage("SpawnBarrier",iteration,lastResult);assert.equal(transient.value,count+iteration+1);transients.push(transient);
    expected.set(transient.value,{rawId:transient.value,main:main(schema,iteration,1),aux:null,flag:null});
    const Update=G.System('Update',{queries:{write:Write},events:{ping:G.System.writeEvent(Ping)}},({queries,events})=>{
      const r=queries.write.get(transient);assert.equal(r.ok,true);const old=r.value.data.main.get(),xs=cells(schema,old);
      assert.deepEqual(old,main(schema,iteration));const next=[xs[0]+1,xs[1],xs[2],xs[3]];
      r.value.data.main.set(schema==='Motion'?{coordinates:next,frame:old.frame}:{levels:next,reserve:old.reserve,class:old.class});events.ping.emit({code:iteration});
    });tick(Update,Fast,...(iteration%4===3?[Slow]:[]));method.stage("UpdateReaders",iteration,lastResult);
    const Dispose=G.System('Dispose',{},({commands})=>{commands.remove(transient,Main);commands.despawn(transient);});tick(Dispose,G.Schedule.applyDeferred());method.stage("DisposeBarrier",iteration,lastResult);expected.delete(transient.value);
  }
  iteration=iterations-1;phase='drain';tick(Fast,Slow);method.stage('Drain',null,lastResult);
  let final;const Dump=G.System('Dump',{queries:{q:Q},resources:{ledger:G.System.readResource(Ledger)}},({queries,resources})=>{final={rows:queries.q.each().map(row),ledger:structuredClone(resources.ledger.get())};});tick(Dump);
  assert.deepEqual(final,{rows:[...expected.values()],ledger:{totals:[0,101,102,103],epoch:4}});
  assert.equal(audit.length,84);assert.equal(diagnostics.length,audit.length);for(const d of diagnostics){assert.equal(d.outcome,'ok');assert.deepEqual(d.missed,[]);}
  method.record({kind:'Final',rows:structuredClone(final.rows),ledger:structuredClone(final.ledger),status:{kind:lastResult.ok?'Complete':'BodyFailed'}});
  const records=method.completeRecords(),tuple=encode(records);writeAll('FORCE:'+fold32(tuple)+'\n');const end=process.hrtime.bigint();
  writeFileSync(clockPath,String(end-start)+'\n',{flag:'wx'});writeFileSync(rssPath,JSON.stringify({peakRssKiB:process.resourceUsage().maxRSS,platform:process.platform,units:'KiB',scope:'whole-process-highwater-including-warmup'})+'\n',{flag:'wx'});
  const full={schema,workload:'readers',count,iterations,status:'PASS',capacity:65536,registration:'same Fast and Slow instances first invoked after seed+barrier, before first transient publication',
    initialPublicDiagnostics:diagnostics.slice(0,2),diagnostics,audit,finalSha256:sha(JSON.stringify(final)),retainedLiveCount:count,rawTransientRange:[transients[0].value,transients.at(-1).value],
    finalLogicalUnread:{Fast:{messages:[],removed:[],despawned:[]},Slow:{messages:[],removed:[],despawned:[]}},
    unreadEvidence:'Both instances drain at the final boundary; no private cursor or physical log occupancy is inspected. Subsequent empty reads are not yet performed.',
    scope:'Correctness only; actual transient spawn/update/publish/read/remove/despawn barriers; every live field and every delivery checked, no timing.',method:{rawActorMap:method.rawActorMap,rawTickOutcomes:method.rawTickOutcomes,referenceExpectationCursors:structuredClone(cursor),records,finalRows:final.rows,ledger:final.ledger}};
  writeAll('TUPLE:'+JSON.stringify(tuple)+'\nACTORS:'+JSON.stringify(method.rawActorMap)+'\nFULL:'+JSON.stringify(full)+'\n');
}
const [countArg,iterationsArg,warmupClock,sampleClock,warmupRss,sampleRss]=process.argv.slice(2);assert.equal(Number(countArg),64);assert.equal(Number(iterationsArg),64);for(const path of [warmupClock,sampleClock,warmupRss,sampleRss])assert.equal(typeof path,'string');writeAll('WARMUP\n');readers('Health',Number(countArg),warmupClock,warmupRss);writeAll('SAMPLE\n');readers('Health',Number(countArg),sampleClock,sampleRss);
