import {Descriptor,Fx,Schema} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const Ping=Descriptor.Event()('Ping');
const G=Schema.bind(Schema.fragment({events:{Ping}}));
const Mode=G.StateMachine('Mode',['On','Off']);
const runtime=G.Runtime.make({services:G.Runtime.services(),machines:G.Runtime.machines(G.Runtime.machine(Mode,'On'))});
let fastName='fast:init', slowName='slow:init', fail=false;
function print(name,events){console.log(name+':'+events.ping.all().map(x=>x+',').join('')+':'+events.ping.lagged());}
const Fast=G.System('Fast',{events:{ping:G.System.readEvent(Ping)}},({events})=>print(fastName,events));
const Slow=G.System('Slow',{when:[G.Condition.inState(Mode,'On')],events:{ping:G.System.readEvent(Ping)}},({events})=>{print(slowName,events);if(fail)return Fx.fail(7);});
const emitter=(name,values,success=true)=>G.System(name,{events:{ping:G.System.writeEvent(Ping)}},({events})=>{for(const v of values)events.ping.emit(v);if(!success)return Fx.fail(9);});
const Off=G.System('Off',{nextMachines:{mode:G.System.nextState(Mode)}},({nextMachines})=>nextMachines.mode.set('Off'));
const On=G.System('On',{nextMachines:{mode:G.System.nextState(Mode)}},({nextMachines})=>nextMachines.mode.set('On'));
function tick(...steps){return runtime.tick(G.Schedule(...steps));}
tick(Fast);tick(Slow);
fastName='fast:batch12';tick(emitter('Emit12',[1,2]),Fast);
fastName='fast:batch3';tick(emitter('Emit3',[3]),Fast);
fastName='fast:empty';slowName='slow:failed';fail=true;tick(Fast,Slow);
slowName='slow:retry';fail=false;tick(Slow);
fastName='fast:again';slowName='slow:again';tick(Fast,Slow);
// Expected failure stops the schedule: execute the reader in the next tick.
slowName='slow:failed-emission';tick(emitter('FailedEmit',[9],false));tick(Slow);
// A state-transition system changes ticks, but skipping must discard exactly
// the publications committed before the skipped invocation.
tick(Off,G.Schedule.applyStateTransitions());tick(emitter('Emit4',[4]),Slow);
slowName='slow:after-skip';fastName='fast:held';tick(On,G.Schedule.applyStateTransitions(),Slow,Fast);
