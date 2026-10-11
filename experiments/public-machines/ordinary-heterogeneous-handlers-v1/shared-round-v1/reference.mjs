import {Descriptor as D,Schema,Fx} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const clone=x=>JSON.parse(JSON.stringify(x));
export function run(){
 const Cells=D.Component()('Cells'),Sibling=D.Component()('Sibling');
 const Owned=D.Resource()('Owned'),SiblingOwner=D.Resource()('SiblingOwner'),Trace=D.Resource()('Trace'),Pulse=D.Event()('Pulse');
 const G=Schema.bind(Schema.fragment({components:{Cells,Sibling},resources:{Owned,SiblingOwner,Trace},events:{Pulse}}));
 const First=G.StateMachine('First',['Cold','Warm','Settled']),Second=G.StateMachine('Second',[0,7]);
 const runtime=G.Runtime.make({services:G.Runtime.services(),resources:{Owned:[11,12],SiblingOwner:[21,22],Trace:[]},machines:G.Runtime.machines(G.Runtime.machine(First,'Cold'),G.Runtime.machine(Second,0)),debug:true});
 const local=Array(6).fill(0),attempts=[],firstDelivered=[],secondDelivered=[],records=[],traces=[];
 runtime.debug.observe(({ms,...event})=>traces.push(clone(event)));
 let handle;
 const seed=G.System('seed',{},ctx=>{handle=ctx.commands.spawn(G.Command.spawn([Cells,[31,32]],[Sibling,[41,42]]));});
 const initial=G.System('initial-pending',{},ctx=>{ctx.commands.insert(handle,[Cells,[0,32]]);});
 runtime.tick(G.Schedule(seed,G.Schedule.applyDeferred(),initial));
 const hook=(name,machine,phase,index,state)=>G.System(name,{resources:{owned:G.System.writeResource(Owned),trace:G.System.writeResource(Trace)},events:{pulse:G.System.writeEvent(Pulse)},transitions:{active:G.System.transition(state)},...(index===2?{nextMachines:{first:G.System.nextState(First)}}:{})},ctx=>{
  local[index]++;attempts.push({machine,phase,attempt:local[index]});
  ctx.resources.owned.update(([a,b])=>[a+machine*10+phase,b]);
  ctx.resources.trace.update(prior=>[...prior,`${machine}:${phase}`]);
  ctx.events.pulse.emit({machine,phase});ctx.commands.insert(handle,[Cells,[machine*10+phase,32]]);
  if(index===1&&local[index]===1)return Fx.fail('transition-first-attempt');
  if(index===2)ctx.nextMachines.first.set('Settled');
 });
 const handlers=[hook('first-exit',1,1,0,First),hook('first-transition',1,2,1,First),hook('first-enter',1,3,2,First),hook('second-exit',2,1,3,Second),hook('second-transition',2,2,4,Second),hook('second-enter',2,3,5,Second)];
 const bundle=G.Schedule.transitions(G.Schedule.onExit(First,'Cold',[handlers[0]]),G.Schedule.onTransition(First,['Cold','Warm'],[handlers[1]]),G.Schedule.onEnter(First,'Warm',[handlers[2]]),G.Schedule.onExit(Second,0,[handlers[3]]),G.Schedule.onTransition(Second,[0,7],[handlers[4]]),G.Schedule.onEnter(Second,7,[handlers[5]]));
 const queue=G.System('queue',{nextMachines:{first:G.System.nextState(First),second:G.System.nextState(Second)}},ctx=>{ctx.nextMachines.first.set('Warm');ctx.nextMachines.second.set(7);});
 const firstReader=G.System('first-reader',{transitionEvents:{first:G.System.readTransitionEvent(First)}},ctx=>firstDelivered.push(...clone(ctx.transitionEvents.first.all())));
 const secondReader=G.System('second-reader',{transitionEvents:{second:G.System.readTransitionEvent(Second)}},ctx=>secondDelivered.push(...clone(ctx.transitionEvents.second.all())));
 function point(label,result=null){records.push({label,result:clone(result),world:clone(runtime.debug.dump()),streams:clone(runtime.debug.streams()),local:clone(local),attempts:clone(attempts),firstDelivered:clone(firstDelivered),secondDelivered:clone(secondDelivered),traces:clone(traces)});}
 const round=()=>runtime.tryTick(G.Schedule(G.Schedule.applyStateTransitions(bundle)));
 point('before');point('queued',runtime.tick(G.Schedule(queue)));point('round-failure',round());
 point('first-reader-before-retry',runtime.tick(G.Schedule(firstReader)));point('round-retry',round());
 point('second-reader',runtime.tick(G.Schedule(secondReader)));point('first-reader',runtime.tick(G.Schedule(firstReader)));
 point('later-round',round());point('final-first-reader',runtime.tick(G.Schedule(firstReader)));point('final-second-reader',runtime.tick(G.Schedule(secondReader)));point('final-barrier',runtime.tick(G.Schedule(G.Schedule.applyDeferred())));
 const world=clone(runtime.debug.dump());
 const entity=world.entities.find(e=>Object.hasOwn(e.components,'Cells'));
 const applied=traces.filter(e=>e.type==='deferred').flatMap(e=>e.commands).filter(c=>c.tag==='insert').length;
 const pulse=traces.filter(e=>e.type==='system'&&e.outcome==='ok').flatMap(e=>e.events).filter(e=>e.event==='Pulse').flatMap(e=>e.values);
 const ledger={component:entity.components.Cells,siblingComponent:entity.components.Sibling,owned:world.resources.Owned,siblingOwner:world.resources.SiblingOwner,locals:local,committedCallbacks:world.resources.Trace,appliedReplacements:applied,firstDelivered,secondDelivered,pulse,pendingCommands:world.pendingCommands.length};
 return {records,ledger};
}
console.log(JSON.stringify(run()));
