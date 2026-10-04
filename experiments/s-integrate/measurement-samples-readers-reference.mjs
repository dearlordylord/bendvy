// Pinned public bevy-ts measurement reference. No Bend or performance acceptance.
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {readFileSync,writeFileSync} from 'node:fs';
import {execFileSync} from 'node:child_process';
import {fileURLToPath} from 'node:url';
import {Descriptor,Schema,Fx} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const reference='/workspace/formal-proofs/bendvy/.references/bevy-ts';
const pin='3040a3b2a3f28fa8554d856f9ccb6bf5433fa334';
const self=fileURLToPath(import.meta.url), iterations=64;
const sha=x=>createHash('sha256').update(x).digest('hex');
const hashFile=p=>sha(readFileSync(p));
assert.equal(execFileSync('git',['-C',reference,'rev-parse','HEAD'],{encoding:'utf8',timeout:5000}).trim(),pin);
assert.equal(JSON.parse(readFileSync(new URL('../../.references/sources.json',import.meta.url))).sources['bevy-ts'].commit,pin);
const schemas=['Motion','Health'],workloads=['dense','sparse','lifecycle','readers','failed-transaction'],counts=[64,256,1024];
const main=(schema,j,delta=0)=>schema==='Motion'?{coordinates:[j+delta,j+1,j+2,j+3],frame:7}:{levels:[j+delta,j+1,j+2,j+3],reserve:9,class:2};
const aux=schema=>schema==='Motion'?{rates:[1,2,3,4],moving:true}:{layers:[1,2,3,4],grade:3};
const cells=(schema,value)=>schema==='Motion'?value.coordinates:value.levels;
// An integer checksum supplements exact full-field comparisons. Inputs stay below 2^53.
function fold(acc,values){for(const value of values)acc=(acc*33+Number(value))%2147483647;return acc;}
function rowValues(schema,row){return [row.rawId,...cells(schema,row.main),...(schema==='Motion'?[row.main.frame]:[row.main.reserve,row.main.class]),row.aux!==null,...(row.aux===null?[]:schema==='Motion'?[...row.aux.rates,row.aux.moving]:[...row.aux.layers,row.aux.grade]),row.flag!==null,...(row.flag===null?[]:[row.flag.group])];}
function readers(schema,count){
  const Main=Descriptor.Component()(schema==='Motion'?'Position':'Vitals'),Aux=Descriptor.Component()(schema==='Motion'?'Velocity':'Armor'),Flag=Descriptor.Component()(schema==='Motion'?'Selected':'Tracked'),Ledger=Descriptor.Resource()(schema+'Ledger'),Ping=Descriptor.Event()(schema+'Ping');
  const G=Schema.bind(Schema.fragment({components:{Main,Aux,Flag},resources:{[Ledger.name]:Ledger},events:{Ping}}));
  const runtime=G.Runtime.make({resources:{[Ledger.name]:{totals:[0,101,102,103],epoch:4}},services:G.Runtime.services(),debug:true});
  const query=filters=>G.Query({selection:{main:G.Query.read(Main),aux:G.Query.optional(Aux),flag:G.Query.optional(Flag)},...(filters?{filters}:{})});
  const Q=query(),Added=query([G.Query.added(Main)]),Changed=query([G.Query.changed(Main)]),Write=G.Query({selection:{main:G.Query.write(Main)}});
  const expected=new Map(),ids=[],transients=[],audit=[],diagnostics=[];
  let phase='prime',iteration=-1,transient=null;
  const tick=(...steps)=>assert.equal(runtime.tick(G.Schedule(...steps)).ok,true);
  const row=r=>({rawId:r.entity.id.value,main:r.data.main.get(),aux:r.data.aux.present?r.data.aux.get():null,flag:r.data.flag.present?r.data.flag.get():null});
  const Seed=G.System('Seed',{},({commands})=>{for(let j=0;j<count;j++){
    const entries=[[Main,main(schema,j)]];if(j%3===0)entries.push([Aux,aux(schema)]);if(j%3===1)entries.push([Flag,{group:8}]);
    const id=commands.spawn(G.Command.spawn(...entries));ids.push(id);expected.set(id.value,{rawId:id.value,main:main(schema,j),aux:j%3===0?aux(schema):null,flag:j%3===1?{group:8}:null});
  }});tick(Seed,G.Schedule.applyDeferred());
  runtime.debug.observe(event=>{if(event.type==='system'&&['Fast','Slow'].includes(event.system)){
    diagnostics.push({who:event.system,phase,iteration,frame:event.frame,tick:event.tick,outcome:event.outcome,missed:event.missed});
  }});
  function reader(who){return G.System(who,{queries:{q:Q,added:Added,changed:Changed},removed:{main:G.System.readRemoved(Main)},despawned:{entities:G.System.readDespawned()},events:{ping:G.System.readEvent(Ping)}},({queries,removed,despawned,events})=>{
    audit.push({who,phase,iteration,rows:queries.q.each().map(row),added:queries.added.each().map(row),changed:queries.changed.each().map(row),removed:removed.main.all().map(id=>id.value),despawned:despawned.entities.all().map(id=>id.value),messages:events.ping.all(),lagged:events.ping.lagged()});
  });}
  const Fast=reader('Fast'),Slow=reader('Slow');tick(Fast,Slow);
  const started=performance.now();
  for(iteration=0;iteration<iterations;iteration++){
    phase='read';
    const Spawn=G.System('Spawn',{},({commands})=>{transient=commands.spawn(G.Command.spawn([Main,main(schema,iteration)]));});
    tick(Spawn,G.Schedule.applyDeferred());transients.push(transient);
    const Update=G.System('Update',{queries:{write:Write},events:{ping:G.System.writeEvent(Ping)}},({queries,events})=>{
      const r=queries.write.get(transient);assert.equal(r.ok,true);const old=r.value.data.main.get(),xs=cells(schema,old);
      const next=[xs[0]+1,xs[1],xs[2],xs[3]];
      r.value.data.main.set(schema==='Motion'?{coordinates:next,frame:old.frame}:{levels:next,reserve:old.reserve,class:old.class});events.ping.emit({code:iteration});
    });tick(Update,Fast,...(iteration%4===3?[Slow]:[]));
    const Dispose=G.System('Dispose',{},({commands})=>{commands.remove(transient,Main);commands.despawn(transient);});tick(Dispose,G.Schedule.applyDeferred());
  }
  const executionMilliseconds=performance.now()-started;
  iteration=iterations-1;phase='drain';tick(Fast,Slow);
  let final;const Dump=G.System('Dump',{queries:{q:Q},resources:{ledger:G.System.readResource(Ledger)}},({queries,resources})=>{final={rows:queries.q.each().map(row),ledger:structuredClone(resources.ledger.get())};});tick(Dump);
  assert.deepEqual(final,{rows:[...expected.values()],ledger:{totals:[0,101,102,103],epoch:4}});
  assert.equal(audit.length,84);assert.equal(diagnostics.length,audit.length);for(const d of diagnostics){assert.equal(d.outcome,'ok');assert.deepEqual(d.missed,[]);}
  return {executionMilliseconds,final,schema,workload:'readers',count,iterations,status:'PASS',capacity:65536,registration:'same Fast and Slow instances first invoked after seed+barrier, before first transient publication',
    initialPublicDiagnostics:diagnostics.slice(0,2),diagnostics,audit,finalSha256:sha(JSON.stringify(final)),retainedLiveCount:count,rawTransientRange:[transients[0].value,transients.at(-1).value],
    finalLogicalUnread:{Fast:{messages:[],removed:[],despawned:[]},Slow:{messages:[],removed:[],despawned:[]}},
    unreadEvidence:'Both instances drain at the final boundary; no private cursor or physical log occupancy is inspected. Subsequent empty reads are not yet performed.',
    peakRssKiB:process.resourceUsage().maxRSS,scope:'Correctness only; actual transient spawn/update/publish/read/remove/despawn barriers; every live field and every delivery checked, no timing.'};
}
const [schema,n]=process.argv.slice(2);assert(schemas.includes(schema));const count=Number(n);assert(counts.includes(count));
const warmup=readers(schema,count),sample=readers(schema,count);console.log(JSON.stringify({warmup,sample}));
