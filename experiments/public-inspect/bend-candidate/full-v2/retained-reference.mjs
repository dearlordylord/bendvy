import assert from 'node:assert/strict';
import {Descriptor as D,Schema} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const observations=[];
for(const schema of ['Workshop','Garden']){
 const Stock=D.Component()(schema+'/JointStock'),Score=D.Resource()(schema+'/JointScore'),Ping=D.Event()(schema+'/JointPing');
 const G=Schema.bind(Schema.fragment({components:{Stock},resources:{Score},events:{Ping}}));
 const runtime=G.Runtime.make({resources:{Score:{cells:[21,21,21,24]}}});let target,fail=true,label;
 const plain=G.Query({selection:{stock:G.Query.read(Stock)}});
 const added=G.Query({selection:{stock:G.Query.read(Stock)},filters:[G.Query.added(Stock)]});
 const changed=G.Query({selection:{stock:G.Query.read(Stock)},filters:[G.Query.changed(Stock)]});
 const spec={queries:{plain,added,changed},resources:{score:G.System.readResource(Score)},events:{ping:G.System.readEvent(Ping)},removed:{stock:G.System.readRemoved(Stock)},despawned:{entities:G.System.readDespawned()}};
 const inspector=G.Inspector(schema+'/JointInspector',spec,ctx=>{
  const a=new Set(ctx.queries.added.each().map(x=>x.entity.id.value)),c=new Set(ctx.queries.changed.each().map(x=>x.entity.id.value));
  const lookup=ctx.queries.plain.get(target); const snapshot={lookup:lookup.ok?{ok:true,cells:[...lookup.value.data.stock.get().cells]}:{ok:false,error:lookup.error._tag},rows:ctx.queries.plain.each().map(x=>({id:x.entity.id.value,cells:[...x.data.stock.get().cells],added:a.has(x.entity.id.value),changed:c.has(x.entity.id.value)})),score:[...ctx.resources.score.get().cells],events:[...ctx.events.ping.all()],eventLag:ctx.events.ping.lagged(),removed:ctx.removed.stock.all().map(x=>x.value),despawned:ctx.despawned.entities.all().map(x=>x.value)};
  observations.push({schema,label,ok:!fail,snapshot});if(fail)throw new Error('joint-after-read');return snapshot;
 });
 const attempt=name=>{label=name;try{runtime.inspect(inspector);assert.equal(fail,false);}catch(error){assert.equal(fail,true);assert.equal(error.message,'joint-after-read');}};
 const retainRemoved=G.System(schema+'/RetainRemoved',{removed:{stock:G.System.readRemoved(Stock)}},()=>{throw new Error('hold');});
 const retainDespawned=G.System(schema+'/RetainDespawned',{despawned:{entities:G.System.readDespawned()}},()=>{throw new Error('hold');});
 for(const system of [retainRemoved,retainDespawned]){assert.throws(()=>runtime.tick(G.Schedule(system)),/hold/);}
 const seed=G.System(schema+'/JointSeed',{},({commands})=>{target=commands.spawn(G.Command.spawn([Stock,{cells:[11,11,11,14]}]));});
 assert.equal(runtime.tick(G.Schedule(seed,G.Schedule.applyDeferred())).ok,true);attempt('warm-failure');
 const publish=G.System(schema+'/JointPublish',{events:{ping:G.System.writeEvent(Ping)}},({commands,events})=>{commands.despawn(target);events.ping.emit(31);events.ping.emit(32);});
 assert.equal(runtime.tick(G.Schedule(publish,G.Schedule.applyDeferred())).ok,true);attempt('mixed-failure');
 assert.equal(runtime.tick(G.Schedule()).ok,true);assert.equal(runtime.tick(G.Schedule()).ok,true);
 fail=false;attempt('lag-retry');attempt('repeat');
}
console.log(JSON.stringify({format:1,application:'PublicInspectJointReference',observations}));
