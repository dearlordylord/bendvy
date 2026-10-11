import {Descriptor as D,Schema} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const clone=x=>JSON.parse(JSON.stringify(x));
export function run(){
 const output=[];
 for(const name of ['Workshop','Garden']){
  const Cells=D.Component()(name+'/Cells'),Sibling=D.Component()(name+'/Sibling');
  const Owned=D.Resource()(name+'/Owned'),SiblingOwner=D.Resource()(name+'/SiblingOwner');
  const {relation:Link}=D.Relation(name+'/Link',name+'/LinkedBy');
  const {relation:Parent}=D.Hierarchy(name+'/Parent',name+'/Children');
  const G=Schema.bind(Schema.fragment({components:{Cells,Sibling},resources:{Owned,SiblingOwner},relations:{Link,Parent}}),Schema.defineRoot(name));
  const Flow=G.StateMachine(name+'/Flow',[4,7,8,9]),Level=G.StateMachine(name+'/Level',[10,11,12]);
  const runtime=G.Runtime.make({services:G.Runtime.services(),resources:{Owned:[11,12],SiblingOwner:[21,22]},machines:G.Runtime.machines(G.Runtime.machine(Flow,4),G.Runtime.machine(Level,10)),debug:true});
  const ids=[],readerValues=[];
  const spec={machines:{flow:G.System.machine(Flow),level:G.System.machine(Level)},transitionEvents:{flow:G.System.readTransitionEvent(Flow),level:G.System.readTransitionEvent(Level)},relationFailures:{parent:G.System.readRelationFailures(Parent)}};
  const project=ctx=>({flow:ctx.machines.flow.get(),level:ctx.machines.level.get(),flowTransitions:clone(ctx.transitionEvents.flow.all()),levelTransitions:clone(ctx.transitionEvents.level.all()),flowLagged:ctx.transitionEvents.flow.lagged(),levelLagged:ctx.transitionEvents.level.lagged(),parentFailures:clone(ctx.relationFailures.parent.all()),parentLagged:ctx.relationFailures.parent.lagged()});
  const reader=G.System(name+'/Reader',spec,ctx=>{readerValues.push(project(ctx));});
  const peek=G.Inspector(name+'/Peek',spec,project);
  const tick=(...steps)=>{const result=runtime.tick(G.Schedule(...steps));if(!result.ok)throw new Error(JSON.stringify(result));return result;};
  const point=()=>({world:clone(runtime.debug.dump()),streams:clone(runtime.debug.streams()),readerValues:clone(readerValues)});
  tick(reader);
  tick(G.System(name+'/Seed',{},ctx=>{for(let id=1;id<=3;id++)ids.push(ctx.commands.spawn(G.Command.spawn([Cells,[id*10+1,id*10+2]],[Sibling,[id*10+3,id*10+4]])));}),G.Schedule.applyDeferred());
  tick(G.System(name+'/Edges',{},ctx=>{ctx.commands.relate(ids[2],Link,ids[1]);ctx.commands.relate(ids[0],Link,ids[1]);ctx.commands.relate(ids[0],Parent,ids[1]);ctx.commands.relate(ids[2],Parent,ids[1]);}),G.Schedule.applyDeferred());
  tick(G.System(name+'/CommitRequests',{nextMachines:{flow:G.System.nextState(Flow),level:G.System.nextState(Level)}},ctx=>{ctx.nextMachines.flow.set(7);ctx.nextMachines.level.set(11);}),G.Schedule.applyStateTransitions());
  tick(G.System(name+'/RejectedCycle',{},ctx=>{ctx.commands.relate(ids[1],Parent,ids[2]);}),G.Schedule.applyDeferred());
  tick(G.System(name+'/Pending',{nextMachines:{flow:G.System.nextState(Flow),level:G.System.nextState(Level)}},ctx=>{ctx.nextMachines.flow.set(9);ctx.nextMachines.level.set(12);ctx.commands.spawn(G.Command.spawn([Cells,[99,100]],[Sibling,[101,102]]));}));
  const before=point(),first=runtime.inspect(peek),afterFirst=point(),second=runtime.inspect(peek),afterSecond=point();
  const readResult=tick(reader),afterReader=point();
  output.push({schema:name,before,first,afterFirst,second,afterSecond,readResult:clone(readResult),afterReader});
 }
 return output;
}
console.log(JSON.stringify(run()));
