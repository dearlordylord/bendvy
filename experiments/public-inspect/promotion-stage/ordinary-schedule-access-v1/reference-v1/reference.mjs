import {Descriptor as D,Schema} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const output=[];
for(const schema of ['Alpha','Beta']){
 const First=D.Component()(schema+'/First'),Unused=D.Component()(schema+'/Unused');
 const Inventory=D.Resource()(schema+'/Inventory'),Hidden=D.Resource()(schema+'/Hidden');
 const G=Schema.bind(Schema.fragment({components:{First,Unused},resources:{Inventory,Hidden}}),Schema.defineRoot(schema));
 const runtime=G.Runtime.make({services:G.Runtime.services(),resources:{Inventory:[41,42],Hidden:[51,52]},debug:true});
 const calls=[];
 const unrelated=G.System(schema+'/Unrelated',{queries:{q:G.Query({selection:{u:G.Query.write(Unused)}})},resources:{h:G.System.writeResource(Hidden)}},()=>{calls.push('U');});
 const resource=G.System(schema+'/Resource',{resources:{inventory:G.System.readResource(Inventory)}},ctx=>{calls.push('R:'+ctx.resources.inventory.get().join(','));});
 const component=G.System(schema+'/Component',{queries:{q:G.Query({selection:{first:G.Query.read(First)}})}},()=>{calls.push('C');});
 const selected=G.Schedule(resource,G.Schedule.applyDeferred(),component);
 const tick=schedule=>{const result=runtime.tick(schedule);if(!result.ok)throw new Error(JSON.stringify(result));};
 const view=()=>{const value=runtime.debug.describe();return {systems:value.systems.map(({name,placements})=>({name,placements})),access:value.access,calls:[...calls]};};
 tick(G.Schedule(unrelated));
 runtime.debug.nameSchedules({All:G.Schedule(unrelated,resource,component)});
 const all=view();
 runtime.debug.nameSchedules({Selected:selected});
 const before=view(),repeat=view();
 tick(selected);
 const after=view();
 output.push({schema,all,before,repeat,after});
}
console.log(JSON.stringify(output));
