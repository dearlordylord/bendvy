import assert from 'node:assert/strict';
import {Schema} from '../../.references/bevy-ts/packages/core/src/index.ts';
// Runtime observations; Node stripping does not check nominal scope types.
const observations=[];
for(const name of ['ScopesAlpha','ScopesBeta']) {
 const G=Schema.bind(Schema.fragment({}),Schema.defineRoot(name));
 const runtime=G.Runtime.make({services:G.Runtime.services()});
 const scene=G.EntityScope('scene');
 const sameName=G.EntityScope('scene');
 const inspect=G.Inspector('scope/live',{queries:{all:G.Query({selection:{}})}},({queries})=>queries.all.each().map(({entity})=>entity.id.value));
 const spawn=G.System('scope/spawn',{},({commands})=>{
   commands.spawnIn(scene,G.Command.spawn());
   commands.spawn(G.Command.spawn());
   commands.spawnIn(sameName,G.Command.spawn());
 });
 const clean=G.System('scope/clean',{},({commands})=>commands.despawnScope(scene));
 const barrier=G.Schedule(G.Schedule.applyDeferred());
 const record=label=>observations.push({root:name,label,live:runtime.inspect(inspect)});
 runtime.tick(G.Schedule(spawn));record('pending-spawn');
 runtime.tick(barrier);record('spawned');
 runtime.tick(G.Schedule(clean));record('pending-clean');
 runtime.tick(barrier);record('cleaned');
 runtime.tick(G.Schedule(clean));runtime.tick(barrier);record('repeated-clean');
}
assert.deepEqual(observations.map(x=>x.live),[[],[1,2,3],[1,2,3],[2],[2],[],[1,2,3],[1,2,3],[2],[2]]);
console.log(JSON.stringify(observations));
