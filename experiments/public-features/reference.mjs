import assert from 'node:assert/strict';
import {Schema} from '../../.references/bevy-ts/packages/core/src/index.ts';

// Executed runtime observations only. Node type stripping does not establish
// the FeatureBuildGame compile-time dependency visibility boundary.
const output=[];
for(const rootName of ['FeatureAlpha','FeatureBeta']) {
  const trace=[];
  const root=Schema.defineRoot(rootName);
  const build=(name)=>(Game)=>{
    trace.push(`build:${name}`);
    const bootstrap=Game.System(`${name}/bootstrap`,{},()=>{trace.push(`bootstrap:${name}`);});
    const update=Game.System(`${name}/update`,{},()=>{trace.push(`update:${name}`);});
    return {bootstrap:[Game.Schedule(bootstrap)],update:[Game.Schedule(update)],label:name};
  };
  const Core=Schema.Feature.define('Core',{schema:Schema.fragment({}),build:build('Core')});
  const Combat=Schema.Feature.define('Combat',{schema:Schema.fragment({}),requires:[Core],build:build('Combat')});
  const Empty=Schema.Feature.define('Empty',{schema:Schema.fragment({}),build:()=>({label:'empty'})});
  const project=Schema.Feature.compose({root,features:[Combat,Core,Empty]});
  assert.deepEqual(trace,['build:Combat','build:Core']);
  const runtime=project.Game.Runtime.make({services:project.Game.Runtime.services()});
  const result=runtime.tick(...project.schedules.bootstrap,...project.schedules.update);
  assert.equal(result.ok,true);
  assert.deepEqual(trace,['build:Combat','build:Core','bootstrap:Combat','bootstrap:Core','update:Combat','update:Core']);
  assert.deepEqual(project.features.Empty,{label:'empty',bootstrap:[],update:[]});
  output.push({root:rootName,case:'selected-order',trace:[...trace],names:Object.keys(project.features),empty:project.features.Empty});
  for(const [name,features,expected] of [
    ['duplicate',[Core,Core],'Duplicate feature name: Core'],
    ['missing',[Combat],'Missing required feature: Core'],
    ['duplicate-before-missing',[Combat,Combat],'Duplicate feature name: Combat']
  ]) {
    const before=[...trace];let error;
    try {Schema.Feature.compose({root,features});}catch(caught){error=caught.message;}
    assert.equal(error,expected);assert.deepEqual(trace,before);
    output.push({root:rootName,case:name,error,trace:[...trace]});
  }
}
console.log(JSON.stringify(output));
