import assert from 'node:assert/strict';
import {Schema,Descriptor} from '../../.references/bevy-ts/packages/core/src/index.ts';
const output=[];
for(const root of ['ReadersAlpha','ReadersBeta']) {
 const {relation:Parent}=Descriptor.Hierarchy('Parent','Children');
 const G=Schema.bind(Schema.fragment({relations:{Parent}}),Schema.defineRoot(root));
 const r=G.Runtime.make({});let id,enabled=true,label;
 const condition=G.Condition.check('enabled',{},()=>enabled);
 const encode=f=>({operation:f.operation,relation:f.relation.name,source:f.source.value,target:f.target.value,error:f.error});
 const make=(name,when)=>G.System(name,{relationFailures:{p:G.System.readRelationFailures(Parent)},...(when?{when:[condition]}:{})},({relationFailures})=>{output.push({root,label,reader:name,failures:relationFailures.p.all().map(encode)});});
 const fast=make('fast',false),gated=make('gated',true);
 const tick=(...steps)=>assert.equal(r.tick(G.Schedule(...steps)).ok,true);
 const flush=G.Schedule.applyDeferred();
 label='registered';tick(fast,gated);
 tick(G.System('seed',{},({commands})=>{id=commands.spawn(G.Command.spawn());}),flush);
 const publish=G.System('publish',{},({commands})=>commands.relate(id,Parent,id));
 label='published';tick(publish,flush,fast);
 enabled=false;label='false-condition';const count=output.length;tick(gated);assert.equal(output.length,count);
 output.push({root,label,reader:'gated',ran:false});
 enabled=true;label='resume';tick(gated);
 label='new-publication';tick(publish,flush,gated);
}
const failure={operation:'relate',relation:'Parent',source:1,target:1,error:{_tag:'SelfRelationNotAllowed',entityId:1,relation:'Parent'}};
assert.deepEqual(output,['ReadersAlpha','ReadersBeta'].flatMap(root=>[
 {root,label:'registered',reader:'fast',failures:[]},
 {root,label:'registered',reader:'gated',failures:[]},
 {root,label:'published',reader:'fast',failures:[failure]},
 {root,label:'false-condition',reader:'gated',ran:false},
 {root,label:'resume',reader:'gated',failures:[]},
 {root,label:'new-publication',reader:'gated',failures:[failure]}
]));
console.log(JSON.stringify(output));
