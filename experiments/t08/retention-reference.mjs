import {Descriptor,Schema} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const P=Descriptor.Component()('Position');const G=Schema.bind(Schema.fragment({components:{P}}));
const runtime=G.Runtime.make({services:G.Runtime.services()});let id,name='';
const A=G.Query({selection:{p:G.Query.read(P)},filters:[G.Query.added(P)]});
const C=G.Query({selection:{p:G.Query.read(P)},filters:[G.Query.changed(P)]});
const All=G.Query({selection:{p:G.Query.read(P)}});const Write=G.Query({selection:{p:G.Query.write(P)}});
const text=xs=>xs.map(x=>x+',').join('');
function reader(label){return G.System(label,{queries:{a:A,c:C,v:All},removed:{p:G.System.readRemoved(P)},despawned:{e:G.System.readDespawned()}},({queries,removed,despawned})=>{const ids=xs=>xs.map(x=>{if(x.value!==id.value)throw Error('unmapped');return 0;});console.log(name+':v='+text(queries.v.each().map(x=>x.data.p.get().x))+';a='+text(queries.a.each().map(x=>x.data.p.get().x))+';c='+text(queries.c.each().map(x=>x.data.p.get().x))+';r='+text(ids(removed.p.all()))+';d='+text(ids(despawned.e.all()))+';e=');});}
const Fast=reader('Fast'),Slow=reader('Slow');
const Spawn=G.System('Spawn',{},({commands})=>{id=commands.spawn(G.Command.spawn([P,{x:1}]));});
const Update=G.System('Update',{queries:{w:Write}},({queries})=>{for(const x of queries.w.each())x.data.p.set({x:9});});
const Delete=G.System('Delete',{},({commands})=>{commands.despawn(id);});
const tick=(...steps)=>runtime.tick(G.Schedule(...steps));
name='holder:init';tick(Spawn,G.Schedule.applyDeferred(),Fast);
tick(Update);tick();tick();tick();name='late:old-change';tick(Slow);
tick(Delete,G.Schedule.applyDeferred());tick();tick();name='holder:old-removal';tick(Fast);name='late:old-removal';tick(Slow);
tick();name='holder:empty';tick(Fast);
