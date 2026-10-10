import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {Descriptor,Schema,Fx} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const output=[];
for(const schema of ['ResourceA','ResourceOther']) for(const entities of [0,2]) for(const enabled of [true,false]) {
 const Counter=Descriptor.Resource()(schema+'/Counter'),Tag=Descriptor.Component()(schema+'/Tag');
 const G=Schema.bind(Schema.fragment({resources:{Counter},components:{Tag}}));
 const runtime=G.Runtime.make({resources:{Counter:10},debug:enabled});
 const calls=[];
 const Seed=G.System(schema+'/Seed',{},({commands})=>{for(let i=0;i<entities;i++)commands.spawn(G.Command.spawn([Tag,i+7]));});
 const Increment=G.System(schema+'/Increment',{resources:{counter:G.System.writeResource(Counter)}},({resources})=>{calls.push({body:'increment',prior:resources.counter.get()});resources.counter.update(x=>x+1);});
 const Fail=G.System(schema+'/Fail',{resources:{counter:G.System.writeResource(Counter)}},({resources})=>{calls.push({body:'fail',prior:resources.counter.get()});resources.counter.update(x=>x+1);return Fx.fail('ExpectedFailure');});
 const setup=G.Schedule(Seed,G.Schedule.applyDeferred()),success=G.Schedule(Increment),failure=G.Schedule(Fail);
 const query=G.Query({selection:{tag:G.Query.read(Tag)}});
 const peek=G.Inspector(schema+'/Peek',{queries:{query},resources:{counter:G.System.readResource(Counter)}},({queries,resources})=>({counter:resources.counter.get(),rows:queries.query.each().map(({entity,data})=>({id:entity.id.value,tag:data.tag.get()}))}));
 assert.equal(runtime.tick(setup).ok,true);
 assert.equal(Object.hasOwn(runtime,'debug'),enabled);
 const state=()=>runtime.inspect(peek);
 const describe=()=>{
  const d=runtime.debug.describe();
  return {components:d.components,resources:d.resources,schedules:d.schedules,systems:d.systems.map(s=>({name:s.name,placements:s.placements,queries:s.queries,resources:s.resources}))};
 };
 if(enabled)runtime.debug.nameSchedules({success,failure});
 const before=state(),description=enabled?describe():null;
 if(enabled){assert.deepEqual(describe(),description);assert.deepEqual(state(),before);}
 const phases=[];
 for(const [label,schedule] of [['success',success],['failure',failure],['retry',success]]) {
  const result=runtime.tick(schedule),current=state();
  if(enabled){assert.deepEqual(describe(),description);assert.deepEqual(describe(),description);assert.deepEqual(state(),current);}
  phases.push({label,result,state:current,calls:structuredClone(calls)});
 }
 output.push({schema,entities,enabled,debugHandle:enabled,description,before,phases});
}
const serialized=JSON.stringify(output);
console.log(serialized);
assert.deepEqual(JSON.parse(serialized),JSON.parse(readFileSync(new URL('./expected.json',import.meta.url))));
