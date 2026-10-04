import {Descriptor, Fx, Schema} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const Payload=Descriptor.Component()('Payload'), Tag=Descriptor.Component()('Tag'), Ping=Descriptor.Event()('Ping');
const G=Schema.bind(Schema.fragment({components:{Payload,Tag},events:{Ping}}));
const Mode=G.StateMachine('Mode',['On','Off']);
const runtime=G.Runtime.make({services:G.Runtime.services(),debug:true,machines:G.Runtime.machines(G.Runtime.machine(Mode,'On'))});
let entity, mode='noop', aCount=0,bCount=0,tail=0;
const Spawn=G.System('Spawn',{},({commands})=>{entity=commands.spawn(G.Command.spawn([Payload,[10,20,30,40]],[Tag,{}]));});
runtime.tick(G.Schedule(Spawn,G.Schedule.applyDeferred()));
const writable=G.Query({selection:{payload:G.Query.write(Payload)}});
function instance(name,delta,publish){
  let count=0; // Separate real lexical environment for each system instance.
  return G.System(name,{...(name==='B'?{when:[G.Condition.inState(Mode,'On')]}:{}),queries:{row:writable},events:{out:G.System.writeEvent(Ping),...(name==='B'?{input:G.System.readEvent(Ping)}:{})}},({queries,events,commands})=>{
    count++;if(name==='A')aCount=count;else bCount=count;
    const seen=name==='B'?events.input.all():[];
    console.log(`invoke:${name}:local=${count}:seen=${seen.map(x=>x+',').join('')}`);
    if(mode==='noop')return;
    const m=queries.row.each()[0];
    m.data.payload.update(a=>{const next=a.slice();next[0]+=delta;return next;});
    if(name==='B')m.data.payload.update(a=>{const next=a.slice();next[0]+=delta;return next;});
    console.log(`own:${name}:${m.data.payload.get().join(',')}`);
    events.out.emit(publish===1?count:9);
    if(name==='A')commands.remove(entity,Tag);else commands.insert(entity,[Tag,{}]);
    console.log(`host:${name}:${count}`);
    if(mode==='fail')return Fx.fail({code:7});
  });
}
const A=instance('A',1,1),B=instance('B',10,9);
const Tail=G.System('Tail',{},()=>{tail++;console.log('tail:'+tail);});
const Off=G.System('Off',{nextMachines:{mode:G.System.nextState(Mode)}},({nextMachines})=>nextMachines.mode.set('Off'));
const On=G.System('On',{nextMachines:{mode:G.System.nextState(Mode)}},({nextMachines})=>nextMachines.mode.set('On'));
function boundary(name,result){
  const dump=runtime.debug.dump();
  const stream=runtime.debug.streams().find(s=>s.stream==='Ping');
  const reader=stream?.readers.find(r=>r.system==='B');
  const commands=dump.pendingCommands.map(c=>c.tag+':'+c.system+',').join('');
  console.log(`${name}:result=${result.ok?'Success':result.error.system+':'+result.error.error.code}:payload=${dump.entities[0].components.Payload.join(',')}:commands=${commands}:local=${aCount},${bCount}:B-unread=${reader?.unread??0}:tail=${tail}`);
}
function run(name,system,input='success'){mode=input;boundary(name,runtime.tick(G.Schedule(G.Schedule(system),Tail)));}
boundary('empty-schedule',runtime.tick(G.Schedule()));
run('empty',B,'noop');
run('earlier',A);
run('failed',B,'fail');
run('retry',B);
run('repeat',B);
run('other-repeat',A);
run('noop',B,'noop');
runtime.tick(G.Schedule(Off,G.Schedule.applyStateTransitions()));
console.log('barrier:off:commands='+runtime.debug.dump().pendingCommands.length);
runtime.tick(G.Schedule(G.System('EmitForSkip',{events:{out:G.System.writeEvent(Ping)}},({events})=>events.out.emit(7))));
console.log('before-skip:B-unread='+runtime.debug.streams().find(s=>s.stream==='Ping').readers.find(r=>r.system==='B').unread);
run('skip',B);
runtime.tick(G.Schedule(On,G.Schedule.applyStateTransitions()));
console.log('barrier:on:commands='+runtime.debug.dump().pendingCommands.length);
run('after-skip',B,'noop');
