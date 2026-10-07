import {Descriptor as D,Schema,Fx} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const clone=x=>JSON.parse(JSON.stringify(x));
export function run(schema,phase,position){
 const Cells=D.Component()('Cells'),Owned=D.Resource()('Owned'),Ping=D.Event()('Ping');
 const G=Schema.bind(Schema.fragment({components:{Cells},resources:{Owned},events:{Ping}}));
 const Flow=G.StateMachine('Flow',['Boot','Play','Pause']),Level=G.StateMachine('Level',[0,1]);
 const runtime=G.Runtime.make({services:G.Runtime.services(),resources:{Owned:[3,13]},machines:G.Runtime.machines(G.Runtime.machine(Level,0),G.Runtime.machine(Flow,'Boot')),debug:true});
 const local={},attempts=[],deliveries=[],records=[];let failing=true,readerFails=true;
 const selection=G.Query({selection:{cells:G.Query.write(Cells)}});
 const readSpec={events:{ping:G.System.readEvent(Ping)},transitionEvents:{flow:G.System.readTransitionEvent(Flow),level:G.System.readTransitionEvent(Level)}};
 function delivery(name,ctx){return {name,ping:clone(ctx.events.ping.all()),flow:clone(ctx.transitionEvents.flow.all()),level:clone(ctx.transitionEvents.level.all()),lagged:[ctx.events.ping.lagged(),ctx.transitionEvents.flow.lagged(),ctx.transitionEvents.level.lagged()]};}
 const reader=name=>G.System(name,readSpec,ctx=>{deliveries.push(delivery(name,ctx));return name==='flaky'&&readerFails?Fx.fail('reader-failed'):undefined;});
 const fast=reader('fast'),slow=reader('slow'),flaky=reader('flaky');
 const hook=(name,index,machine=Flow)=>G.System(name,{...readSpec,events:{ping:G.System.readEvent(Ping),emit:G.System.writeEvent(Ping)},queries:{all:selection},resources:{owned:G.System.writeResource(Owned)},machines:{flow:G.System.machine(Flow),level:G.System.machine(Level)},nextMachines:{flow:G.System.nextState(Flow)},transitions:{active:G.System.transition(machine)}},ctx=>{
  local[name]=(local[name]??0)+1;
  attempts.push({...delivery(name,ctx),local:local[name],current:[ctx.machines.flow.get(),ctx.machines.level.get()],active:clone(ctx.transitions.active.get())});
  for(const {data} of ctx.queries.all.each()){const [a,b,c]=data.cells.get();data.cells.set([a,b,c+1]);}
  ctx.resources.owned.update(([a,b])=>[a+1,b+10]);ctx.events.emit.emit({handler:name,attempt:local[name]});
  ctx.commands.spawn(G.Command.spawn([Cells,[100+index,1000+index,0]]));
  if(name==='enter0')ctx.nextMachines.flow.set('Pause');
  return failing&&name===phase+position?Fx.fail('hook-failed:'+name):undefined;
 });
 const exit=[hook('exit0',0),hook('exit1',1)],transition=[hook('transition0',2),hook('transition1',3)],enter=[hook('enter0',4),hook('enter1',5)],level=hook('level0',6,Level);
 // Bundle author order intentionally differs from required phase and machine order.
 const bundle=G.Schedule.transitions(G.Schedule.onEnter(Level,1,[level]),G.Schedule.onEnter(Flow,'Play',enter),G.Schedule.onTransition(Flow,['Boot','Play'],transition),G.Schedule.onExit(Flow,'Boot',exit));
 const queue=G.System('queue',{nextMachines:{level:G.System.nextState(Level),flow:G.System.nextState(Flow)}},({nextMachines,commands})=>{nextMachines.level.set(1);nextMachines.flow.set('Play');commands.spawn(G.Command.spawn([Cells,[90,900,0]]));});
 const seed=G.System('seed',{},({commands})=>{commands.spawn(G.Command.spawn([Cells,[1,10,0]]));});
 function point(label,result){records.push({label,result:clone(result),world:clone(runtime.debug.dump()),streams:clone(runtime.debug.streams()),hostLocal:clone(local),attempts:clone(attempts),deliveries:clone(deliveries)});}
 point('initial',runtime.tick(G.Schedule(seed,G.Schedule.applyDeferred(),fast,slow)));
 point('queued',runtime.tick(G.Schedule(queue)));
 point('handler-failure',runtime.tick(G.Schedule(G.Schedule.applyStateTransitions(bundle))));
 point('reader-failure',runtime.tick(G.Schedule(flaky)));
 failing=false;point('handler-retry',runtime.tick(G.Schedule(G.Schedule.applyStateTransitions(bundle))));
 readerFails=false;point('reader-retry',runtime.tick(G.Schedule(flaky)));
 point('later-marker',runtime.tick(G.Schedule(G.Schedule.applyStateTransitions(bundle),fast,slow)));
 point('repeat-readers',runtime.tick(G.Schedule(fast,slow)));
 const missing=G.Runtime.make({services:G.Runtime.services(),machines:G.Runtime.machines(G.Runtime.machine(Flow,'Boot')),debug:true});
 const before=clone(missing.debug.dump());const rejected=missing.tryTick(G.Schedule(queue,G.Schedule.applyStateTransitions(bundle)));
 return {schema,phase,position,requirements:bundle.requirements.map(({kind,name})=>({kind,name})),records,missingRequirements:{result:clone(rejected),before,after:clone(missing.debug.dump())}};
}
console.log(JSON.stringify({applications:['HandlersAlpha','HandlersBeta'].flatMap(schema=>['exit','transition','enter'].flatMap(phase=>[0,1].map(position=>run(schema,phase,position))))}));
