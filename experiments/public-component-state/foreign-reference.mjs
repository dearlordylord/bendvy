import {Descriptor,Schema,Decode} from '../../.references/bevy-ts/packages/core/src/index.ts';
const Phase=Descriptor.State('State/Phase',['ready','windup','active']);const Neighbor=Descriptor.ConstructedComponent(Decode.array(Decode.number))('State/Neighbor');
const G=Schema.bind(Schema.fragment({components:{Phase,Neighbor}}));const a=G.Runtime.make({services:G.Runtime.services()}),b=G.Runtime.make({services:G.Runtime.services()});let aid,bid;
function seed(runtime,setId){const Seed=G.System('state/seed',{},({commands})=>{setId(commands.spawn(G.Command.spawn([Phase,'ready'],[Neighbor,[11,22,33,44]])));});runtime.tick(G.Schedule(Seed,G.Schedule.applyDeferred()));}
seed(a,id=>aid=id);seed(b,id=>bid=id);
const query=G.Query({selection:{phase:G.Query.write(Phase),neighbor:G.Query.read(Neighbor)}});
const Use=G.System('state/foreign',{},({lookup})=>{const found=lookup.getHandle(G.Entity.handle(bid),query);console.log(JSON.stringify({label:'foreign-collision',ids:[aid.value,bid.value],ok:found.ok,phase:found.ok?found.value.data.phase.get():null}));if(found.ok)found.value.data.phase.set('active');});a.tick(G.Schedule(Use));
const Read=G.Inspector('state/read',{queries:{q:G.Query({selection:{phase:G.Query.read(Phase),neighbor:G.Query.read(Neighbor)}})}},({queries})=>queries.q.each().map(({data})=>[data.phase.get(),data.neighbor.get()]));
for(const [label,runtime] of [['home',a],['other',b]])console.log(JSON.stringify({label,rows:runtime.inspect(Read)}));
