import assert from 'node:assert/strict';
import {Schema,Descriptor} from '../../.references/bevy-ts/packages/core/src/index.ts';
const output=[];
for(const root of ['ReadersAlpha','ReadersBeta']) {
 const {relation:Parent}=Descriptor.Hierarchy('Parent','Children');
 const G=Schema.bind(Schema.fragment({relations:{Parent}}),Schema.defineRoot(root));
 const runtime=G.Runtime.make({debug:true});let id,enabled=false,label;
 const condition=G.Condition.check('enabled',{},()=>enabled);
 const deliveries=[];
 const reader=G.System('never-activated',{relationFailures:{p:G.System.readRelationFailures(Parent)},when:[condition]},({relationFailures})=>{
  deliveries.push({label,lagged:relationFailures.p.lagged(),failures:relationFailures.p.all().map(f=>({operation:f.operation,relation:f.relation.name,source:f.source.value,target:f.target.value,error:f.error}))});
 });
 const tick=(...steps)=>assert.equal(runtime.tick(G.Schedule(...steps)).ok,true);
 const capture=()=>output.push({root,label,world:structuredClone(runtime.debug.dump()),streams:structuredClone(runtime.debug.streams()),deliveries:structuredClone(deliveries)});
 const flush=G.Schedule.applyDeferred();
 tick(G.System('seed',{},({commands})=>{id=commands.spawn(G.Command.spawn());}),flush);
 const publish=G.System('publish',{},({commands})=>commands.relate(id,Parent,id));
 label='never-activated';tick(reader);assert.equal(deliveries.length,0);capture();
 label='published-before-activation';tick(publish,flush,reader);assert.equal(deliveries.length,0);capture();
 label='aged-without-reader';tick(reader);tick(reader);assert.equal(deliveries.length,0);capture();
 enabled=true;label='first-activation';tick(reader);assert.deepEqual(deliveries,[{label,lagged:false,failures:[]}]);capture();
 label='new-publication';tick(publish,flush,reader);
 assert.deepEqual(deliveries[1],{label,lagged:false,failures:[{operation:'relate',relation:'Parent',source:1,target:1,error:{_tag:'SelfRelationNotAllowed',entityId:1,relation:'Parent'}}]});capture();
 label='consumed';tick(reader);assert.deepEqual(deliveries[2],{label,lagged:false,failures:[]});capture();
}
console.log(JSON.stringify(output));
