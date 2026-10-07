import assert from 'node:assert/strict';
import {Schema} from '../../../.references/bevy-ts/packages/core/src/index.ts';
function runApplication(size) {
const records=[];
for(const root of ['A','B']) for(const mode of ['selected','duplicate','missing','priority']) {
  const pad=(cells,extra)=>size==='grown'?cells.concat(extra):cells;
  const owners={front:pad([31,32],[33,34]),back:pad([41,42],[43,44]),queued:[pad([51,52],[53,54])],core:pad([11,12],[13,14]),tag:'tag'};
  const trace=[],calls=[0,0];
  const phase=(Game,name,index)=>{
    const bootstrap=Game.System(name+'/bootstrap',{},()=>{calls[index]++;trace.push('bootstrap:'+name);});
    const update=Game.System(name+'/update',{},()=>{calls[index]++;trace.push('update:'+name);});
    return {bootstrap:[Game.Schedule(bootstrap)],update:[Game.Schedule(update)]};
  };
  const Core=Schema.Feature.define('Core',{schema:Schema.fragment({}),build:(Game)=>{trace.push('build:Core');owners.core[1]=212;return {...phase(Game,'Core',0),owner:{cells:owners.core,tag:owners.tag}};}});
  const Combat=Schema.Feature.define('Combat',{schema:Schema.fragment({}),requires:[Core],build:(Game)=>{trace.push('build:Combat');owners.front[0]=131;owners.back[1]=142;return {...phase(Game,'Combat',1),owner:{front:owners.front,back:owners.back,queued:owners.queued}};}});
  const Empty=Schema.Feature.define('Empty',{schema:Schema.fragment({}),build:()=>({label:'empty'})});
  const Other=Schema.Feature.define('Other',{schema:Schema.fragment({}),build:()=>({})});
  const selected=mode==='selected'?[Combat,Core,Empty]:mode==='duplicate'?[Core,Core,Empty]:mode==='missing'?[Combat,Other,Empty]:[Combat,Combat,Empty];
  let project,error;
  try {project=Schema.Feature.compose({root:Schema.defineRoot('FeatureTiming'+root),features:selected});}catch(caught){error=caught.message;}
  if(mode==='selected') {
    assert(project);
    const runtime=project.Game.Runtime.make({services:project.Game.Runtime.services()});
    const result=runtime.tick(...project.schedules.bootstrap,...project.schedules.update);assert.equal(result.ok,true);
    assert.deepEqual(trace,['build:Combat','build:Core','bootstrap:Combat','bootstrap:Core','update:Combat','update:Core']);assert.deepEqual(calls,[2,2]);
  } else {assert.deepEqual(trace,[]);assert.deepEqual(calls,[0,0]);assert.equal(error,mode==='duplicate'?'Duplicate feature name: Core':mode==='missing'?'Missing required feature: Core':'Duplicate feature name: Combat');}
  const returned=project?{front:project.features.Combat.owner.front,back:project.features.Combat.owner.back,queued:project.features.Combat.owner.queued,core:project.features.Core.owner.cells,tag:project.features.Core.owner.tag}:owners;
  records.push({case:root+'-'+size+'-'+mode,status:mode==='selected'?'executed':'refused',error:error??null,trace,calls,owners:returned,empty:project?.features.Empty.label??null});
}
console.log(JSON.stringify(records));
}
const size=process.argv[2];assert(size==='small'||size==='grown');
for(let iteration=0;iteration<200;iteration++) runApplication(size);
