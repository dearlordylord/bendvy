import * as Schema from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/Schema.ts';
import * as D from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/Descriptor.ts';
const clone=x=>JSON.parse(JSON.stringify(x));
export function run(){
 const output=[];
 for(const name of ['Workshop','Garden']){
  const Cells=D.Component()(name+'/Cells'),Owned=D.Resource()(name+'/Owned');
  const G=Schema.bind(Schema.fragment({components:{Cells},resources:{Owned}}),Schema.defineRoot(name));
  const Flow=G.StateMachine(name+'/Flow',[7,9]),Level=G.StateMachine(name+'/Level',[11,12]);
  const runtime=G.Runtime.make({services:G.Runtime.services(),resources:{Owned:[11,12]},machines:G.Runtime.machines(G.Runtime.machine(Flow,7),G.Runtime.machine(Level,11)),debug:true});
  const readerValues=[],ids=[],points=[];
  const spec={machines:{flow:G.System.machine(Flow),level:G.System.machine(Level)},transitionEvents:{flow:G.System.readTransitionEvent(Flow),level:G.System.readTransitionEvent(Level)}};
  const project=ctx=>({flow:ctx.machines.flow.get(),level:ctx.machines.level.get(),flowTransitions:clone(ctx.transitionEvents.flow.all()),levelTransitions:clone(ctx.transitionEvents.level.all()),flowLagged:ctx.transitionEvents.flow.lagged(),levelLagged:ctx.transitionEvents.level.lagged()});
  const reader=G.System(name+'/Reader',spec,ctx=>{readerValues.push(project(ctx));});
  const peek=G.Inspector(name+'/Peek',spec,project);
  const tick=(...steps)=>{const result=runtime.tick(G.Schedule(...steps));if(!result.ok)throw new Error(JSON.stringify(result));return clone(result);};
  const point=label=>{points.push({label,world:clone(runtime.debug.dump()),streams:clone(runtime.debug.streams()),readerValues:clone(readerValues)});};
  tick(reader);
  tick(G.System(name+'/Seed',{},ctx=>{ids.push(ctx.commands.spawn(G.Command.spawn([Cells,[31,32]])));}),G.Schedule.applyDeferred());
  tick(G.System(name+'/Pending',{},ctx=>{ctx.commands.spawn(G.Command.spawn([Cells,[99,100]]));}));
  point('before');
  const falseQueue=tick(G.System(name+'/EqualSet',{nextMachines:{flow:G.System.nextState(Flow)}},ctx=>{ctx.nextMachines.flow.set(7);}));
  point('false-queued');
  const falseMarker=tick(G.Schedule.applyStateTransitions());point('false-before-inspect');
  const falseFirst=clone(runtime.inspect(peek));point('false-after-first');
  const falseSecond=clone(runtime.inspect(peek));point('false-after-second');
  const trueQueue=tick(G.System(name+'/EqualSetIfChanged',{nextMachines:{flow:G.System.nextState(Flow)}},ctx=>{ctx.nextMachines.flow.setIfChanged(7);}));
  point('true-queued');
  const trueMarker=tick(G.Schedule.applyStateTransitions());point('true-before-inspect');
  const trueFirst=clone(runtime.inspect(peek));point('true-after-first');
  const trueSecond=clone(runtime.inspect(peek));point('true-after-second');
  const readResult=tick(reader);point('after-operational');
  output.push({schema:name,ids:clone(ids),falseQueue,falseMarker,falseFirst,falseSecond,trueQueue,trueMarker,trueFirst,trueSecond,readResult,points});
 }
 return output;
}
console.log(JSON.stringify(run()));
