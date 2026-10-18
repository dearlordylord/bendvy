from pathlib import Path
root=Path('/tmp/bendvy-failedtxn-matched-method');leaf=root/'experiments/s-perf/canonical-api-v1/failedtxn-runtime-v1/diagnostics/matched-timing-v1'
source=(root/'experiments/s-integrate/measurement-reference.mjs').read_text()
prefix=source[:source.index('function execute(')].replace('readFileSync,writeFileSync','readFileSync,writeFileSync,writeSync')
prefix=prefix.replace("new URL('../../.references/sources.json',import.meta.url)","'/workspace/formal-proofs/bendvy/.references/sources.json'")
body=source[source.index('function transactions('):source.index("if(process.argv[2]==='--all')")]
def change(old,new):
 global body
 assert body.count(old)==1,(old,body.count(old))
 body=body.replace(old,new)
change('function transactions(schema,count){','function transactions(schema,count,clockPath,rssPath){\n  const method=new Method();let callbackPending=null,publicationPending=null,lastTick=null,lastRows=null,lastLedger=null;')
change('tick=(...steps)=>runtime.tick(G.Schedule(...steps))','tick=(...steps)=>{const result=runtime.tick(G.Schedule(...steps));method.rawTickOutcomes.push(result.ok?{ok:true,value:{kind:"Undefined"}}:structuredClone(result));lastTick=result;return result;}')
change('ids.push(id);expected.set','ids.push(id);method.reserve(id);expected.set')
change('}});ok(seed,G.Schedule.applyDeferred());','}});ok(seed,G.Schedule.applyDeferred());method.record({kind:"SeedActors",actors:ids.map(id=>method.actor(id.value))});')
change('captures.A++;const r=', 'captures.A++;callbackPending=method.callback("A",iteration,captures.A);const r=')
change('r.value.data.main.set(replaceFirst(old,cells(schema,old)[0]+1));','r.value.data.main.set(replaceFirst(old,cells(schema,old)[0]+1));callbackPending.writes.push(found(mainView(r.value.data.main.get())));')
change('epoch:l.epoch});events.out.emit({code:2*iteration});','epoch:l.epoch});callbackPending.ledger=ledgerView(resources.ledger.get());events.out.emit({code:2*iteration});')
change("aSpawn=commands.spawn(G.Command.spawn([Main,spawnValue(iteration,false)]));assert.equal(lookup.getHandle(G.Entity.handle(aSpawn),Q).error._tag,'MissingEntity');","const spawned=spawnValue(iteration,false);aSpawn=commands.spawn(G.Command.spawn([Main,spawned]));method.reserve(aSpawn);callbackPending.reservation={kind:'Reserved',actor:method.actor(aSpawn.value)};callbackPending.payload=mainView(spawned);const pending=lookup.getHandle(G.Entity.handle(aSpawn),Q);assert.equal(pending.error._tag,'MissingEntity');callbackPending.pendingLookup=accessResult(pending);")
change('captures.B++;const messages=', 'captures.B++;callbackPending=method.callback("B",iteration,captures.B);const messages=')
change("reads.push({iteration,mode,capture:captures.B,messages,lagged:false});if(mode==='prime')return;", "reads.push({iteration,mode,capture:captures.B,messages,lagged:false});callbackPending.reading={messages:structuredClone(messages),lagged:events.input.lagged()};if(mode==='prime')return;")
change('r.value.data.main.set(replaceFirst(old,x+10));assert.deepEqual','r.value.data.main.set(replaceFirst(old,x+10));callbackPending.writes.push(found(mainView(r.value.data.main.get())));assert.deepEqual')
change('r.value.data.main.set(replaceFirst(old,x+30));assert.deepEqual','r.value.data.main.set(replaceFirst(old,x+30));callbackPending.writes.push(found(mainView(r.value.data.main.get())));assert.deepEqual')
change('epoch:l.epoch});\n    const id=commands.spawn(G.Command.spawn([Main,spawnValue(iteration,true)]));','epoch:l.epoch});callbackPending.ledger=ledgerView(resources.ledger.get());\n    const spawned=spawnValue(iteration,true),id=commands.spawn(G.Command.spawn([Main,spawned]));method.reserve(id);callbackPending.reservation={kind:"Reserved",actor:method.actor(id.value)};callbackPending.payload=mainView(spawned);')
change("assert.equal(lookup.getHandle(G.Entity.handle(id),Q).error._tag,'MissingEntity');events.out.emit", "const pending=lookup.getHandle(G.Entity.handle(id),Q);assert.equal(pending.error._tag,'MissingEntity');callbackPending.pendingLookup=accessResult(pending);events.out.emit")
old="runtime.debug.observe(event=>{if(event.type==='system'&&event.system==='B')diagnostics.push({iteration,mode,frame:event.frame,tick:event.tick,outcome:event.outcome,missed:event.missed});});"
new="runtime.debug.observe(event=>{if(event.type==='system'&&event.system==='B')diagnostics.push({iteration,mode,frame:event.frame,tick:event.tick,outcome:event.outcome,missed:event.missed});if(event.type==='system'&&(event.system==='A'||event.system==='B')){assert.ok(callbackPending);callbackPending.mode=iteration===-1?'Prime':event.outcome==='failed'?'Fail':event.system==='A'?'Commit':'Retry';callbackPending.readerStatus=event.system==='A'?null:event.outcome==='failed'?1:0;callbackPending.readerError=event.system==='A'||event.outcome!=='failed'?null:event.error.code;callbackPending.outcome=event.outcome==='ok'?{kind:'Success'}:{kind:'Failure',code:event.error.code};method.record(callbackPending);callbackPending=null;}if(event.type==='system'&&event.system==='PublicationObserver'){assert.ok(publicationPending);publicationPending.status=event.outcome==='ok'?0:1;method.record(publicationPending);publicationPending=null;}});"
change(old,new)
change("assert.equal(events.input.lagged(),false);});\n  ok(B,Publications);", "assert.equal(events.input.lagged(),false);publicationPending={kind:'Publications',mode:iteration===-1?'Prime':mode==='fail'?'AfterFailure':'AfterRetry',iteration:iteration===-1?null:iteration,status:null,messages:structuredClone(events.input.all()),lagged:events.input.lagged()};});\n  ok(B,Publications);method.phase(0,iteration,lastTick);")
change("const handles=[aSpawn,bFail,bRetry].filter(Boolean),lookups=[];for(const id of failedHandles)assert.equal(lookup.getHandle(G.Entity.handle(id),Q).error._tag,'MissingEntity');","const handles=[aSpawn,bFail,bRetry].filter(Boolean),lookups=[],fullLookups=[],allFailed=[];for(const id of failedHandles){const result=lookup.getHandle(G.Entity.handle(id),Q);assert.equal(result.error._tag,'MissingEntity');allFailed.push(method.lookup(id,result));}")
change("lookups.push({rawId:id.value,result:result.ok?'Found':result.error._tag});","lookups.push({rawId:id.value,result:result.ok?'Found':result.error._tag});fullLookups.push(method.lookup(id,result));")
change('captures:{...captures}});\n  });','captures:{...captures},rows:structuredClone(rows),fullLookups,allFailed});lastRows=structuredClone(rows);lastLedger=structuredClone(resources.ledger.get());method.record({kind:"Boundary",iteration,phase:stage,rows:rows.map(r=>method.row(r)),ledger:ledgerView(lastLedger),pendingA:fullLookups[0]??null,latestFailed:fullLookups[1]??null,retryB:fullLookups[2]??null,allFailed,captures:{...captures}});\n  });\n  const start=performance.now();')
change("const failure=tick(A,B);assert.deepEqual", "const failure=tick(A,B);method.phase(1,iteration,failure);assert.deepEqual")
change('publicationWant=[{code:2*iteration}];ok(Publications);','publicationWant=[{code:2*iteration}];ok(Publications);method.phase(2,iteration,lastTick);')
change("mode='retry';ok(B);","mode='retry';ok(B);method.phase(3,iteration,lastTick);")
change('publicationWant=[{code:2*iteration+1}];ok(Publications);','publicationWant=[{code:2*iteration+1}];ok(Publications);method.phase(4,iteration,lastTick);')
change('ok(G.Schedule.applyDeferred());expected.set','ok(G.Schedule.applyDeferred());method.phase(5,iteration,lastTick);expected.set')
change('ok(Dispose,G.Schedule.applyDeferred());expected.delete','ok(Dispose,G.Schedule.applyDeferred());method.phase(6,iteration,lastTick);expected.delete')
change('  return {schema,workload:', """  method.record({kind:'Final',rows:lastRows.map(r=>method.row(r)),ledger:ledgerView(lastLedger),captures:{...captures},effects:effects.map(x=>JSON.stringify(x)),status:{kind:lastTick.ok?'Complete':'Stopped'}});
  const tuple=encode(method.records),forced=tuple.reduce((acc,x)=>(Math.imul(acc,33)+x)>>>0,0);writeAll('FORCE:'+forced+'\\n');const end=performance.now();
  writeFileSync(clockPath,String(Math.max(0,Math.floor(end-start)))+'\\n',{flag:'wx'});const rss=process.resourceUsage().maxRSS;writeFileSync(rssPath,JSON.stringify({peakRssKiB:rss,platform:process.platform,units:'KiB',scope:'whole-process-highwater-including-warmup'})+'\\n',{flag:'wx'});
  const full={schema,workload:""")
