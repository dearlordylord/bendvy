import {Descriptor as D,Schema} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const clone=x=>JSON.parse(JSON.stringify(x));
export function run(){
 const Cells=D.Component()('Cells'),Sibling=D.Component()('Sibling');
 const Owned=D.Resource()('Owned'),SiblingOwner=D.Resource()('SiblingOwner'),Pulse=D.Event()('Pulse');
 const G=Schema.bind(Schema.fragment({components:{Cells,Sibling},resources:{Owned,SiblingOwner},events:{Pulse}}));
 const First=G.StateMachine('First',['Cold','Warm']),Second=G.StateMachine('Second',[0,7]);
 const runtime=G.Runtime.make({services:G.Runtime.services(),resources:{Owned:[11,12],SiblingOwner:[21,22]},machines:G.Runtime.machines(G.Runtime.machine(First,'Cold')),debug:true});
 const callbacks=[],seedReads=[],records=[],traces=[];
 runtime.debug.observe(({ms,...event})=>traces.push(clone(event)));
 const seed=G.System('seed',{events:{pulse:G.System.readEvent(Pulse)},transitionEvents:{first:G.System.readTransitionEvent(First)}},ctx=>{
  seedReads.push({pulse:clone(ctx.events.pulse.all()),first:clone(ctx.transitionEvents.first.all())});
  ctx.commands.spawn(G.Command.spawn([Cells,[31,32]],[Sibling,[41,42]]));
 });
 const enter=G.System('first-enter-needs-second',{machines:{second:G.System.machine(Second)},resources:{owned:G.System.writeResource(Owned)}},ctx=>{
  callbacks.push(ctx.machines.second.get());
  ctx.resources.owned.update(([a,b])=>[a+1,b]);
 });
 const bundle=G.Schedule.transitions(G.Schedule.onEnter(First,'Warm',[enter]));
 const marker=G.Schedule(G.Schedule.applyStateTransitions(bundle));
 function point(label,result=null){records.push({label,result:clone(result),world:clone(runtime.debug.dump()),streams:clone(runtime.debug.streams()),callbacks:clone(callbacks),seedReads:clone(seedReads),traces:clone(traces)});}
 point('before');point('queued',runtime.tick(G.Schedule(seed)));point('missing-unselected-rejected',runtime.tryTick(marker));
 return {requirements:marker.requirements.map(({kind,name})=>({kind,name})),records};
}
console.log(JSON.stringify(run()));
