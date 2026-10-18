// Timing-only Dense/Sparse adapter; correctness reference remains unchanged.
// Pinned public bevy-ts measurement reference. No Bend or performance acceptance.
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {readFileSync,writeFileSync,writeSync} from 'node:fs';
import {execFileSync} from 'node:child_process';
import {fileURLToPath} from 'node:url';
import {Descriptor,Schema,Fx} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const reference='/workspace/formal-proofs/bendvy/.references/bevy-ts';
const pin='3040a3b2a3f28fa8554d856f9ccb6bf5433fa334';
const self=fileURLToPath(import.meta.url), iterations=Number(process.argv[3]);
const sha=x=>createHash('sha256').update(x).digest('hex');
const hashFile=p=>sha(readFileSync(p));
function writeAll(text){const bytes=Buffer.from(text);let offset=0;while(offset<bytes.length)offset+=writeSync(1,bytes,offset,bytes.length-offset);}
assert.equal(execFileSync('git',['-C',reference,'rev-parse','HEAD'],{encoding:'utf8',timeout:5000}).trim(),pin);
assert.equal(JSON.parse(readFileSync('/workspace/formal-proofs/bendvy/.references/sources.json')).sources['bevy-ts'].commit,pin);
const schemas=['Motion','Health'],workloads=['dense','sparse','lifecycle','readers','failed-transaction'],counts=[64,256,1024];
const main=(schema,j,delta=0)=>schema==='Motion'?{coordinates:[j+delta,j+1,j+2,j+3],frame:7}:{levels:[j+delta,j+1,j+2,j+3],reserve:9,class:2};
const aux=schema=>schema==='Motion'?{rates:[1,2,3,4],moving:true}:{layers:[1,2,3,4],grade:3};
const cells=(schema,value)=>schema==='Motion'?value.coordinates:value.levels;
// An integer checksum supplements exact full-field comparisons. Inputs stay below 2^53.
function fold(acc,values){for(const value of values)acc=(acc*33+Number(value))%2147483647;return acc;}
function rowValues(schema,row){return [row.rawId,...cells(schema,row.main),...(schema==='Motion'?[row.main.frame]:[row.main.reserve,row.main.class]),row.aux!==null,...(row.aux===null?[]:schema==='Motion'?[...row.aux.rates,row.aux.moving]:[...row.aux.layers,row.aux.grade]),row.flag!==null,...(row.flag===null?[]:[row.flag.group])];}
// Same U32-weighted observation checksum as measurement-bend.bend. The leading
// one is an encoding tag, not an invented TS world namespace or handle.
function rowScore(schema,r){
 const xs=cells(schema,r.main);let out=1+r.rawId+xs.reduce((a,b)=>a+b,0)+(schema==='Motion'?r.main.frame:r.main.reserve+r.main.class);
 if(r.aux!==null)out+=1+(schema==='Motion'?r.aux.rates.reduce((a,b)=>a+b,0)+Number(r.aux.moving):r.aux.layers.reduce((a,b)=>a+b,0)+r.aux.grade);
 if(r.flag!==null)out+=1+r.flag.group;
 return out>>>0;
}
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
  const statuses=[],audits=[];let measured=false;
  const tick=(...steps)=>{const value=runtime.tick(G.Schedule(...steps));if(measured)statuses.push(structuredClone(value));return value;};
  const Seed=G.System('Seed',{},({commands})=>{for(let j=0;j<count;j++){
    const entries=[];if(workload==='dense'||j%8===0)entries.push([Main,main(schema,j)]);
    if(j%3===0)entries.push([Aux,aux(schema)]);if(j%3===1)entries.push([Flag,{group:8}]);
    ids.push(commands.spawn(G.Command.spawn(...entries)));
  }});
  tick(Seed,G.Schedule.applyDeferred());
  const row=r=>({rawId:r.entity.id.value,main:r.data.main.get(),aux:r.data.aux.present?r.data.aux.get():null,flag:r.data.flag.present?r.data.flag.get():null});
  let worksum=0;
  const Update=G.System('Update',{queries:{write:Write,...(workload==='sparse'?{optional:Q,present:With,absent:Without}:{})},resources:{ledger:G.System.writeResource(Ledger)}},({queries,resources})=>{
    let readSum=0,updated=0;const values=[];
    for(const r of queries.write.each()){
      const old=r.data.main.get(),xs=cells(schema,old);const actual=xs[0]+xs[1]+xs[2]+xs[3];readSum+=actual;values.push(actual);
      const next=[xs[0]+1,xs[1],xs[2],xs[3]];
      r.data.main.set(schema==='Motion'?{coordinates:next,frame:old.frame}:{levels:next,reserve:old.reserve,class:old.class});
      const resource=resources.ledger.get();resources.ledger.set({totals:[resource.totals[0]+1,...resource.totals.slice(1)],epoch:resource.epoch});updated++;
    }
    let selectionSum=0;
    if(workload==='sparse')for(const [name,weight] of [['optional',1],['present',3],['absent',5]]){
      let value=0,rank=1;for(const r of queries[name].each()){value=(value+rank*rowScore(schema,row(r)))>>>0;rank++;}selectionSum=(selectionSum+weight*(value+rank))>>>0;
    }
    worksum=(worksum+readSum+selectionSum)>>>0;audits.push({values,readsum:readSum,updated});
  });
  let final;
  const Dump=G.System('Dump',{queries:{q:Q},resources:{ledger:G.System.readResource(Ledger)}},({queries,resources})=>{final={rows:queries.q.each().map(row),ledger:structuredClone(resources.ledger.get())};});
  const setupMilliseconds=performance.now()-setupStart;
  return {run(){measured=true;for(let i=0;i<iterations;i++)tick(Update);measured=false;tick(Dump);
    const tuple=encode({rows:final.rows,ledger:final.ledger,audits,statuses});writeAll('FORCE:'+commonFold(tuple)+'\n');return tuple;
  },validate(){
  const selected=Array.from({length:count},(_,j)=>j).filter(j=>workload==='dense'||j%8===0);
  function expectedRows(delta){return selected.map(j=>({rawId:ids[j].value,main:main(schema,j,delta),aux:j%3===0?aux(schema):null,flag:j%3===1?{group:8}:null}));}
  // Verify raw allocation order rather than hiding it behind labels.
  assert.deepEqual(ids.map(x=>x.value),Array.from({length:count},(_,j)=>j+1));
  const expected={rows:expectedRows(iterations),ledger:{totals:[selected.length*iterations,101,102,103],epoch:4}};
  assert.deepEqual(final,expected,'every final field and ordered raw ID');
  let expectedWork=0;
  for(let i=0;i<iterations;i++){
    let sums=selected.reduce((sum,j)=>sum+4*j+6+i,0);
    if(workload==='sparse'){
      const rows=expectedRows(i+1);
      for(const [weight,rs] of [[1,rows],[3,rows.filter(r=>r.aux!==null)],[5,rows.filter(r=>r.aux===null)]])sums+=weight*(rs.length+1+rs.reduce((sum,r,index)=>sum+(index+1)*rowScore(schema,r),0));
    }
    expectedWork=(expectedWork+sums)>>>0;
  }
  assert.equal(worksum,expectedWork,'same ordered complete-field checksum as Bend');
  assert.equal(statuses.length,iterations);for(const status of statuses)assert.equal(status.ok,true,'actual Update outcome');
  return {final,audits,statuses,worksum,ids:ids.map(x=>x.value),finalSha256:sha(JSON.stringify(final)),oracleSha256:sha(JSON.stringify(expected)),fullFieldsCompared:final.rows.length,samples:{first:final.rows[0],last:final.rows.at(-1)}};
  }};
}


