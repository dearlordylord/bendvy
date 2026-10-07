import {Descriptor,Schema,Fx,Decode} from '../../.references/bevy-ts/packages/core/src/index.ts';
const emit=(label,value)=>console.log(JSON.stringify({label,value}));
const Phase=Descriptor.State('State/Phase',['ready','windup','active'],{transitions:{ready:['windup'],windup:['active','ready'],active:['ready']}});
const Mode=Descriptor.State('State/Mode',[0,1,2]);
for(const [name,d,values] of [['Phase',Phase,['ready','windup','active','sleeping',undefined,null,0]],['Mode',Mode,[0,1,2,3,'0',undefined,null]]]){
 emit('descriptor/'+name,{states:d.states,transitions:d.transitions??null});
 for(const value of values)emit('construct/'+name+'/'+String(value),Descriptor.constructorOf(d).result(value));
}
const Neighbor=Descriptor.ConstructedComponent(Decode.array(Decode.number))('State/Neighbor');
const G=Schema.bind(Schema.fragment({components:{Phase,Mode,Neighbor}}));
const r=G.Runtime.make({services:G.Runtime.services()});
const write=G.Query({selection:{phase:G.Query.write(Phase),mode:G.Query.write(Mode),neighbor:G.Query.read(Neighbor)}});
const read=G.Inspector('state/read',{queries:{q:G.Query({selection:{phase:G.Query.read(Phase),mode:G.Query.read(Mode),neighbor:G.Query.read(Neighbor)}})}},({queries})=>queries.q.each().map(({data})=>[data.phase.get(),data.mode.get(),data.neighbor.get()]));
const snap=label=>emit(label,r.inspect(read));
const spawn=G.System('state/spawn',{},({commands})=>{commands.spawn(G.Command.spawn([Phase,'ready'],[Mode,0],[Neighbor,[11,22,33]]));commands.spawn(G.Command.spawn([Neighbor,[44,55,66]]));});
r.tick(G.Schedule(spawn));snap('before-barrier');r.tick(G.Schedule(G.Schedule.applyDeferred()));snap('after-barrier');
const watch=G.System('state/watch',{queries:{q:G.Query({selection:{phase:G.Query.read(Phase)},filters:[G.Query.changed(Phase)]})}},({queries})=>emit('changed',queries.q.each().map(({data})=>data.phase.get())));
r.tick(G.Schedule(watch));
const fail=G.System('state/fail',{queries:{q:write}},({queries})=>Fx.flatMap(Fx.sync(()=>{for(const {data} of queries.q.each()){emit('fail/transition',data.phase.transition('ready','windup'));data.mode.set(2);}}),()=>Fx.fail('Rejected')));
emit('failed-tick',r.tick(G.Schedule(fail)));snap('rollback');r.tick(G.Schedule(watch));
const advance=G.System('state/advance',{queries:{q:write}},({queries})=>{for(const {data} of queries.q.each()){emit('transition',data.phase.transition('ready','windup'));emit('stale',data.phase.transition('ready','windup'));emit('next',data.phase.transition('windup','active'));emit('numeric',data.mode.transition(0,2));}});
r.tick(G.Schedule(advance,watch));snap('advanced');r.tick(G.Schedule(watch));
const raw=G.System('state/raw',{queries:{q:write}},({queries})=>{for(const {data} of queries.q.each()){emit('raw/legal',data.phase.setRaw('ready'));emit('raw/illegal',data.phase.setRaw('sleeping'));}});
r.tick(G.Schedule(raw));snap('raw-retains');
const snapshot=r.snapshot();const e=snapshot.entities.find(e=>'State/Phase' in e.components);
emit('restore/illegal',r.restore({...snapshot,entities:snapshot.entities.map(x=>x===e?{...x,components:{...x.components,'State/Phase':'sleeping'}}:x)}));snap('restore-retains');emit('restore/legal',r.restore(JSON.parse(JSON.stringify(snapshot))));
// Runtime graph enforcement is distinct from TS compile-time pair restrictions.
const bypass=G.System('state/runtime-graph',{queries:{q:write}},({queries})=>{for(const {data} of queries.q.each())emit('graph/bypassed',data.phase.transition('ready','active'));});r.tick(G.Schedule(bypass));snap('graph-bypassed');
const equal=G.System('state/equal-write',{queries:{q:write}},({queries})=>{for(const {data} of queries.q.each())data.phase.set(data.phase.get());});r.tick(G.Schedule(watch));r.tick(G.Schedule(equal,watch));
const pairs=G.System('state/all-pairs',{queries:{q:write}},({queries})=>{for(const {data} of queries.q.each()){
 for(const [from,tos] of Object.entries(Phase.transitions))for(const to of tos){data.phase.set(from);emit('edge/'+from+'/'+to,data.phase.transition(from,to));}
 for(const from of Mode.states)for(const to of Mode.states){data.mode.set(from);emit('free-edge/'+from+'/'+to,data.mode.transition(from,to));}
}});r.tick(G.Schedule(pairs));snap('all-pairs-final');
