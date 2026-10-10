import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {Descriptor,Schema,Fx} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';

const values=n=>[n,n+1,n+2,n+3];
function fixture(schema,missingSecond=false) {
 const firstName=schema==='A'?'First':'Primary',secondName=schema==='A'?'Second':'Secondary';
 const First=Descriptor.Resource()(schema+'/'+firstName),Second=Descriptor.Resource()(schema+'/'+secondName);
 const Untouched=Descriptor.Resource()(schema+'/Untouched');
 const Cell=Descriptor.Component()(schema+'/Cell'),Marker=Descriptor.Component()(schema+'/Marker');
 const Event=Descriptor.Event()(schema+'/Event');
 const fragment=Schema.fragment({components:{Cell,Marker},resources:{First,Second,...(schema==='Other'?{Untouched}:{})},events:{Event}});
 const G=Schema.bind(fragment);
 const first=schema==='A'?10:30,second=schema==='A'?100:300;
 const runtime=G.Runtime.make({services:{},resources:{First:values(first),...(!missingSecond?{Second:values(second)}:{}),...(schema==='Other'?{Untouched:{values:[700,701],flags:[true,false]}}:{})},debug:true});
 let one,fail=false,peekId=0;
 const calls=[];
 // A real registered reader retains the TS stream across subsequent frames.
 // Bend's fixture has a plain retained event list and needs no such reader.
 const hold=G.System(schema+'/HoldEvents',{events:{event:G.System.readEvent(Event)}},({events})=>{assert.deepEqual(events.event.all(),[]);});
 const seed=G.System(schema+'/Seed',{events:{event:G.System.writeEvent(Event)}},({commands,events})=>{
  one=commands.spawn(G.Command.spawn([Cell,{}]));
  commands.spawn(G.Command.spawn([Cell,{}]));
  events.event.emit(91);events.event.emit(92);
 });
 const unrelated=G.System(schema+'/Unrelated',{},()=>{});
 const queue=G.System(schema+'/QueueMarker',{},({commands})=>{commands.insert(one,[Marker,99]);});
 const selected=G.System(schema+'/SelectedResources',{resources:{first:G.System.writeResource(First),second:G.System.writeResource(Second)}},({resources})=>{
  const a=resources.first.get()[0];
  resources.first.set([a+1,a+101,a+102,a+103]);
  const afterFirst=resources.first.get()[0];
  resources.first.set(values(a+2));
  const b=resources.second.get()[0];resources.second.set(values(b+10));
  calls.push({fail,observed:[a,b,afterFirst,a+2]});
  if(fail)return Fx.fail({first:a,second:b,afterFirst});
 });
 const setup=G.Schedule(hold,seed,G.Schedule.applyDeferred(),unrelated,queue);
 const run=G.Schedule(selected),barrier=G.Schedule(G.Schedule.applyDeferred());
 runtime.debug.nameSchedules({setup,run,barrier});
 assert.deepEqual(runtime.tick(setup),{ok:true,value:undefined});
 const description=()=>runtime.debug.describe().systems.map(({name,resources})=>({name,resources}));
 const metadata=description();assert.deepEqual(description(),metadata);
 const dump=()=>structuredClone(runtime.debug.dump());
 const snapshot=()=>{
  // Fresh public inspectors expose the retained event values. Their reader
  // clocks advance: this is explicit TS behavior, not Bend noninterference.
  const peek=G.Inspector(schema+'/Peek'+peekId++,{events:{event:G.System.readEvent(Event)}},({events})=>[...events.event.all()]);
  const events=runtime.inspect(peek),world=dump();
  assert.deepEqual(dump(),world);assert.deepEqual(description(),metadata);
  return {world,events};
 };
 return {G,runtime,run,barrier,calls,metadata,dump,snapshot,setFail:value=>{fail=value;}};
}

const seeded=[];
for(const schema of ['A','Other']) {
 const f=fixture(schema);const phases=[{label:'before',...f.snapshot(),calls:[]}];
 for(const [label,fail] of [['commit',false],['failure',true],['retry',false]]) {
  f.setFail(fail);const result=f.runtime.tick(f.run);
  phases.push({label,result,...f.snapshot(),calls:structuredClone(f.calls)});
 }
 const result=f.runtime.tick(f.barrier);
 phases.push({label:'barrier',result,...f.snapshot(),calls:structuredClone(f.calls)});
 seeded.push({schema,metadata:f.metadata,phases});
}

const First=Descriptor.Resource()('A/First');
let duplicate;
try {Schema.bind(Schema.fragment({resources:{First}}),Schema.fragment({resources:{First}}));}
catch(error) {duplicate=error.message;}
const provisioning=[];
for(const missingSecond of [true,false]) {
 const f=fixture('A',missingSecond),before=f.dump();
 const result=f.runtime.tryTick(f.run),after=f.dump();
 if(missingSecond)assert.deepEqual(after,before);
 provisioning.push({missingSecond,before,result,after,calls:structuredClone(f.calls)});
}
const output={seeded,duplicate,provisioning};
const serialized=JSON.stringify(output);
console.log(serialized);
assert.deepEqual(JSON.parse(serialized),JSON.parse(readFileSync(new URL('./expected.json',import.meta.url))));
