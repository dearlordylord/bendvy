import assert from 'node:assert/strict';
import {Schema} from '../../.references/bevy-ts/packages/core/src/index.ts';
const observations=[];
for (const name of ['RepeatedAlpha','RepeatedBeta']) {
  const trace=[];
  const Core=Schema.Feature.define('Core',{schema:Schema.fragment({}),build:()=>{trace.push('Core');return {};}});
  const Combat=Schema.Feature.define('Combat',{schema:Schema.fragment({}),requires:[Core,Core],build:()=>{trace.push('Combat');return {};}});
  const project=Schema.Feature.compose({root:Schema.defineRoot(name),features:[Combat,Core]});
  assert.deepEqual(trace,['Combat','Core']);
  observations.push({root:name,trace,names:Object.keys(project.features)});
}
console.log(JSON.stringify(observations));
