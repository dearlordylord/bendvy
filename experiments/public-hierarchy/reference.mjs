import assert from 'node:assert/strict';
import {Schema,Descriptor as D} from '../../.references/bevy-ts/packages/core/src/index.ts';

const output=[];
for(const root of ['HierarchyAlpha','HierarchyBeta']) {
  const Payload=D.Component()('Payload');
  const {relation:Parent}=D.Hierarchy('Parent','Children');
  const {relation:Link}=D.Relation('Link','Incoming');
  const G=Schema.bind(Schema.fragment({components:{Payload},relations:{Parent,Link}}),Schema.defineRoot(root));
  const runtime=G.Runtime.make({});
  const ids=[];
  const records=[];
  let phase='seed';
  const query=G.Query({selection:{payload:G.Query.read(Payload)}});
  const tick=(...steps)=>assert.equal(runtime.tick(G.Schedule(...steps)).ok,true);
  const flush=G.Schedule.applyDeferred();
  const values=r=>r.ok?{ok:true,value:Array.isArray(r.value)?r.value.map(id=>id.value):r.value?.value??null}:{ok:false,error:r.error};
  tick(G.System('spawn',{},({commands})=>{
    for(let n=1;n<=8;n++)ids.push(commands.spawn(G.Command.spawn([Payload,{label:n,cells:[n,n*10]}])));
  }),flush);
  tick(G.System('seed',{},({commands})=>{
    for(const [child,parent] of [[2,1],[3,1],[4,2],[5,2],[6,3]])commands.relate(ids[child-1],Parent,ids[parent-1]);
    commands.relate(ids[6],Link,ids[2]);
    commands.despawn(ids[7]);
  }),flush);
  const observer=G.System('observe',{
    queries:{all:query},
    relationFailures:{parent:G.System.readRelationFailures(Parent)},
    removed:{payload:G.System.readRemoved(Payload)},
    despawned:{all:G.System.readDespawned()}
  },({queries,lookup,relationFailures,removed,despawned})=>{
    const traversal=ids.map(id=>({
      id:id.value,parent:values(lookup.parent(id,Parent)),children:values(lookup.relatedSources(id,Parent)),
      ancestors:values(lookup.ancestors(id,Parent)),root:values(lookup.root(id,Parent)),
      depth:values(lookup.descendants(id,Parent)),breadth:values(lookup.descendants(id,Parent,{order:'breadth'})),
      link:values(lookup.related(id,Link)),incoming:values(lookup.relatedSources(id,Link)),
      childMatches:matches(lookup.childMatches(id,Parent,query)),
      depthMatches:matches(lookup.descendantMatches(id,Parent,query)),
      breadthMatches:matches(lookup.descendantMatches(id,Parent,query,{order:'breadth'}))
    }));
    records.push({phase,rows:queries.all.each().map(row=>({id:row.entity.id.value,payload:structuredClone(row.data.payload.get())})),traversal,
      failures:relationFailures.parent.all().map(f=>({operation:f.operation,relation:f.relation.name,source:f.source.value,target:f.target.value,error:f.error})),
      removed:removed.payload.all().map(id=>id.value),despawned:despawned.all.all().map(id=>id.value)});
  });
  function matches(r){return r.ok?{ok:true,value:r.value.map(row=>({id:row.entity.id.value,payload:structuredClone(row.data.payload.get())}))}:{ok:false,error:r.error};}
  const observe=label=>{phase=label;tick(observer);return records.at(-1);};
  const first=observe('initial');
  assert.deepEqual(first.traversal[0].depth.value,[2,4,5,3,6]);
  assert.deepEqual(first.traversal[0].breadth.value,[2,3,4,5,6]);
  assert.deepEqual(first.traversal[3].ancestors.value,[2,1]);
  assert.equal(first.traversal[3].root.value,1);
  assert.equal(first.traversal[7].depth.error._tag,'MissingEntity');
  const operation=(label,body)=>{
    phase=label+'-queued';tick(G.System(label,{},body),observer);
    const before=records.at(-1);
    phase=label+'-applied';tick(flush,observer);
    const after=records.at(-1);
    return {before,after};
  };
  let r=operation('reorder',({commands})=>commands.reorderChildren(ids[0],Parent,[ids[2],ids[1]]));
  assert.deepEqual(r.before.traversal[0].children.value,[2,3]);
  assert.deepEqual(r.after.traversal[0].children.value,[3,2]);
  assert.deepEqual(r.after.traversal[0].depth.value,[3,6,2,4,5]);
  r=operation('reparent',({commands})=>commands.relate(ids[3],Parent,ids[2]));
  assert.deepEqual(r.after.traversal[1].children.value,[5]);
  assert.deepEqual(r.after.traversal[2].children.value,[6,4]);
  assert.deepEqual(r.after.traversal[0].depth.value,[3,6,4,2,5]);
  const rejected=[
    ['self',({commands})=>commands.relate(ids[0],Parent,ids[0]),'SelfRelationNotAllowed'],
    ['cycle',({commands})=>commands.relate(ids[0],Parent,ids[3]),'HierarchyCycle'],
    ['missing-child',({commands})=>commands.reorderChildren(ids[0],Parent,[ids[7],ids[2],ids[1]]),'MissingChildEntity'],
    ['duplicate-child',({commands})=>commands.reorderChildren(ids[0],Parent,[ids[2],ids[2],ids[1]]),'DuplicateChild'],
    ['unrelated-child',({commands})=>commands.reorderChildren(ids[0],Parent,[ids[6],ids[2],ids[1]]),'ChildNotRelatedToParent'],
    ['child-set',({commands})=>commands.reorderChildren(ids[0],Parent,[ids[2]]),'ChildSetMismatch']
  ];
  for(const [label,body,error] of rejected){
    r=operation(label,body);
    assert.deepEqual(r.before.failures,[]);
    assert.equal(r.after.failures.length,1);
    assert.equal(r.after.failures[0].error._tag,error);
    assert.deepEqual(r.after.rows,r.before.rows);
    assert.deepEqual(r.after.traversal,r.before.traversal);
    assert.deepEqual(r.after.removed,[]);assert.deepEqual(r.after.despawned,[]);
  }
  r=operation('delete-subtree',({commands})=>commands.despawn(ids[2]));
  assert.deepEqual(r.before.rows.map(row=>row.id),[1,2,3,4,5,6,7]);
  assert.deepEqual(r.after.rows.map(row=>row.id),[1,2,5,7]);
  assert.deepEqual(r.after.removed,[6,4,3]);assert.deepEqual(r.after.despawned,[6,4,3]);
  assert.deepEqual(r.after.traversal[6].link,{ok:false,error:{_tag:'MissingRelation',entityId:7,relation:'Link'}});
  r=operation('repeat-delete',({commands})=>commands.despawn(ids[2]));
  assert.deepEqual(r.after.removed,[]);assert.deepEqual(r.after.despawned,[]);
  r=operation('delete-root',({commands})=>commands.despawn(ids[0]));
  assert.deepEqual(r.after.rows.map(row=>row.id),[7]);
  assert.deepEqual(r.after.removed,[5,2,1]);assert.deepEqual(r.after.despawned,[5,2,1]);
  output.push({root,records});
}
console.log(JSON.stringify(output));
