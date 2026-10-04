import {Descriptor,Schema} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const P=Descriptor.Component()('P'),G=Schema.bind(Schema.fragment({components:{P}})),q=G.Query({selection:{p:G.Query.read(P)}});
const r=G.Runtime.make({services:G.Runtime.services()}),ids=[],labels=new Map();let label='';
r.tick(G.Schedule(G.System('Spawn',{},({commands})=>{for(const [i,x] of [10,20,30].entries()){const id=commands.spawn(G.Command.spawn([P,{x}]));ids.push(id);labels.set(id.value,i);}}),G.Schedule.applyDeferred()));
const Read=G.System('Read',{queries:{q}},({queries})=>{console.log(label+':'+queries.q.each().map(x=>labels.get(x.entity.id.value)+'='+x.data.p.get().x+';').join(''));});
const observe=(name,...steps)=>{label=name;r.tick(G.Schedule(...steps,Read));};
observe('before');observe('after');
observe('vacated-component',G.System('Remove',{},({commands})=>{commands.remove(ids[1],P);}),G.Schedule.applyDeferred());
observe('reinsert',G.System('Insert',{},({commands})=>{commands.insert(ids[1],[P,{x:20}]);}),G.Schedule.applyDeferred());observe('preserved');
