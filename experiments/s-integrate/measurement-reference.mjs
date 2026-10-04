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
function execute(schema,workload,count){
  const setupStart=performance.now();
  const Main=Descriptor.Component()(schema==='Motion'?'Position':'Vitals');
  const Aux=Descriptor.Component()(schema==='Motion'?'Velocity':'Armor');
  const Flag=Descriptor.Component()(schema==='Motion'?'Selected':'Tracked');
  const Ledger=Descriptor.Resource()(schema+'Ledger');
  const G=Schema.bind(Schema.fragment({components:{Main,Aux,Flag},resources:{[Ledger.name]:Ledger}}));
  const runtime=G.Runtime.make({resources:{[Ledger.name]:{totals:[0,101,102,103],epoch:4}},services:G.Runtime.services()});
  const ids=[];
  const Q=G.Query({selection:{main:G.Query.read(Main),aux:G.Query.optional(Aux),flag:G.Query.optional(Flag)}});
  const With=G.Query({selection:{main:G.Query.read(Main),aux:G.Query.optional(Aux),flag:G.Query.optional(Flag)},with:[Aux]});
  const Without=G.Query({selection:{main:G.Query.read(Main),aux:G.Query.optional(Aux),flag:G.Query.optional(Flag)},without:[Aux]});
  const Write=G.Query({selection:{main:G.Query.write(Main)}});
  const tick=(...steps)=>assert.equal(runtime.tick(G.Schedule(...steps)).ok,true);
  const Seed=G.System('Seed',{},({commands})=>{for(let j=0;j<count;j++){
    const entries=[];if(workload==='dense'||j%8===0)entries.push([Main,main(schema,j)]);
    if(j%3===0)entries.push([Aux,aux(schema)]);if(j%3===1)entries.push([Flag,{group:8}]);
    ids.push(commands.spawn(G.Command.spawn(...entries)));
  }});
  tick(Seed,G.Schedule.applyDeferred());
  const row=r=>({rawId:r.entity.id.value,main:structuredClone(r.data.main.get()),aux:r.data.aux.present?structuredClone(r.data.aux.get()):null,flag:r.data.flag.present?structuredClone(r.data.flag.get()):null});
  const audit=[];
  const Update=G.System('Update',{queries:{write:Write,...(workload==='sparse'?{optional:Q,present:With,absent:Without}:{})},resources:{ledger:G.System.writeResource(Ledger)}},({queries,resources})=>{
    let readSum=0,updated=0;
    for(const r of queries.write.each()){
      const old=r.data.main.get(),xs=cells(schema,old);readSum+=xs[0]+xs[1]+xs[2]+xs[3];
      const next=[xs[0]+1,xs[1],xs[2],xs[3]];
      r.data.main.set(schema==='Motion'?{coordinates:next,frame:old.frame}:{levels:next,reserve:old.reserve,class:old.class});
      const resource=resources.ledger.get();resources.ledger.set({totals:[resource.totals[0]+1,...resource.totals.slice(1)],epoch:resource.epoch});updated++;
    }
    const selections={};
    if(workload==='sparse')for(const name of ['optional','present','absent']){
      let checksum=0,length=0;for(const r of queries[name].each()){checksum=fold(checksum,rowValues(schema,row(r)));length++;}selections[name]={length,checksum};
    }
    audit.push({readSum,updated,selections});
  });
  let final;
  const Dump=G.System('Dump',{queries:{q:Q},resources:{ledger:G.System.readResource(Ledger)}},({queries,resources})=>{final={rows:queries.q.each().map(row),ledger:structuredClone(resources.ledger.get())};});
  const setupMilliseconds=performance.now()-setupStart;
  const start=performance.now();for(let i=0;i<iterations;i++)tick(Update);const executionMilliseconds=performance.now()-start;
  const observationStart=performance.now();tick(Dump);
  const selected=Array.from({length:count},(_,j)=>j).filter(j=>workload==='dense'||j%8===0);
  function expectedRows(delta){return selected.map(j=>({rawId:ids[j].value,main:main(schema,j,delta),aux:j%3===0?aux(schema):null,flag:j%3===1?{group:8}:null}));}
  // Verify raw allocation order rather than hiding it behind labels.
  assert.deepEqual(ids.map(x=>x.value),Array.from({length:count},(_,j)=>j+1));
  const expected={rows:expectedRows(iterations),ledger:{totals:[selected.length*iterations,101,102,103],epoch:4}};
  assert.deepEqual(final,expected,'every final field and ordered raw ID');
  for(let i=0;i<iterations;i++){
    const selections={};if(workload==='sparse'){
      const rows=expectedRows(i+1);
      for(const [name,rs] of [['optional',rows],['present',rows.filter(r=>r.aux!==null)],['absent',rows.filter(r=>r.aux===null)]])selections[name]={length:rs.length,checksum:rs.reduce((acc,r)=>fold(acc,rowValues(schema,r)),0)};
    }
    assert.deepEqual(audit[i],{readSum:selected.reduce((sum,j)=>sum+4*j+6+i,0),updated:selected.length,selections},'iteration '+i);
  }
  return {schema,workload,count,iterations,status:'PASS',selectedCount:selected.length,rawReservationRange:[ids[0].value,ids.at(-1).value],fullFieldsCompared:final.rows.length,
    finalSha256:sha(JSON.stringify(final)),oracleSha256:sha(JSON.stringify(expected)),auditSha256:sha(JSON.stringify(audit)),ledger:final.ledger,
    samples:{first:final.rows[0],last:final.rows.at(-1)},setupMilliseconds,executionMilliseconds,observationAndValidationMilliseconds:performance.now()-observationStart,
    peakRssKiB:process.resourceUsage().maxRSS,memoryScope:'whole child process including imports, setup, validation; not component allocation',
    commandOccupancyAfterSeed:0,readerOccupancy:'not used by dense/sparse',retainedLiveCount:count};
}
function lifecycle(schema,count){
  const Main=Descriptor.Component()(schema==='Motion'?'Position':'Vitals'),Aux=Descriptor.Component()(schema==='Motion'?'Velocity':'Armor'),Flag=Descriptor.Component()(schema==='Motion'?'Selected':'Tracked'),Ledger=Descriptor.Resource()(schema+'Ledger');
  const G=Schema.bind(Schema.fragment({components:{Main,Aux,Flag},resources:{[Ledger.name]:Ledger}}));
  const make=()=>G.Runtime.make({resources:{[Ledger.name]:{totals:[0,101,102,103],epoch:4}},services:G.Runtime.services()});
  const runtime=make(),foreign=make(),ids=[],expected=new Map(),audit=[];
  const Q=G.Query({selection:{main:G.Query.read(Main),aux:G.Query.optional(Aux),flag:G.Query.optional(Flag)}});
  const row=r=>({rawId:r.entity.id.value,main:structuredClone(r.data.main.get()),aux:r.data.aux.present?structuredClone(r.data.aux.get()):null,flag:r.data.flag.present?structuredClone(r.data.flag.get()):null});
  const tick=(...steps)=>assert.equal(runtime.tick(G.Schedule(...steps)).ok,true);
  const Seed=G.System('Seed',{},({commands})=>{for(let j=0;j<count;j++){
    const entries=[[Main,main(schema,j)]];if(j%3===0)entries.push([Aux,aux(schema)]);if(j%3===1)entries.push([Flag,{group:8}]);
    const id=commands.spawn(G.Command.spawn(...entries));ids.push(id);expected.set(id.value,{rawId:id.value,main:main(schema,j),aux:j%3===0?aux(schema):null,flag:j%3===1?{group:8}:null});
  }});tick(Seed,G.Schedule.applyDeferred());
  let foreignId;
  const SeedForeign=G.System('SeedForeign',{},({commands})=>{foreignId=commands.spawn(G.Command.spawn([Main,main(schema,999)]));});
  assert.equal(foreign.tick(G.Schedule(SeedForeign,G.Schedule.applyDeferred())).ok,true);assert.equal(foreignId.value,1);
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
  });
  for(let i=0;i<iterations;i++){
    const live=[...expected.keys()].sort((a,b)=>a-b),offset=i%3===0?0:i%3===1?Math.floor(live.length/2):live.length-1,target=ids.find(id=>id.value===live[offset]);
    assert.notEqual(target,undefined);
    const Reserve=G.System('Reserve',{},({commands})=>{pending=commands.spawn(G.Command.spawn([Main,main(schema,i)]));ids.push(pending);});
    tick(Reserve);assert.equal(pending.value,count+i+1);label=i+':pending';tick(Observe);
    const fresh=pending;tick(G.Schedule.applyDeferred());expected.set(fresh.value,{rawId:fresh.value,main:main(schema,i),aux:null,flag:null});pending=null;label=i+':live';tick(Observe);
    const Dispose=G.System('Dispose',{},({commands})=>{commands.remove(target,Main);commands.despawn(target);});
    tick(Dispose,G.Schedule.applyDeferred());expected.delete(target.value);stale.push(target);label=i+':disposed';tick(Observe);
  }
  return {schema,workload:'lifecycle',count,iterations,status:'PASS',fullBoundaryChecks:audit.length,retainedLiveCount:expected.size,rawReservationRange:[1,ids.at(-1).value],
    finalSha256:sha(JSON.stringify([...expected.values()].sort((a,b)=>a.rawId-b.rawId))),audit,peakRssKiB:process.resourceUsage().maxRSS,
    scope:'Correctness only; no timings. Actual reserve, pending lookup/query, barriers, rotating first/middle/last remove/despawn, full surviving fields, stale and foreign lookup.',
    foreignLookup:'Pinned TS raw-ID collision behavior retained separately; Bend MissingEntity divergence is approved, not a TS parity expectation.'};
}
function readers(schema,count){
  const Main=Descriptor.Component()(schema==='Motion'?'Position':'Vitals'),Aux=Descriptor.Component()(schema==='Motion'?'Velocity':'Armor'),Flag=Descriptor.Component()(schema==='Motion'?'Selected':'Tracked'),Ledger=Descriptor.Resource()(schema+'Ledger'),Ping=Descriptor.Event()(schema+'Ping');
  const G=Schema.bind(Schema.fragment({components:{Main,Aux,Flag},resources:{[Ledger.name]:Ledger},events:{Ping}}));
  const runtime=G.Runtime.make({resources:{[Ledger.name]:{totals:[0,101,102,103],epoch:4}},services:G.Runtime.services(),debug:true});
  const query=filters=>G.Query({selection:{main:G.Query.read(Main),aux:G.Query.optional(Aux),flag:G.Query.optional(Flag)},...(filters?{filters}:{})});
  const Q=query(),Added=query([G.Query.added(Main)]),Changed=query([G.Query.changed(Main)]),Write=G.Query({selection:{main:G.Query.write(Main)}});
  const expected=new Map(),ids=[],transients=[],audit=[],diagnostics=[],cursor={Fast:{message:-1,removed:-1},Slow:{message:-1,removed:-1}};
  let phase='prime',iteration=-1,transient=null;
  const tick=(...steps)=>assert.equal(runtime.tick(G.Schedule(...steps)).ok,true);
  const row=r=>({rawId:r.entity.id.value,main:structuredClone(r.data.main.get()),aux:r.data.aux.present?structuredClone(r.data.aux.get()):null,flag:r.data.flag.present?structuredClone(r.data.flag.get()):null});
  const Seed=G.System('Seed',{},({commands})=>{for(let j=0;j<count;j++){
    const entries=[[Main,main(schema,j)]];if(j%3===0)entries.push([Aux,aux(schema)]);if(j%3===1)entries.push([Flag,{group:8}]);
    const id=commands.spawn(G.Command.spawn(...entries));ids.push(id);expected.set(id.value,{rawId:id.value,main:main(schema,j),aux:j%3===0?aux(schema):null,flag:j%3===1?{group:8}:null});
  }});tick(Seed,G.Schedule.applyDeferred());
  runtime.debug.observe(event=>{if(event.type==='system'&&['Fast','Slow'].includes(event.system)){
    diagnostics.push({who:event.system,phase,iteration,frame:event.frame,tick:event.tick,outcome:event.outcome,missed:event.missed});
  }});
  function reader(who){return G.System(who,{queries:{q:Q,added:Added,changed:Changed},removed:{main:G.System.readRemoved(Main)},despawned:{entities:G.System.readDespawned()},events:{ping:G.System.readEvent(Ping)}},({queries,removed,despawned,events})=>{
    const rows=queries.q.each().map(row),want=[...expected.values()].sort((a,b)=>a.rawId-b.rawId);assert.deepEqual(rows,want);
    const changed=phase==='prime'?want:phase==='drain'?[]:[expected.get(transient.value)];
    assert.deepEqual(queries.added.each().map(row),changed);assert.deepEqual(queries.changed.each().map(row),changed);
    const upper=phase==='prime'?-1:phase==='drain'?iterations-1:iteration-1;
    const expectedRemoved=transients.slice(cursor[who].removed+1,upper+1).map(id=>id.value);
    const actualRemoved=removed.main.all().map(id=>id.value),actualDespawned=despawned.entities.all().map(id=>id.value);
    assert.deepEqual(actualRemoved,expectedRemoved);assert.deepEqual(actualDespawned,expectedRemoved);
    const messages=events.ping.all(),expectedMessages=Array.from({length:Math.max(0,iteration-cursor[who].message)},(_,j)=>({code:cursor[who].message+j+1}));
    assert.deepEqual(messages,expectedMessages);assert.equal(events.ping.lagged(),false);
    audit.push({who,phase,iteration,count:rows.length,rowsSha256:sha(JSON.stringify(rows)),added:changed.map(r=>r.rawId),changed:changed.map(r=>r.rawId),removed:actualRemoved,despawned:actualDespawned,messages,lagged:false});
    cursor[who]={message:iteration,removed:upper};
  });}
  const Fast=reader('Fast'),Slow=reader('Slow');tick(Fast,Slow);
  for(iteration=0;iteration<iterations;iteration++){
    phase='read';
    const Spawn=G.System('Spawn',{},({commands})=>{transient=commands.spawn(G.Command.spawn([Main,main(schema,iteration)]));});
    tick(Spawn,G.Schedule.applyDeferred());assert.equal(transient.value,count+iteration+1);transients.push(transient);
    expected.set(transient.value,{rawId:transient.value,main:main(schema,iteration,1),aux:null,flag:null});
    const Update=G.System('Update',{queries:{write:Write},events:{ping:G.System.writeEvent(Ping)}},({queries,events})=>{
      const r=queries.write.get(transient);assert.equal(r.ok,true);const old=r.value.data.main.get(),xs=cells(schema,old);
      assert.deepEqual(old,main(schema,iteration));const next=[xs[0]+1,xs[1],xs[2],xs[3]];
      r.value.data.main.set(schema==='Motion'?{coordinates:next,frame:old.frame}:{levels:next,reserve:old.reserve,class:old.class});events.ping.emit({code:iteration});
    });tick(Update,Fast,...(iteration%4===3?[Slow]:[]));
    const Dispose=G.System('Dispose',{},({commands})=>{commands.remove(transient,Main);commands.despawn(transient);});tick(Dispose,G.Schedule.applyDeferred());expected.delete(transient.value);
  }
  iteration=iterations-1;phase='drain';tick(Fast,Slow);
  let final;const Dump=G.System('Dump',{queries:{q:Q},resources:{ledger:G.System.readResource(Ledger)}},({queries,resources})=>{final={rows:queries.q.each().map(row),ledger:structuredClone(resources.ledger.get())};});tick(Dump);
  assert.deepEqual(final,{rows:[...expected.values()],ledger:{totals:[0,101,102,103],epoch:4}});
  assert.equal(audit.length,84);assert.equal(diagnostics.length,audit.length);for(const d of diagnostics){assert.equal(d.outcome,'ok');assert.deepEqual(d.missed,[]);}
  return {schema,workload:'readers',count,iterations,status:'PASS',capacity:65536,registration:'same Fast and Slow instances first invoked after seed+barrier, before first transient publication',
    initialPublicDiagnostics:diagnostics.slice(0,2),diagnostics,audit,finalSha256:sha(JSON.stringify(final)),retainedLiveCount:count,rawTransientRange:[transients[0].value,transients.at(-1).value],
    finalLogicalUnread:{Fast:{messages:[],removed:[],despawned:[]},Slow:{messages:[],removed:[],despawned:[]}},
    unreadEvidence:'Both instances drain at the final boundary; no private cursor or physical log occupancy is inspected. Subsequent empty reads are not yet performed.',
    peakRssKiB:process.resourceUsage().maxRSS,scope:'Correctness only; actual transient spawn/update/publish/read/remove/despawn barriers; every live field and every delivery checked, no timing.'};
}
function transactions(schema,count){
  const Main=Descriptor.Component()(schema==='Motion'?'Position':'Vitals'),Aux=Descriptor.Component()(schema==='Motion'?'Velocity':'Armor'),Flag=Descriptor.Component()(schema==='Motion'?'Selected':'Tracked'),Ledger=Descriptor.Resource()(schema+'Ledger'),Ping=Descriptor.Event()(schema+'Ping'),Audit=Descriptor.Service()('Audit');
  const G=Schema.bind(Schema.fragment({components:{Main,Aux,Flag},resources:{[Ledger.name]:Ledger},events:{Ping}}));
  const failedHandles=[],effects=[],runtime=G.Runtime.make({resources:{[Ledger.name]:{totals:[0,101,102,103],epoch:4}},services:G.Runtime.services(G.Runtime.service(Audit,{log:x=>effects.push(x)})),debug:true});
  const Q=G.Query({selection:{main:G.Query.read(Main),aux:G.Query.optional(Aux),flag:G.Query.optional(Flag)}}),Write=G.Query({selection:{main:G.Query.write(Main)}});
  const row=r=>({rawId:r.entity.id.value,main:structuredClone(r.data.main.get()),aux:r.data.aux.present?structuredClone(r.data.aux.get()):null,flag:r.data.flag.present?structuredClone(r.data.flag.get()):null});
  const expected=new Map(),ids=[],reads=[],audit=[],reservations=[],diagnostics=[];let iteration=-1,mode='prime',stage='prime',aSpawn=null,bFail=null,bRetry=null,ledgerFirst=0;
  const captures={A:0,B:0},tick=(...steps)=>runtime.tick(G.Schedule(...steps)),ok=(...steps)=>assert.equal(tick(...steps).ok,true);
  const seed=G.System('Seed',{},({commands})=>{for(let j=0;j<count;j++){
    const entries=[[Main,main(schema,j)]];if(j%3===0)entries.push([Aux,aux(schema)]);if(j%3===1)entries.push([Flag,{group:8}]);
    const id=commands.spawn(G.Command.spawn(...entries));ids.push(id);expected.set(id.value,{rawId:id.value,main:main(schema,j),aux:j%3===0?aux(schema):null,flag:j%3===1?{group:8}:null});
  }});ok(seed,G.Schedule.applyDeferred());
  const replaceFirst=(old,x)=>schema==='Motion'?{coordinates:[x,...old.coordinates.slice(1)],frame:old.frame}:{levels:[x,...old.levels.slice(1)],reserve:old.reserve,class:old.class};
  const spawnValue=(i,b)=>schema==='Motion'?{coordinates:[i,...(b?[200,300,400]:[20,30,40])],frame:7}:{levels:[i,...(b?[200,300,400]:[20,30,40])],reserve:9,class:2};
  const A=G.System('A',{queries:{write:Write},resources:{ledger:G.System.writeResource(Ledger)},events:{out:G.System.writeEvent(Ping)},services:{audit:G.System.service(Audit)}},({queries,resources,events,commands,services,lookup})=>{
    captures.A++;const r=queries.write.get(ids[0]);assert.equal(r.ok,true);const old=r.value.data.main.get();r.value.data.main.set(replaceFirst(old,cells(schema,old)[0]+1));
    const l=resources.ledger.get();resources.ledger.set({totals:[l.totals[0]+1,...l.totals.slice(1)],epoch:l.epoch});events.out.emit({code:2*iteration});
    aSpawn=commands.spawn(G.Command.spawn([Main,spawnValue(iteration,false)]));assert.equal(lookup.getHandle(G.Entity.handle(aSpawn),Q).error._tag,'MissingEntity');services.audit.log({who:'A',iteration,capture:captures.A});
  });
  const B=G.System('B',{queries:{write:Write},resources:{ledger:G.System.writeResource(Ledger)},events:{input:G.System.readEvent(Ping),out:G.System.writeEvent(Ping)},services:{audit:G.System.service(Audit)}},({queries,resources,events,commands,services,lookup})=>{
    captures.B++;const messages=events.input.all(),want=mode==='prime'?[]:iteration===0?[{code:0}]:[{code:2*iteration-1},{code:2*iteration}];assert.deepEqual(messages,want);assert.equal(events.input.lagged(),false);
    reads.push({iteration,mode,capture:captures.B,messages,lagged:false});if(mode==='prime')return;
    const r=queries.write.get(ids[1]);assert.equal(r.ok,true);const old=r.value.data.main.get(),x=cells(schema,old)[0];
    r.value.data.main.set(replaceFirst(old,x+10));assert.deepEqual(r.value.data.main.get(),replaceFirst(old,x+10));r.value.data.main.set(replaceFirst(old,x+30));assert.deepEqual(r.value.data.main.get(),replaceFirst(old,x+30));
    const l=resources.ledger.get();resources.ledger.set({totals:[l.totals[0]+100,...l.totals.slice(1)],epoch:l.epoch});
    const id=commands.spawn(G.Command.spawn([Main,spawnValue(iteration,true)]));if(mode==='fail')bFail=id;else bRetry=id;
    assert.equal(lookup.getHandle(G.Entity.handle(id),Q).error._tag,'MissingEntity');events.out.emit({code:2*iteration+1});services.audit.log({who:'B',iteration,capture:captures.B});
    if(mode==='fail')return Fx.fail({code:7});
  });
  runtime.debug.observe(event=>{if(event.type==='system'&&event.system==='B')diagnostics.push({iteration,mode,frame:event.frame,tick:event.tick,outcome:event.outcome,missed:event.missed});});
  let publicationWant=[];
  const Publications=G.System('PublicationObserver',{events:{input:G.System.readEvent(Ping)}},({events})=>{assert.deepEqual(events.input.all(),publicationWant);assert.equal(events.input.lagged(),false);});
  ok(B,Publications); // Explicit same-instance registration before A's first publication.
  const Observe=G.System('Observe',{queries:{q:Q},resources:{ledger:G.System.readResource(Ledger)}},({queries,resources,lookup})=>{
    const rows=queries.q.each().map(row),want=[...expected.values()].sort((a,b)=>a.rawId-b.rawId);assert.deepEqual(rows,want,stage+'.full-fields');
    assert.deepEqual(resources.ledger.get(),{totals:[ledgerFirst,101,102,103],epoch:4});
    const handles=[aSpawn,bFail,bRetry].filter(Boolean),lookups=[];for(const id of failedHandles)assert.equal(lookup.getHandle(G.Entity.handle(id),Q).error._tag,'MissingEntity');for(const id of handles){const result=lookup.getHandle(G.Entity.handle(id),Q);if(expected.has(id.value)){assert.equal(result.ok,true);assert.deepEqual(row(result.value),expected.get(id.value));}else assert.equal(result.error._tag,'MissingEntity');lookups.push({rawId:id.value,result:result.ok?'Found':result.error._tag});}
    audit.push({iteration,stage,count:rows.length,rowsSha256:sha(JSON.stringify(rows)),ledger:structuredClone(resources.ledger.get()),lookups,captures:{...captures}});
  });
  for(iteration=0;iteration<iterations;iteration++){
    bRetry=null;mode='fail';const failure=tick(A,B);assert.deepEqual(failure,{ok:false,error:{kind:'SystemFailure',system:'B',error:{code:7}}});
    expected.get(ids[0].value).main=replaceFirst(expected.get(ids[0].value).main,iteration+1);ledgerFirst=iteration*101+1;
    failedHandles.push(bFail);stage='failed-before-barrier';ok(Observe);publicationWant=[{code:2*iteration}];ok(Publications);
    assert.deepEqual([aSpawn.value,bFail.value],[count+3*iteration+1,count+3*iteration+2]);
    mode='retry';ok(B);expected.get(ids[1].value).main=replaceFirst(expected.get(ids[1].value).main,1+30*(iteration+1));ledgerFirst=(iteration+1)*101;
    assert.equal(bRetry.value,count+3*iteration+3);assert.equal(captures.B,1+2*(iteration+1));stage='retry-before-barrier';ok(Observe);publicationWant=[{code:2*iteration+1}];ok(Publications);
    reservations.push({iteration,A:aSpawn.value,failedB:bFail.value,retryB:bRetry.value});
    ok(G.Schedule.applyDeferred());expected.set(aSpawn.value,{rawId:aSpawn.value,main:spawnValue(iteration,false),aux:null,flag:null});expected.set(bRetry.value,{rawId:bRetry.value,main:spawnValue(iteration,true),aux:null,flag:null});stage='applied-FIFO';ok(Observe);
    const Dispose=G.System('Dispose',{},({commands})=>{commands.despawn(aSpawn);commands.despawn(bRetry);});ok(Dispose,G.Schedule.applyDeferred());expected.delete(aSpawn.value);expected.delete(bRetry.value);stage='disposed';ok(Observe);
  }
  assert.equal(effects.length,3*iterations);for(let i=0;i<iterations;i++)assert.deepEqual(effects.slice(3*i,3*i+3),[{who:'A',iteration:i,capture:i+1},{who:'B',iteration:i,capture:2*i+2},{who:'B',iteration:i,capture:2*i+3}]);
  for(const d of diagnostics){assert.equal(d.outcome,d.mode==='fail'?'failed':'ok');assert.deepEqual(d.missed,[]);}
  return {schema,workload:'failed-transaction',count,iterations,status:'PASS',capacity:65536,registration:'B and independent publication observer invoked after seed/barrier, before A publication; priming consumes one B capture',
    captures,reservations,reads,diagnostics,audit,effects,retainedLiveCount:expected.size,finalSha256:sha(JSON.stringify([...expected.values()])),ledger:{totals:[ledgerFirst,101,102,103],epoch:4},
    peakRssKiB:process.resourceUsage().maxRSS,scope:'Correctness only; same actual B instance fails/retries, earlier A survives, full inverse restoration/publication discard/pending and allocation observations checked; no timing.'};
}
if(process.argv[2]==='--all'){
  const results=[];
  for(const schema of schemas)for(const workload of workloads)for(const count of counts){
    const output=execFileSync(process.execPath,[self,schema,workload,String(count)],{encoding:'utf8',timeout:5000,maxBuffer:2*1024*1024});results.push(JSON.parse(output));
  }
  const files=['Runtime.ts','System.ts','Query.ts','Command.ts','internal/world.ts','internal/streams.ts'];
  const evidence={status:'PASS',scope:'Fresh five-workload correctness checkpoint only; execution durations diagnostic, not accepted performance samples',
    openWorkloads:[],node:process.version,reference:{commit:pin,files:Object.fromEntries(files.map(f=>[f,hashFile(reference+'/packages/core/src/'+f)]))},adapterSha256:hashFile(self),
    measurementContractSha256:hashFile(new URL('../../docs/design/s-integrate-measurement.md',import.meta.url)),traceSha256:hashFile(new URL('../../docs/design/s-integrate-trace.md',import.meta.url)),
    command:'node experiments/s-integrate/measurement-reference.mjs --all',perChildLimitSeconds:5,results};
  const header=JSON.stringify({...evidence,results:undefined},null,2);
  writeFileSync(new URL('measurement-reference-evidence.json',import.meta.url),header.slice(0,-2)+',\n  \"results\": [\n'+results.map(r=>'    '+JSON.stringify(r)).join(',\n')+'\n  ]\n}\n');
  console.log(JSON.stringify({status:evidence.status,cases:results.length,scope:evidence.scope}));
}else{
  const [schema,workload,n]=process.argv.slice(2),count=Number(n);assert.ok(schemas.includes(schema));assert.ok(workloads.includes(workload));assert.ok(counts.includes(count));
  console.log(JSON.stringify(workload==='failed-transaction'?transactions(schema,count):workload==='readers'?readers(schema,count):workload==='lifecycle'?lifecycle(schema,count):execute(schema,workload,count)));
}
