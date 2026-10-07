import {Schema,Descriptor as D,Entity,Result} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const encode=result=>result.ok?{ok:true,value:Array.isArray(result.value)?result.value.map(x=>x.value):result.value?.value??result.value}:{ok:false,error:result.error};
for(const root of ['Workshop','Other']){
 const Payload=D.Component()('Payload');const {relation:Link,related:LinkedBy}=D.Relation('Link','LinkedBy');const {relation:Parent}=D.Hierarchy('Parent','Children');
 const G=Schema.bind(Schema.fragment({components:{Payload},relations:{Link,Parent}}),Schema.defineRoot(root));const runtime=G.Runtime.make({});const ids=[];let phase='initial';const output=[];
 const q=G.Query({selection:{payload:G.Query.read(Payload),target:G.Query.optionalRelation(Link),sources:G.Query.optionalRelated(Link)}});
 const outgoing=G.Query({selection:{target:G.Query.readRelation(Link)}}),incoming=G.Query({selection:{sources:G.Query.readRelated(Link)}});
 const withOutgoing=G.Query({selection:{payload:G.Query.read(Payload)},withRelations:[Link]}),withoutOutgoing=G.Query({selection:{payload:G.Query.read(Payload)},withoutRelations:[Link]});
 const withIncoming=G.Query({selection:{payload:G.Query.read(Payload)},withRelated:[Link]}),withoutIncoming=G.Query({selection:{payload:G.Query.read(Payload)},withoutRelated:[Link]});
 const fullFailure=f=>({operation:f.operation,relation:f.relation.name,source:f.source.value,target:f.target.value,error:f.error});
 const snapshot=G.System('snapshot',{queries:{q,outgoing,incoming,withOutgoing,withoutOutgoing,withIncoming,withoutIncoming},relationFailures:{link:G.System.readRelationFailures(Link),parent:G.System.readRelationFailures(Parent)}},({queries,lookup,relationFailures})=>{
  const rows=queries.q.each().map(({entity,data})=>({id:entity.id.value,payload:[...data.payload.get().cells],target:data.target.present?data.target.get().value:null,sources:data.sources.present?data.sources.get().map(x=>x.value):null}));
  const result={root,phase,rows,requiredOutgoing:queries.outgoing.each().map(x=>({id:x.entity.id.value,target:x.data.target.get().value})),requiredIncoming:queries.incoming.each().map(x=>({id:x.entity.id.value,sources:x.data.sources.get().map(y=>y.value)})),withOutgoing:queries.withOutgoing.each().map(x=>x.entity.id.value),withoutOutgoing:queries.withoutOutgoing.each().map(x=>x.entity.id.value),withIncoming:queries.withIncoming.each().map(x=>x.entity.id.value),withoutIncoming:queries.withoutIncoming.each().map(x=>x.entity.id.value),lookups:ids.map(id=>({id:id.value,target:encode(lookup.related(id,Link)),sources:encode(lookup.relatedSources(id,Link))})),linkFailures:relationFailures.link.all().map(fullFailure),parentFailures:relationFailures.parent.all().map(fullFailure)};
  if(ids.length>=6){result.children=encode(lookup.relatedSources(ids[0],Parent));result.ancestors=encode(lookup.ancestors(ids[5],Parent));result.breadth=encode(lookup.descendants(ids[0],Parent,{order:'breadth'}));result.depth=encode(lookup.descendants(ids[0],Parent,{order:'depth'}));result.parent=encode(lookup.parent(ids[5],Parent));result.root=encode(lookup.root(ids[5],Parent));result.childMatches=lookup.childMatches(ids[0],Parent,outgoing).ok?lookup.childMatches(ids[0],Parent,outgoing).value.map(x=>x.entity.id.value):[];result.descendantMatches=lookup.descendantMatches(ids[0],Parent,outgoing,{order:'depth'}).ok?lookup.descendantMatches(ids[0],Parent,outgoing,{order:'depth'}).value.map(x=>x.entity.id.value):[];}
  output.push(result);
 });
 let serial=0;
 const tick=(...steps)=>{const r=runtime.tick(G.Schedule(...steps));if(!r.ok)throw Error(JSON.stringify(r));};
 const record=label=>{phase=label;tick(snapshot);};
 const queue=(label,body)=>{phase=label;tick(G.System('queue-'+(++serial),{},body),snapshot);phase=label+'-barrier';tick(G.Schedule.applyDeferred(),snapshot);};
 record('reader-registration');
 queue('spawn',({commands})=>{for(let i=1;i<=6;i++)ids.push(commands.spawn(G.Command.spawn([Payload,{cells:[i,i+100,i+200,i+300]}])));});
 queue('ordered-inverse',({commands})=>{commands.relate(ids[2],Link,ids[0]);commands.relate(ids[1],Link,ids[0]);});
 queue('repeat-same-edge',({commands})=>commands.relate(ids[2],Link,ids[0]));
 queue('replace-source',({commands})=>commands.relate(ids[2],Link,ids[1]));
 queue('unrelate-total',({commands})=>{commands.unrelate(ids[2],Link);commands.unrelate(ids[2],Link);commands.unrelate(Entity.makeEntityId(999),Link);});
 queue('fifo-relate-replace',({commands})=>{commands.relate(ids[2],Link,ids[0]);commands.relate(ids[2],Link,ids[1]);commands.relate(ids[2],Link,ids[0]);});
 queue('general-cycle',({commands})=>{commands.relate(ids[0],Link,ids[1]);commands.relate(ids[1],Link,ids[0]);});
 queue('ordered-errors',({commands})=>{commands.relate(Entity.makeEntityId(999),Link,Entity.makeEntityId(998));commands.relate(ids[0],Link,Entity.makeEntityId(999));commands.relate(ids[0],Link,ids[0]);});
 queue('spawn-hierarchy',({commands})=>{commands.relate(ids[3],Link,ids[0]);commands.relate(ids[3],Parent,ids[0]);commands.relate(ids[4],Parent,ids[0]);commands.relate(ids[5],Parent,ids[3]);});
 queue('hierarchy-reorder',({commands})=>commands.reorderChildren(ids[0],Parent,[ids[4],ids[3]]));
 queue('hierarchy-errors-and-later-success',({commands})=>{commands.relate(ids[0],Parent,ids[5]);commands.relate(ids[3],Parent,ids[3]);commands.reorderChildren(ids[0],Parent,[Entity.makeEntityId(999)]);commands.reorderChildren(ids[0],Parent,[ids[3],ids[3]]);commands.reorderChildren(ids[0],Parent,[ids[1]]);commands.reorderChildren(ids[0],Parent,[ids[3]]);commands.reorderChildren(ids[0],Parent,[ids[3],ids[4]]);});
 // A failed system must discard its queued mutations before any structural barrier.
 phase='system-failure';const failed=runtime.tick(G.Schedule(G.System('failed-system',{},({commands})=>{commands.relate(ids[2],Link,ids[1]);return Result.failure('boom');})));output.push({root,phase,result:failed});record('after-system-failure');phase='failed-system-barrier';tick(G.Schedule.applyDeferred(),snapshot);
 queue('delete-source',({commands})=>commands.despawn(ids[2]));
 queue('delete-general-target',({commands})=>commands.despawn(ids[1]));
 queue('delete-hierarchy-target',({commands})=>commands.despawn(ids[0]));
 console.log(JSON.stringify({root,descriptors:[Link,Parent].map(r=>({name:r.name,relatedName:r.relatedName,kind:r.relationKind,linkedDespawn:r.linkedDespawn,allowSelf:r.allowSelf,ordered:r.ordered,key:Symbol.keyFor(r.key),inverseKey:Symbol.keyFor(r.related.key)})),pair:{forward:Link.related===LinkedBy,sameNameKey:D.Relation('Link','DifferentInverse').relation.key===Link.key},observations:output}));
}