change('    peakRssKiB:process.resourceUsage().maxRSS,scope:', '    scope:')
change("full inverse restoration/publication discard/pending and allocation observations checked; no timing.'};\n}","full inverse restoration/publication discard/pending and allocation observations checked; no timing.',method:{rawActorMap:method.rawActorMap,records:method.records,rawTickOutcomes:method.rawTickOutcomes,finalRows:lastRows}};\n  writeAll('TUPLE:'+JSON.stringify(tuple)+'\\nFULL:'+JSON.stringify(full)+'\\n');\n}")
helpers=r'''
function writeAll(text){const bytes=Buffer.from(text);let offset=0;while(offset<bytes.length)offset+=writeSync(1,bytes,offset,bytes.length-offset);}
const four=values=>({a:values[0],b:values[1],c:values[2],d:values[3]});
const mainView=value=>({coordinates:four(value.coordinates),frame:value.frame});
const auxView=value=>({rates:four(value.rates),moving:value.moving});
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
'''
footer=r'''
const [countText,iterationText,warmupClock,sampleClock,warmupRss,sampleRss]=process.argv.slice(2);assert.equal(iterationText,'64');const count=Number(countText);assert.equal(count,64);for(const path of [warmupClock,sampleClock,warmupRss,sampleRss])assert.equal(typeof path,'string');
writeAll('WARMUP\n');transactions('Motion',count,warmupClock,warmupRss);writeAll('SAMPLE\n');transactions('Motion',count,sampleClock,sampleRss);
'''
(leaf/'ts-pilot.mjs').write_text(prefix+helpers+body+footer)
(leaf/'build-ts-pilot.py').write_text(Path(__file__).read_text())
