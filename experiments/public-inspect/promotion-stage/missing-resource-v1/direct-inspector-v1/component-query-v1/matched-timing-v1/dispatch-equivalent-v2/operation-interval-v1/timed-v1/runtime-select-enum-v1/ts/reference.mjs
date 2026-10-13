import * as Clock from './ts-timing.mjs';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {Descriptor as D,Schema} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';

const spec=JSON.parse(fs.readFileSync(new URL('./MODEL.json',import.meta.url),'utf8'));
const model=JSON.parse(fs.readFileSync(new URL('./COMPONENT-ORACLE-v2.json',import.meta.url),'utf8'));
let intervalIndex=0;
function application(){
const observations=[];
for(const schema of model.schemas){
 const descriptors=Object.fromEntries(['stock','title','active','count'].map(name=>[name,D.Component()(schema+'/'+name)]));
 const CheckInputs=D.Resource()(schema+'/CheckInputs');
 const G=Schema.bind(Schema.fragment({components:descriptors,resources:{CheckInputs}}));
 const runtime=G.Runtime.make({resources:{CheckInputs:{kind:0,targets:[],expected:''}}});
 const targets=[];
 const tick=(...steps)=>assert.equal(runtime.tick(G.Schedule(...steps)).ok,true);
 const payload=(family,value)=>({cells:[family==='active'?(value?1:0):family==='count'?value[0]:Number(value)]});
 const value=(family,owner)=>family==='title'?String(owner.cells[0]):family==='active'?owner.cells[0]===1:family==='count'?[owner.cells[0]]:owner.cells[0];
 const queries=Object.fromEntries(model.queries.map(q=>[q.name,G.Query({
  selection:Object.fromEntries(q.selection.map(([slot,family,mode])=>[slot,mode==='optional'?G.Query.optional(descriptors[family]):G.Query.read(descriptors[family])])),
  with:(q.with??[]).map(f=>descriptors[f]),without:(q.without??[]).map(f=>descriptors[f]),
  filters:(q.filters??[]).map(([kind,f])=>G.Query[kind](descriptors[f]))
 })]));
 const row=(q,match)=>({entityId:match.entity.id.value,data:Object.fromEntries(q.selection.map(([slot,family,mode])=>{
  const cell=match.data[slot];
  return [slot,mode==='optional'?cell.present?{present:true,value:value(family,cell.get())}:{present:false}:value(family,cell.get())];
 }))});
 const record=(q,query)=>({query:q.name,each:query.each().map(m=>row(q,m))});
 const inspectors=Object.fromEntries(model.queries.map(q=>[q.name,G.Inspector(schema+'/'+q.name,{queries:{selected:queries[q.name]}},({queries})=>record(q,queries.selected))]));
 const bootstrap=G.System(schema+'/Bootstrap',{},({commands})=>{
  for(const entity of Object.values(model.construction.allProperFourFamilyPresenceSubsets)){
   const components=entity.present.map(f=>[descriptors[f],payload(f,entity.values[f])]);
   targets.push(commands.spawn(G.Command.spawn(...components)));
  }
 });
 tick(bootstrap,G.Schedule.applyDeferred());

 // A failed callback is retried before the shared rounds. The public TS
 // Inspector call must leave its own reader unchanged when it throws.
 const retrySpec=model.queries.find(q=>q.name==='addedBoth');
 let failNext=true;const retryAttempts=[];
 const retryInspector=G.Inspector(schema+'/ExceptionRetry',{queries:{selected:queries.addedBoth}},({queries})=>{
  const observed=record(retrySpec,queries.selected);retryAttempts.push(observed);
  if(failNext){failNext=false;throw new Error('component-query-retry');}
  return observed;
 });

 const kinds=model.queries.filter(q=>!q.filters?.length);
 let nextInput={kind:0,targets:[],expected:''};
 const setInputs=G.System(schema+'/SetCheckInputs',{resources:{input:G.System.writeResource(CheckInputs)}},({resources})=>resources.input.set(nextInput));
 const checks=Object.fromEntries(kinds.map((q,kind)=>{
  let observed,ran=0;
  const check=G.Condition.check(schema+'/'+q.name+'/Check',{queries:{selected:queries[q.name]},resources:{input:G.System.readResource(CheckInputs)}},({queries,resources})=>{
   const input=resources.input.get(); observed=record(q,queries.selected);
   return observed.each.length>0 && JSON.stringify(observed)===input.expected;
  });
  const noop=G.System(schema+'/'+q.name+'/Noop',{},()=>{ran++;});
  const schedule=G.Schedule(setInputs,G.Schedule.when([check],noop));
  return [q.name,{run(expected){nextInput={kind,targets,expected:JSON.stringify(expected)};const before=ran;tick(schedule);return {query:q.name,allowed:ran!==before,bodyDispatchCount:ran-before,record:observed,carrier:{kind,expected:nextInput.expected}};}}];
 }));

 const pair=G.Query({selection:{stock:G.Query.write(descriptors.stock),title:G.Query.write(descriptors.title)}});
 let writerValue=spec.writerSource.initialValue;
 const pairedWriter=G.System(schema+'/PairedStockTitleWriter',{queries:{paired:pair}},({queries})=>{
  for(const match of queries.paired.each()){
   match.data.stock.set(payload('stock',writerValue));
   match.data.title.set(payload('title',writerValue+spec.writerSource.titleOffset));
  }
 });
 const phases=[];let exceptionRetry;
 for(const phase of spec.rounds){
  const event=spec.writerSource.events.find(item=>item.name===phase.writer);
  if(event){
   assert.equal(event.value,writerValue);
   Clock.begin(intervalIndex++);
   tick(G.Schedule(pairedWriter));
   Clock.end();
   writerValue+=spec.writerSource.successIncrement;
  }
  Clock.begin(intervalIndex++);
  const records=model.queries.map(q=>runtime.inspect(inspectors[q.name]));
  const gates=kinds.map(q=>checks[q.name].run(records.find(r=>r.query===q.name)));
  Clock.end();
  phases.push({name:phase.name,completeQueryRecords:records,structuralCheckGates:gates});
  if(phase.name==='repeat'){ let refusal;
 Clock.begin(intervalIndex++);
 try{runtime.inspect(retryInspector);}catch(error){refusal=error.message;}
 Clock.end();
 assert.equal(refusal,'component-query-retry');
 Clock.begin(intervalIndex++);
 const retrySuccess=runtime.inspect(retryInspector);
 Clock.end();
 Clock.begin(intervalIndex++);
 const retryRepeat=runtime.inspect(retryInspector);
 Clock.end();
 exceptionRetry={refusal,attempts:retryAttempts,retrySuccess,retryRepeat};

  }
 }
 observations.push({schema,exceptionRetry,phases});
}
return JSON.stringify({format:1,application:'InspectorComponentComposition',observations});
}
export function run(repetitions){
 Clock.reset();intervalIndex=0;
 for(let i=0;i<repetitions;i++)Clock.capture(application());
 Clock.finish(20*repetitions);
}
