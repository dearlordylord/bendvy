// Pinned public bevy-ts measurement reference. No Bend or performance acceptance.
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {readFileSync,writeFileSync} from 'node:fs';
import {execFileSync} from 'node:child_process';
import {fileURLToPath} from 'node:url';
import {Descriptor,Schema} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const reference='/workspace/formal-proofs/bendvy/.references/bevy-ts';
const pin='3040a3b2a3f28fa8554d856f9ccb6bf5433fa334';
const self=fileURLToPath(import.meta.url), iterations=64;
const sha=x=>createHash('sha256').update(x).digest('hex');
const hashFile=p=>sha(readFileSync(p));
assert.equal(execFileSync('git',['-C',reference,'rev-parse','HEAD'],{encoding:'utf8',timeout:5000}).trim(),pin);
assert.equal(JSON.parse(readFileSync(new URL('../../.references/sources.json',import.meta.url))).sources['bevy-ts'].commit,pin);
const schemas=['Motion','Health'],workloads=['dense','sparse'],counts=[64,256,1024];
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
if(process.argv[2]==='--all'){
  const results=[];
  for(const schema of schemas)for(const workload of workloads)for(const count of counts){
    const output=execFileSync(process.execPath,[self,schema,workload,String(count)],{encoding:'utf8',timeout:5000,maxBuffer:2*1024*1024});results.push(JSON.parse(output));
  }
  const files=['Runtime.ts','System.ts','Query.ts','Command.ts','internal/world.ts','internal/streams.ts'];
  const evidence={status:'PASS',scope:'Fresh Dense/Sparse correctness checkpoint only; execution durations diagnostic, not accepted performance samples',
    openWorkloads:['lifecycle/churn','readers','failed transaction'],node:process.version,reference:{commit:pin,files:Object.fromEntries(files.map(f=>[f,hashFile(reference+'/packages/core/src/'+f)]))},adapterSha256:hashFile(self),
    measurementContractSha256:hashFile(new URL('../../docs/design/s-integrate-measurement.md',import.meta.url)),traceSha256:hashFile(new URL('../../docs/design/s-integrate-trace.md',import.meta.url)),
    command:'node experiments/s-integrate/measurement-reference.mjs --all',perChildLimitSeconds:5,results};
  writeFileSync(new URL('measurement-reference-evidence.json',import.meta.url),JSON.stringify(evidence,null,2)+'\n');
  console.log(JSON.stringify({status:evidence.status,cases:results.length,scope:evidence.scope}));
}else{
  const [schema,workload,n]=process.argv.slice(2),count=Number(n);assert.ok(schemas.includes(schema));assert.ok(workloads.includes(workload));assert.ok(counts.includes(count));
  console.log(JSON.stringify(execute(schema,workload,count)));
}
