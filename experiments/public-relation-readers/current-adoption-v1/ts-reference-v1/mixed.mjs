import assert from 'node:assert/strict';
import {Descriptor as D,Schema,Entity} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const observations=[];
for(const root of ['ReadersAlpha','ReadersBeta']){
 const Stock=D.Component()(root+'/MixedStock'),Ping=D.Event()(root+'/MixedPing');
 const {relation:Parent}=D.Hierarchy(root+'/MixedParent',root+'/MixedChildren');
 const G=Schema.bind(Schema.fragment({components:{Stock},events:{Ping},relations:{Parent}}),Schema.defineRoot(root));
 const runtime=G.Runtime.make({debug:true});let target,label;let snapshots=[];
 const plain=G.Query({selection:{stock:G.Query.read(Stock)}}),added=G.Query({selection:{stock:G.Query.read(Stock)},filters:[G.Query.added(Stock)]}),changed=G.Query({selection:{stock:G.Query.read(Stock)},filters:[G.Query.changed(Stock)]});
 const reader=G.System('mixed-reader',{queries:{plain,added,changed},events:{ping:G.System.readEvent(Ping)},removed:{stock:G.System.readRemoved(Stock)},relationFailures:{parent:G.System.readRelationFailures(Parent)}},ctx=>{
  snapshots.push({rows:ctx.queries.plain.each().map(x=>({id:x.entity.id.value,cells:[...x.data.stock.get().cells]})),added:ctx.queries.added.each().map(x=>x.entity.id.value),changed:ctx.queries.changed.each().map(x=>x.entity.id.value),events:[...ctx.events.ping.all()],eventLag:ctx.events.ping.lagged(),removed:ctx.removed.stock.all().map(x=>x.value),failures:ctx.relationFailures.parent.all().map(x=>({operation:x.operation,relation:x.relation.name,source:x.source.value,target:x.target.value,error:x.error})),relationLag:ctx.relationFailures.parent.lagged()});
 });
 const tick=(...steps)=>assert.equal(runtime.tick(G.Schedule(...steps)).ok,true);const flush=G.Schedule.applyDeferred();
 const capture=()=>{observations.push({root,label,snapshots:structuredClone(snapshots),world:structuredClone(runtime.debug.dump()),streams:structuredClone(runtime.debug.streams())});snapshots=[];};
 tick(G.System('seed',{},({commands})=>{target=commands.spawn(G.Command.spawn());}),flush);
 label='activated';tick(reader);assert.deepEqual(snapshots,[{rows:[],added:[],changed:[],events:[],eventLag:false,removed:[],failures:[],relationLag:false}]);capture();
 tick(G.System('insert',{},({commands})=>{commands.insert(target,[Stock,{cells:[11,12,13,14]}]);}),flush);
 label='inserted';tick(reader);assert.deepEqual(snapshots,[{rows:[{id:1,cells:[11,12,13,14]}],added:[1],changed:[1],events:[],eventLag:false,removed:[],failures:[],relationLag:false}]);capture();
 label='repeat';tick(reader);assert.deepEqual(snapshots,[{rows:[{id:1,cells:[11,12,13,14]}],added:[],changed:[],events:[],eventLag:false,removed:[],failures:[],relationLag:false}]);capture();
 tick(G.System('publish',{events:{ping:G.System.writeEvent(Ping)}},({commands,events})=>{commands.relate(target,Parent,Entity.makeEntityId(999));events.ping.emit(31);events.ping.emit(32);commands.remove(target,Stock);}),flush);
 label='published';tick(reader);assert.deepEqual(snapshots,[{rows:[],added:[],changed:[],events:[31,32],eventLag:false,removed:[1],failures:[{operation:'relate',relation:root+'/MixedParent',source:1,target:999,error:{_tag:'MissingTargetEntity',entityId:1,targetId:999,relation:root+'/MixedParent'}}],relationLag:false}]);capture();
}
export const result = {developmentOnly:true,acceptance:false,completeIssue43:false,application:'ActualMixedRegisteredReader',observations};
