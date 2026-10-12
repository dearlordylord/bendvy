import assert from 'node:assert/strict';
import fs from 'node:fs';
import {Descriptor as D,Schema} from '../../../../../.references/bevy-ts/packages/core/src/index.ts';

const spec=JSON.parse(fs.readFileSync(new URL('./MODEL.json',import.meta.url),'utf8'));
const model=JSON.parse(fs.readFileSync(new URL(spec.baseComponentOracle,import.meta.url),'utf8'));
const observations=[];
for(const schema of model.schemas){
 const descriptors=Object.fromEntries(['stock','title','active','count'].map(name=>[name,D.Component()(schema+'/'+name)]));
 const G=Schema.bind(Schema.fragment({components:descriptors}));
 const runtime=G.Runtime.make();
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
 const result=(q,result)=>result.ok?{ok:true,value:result.value===undefined?null:row(q,result.value)}:{ok:false,error:result.error};
 const record=(q,query)=>({query:q.name,each:query.each().map(m=>row(q,m)),get:targets.map((target,i)=>({target:i+1,result:result(q,query.get(target))})),single:result(q,query.single()),singleOptional:result(q,query.singleOptional())});
 const inspectors=Object.fromEntries(model.queries.map(q=>[q.name,G.Inspector(schema+'/'+q.name,{queries:{selected:queries[q.name]}},({queries})=>record(q,queries.selected))]));
 const bootstrap=G.System(schema+'/Bootstrap',{},({commands})=>{
  for(const entity of Object.values(model.construction.allProperFourFamilyPresenceSubsets)){
   const components=entity.present.map(f=>[descriptors[f],payload(f,entity.values[f])]);
   targets.push(commands.spawn(G.Command.spawn(...components)));
  }
  targets.push(commands.spawn(G.Command.spawn()));
 });
 tick(bootstrap,G.Schedule.applyDeferred());
 tick(G.System(schema+'/MakeMissingTarget',{},({commands})=>commands.despawn(targets[16])),G.Schedule.applyDeferred());

 // A failed callback is retried before the shared rounds. The public TS
 // Inspector call must leave its own reader unchanged when it throws.
 const retrySpec=model.queries.find(q=>q.name==='addedBoth');
 let failNext=true;const retryAttempts=[];
 const retryInspector=G.Inspector(schema+'/ExceptionRetry',{queries:{selected:queries.addedBoth}},({queries})=>{
  const observed=record(retrySpec,queries.selected);retryAttempts.push(observed);
  if(failNext){failNext=false;throw new Error('component-query-retry');}
  return observed;
 });
 let refusal;
 try{runtime.inspect(retryInspector);}catch(error){refusal=error.message;}
 assert.equal(refusal,'component-query-retry');
 const retrySuccess=runtime.inspect(retryInspector);
 const retryRepeat=runtime.inspect(retryInspector);
 const exceptionRetry={refusal,attempts:retryAttempts,retrySuccess,retryRepeat};

 const checks=Object.fromEntries(model.queries.filter(q=>!q.filters?.length).map(q=>{
  let callbacks=[],ran=0;
  const check=G.Condition.check(schema+'/'+q.name+'/Check',{queries:{selected:queries[q.name]}},({queries})=>{
   const observed=record(q,queries.selected);callbacks.push(observed);return observed.each.length>0;
  });
  const system=G.System(schema+'/'+q.name+'/Gated',{},()=>{ran++;});
  return [q.name,{run(){callbacks=[];const before=ran;tick(G.Schedule.when([check],system));return {query:q.name,requirements:check.requirements,allowed:callbacks[0].each.length>0,observation:ran===before?'Skipped':'Ran',bodyDispatchCount:ran-before,callbackRecords:callbacks};}}];
 }));

 const pair=G.Query({selection:{stock:G.Query.write(descriptors.stock),title:G.Query.write(descriptors.title)}});
 let writerValue=spec.writerSource.initialValue;
 const pairedWriter=G.System(schema+'/PairedStockTitleWriter',{queries:{paired:pair}},({queries})=>{
  for(const match of queries.paired.each()){
   match.data.stock.set(payload('stock',writerValue));
   match.data.title.set(payload('title',writerValue+spec.writerSource.titleOffset));
  }
 });
 const phases=[];
 for(const phase of spec.rounds){
  const event=spec.writerSource.events.find(item=>item.name===phase.writer);
  if(event){
   assert.equal(event.value,writerValue);
   tick(G.Schedule(pairedWriter));
   writerValue+=spec.writerSource.successIncrement;
  }
  const records=model.queries.map(q=>runtime.inspect(inspectors[q.name]));
  const gates=model.queries.filter(q=>!q.filters?.length).map(q=>checks[q.name].run());
  phases.push({name:phase.name,completeQueryRecords:records,structuralCheckGates:gates});
 }
 observations.push({schema,exceptionRetry,phases});
}
console.log(JSON.stringify({format:1,application:'InspectorComponentComposition',observations}));
