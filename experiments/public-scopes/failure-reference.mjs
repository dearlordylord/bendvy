import assert from 'node:assert/strict';
import {Schema,Fx} from '../../.references/bevy-ts/packages/core/src/index.ts';
const observations=[];
for(const name of ['ScopesAlpha','ScopesBeta']) {
 const G=Schema.bind(Schema.fragment({}),Schema.defineRoot(name));
 const r=G.Runtime.make({services:G.Runtime.services()});
 const scope=G.EntityScope('scene');
 const all=G.Inspector('scope/live',{queries:{q:G.Query({selection:{}})}},({queries})=>queries.q.each().map(({entity})=>entity.id.value));
 const flush=G.Schedule(G.Schedule.applyDeferred());
 const record=label=>observations.push({root:name,label,live:r.inspect(all)});
 const seed=G.System('seed',{},({commands})=>{commands.spawnIn(scope,G.Command.spawn());commands.spawn(G.Command.spawn());});
 const failure=G.System('fail-clean',{},({commands})=>{commands.despawnScope(scope);return Fx.fail('Rejected');});
 const clean=G.System('clean',{},({commands})=>commands.despawnScope(scope));
 r.tick(G.Schedule(seed));r.tick(flush);record('seeded');
 const failed=r.tick(G.Schedule(failure));assert.equal(failed.ok,false);assert.equal(failed.error.error,'Rejected');
 record('failed-clean');r.tick(flush);record('failed-queue-discarded');
 r.tick(G.Schedule(clean));record('retry-pending');r.tick(flush);record('retry-applied');
 // Commands from an earlier successful system survive the later failure.
 r.tick(G.Schedule(seed));
 const failAgain=r.tick(G.Schedule(failure));assert.equal(failAgain.ok,false);
 record('earlier-spawn-pending');r.tick(flush);record('earlier-spawn-preserved');
 const other=G.Runtime.make({services:G.Runtime.services()});
 other.tick(G.Schedule(seed));other.tick(flush);
 assert.deepEqual(other.inspect(all),[1,2]);
 r.tick(G.Schedule(clean));r.tick(flush);record('final-clean');
 observations.push({root:name,label:'independent-world-retained',live:other.inspect(all)});
}
const expected=[[1,2],[1,2],[1,2],[1,2],[2],[2],[2,3,4],[2,4],[1,2]];
assert.deepEqual(observations.map(x=>x.live),[...expected,...expected]);
console.log(JSON.stringify(observations));
