from pathlib import Path
w=Path('/tmp/bendvy-readers-health-matched-method');d=w/'experiments/s-perf/canonical-api-v1/readers-runtime-v1/diagnostics/matched-timing-v1/health-v1';src=(w/'experiments/s-integrate/measurement-reference.mjs').read_text();prefix=src[:src.index('function execute(')].replace('readFileSync,writeFileSync','readFileSync,writeFileSync,writeSync').replace("new URL('../../.references/sources.json',import.meta.url)","'/workspace/formal-proofs/bendvy/.references/sources.json'")
b=src[src.index('function readers('):src.index('function transactions(')]
def change(a,c):
 global b
 assert b.count(a)==1,(a,b.count(a));b=b.replace(a,c)
change('function readers(schema,count){','function readers(schema,count,clockPath,rssPath){\n  const method=new Method();let lastResult=null;')
change('const tick=(...steps)=>assert.equal(runtime.tick(G.Schedule(...steps)).ok,true);','const tick=(...steps)=>{const result=runtime.tick(G.Schedule(...steps));const dump=runtime.debug.dump({limit:0});method.rawTickOutcomes.push({frame:dump.frame,tick:dump.tick,outcome:result.ok?{ok:true,value:{kind:"Undefined"}}:structuredClone(result)});lastResult=result;assert.equal(result.ok,true);return result;};')
change('ids.push(id);expected.set','ids.push(id);method.reserve(id);expected.set')
change('}});tick(Seed,G.Schedule.applyDeferred());','}});tick(Seed,G.Schedule.applyDeferred());method.record({kind:"SeedActors",actors:ids.map(id=>id.value)});')
change('assert.deepEqual(queries.added.each().map(row),changed);assert.deepEqual(queries.changed.each().map(row),changed);','const actualAdded=queries.added.each().map(row),actualChanged=queries.changed.each().map(row);assert.deepEqual(actualAdded,changed);assert.deepEqual(actualChanged,changed);')
change('assert.deepEqual(messages,expectedMessages);assert.equal(events.ping.lagged(),false);','assert.deepEqual(messages,expectedMessages);const lagged=events.ping.lagged();assert.equal(lagged,false);')
change("diagnostics.push({who:event.system,phase,iteration,frame:event.frame,tick:event.tick,outcome:event.outcome,missed:event.missed});", "diagnostics.push({who:event.system,phase,iteration,frame:event.frame,tick:event.tick,outcome:event.outcome,missed:event.missed});assert.notEqual(method.pendingRead,null);method.pendingRead.status={kind:event.outcome==='ok'?'Success':'Failed'};method.pendingRead=null;")
change('    cursor[who]={message:iteration,removed:upper};','''    method.recordRead({kind:'Read',who,phase:phase==='prime'?'Prime':phase==='drain'?'Drain':'Read',iteration:phase==='read'?iteration:null,rows:structuredClone(rows),added:structuredClone(actualAdded),changed:structuredClone(actualChanged),ping:{values:structuredClone(messages),lagged},removed:{values:actualRemoved.slice()},despawned:{values:actualDespawned.slice()},status:null});
    cursor[who]={message:iteration,removed:upper};''')
change("const Fast=reader('Fast'),Slow=reader('Slow');tick(Fast,Slow);", "const Fast=reader('Fast'),Slow=reader('Slow');tick(Fast,Slow);method.stage('Prime',null,lastResult);\n  const start=performance.now();")
change('});\n    tick(Spawn,G.Schedule.applyDeferred());', '});\n    tick(Spawn,G.Schedule.applyDeferred());') if False else None
change('transient=commands.spawn(G.Command.spawn([Main,main(schema,iteration)]));','transient=commands.spawn(G.Command.spawn([Main,main(schema,iteration)]));method.reserve(transient);')
change('tick(Spawn,G.Schedule.applyDeferred());assert.equal','tick(Spawn,G.Schedule.applyDeferred());method.stage("SpawnBarrier",iteration,lastResult);assert.equal')
change('});tick(Update,Fast,...(iteration%4===3?[Slow]:[]));','});tick(Update,Fast,...(iteration%4===3?[Slow]:[]));method.stage("UpdateReaders",iteration,lastResult);')
change('tick(Dispose,G.Schedule.applyDeferred());expected.delete','tick(Dispose,G.Schedule.applyDeferred());method.stage("DisposeBarrier",iteration,lastResult);expected.delete')
change("iteration=iterations-1;phase='drain';tick(Fast,Slow);","iteration=iterations-1;phase='drain';tick(Fast,Slow);method.stage('Drain',null,lastResult);")
change('  return {schema,workload:', '''  method.record({kind:'Final',rows:structuredClone(final.rows),ledger:structuredClone(final.ledger),status:{kind:lastResult.ok?'Complete':'BodyFailed'}});
  const records=method.completeRecords(),tuple=encode(records);writeAll('FORCE:'+fold32(tuple)+'\\n');const end=performance.now();
  writeFileSync(clockPath,String(Math.max(0,Math.floor(end-start)))+'\\n',{flag:'wx'});writeFileSync(rssPath,JSON.stringify({peakRssKiB:process.resourceUsage().maxRSS,platform:process.platform,units:'KiB',scope:'whole-process-highwater-including-warmup'})+'\\n',{flag:'wx'});
  const full={schema,workload:''')
change("    peakRssKiB:process.resourceUsage().maxRSS,scope:","    scope:")
change("actual transient spawn/update/publish/read/remove/despawn barriers; every live field and every delivery checked, no timing.'};", "actual transient spawn/update/publish/read/remove/despawn barriers; every live field and every delivery checked, no timing.',method:{rawActorMap:method.rawActorMap,rawTickOutcomes:method.rawTickOutcomes,referenceExpectationCursors:structuredClone(cursor),records,finalRows:final.rows,ledger:final.ledger}};\n  writeAll('TUPLE:'+JSON.stringify(tuple)+'\\nACTORS:'+JSON.stringify(method.rawActorMap)+'\\nFULL:'+JSON.stringify(full)+'\\n');")
helpers=r'''
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
'''
footer="""const [countArg,iterationsArg,warmupClock,sampleClock,warmupRss,sampleRss]=process.argv.slice(2);assert.equal(Number(countArg),64);assert.equal(Number(iterationsArg),64);for(const path of [warmupClock,sampleClock,warmupRss,sampleRss])assert.equal(typeof path,'string');writeAll('WARMUP\\n');readers('Health',Number(countArg),warmupClock,warmupRss);writeAll('SAMPLE\\n');readers('Health',Number(countArg),sampleClock,sampleRss);\n"""
(d/'ts-pilot.mjs').write_text(prefix+helpers+b+footer)
