// Actual public lifecycle timing counterpart; diagnostic O.world is excluded.
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
const mix=(a,b)=>(Math.imul(a,65599)+b)>>>0;
const hashFields=(xs,seed=1)=>xs.reduce(mix,seed);
const mainHash=(schema,v)=>hashFields([...cells(schema,v),...(schema==='Motion'?[v.frame]:[v.reserve,v.class])]);
const auxHash=(schema,v)=>v===null?0:hashFields(schema==='Motion'?[...v.rates,Number(v.moving)]:[...v.layers,v.grade]);
const flagHash=v=>v===null?0:hashFields([v.group]);
// Leading1 is the Alpha observation-lane tag; raw entity IDs remain unchanged.
const queryHash=(schema,rs)=>mix(hashFields(rs.map(r=>hashFields([1,r.rawId,mainHash(schema,r.main),auxHash(schema,r.aux),flagHash(r.flag)]))),0);
const tupleMain=(schema,m)=>schema==='Motion'?[m.coordinates,m.frame]:[m.levels,m.reserve,m.class];
const tupleAux=(schema,a)=>a===null?null:schema==='Motion'?[a.rates,a.moving]:[a.layers,a.grade];
const four=v=>Object.fromEntries(v.map((x,i)=>['abcd'[i],x]));
function run(schema,count,full){
 const Main=Descriptor.Component()(schema==='Motion'?'Position':'Vitals'),Aux=Descriptor.Component()(schema==='Motion'?'Velocity':'Armor'),Flag=Descriptor.Component()(schema==='Motion'?'Selected':'Tracked'),Ledger=Descriptor.Resource()(schema+'Ledger');
 const G=Schema.bind(Schema.fragment({components:{Main,Aux,Flag},resources:{[Ledger.name]:Ledger}}));
 const make=()=>G.Runtime.make({resources:{[Ledger.name]:{totals:[0,101,102,103],epoch:4}},services:G.Runtime.services()});
 const runtime=make(),foreign=make(),stale=[],reserved=[];
 const Q=G.Query({selection:{main:G.Query.read(Main),aux:G.Query.optional(Aux),flag:G.Query.optional(Flag)}});
 const row=r=>({rawId:r.entity.id.value,main:r.data.main.get(),aux:r.data.aux.present?r.data.aux.get():null,flag:r.data.flag.present?r.data.flag.get():null});
 const tick=(...steps)=>assert.equal(runtime.tick(G.Schedule(...steps)).ok,true);
 const Seed=G.System('Seed',{},({commands})=>{for(let j=0;j<count;j++){
  const entries=[[Main,main(schema,j)]];if(j%3===0)entries.push([Aux,aux(schema)]);if(j%3===1)entries.push([Flag,{group:8}]);commands.spawn(G.Command.spawn(...entries));
 }});tick(Seed,G.Schedule.applyDeferred());
 let foreignId;
 const SeedForeign=G.System('SeedForeign',{},({commands})=>{foreignId=commands.spawn(G.Command.spawn([Main,main(schema,999)]));});
 assert.equal(foreign.tick(G.Schedule(SeedForeign,G.Schedule.applyDeferred())).ok,true);
 const VerifyForeign=G.System('VerifyForeign',{queries:{q:Q}},({queries})=>{assert.equal(queries.q.get(foreignId).ok,true);});
 assert.equal(foreign.tick(G.Schedule(VerifyForeign)).ok,true);
 let target,pending,iteration=0,phase=0,total=1,lastRows,lastLedger;
 const captures={Select:0,Reserve:0,Dispose:0,Observe:0};
 const Select=G.System('Select',{queries:{q:Q}},({queries})=>{
  captures.Select++;const live=queries.q.each().map(r=>r.entity.id);target=live[iteration%3===0?0:iteration%3===1?Math.floor(count/2):count-1];
 });
 const Reserve=G.System('Reserve',{},({commands})=>{
  captures.Reserve++;const payload=main(schema,iteration);pending=commands.spawn(G.Command.spawn([Main,payload]));reserved.push({rawId:pending.value,main:payload});
 });
 const Dispose=G.System('Dispose',{},({commands})=>{captures.Dispose++;commands.remove(target,Main);commands.despawn(target);stale.push(target);});
 const Observe=G.System('Observe',{queries:{q:Q},resources:{ledger:G.System.readResource(Ledger)}},({queries,resources,lookup})=>{
  captures.Observe++;const rows=queries.q.each().map(row),ledger=resources.ledger.get();
  const access=id=>{const value=lookup.getHandle(G.Entity.handle(id),Q);return value.ok?2:value.error._tag==='MissingEntity'?0:1;};
  const lookupKinds=[access(pending),access(target),access(foreignId),0];
  const history=stale.map(id=>({rawId:id.value,kind:access(id)}));
  const historyHash=mix(hashFields(history.map(v=>hashFields([1,v.rawId,v.kind]))),0);
  const observationHash=hashFields([iteration,phase,queryHash(schema,rows),hashFields([...ledger.totals,ledger.epoch]),hashFields(lookupKinds),historyHash]);
  total=mix(total,observationHash);lastRows=rows;lastLedger=ledger;
  if(full)console.log(JSON.stringify({iteration,phase,query:rows.map(r=>[[1,r.rawId],tupleMain(schema,r.main),tupleAux(schema,r.aux),r.flag===null?null:r.flag.group]),ledger:{totals:four(ledger.totals),epoch:ledger.epoch},lookups:four(lookupKinds),stale:history.map(v=>[{namespace:1,id:v.rawId},v.kind])}));
 });
 const start=performance.now();
 for(iteration=0;iteration<iterations;iteration++){
  tick(Select,Reserve);phase=0;tick(Observe);tick(G.Schedule.applyDeferred());phase=1;tick(Observe);tick(Dispose,G.Schedule.applyDeferred());phase=2;tick(Observe);
 }
 const milliseconds=performance.now()-start;
 // This independent expected state is never consulted by the runtime/selector.
 const expected=new Map(Array.from({length:count},(_,j)=>[j+1,{rawId:j+1,main:main(schema,j),aux:j%3===0?aux(schema):null,flag:j%3===1?{group:8}:null}]));
 for(let i=0;i<iterations;i++){
  const ids=[...expected.keys()].sort((a,b)=>a-b),old=ids[i%3===0?0:i%3===1?Math.floor(count/2):count-1];expected.set(count+i+1,{rawId:count+i+1,main:main(schema,i),aux:null,flag:null});expected.delete(old);
 }
 assert.deepEqual(lastRows,[...expected.values()].sort((a,b)=>a.rawId-b.rawId));assert.deepEqual(lastLedger,{totals:[0,101,102,103],epoch:4});
 assert.deepEqual(reserved.map(v=>v.rawId),Array.from({length:64},(_,i)=>count+i+1));assert.deepEqual(captures,{Select:64,Reserve:64,Dispose:64,Observe:192});
 console.log(JSON.stringify({milliseconds,digest:total,staleCount:stale.length}));
 for(const v of reserved)console.log(JSON.stringify({kind:'Reserved',step:'',worldName:schema.toLowerCase(),label:'pending',handle:{namespace:1,id:v.rawId},components:{main:schema==='Motion'?{coordinates:four(v.main.coordinates),frame:v.main.frame}:{levels:four(v.main.levels),reserve:v.main.reserve,class:v.main.class},aux:null,flag:null}}));
 console.log(JSON.stringify({finalRows:lastRows,ledger:lastLedger,captures,finalSha256:sha(JSON.stringify(lastRows)),foreignLookup:'receiver-local raw-ID collision retained; Alpha tag1 is encoding only'}));
}
const [schema,countText,fullText]=process.argv.slice(2),count=Number(countText),full=fullText==='1';
assert(schemas.includes(schema)&&counts.includes(count));
if(!full)run(schema,count,false);
run(schema,count,full);
