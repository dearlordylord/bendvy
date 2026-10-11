import {Descriptor as D,Schema} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const clone=x=>JSON.parse(JSON.stringify(x));
export function run(){
 const output=[];
 for(const name of ['Workshop','Garden']){
  const Cells=D.Component()(name+'/Cells'),Sibling=D.Component()(name+'/Sibling');
  const Owned=D.Resource()(name+'/Owned'),SiblingOwner=D.Resource()(name+'/SiblingOwner'),Pulse=D.Event()(name+'/Pulse');
  const {relation:Link}=D.Relation(name+'/Link',name+'/LinkedBy');
  const {relation:Parent}=D.Hierarchy(name+'/Parent',name+'/Children');
  const G=Schema.bind(Schema.fragment({components:{Cells,Sibling},resources:{Owned,SiblingOwner},events:{Pulse},relations:{Link,Parent}}),Schema.defineRoot(name));
  const runtime=G.Runtime.make({services:G.Runtime.services(),resources:{Owned:[11,12],SiblingOwner:[21,22]},debug:true});
  const ids=[],readerValues=[];
  const reader=G.System(name+'/Reader',{events:{pulse:G.System.readEvent(Pulse)}},ctx=>{readerValues.push(clone(ctx.events.pulse.all()));});
  const tick=(...steps)=>{const result=runtime.tick(G.Schedule(...steps));if(!result.ok)throw new Error(JSON.stringify(result));return result;};
  tick(reader);
  tick(G.System(name+'/Seed',{events:{pulse:G.System.writeEvent(Pulse)}},ctx=>{for(let i=1;i<=3;i++)ids.push(ctx.commands.spawn(G.Command.spawn([Cells,[i,i+10]],[Sibling,[i+20,i+30]])));ctx.events.pulse.emit([31,32]);}));
  tick(G.Schedule.applyDeferred());
  tick(G.System(name+'/Edges',{},ctx=>{ctx.commands.relate(ids[2],Link,ids[1]);ctx.commands.relate(ids[0],Link,ids[1]);ctx.commands.relate(ids[0],Parent,ids[1]);ctx.commands.relate(ids[2],Parent,ids[1]);}));
  tick(G.Schedule.applyDeferred());
  tick(G.System(name+'/Pending',{},ctx=>{ctx.commands.spawn(G.Command.spawn([Cells,[99,100]],[Sibling,[101,102]]));}));
  const point=()=>({world:clone(runtime.debug.dump()),streams:clone(runtime.debug.streams()),readerValues:clone(readerValues)});
  const modes=['required_out','optional_out','required_in','optional_in','present_out','absent_out','present_in','absent_in'];
  for(const [relationName,relation] of [['Link',Link],['Parent',Parent]])for(const mode of modes){
   const query=mode==='required_out'?G.Query({selection:{target:G.Query.readRelation(relation)}}):mode==='optional_out'?G.Query({selection:{target:G.Query.optionalRelation(relation)}}):mode==='required_in'?G.Query({selection:{sources:G.Query.readRelated(relation)}}):mode==='optional_in'?G.Query({selection:{sources:G.Query.optionalRelated(relation)}}):mode==='present_out'?G.Query({selection:{},withRelations:[relation]}):mode==='absent_out'?G.Query({selection:{},withoutRelations:[relation]}):mode==='present_in'?G.Query({selection:{},withRelated:[relation]}):G.Query({selection:{},withoutRelated:[relation]});
   const rows=q=>q.each().map(({entity,data})=>({id:entity.id.value,cells:mode==='required_out'?[{target:data.target.get().value}]:mode==='optional_out'?[data.target.present?{target:data.target.get().value}:{missing:true}]:mode==='required_in'?[{sources:data.sources.get().map(x=>x.value)}]:mode==='optional_in'?[data.sources.present?{sources:data.sources.get().map(x=>x.value)}:{missing:true}]:[]}));
   const expected=mode==='required_out'||mode==='present_out'||mode==='absent_in'?2:mode==='optional_out'||mode==='optional_in'?3:1;
   const inspector=G.Inspector(name+'/'+relationName+'/'+mode,{queries:{selected:query}},ctx=>rows(ctx.queries.selected));
   const checks=[];
   const condition=G.Condition.check(name+'/'+relationName+'/'+mode+'/Check',{queries:{selected:query}},ctx=>{const value=ctx.queries.selected.each().length===expected;checks.push(value);return value;});
   const record={schema:name,relation:relationName,mode,before:point(),firstRows:clone(runtime.inspect(inspector)),afterFirst:point(),secondRows:clone(runtime.inspect(inspector)),afterSecond:point()};
   tick(G.Schedule.when([condition],G.System(name+'/'+relationName+'/'+mode+'/Noop',{},()=>undefined)));
   tick(G.Schedule.when([condition],G.System(name+'/'+relationName+'/'+mode+'/Noop2',{},()=>undefined)));
   record.checks=checks;record.afterChecks=point();output.push(record);
  }
 }
 return {scope:'Readonly ordinary relation categories and Check; complete TS public dump/stream observations, pending work retained, two nominal schemas; TS physical clock/observer vocabulary differs from Bend',observations:output};
}
console.log(JSON.stringify(run()));
