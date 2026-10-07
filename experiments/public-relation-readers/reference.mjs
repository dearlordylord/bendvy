import assert from 'node:assert/strict';
import {Schema,Descriptor,Entity,Fx} from '../../.references/bevy-ts/packages/core/src/index.ts';
const observations=[];
for(const root of ['ReadersAlpha','ReadersBeta']) {
 const {relation:Parent}=Descriptor.Hierarchy('Parent','Children');
 const G=Schema.bind(Schema.fragment({relations:{Parent}}),Schema.defineRoot(root));
 const r=G.Runtime.make({});let id;let label;let fail=false;
 const encode=f=>({operation:f.operation,relation:f.relation.name,source:f.source.value,target:f.target.value,error:f.error});
 const reader=name=>G.System(name,{relationFailures:{p:G.System.readRelationFailures(Parent)}},({relationFailures})=>{
  observations.push({root,label,reader:name,failures:relationFailures.p.all().map(encode)});
  if(name==='slow'&&fail)return Fx.fail('ReaderRejected');
 });
 const fast=reader('fast'),slow=reader('slow');
 const tick=(...x)=>{const result=r.tick(G.Schedule(...x));assert.equal(result.ok,true);};
 const flush=G.Schedule.applyDeferred();
 label='registered';tick(fast,slow);
 tick(G.System('seed',{},({commands})=>{id=commands.spawn(G.Command.spawn());}),flush);
 tick(G.System('queue-errors',{},({commands})=>{commands.relate(id,Parent,id);commands.relate(id,Parent,Entity.makeEntityId(999));}));
 label='queued';tick(fast,slow);
 label='published';tick(flush,fast); // Slow intentionally skips this publication run.
 label='fast-again';tick(fast);
 label='slow-fails';fail=true;const rejected=r.tick(G.Schedule(slow));assert.equal(rejected.ok,false);
 label='slow-retry';fail=false;tick(slow);
 label='slow-again';tick(slow);
}
const failures=[
 {operation:'relate',relation:'Parent',source:1,target:1,error:{_tag:'SelfRelationNotAllowed',entityId:1,relation:'Parent'}},
 {operation:'relate',relation:'Parent',source:1,target:999,error:{_tag:'MissingTargetEntity',entityId:1,targetId:999,relation:'Parent'}}
];
const checkpoints=[['registered','fast',[]],['registered','slow',[]],['queued','fast',[]],['queued','slow',[]],['published','fast',failures],['fast-again','fast',[]],['slow-fails','slow',failures],['slow-retry','slow',failures],['slow-again','slow',[]]];
assert.deepEqual(observations,['ReadersAlpha','ReadersBeta'].flatMap(root=>checkpoints.map(([label,reader,failures])=>({root,label,reader,failures}))));
console.log(JSON.stringify(observations));