// Natural-number lengths use decimal scalar digits plus NUL terminator; no narrowing.
const natural=n=>Array.from(String(n),x=>x.codePointAt(0)).concat(0);
const commonFold=(values,acc=0)=>{for(const value of values){acc=(Math.imul(acc,33)+value)>>>0;}return acc;};
const sized=(xs,f)=>natural(xs.length).concat(...xs.map(f));
const access=(x,f)=>x===null?[1]:[2,...f(x)];
function encode(x){
 const rows=sized(x.rows,r=>[...natural(r.rawId),2,...r.main.levels,r.main.reserve,r.main.class,...access(r.aux,v=>[...v.layers,v.grade]),...access(r.flag,v=>[v.group])]);
 const audits=sized(x.audits,a=>[...sized(a.values,v=>[v]),a.readsum,...natural(a.updated)]);
 const statuses=sized(x.statuses,s=>s.ok?[0]:[3,...natural(JSON.stringify(s.error).length),...Array.from(JSON.stringify(s.error),c=>c.codePointAt(0))]);
 return rows.concat(x.ledger.totals,[x.ledger.epoch],audits,statuses);
}
const schema='Health',workload='dense',count=Number(process.argv[2]);assert.equal(count,64);assert.equal(iterations,64);
function one(path){const owner=execute(schema,workload,count);const start=process.hrtime.bigint();const tuple=owner.run();const end=process.hrtime.bigint();const full=owner.validate();writeFileSync(path,String(end-start)+'\n',{flag:'w'});writeAll('TUPLE:'+JSON.stringify(tuple)+'\n');writeAll('FULL:'+JSON.stringify(full)+'\n');}
const [warmupClock,sampleClock]=process.argv.slice(4);assert(warmupClock&&sampleClock);
writeAll('WARMUP\n');one(warmupClock);writeAll('SAMPLE\n');one(sampleClock);
