import {Descriptor as D,Schema,Entity} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
function run(label){
 const Sibling=D.Resource()('Sibling');
 const G=Schema.bind(Schema.fragment({resources:{Sibling}}));
 const sibling=[[31,32],[41,42]],runtime=G.Runtime.make({resources:{Sibling:sibling}});
 const draft=G.Command.spawn(),insertedDraft=G.Command.insert(draft);
 const staged=d=>({id:d.id.value,proof:d.proof,components:d.components.map(([k,v])=>[k.name,v]),relations:d.relations});
 const checkpoints=[],statuses=[],all=G.Query({selection:{}});let handle;
 const observe=name=>G.System(label+'-'+name,{queries:{all},resources:{sibling:G.System.readResource(Sibling)}},({queries,resources})=>{
  checkpoints.push({label:name,entities:[...queries.all.each()].map(({entity})=>entity.id.value),sibling:resources.sibling.get(),sameSibling:resources.sibling.get()===sibling});
 });
 const spawn=G.System(label+'-spawn',{},({commands})=>{handle=commands.spawn(draft);});
 const insert=G.System(label+'-insert',{},({commands})=>{const returned=commands.insert(handle);statuses.push({operation:'insert-return',same:returned===handle,id:returned.value});});
 const missing=G.System(label+'-missing',{},({commands})=>{const target=Entity.makeEntityId(999),returned=commands.insert(target);statuses.push({operation:'missing-return',same:returned===target,id:returned.value});});
 const tick=schedule=>{const result=runtime.tick(schedule);statuses.push({operation:'tick',ok:result.ok});};
 tick(G.Schedule(observe('before'),spawn,observe('spawn-queued'),G.Schedule.applyDeferred(),observe('spawn-barrier'),G.Schedule.applyDeferred(),observe('spawn-second-barrier')));
 tick(G.Schedule(insert,observe('insert-queued'),G.Schedule.applyDeferred(),observe('insert-barrier'),G.Schedule.applyDeferred(),observe('insert-second-barrier')));
 tick(G.Schedule(missing,observe('missing-queued'),G.Schedule.applyDeferred(),observe('missing-barrier'),G.Schedule.applyDeferred(),observe('missing-second-barrier')));
 return {schema:label,draft:staged(draft),insertedDraft:staged(insertedDraft),draftDistinct:insertedDraft!==draft,handle:handle.value,statuses,checkpoints};
}
console.log(JSON.stringify(['First','Second'].map(run)));
