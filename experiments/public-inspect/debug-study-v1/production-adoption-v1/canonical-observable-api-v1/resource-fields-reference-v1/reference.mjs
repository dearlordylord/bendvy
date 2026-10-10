import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {Descriptor,Schema,Fx} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const output=[];
for(const schema of ['A','Other']) for(const mode of ['write','read']) {
 const firstName=schema==='A'?'First':'Primary',secondName=schema==='A'?'Second':'Secondary';
 const First=Descriptor.Resource()(schema+'/'+firstName),Second=Descriptor.Resource()(schema+'/'+secondName),Untouched=Descriptor.Resource()(schema+'/Untouched');
 const resourceDescriptors={First,Second,...(schema==='Other'?{Untouched}:{})};
 const G=Schema.bind(Schema.fragment({resources:resourceDescriptors}));
 const first=schema==='A'?10:30,second=schema==='A'?100:300;
 const values=n=>[n,n+1,n+2,n+3];
 const runtime=G.Runtime.make({services:{},resources:{First:values(first),Second:values(second),...(schema==='Other'?{Untouched:{values:[700,701],flags:[true,false]}}:{})},debug:true});
 let fail=false;
 const calls=[];
 const access=mode==='write'?G.System.writeResource:G.System.readResource;
 const system=G.System(schema+'/SelectedResources',{resources:{first:access(First),second:access(Second)}},({resources})=>{
  const before=resources.first.get()[0];
  if(mode==='write')resources.first.set([before+1,before+101,before+102,before+103]);
  const afterFirst=resources.first.get()[0];
  if(mode==='write')resources.first.set(values(before+2));
  const sibling=resources.second.get()[0];
  if(mode==='write')resources.second.set(values(sibling+10));
  const observed=mode==='read'?[before,sibling,before,sibling]:[before,sibling,afterFirst,before+2];
  calls.push({fail,observed});
  if(mode==='write'&&fail)return Fx.fail({first:before,second:sibling,afterFirst});
 });
 const schedule=G.Schedule(system);
 runtime.debug.nameSchedules({run:schedule});
 const peek=G.Inspector(schema+'/Peek',{resources:{first:G.System.readResource(First),second:G.System.readResource(Second),...(schema==='Other'?{untouched:G.System.readResource(Untouched)}:{})}},({resources})=>({first:structuredClone(resources.first.get()),second:structuredClone(resources.second.get()),...(schema==='Other'?{untouched:structuredClone(resources.untouched.get())}:{})}));
 const state=()=>runtime.inspect(peek);
 const metadata=()=>runtime.debug.describe().systems.map(({name,placements,resources})=>({name,placements,resources}));
 const before=state(),description=metadata();
 assert.deepEqual(metadata(),description);assert.deepEqual(state(),before);
 const phases=[];
 for(const [label,input] of [['commit',false],['failure-input',true],['retry',false]]) {
  fail=input;const result=runtime.tick(schedule),current=state();
  assert.deepEqual(metadata(),description);assert.deepEqual(metadata(),description);assert.deepEqual(state(),current);
  phases.push({label,result,state:current,calls:structuredClone(calls)});
 }
 output.push({schema,mode,before,description,phases});
}
const serialized=JSON.stringify(output);
console.log(serialized);
assert.deepEqual(JSON.parse(serialized),JSON.parse(readFileSync(new URL('./expected.json',import.meta.url))));
