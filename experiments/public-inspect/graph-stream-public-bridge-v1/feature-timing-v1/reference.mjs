import {Descriptor as D,Schema} from '../../../../.references/bevy-ts/packages/core/src/index.ts';

// New matched workflow: every inspector declaration below is evaluated once.
// Repeated evaluation of one inspector remains covered by operation-interval-v1.
const clone=value=>JSON.parse(JSON.stringify(value));
const modes=['required_out','optional_out','present_out','absent_out','required_in','optional_in','present_in','absent_in'];
const id=value=>value.value;
function failureError(error){
 return Object.fromEntries(Object.entries(error).map(([key,value])=>[key==='_tag'?'kind':key==='entityId'?'entity':key==='targetId'?'target':key==='childId'?'child':key,key==='relation'?value.split('/').at(-1):value]));
}
function failure(value){
 return {relation:value.relation.name.split('/').at(-1),related:value.relation.relatedName.split('/').at(-1),kind:value.relation.relationKind,linked:value.relation.linkedDespawn,allowSelf:value.relation.allowSelf,ordered:value.relation.ordered,operation:value.operation,source:id(value.source),target:value.target===undefined?null:id(value.target),error:failureError(value.error)};
}
function lifecycle(capturePhysical=false){
 const records=[],physical=[];
 for(const name of ['Workshop','Garden']){
  const Cells=D.Component()(name+'/Cells'),Sibling=D.Component()(name+'/Sibling');
  const Owned=D.Resource()(name+'/Owned'),SiblingOwner=D.Resource()(name+'/SiblingOwner'),Pulse=D.Event()(name+'/Pulse');
  const {relation:Link}=D.Relation(name+'/Link',name+'/LinkedBy');
  const {relation:Parent}=D.Hierarchy(name+'/Parent',name+'/Children');
  const G=Schema.bind(Schema.fragment({components:{Cells,Sibling},resources:{Owned,SiblingOwner},events:{Pulse},relations:{Link,Parent}}),Schema.defineRoot(name));
  const Flow=G.StateMachine(name+'/Flow',[4,7,8,9]),Level=G.StateMachine(name+'/Level',[10,11,12]);
  const runtime=G.Runtime.make({services:G.Runtime.services(),resources:{Owned:[11,12],SiblingOwner:[21,22]},machines:G.Runtime.machines(G.Runtime.machine(Flow,4),G.Runtime.machine(Level,10)),debug:capturePhysical});
  const ids=[],readerValues=[];
  const record=value=>{
   records.push(value);
   if(capturePhysical)physical.push({schema:name,phase:value.operation,recordIndex:records.length-1,world:clone(runtime.debug.dump()),streams:clone(runtime.debug.streams()),readerValues:clone(readerValues)});
  };
  const tick=(...steps)=>{const result=runtime.tick(G.Schedule(...steps));if(!result.ok)throw new Error(JSON.stringify(result));return result;};
  const relationQuery=G.Query({selection:{link:G.Query.optionalRelation(Link),linkedBy:G.Query.optionalRelated(Link),parent:G.Query.optionalRelation(Parent),children:G.Query.optionalRelated(Parent)}});
  const relationRows=query=>query.each().map(({entity,data})=>({id:entity.id.value,cells:[data.link.present?{target:id(data.link.get())}:{missing:true},data.linkedBy.present?{sources:data.linkedBy.get().map(id)}:{missing:true},data.parent.present?{target:id(data.parent.get())}:{missing:true},data.children.present?{sources:data.children.get().map(id)}:{missing:true}]}));
  const streamSpec={machines:{flow:G.System.machine(Flow),level:G.System.machine(Level)},transitionEvents:{flow:G.System.readTransitionEvent(Flow),level:G.System.readTransitionEvent(Level)},relationFailures:{parent:G.System.readRelationFailures(Parent)}};
  const streams=ctx=>({flow:ctx.machines.flow.get(),level:ctx.machines.level.get(),flowTransitions:clone(ctx.transitionEvents.flow.all()),levelTransitions:clone(ctx.transitionEvents.level.all()),flowLagged:ctx.transitionEvents.flow.lagged(),levelLagged:ctx.transitionEvents.level.lagged(),parentFailures:ctx.relationFailures.parent.all().map(failure),parentLagged:ctx.relationFailures.parent.lagged()});
  const reader=G.System(name+'/Reader',streamSpec,ctx=>{readerValues.push(streams(ctx));});
  tick(G.System(name+'/Seed',{events:{pulse:G.System.writeEvent(Pulse)}},ctx=>{for(let i=1;i<=3;i++)ids.push(ctx.commands.spawn(G.Command.spawn([Cells,[i*10+1,i*10+2]],[Sibling,[i*10+3,i*10+4]])));ctx.events.pulse.emit(31);ctx.events.pulse.emit(32);}),G.Schedule.applyDeferred());
  // Identical insertion order to the Bend setup, with no result sorting.
  tick(G.System(name+'/Edges',{},ctx=>{ctx.commands.relate(ids[0],Link,ids[1]);ctx.commands.relate(ids[2],Link,ids[1]);ctx.commands.relate(ids[0],Parent,ids[1]);ctx.commands.relate(ids[2],Parent,ids[1]);}),G.Schedule.applyDeferred());
  // An actual successful empty selected-stream run establishes the ordinary registered reader.
  tick(reader);
  if(capturePhysical)physical.push({schema:name,phase:'empty-reader',world:clone(runtime.debug.dump()),streams:clone(runtime.debug.streams()),readerValues:clone(readerValues)});
  tick(G.System(name+'/CommitRequests',{nextMachines:{flow:G.System.nextState(Flow),level:G.System.nextState(Level)}},ctx=>{ctx.nextMachines.flow.set(7);ctx.nextMachines.level.set(11);}),G.Schedule.applyStateTransitions());
  tick(G.System(name+'/RejectedCycle',{},ctx=>{ctx.commands.relate(ids[1],Parent,ids[2]);}),G.Schedule.applyDeferred());
  tick(G.System(name+'/Pending',{nextMachines:{flow:G.System.nextState(Flow),level:G.System.nextState(Level)}},ctx=>{ctx.nextMachines.flow.set(9);ctx.nextMachines.level.setIfChanged(12);ctx.commands.spawn(G.Command.spawn([Cells,[99,100]],[Sibling,[101,102]]));}));
  for(const [relationName,relation] of [['Link',Link],['Parent',Parent]])for(const mode of modes){
   const query=mode==='required_out'?G.Query({selection:{target:G.Query.readRelation(relation)}}):mode==='optional_out'?G.Query({selection:{target:G.Query.optionalRelation(relation)}}):mode==='required_in'?G.Query({selection:{sources:G.Query.readRelated(relation)}}):mode==='optional_in'?G.Query({selection:{sources:G.Query.optionalRelated(relation)}}):mode==='present_out'?G.Query({selection:{},withRelations:[relation]}):mode==='absent_out'?G.Query({selection:{},withoutRelations:[relation]}):mode==='present_in'?G.Query({selection:{},withRelated:[relation]}):G.Query({selection:{},withoutRelated:[relation]});
   const rows=q=>q.each().map(({entity,data})=>({id:entity.id.value,cells:mode==='required_out'?[{target:id(data.target.get())}]:mode==='optional_out'?[data.target.present?{target:id(data.target.get())}:{missing:true}]:mode==='required_in'?[{sources:data.sources.get().map(id)}]:mode==='optional_in'?[data.sources.present?{sources:data.sources.get().map(id)}:{missing:true}]:[]}));
   for(const pass of ['first','second']){
    const inspector=G.Inspector(name+'/'+relationName+'/'+mode+'/'+pass,{queries:{selected:query}},ctx=>rows(ctx.queries.selected));
    record({schema:name,operation:'inspect',relation:relationName,mode,pass,result:clone(runtime.inspect(inspector))});
   }
   const expected=mode==='required_out'||mode==='present_out'||mode==='absent_in'?2:mode==='optional_out'||mode==='optional_in'?3:1;
   for(const pass of ['first','second']){
    let called=false,allowed=false,ran=false;
    const condition=G.Condition.check(name+'/'+relationName+'/'+mode+'/'+pass+'/Check',{queries:{selected:query}},ctx=>{called=true;allowed=ctx.queries.selected.each().length===expected;return allowed;});
    tick(G.Schedule.when([condition],G.System(name+'/'+relationName+'/'+mode+'/'+pass+'/Noop',{},()=>{ran=true;})));
    record({schema:name,operation:'check-noop',relation:relationName,mode,pass,result:{called,allowed,ran}});
   }
  }
  for(const pass of ['first','second']){
   const inspector=G.Inspector(name+'/UnionPeek/'+pass,{...streamSpec,queries:{relations:relationQuery}},ctx=>({...streams(ctx),rows:relationRows(ctx.queries.relations)}));
   record({schema:name,operation:'machine-inspect',pass,result:clone(runtime.inspect(inspector))});
  }
  let called=false,allowed=false,ran=false;
  const requiredLinks=G.Query({selection:{target:G.Query.readRelation(Link)}});
  const condition=G.Condition.check(name+'/FlowAndLinkCheck',{machines:{flow:G.System.machine(Flow)},queries:{selected:requiredLinks}},ctx=>{called=true;allowed=ctx.machines.flow.get()===7&&ctx.queries.selected.each().length===2;return allowed;});
  tick(G.Schedule.when([condition],G.System(name+'/FlowAndLinkNoop',{},()=>{ran=true;})));
  record({schema:name,operation:'machine-check-noop',result:{called,allowed,ran}});
  tick(reader);
  record({schema:name,operation:'registered-stream-read',result:clone(readerValues.at(-1))});
  if(capturePhysical)physical.push({schema:name,phase:'complete',world:clone(runtime.debug.dump()),streams:clone(runtime.debug.streams()),readerValues:clone(readerValues)});
 }
 if(records.length!==136)throw new Error('Expected complete 136-operation lifecycle');
 return {records,physical};
}
// Harness owns the clock/capture. Every lifecycle creates fresh complete worlds.
export function run(count){
 if(!Number.isSafeInteger(count)||count<0)throw new Error('Nonnegative lifecycle count required');
 const runs=[];
 for(let i=0;i<count;i++)runs.push(lifecycle().records);
 return JSON.stringify(runs);
}
// Complete platform-specific observations stay independently qualified; they are
// not included in the common logical timing string or discarded from evidence.
export function diagnostics(){return lifecycle(true);}
