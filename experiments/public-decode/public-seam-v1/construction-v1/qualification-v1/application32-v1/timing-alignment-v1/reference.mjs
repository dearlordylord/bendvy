// Source-only matched32 candidate; no backend/timing launch before admission.
import {Schema,Descriptor,Decode as D,Result} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const clone=value=>JSON.parse(JSON.stringify(value,(_key,value)=>value===undefined?{undefined:true}:value));
const owner=(value,sentinel=[111,222],flags=[true,false],original=value)=>({value,original,sentinel,flags});
const wrap=codec=>({result:input=>{
 const checked=codec.result(input.value);
 return checked.ok?Result.success(owner(checked.value,input.sentinel,input.flags,input.original)):checked;
},decode:input=>{
 const checked=codec.decode(input.value);
 return checked.ok?Result.success(owner(checked.value,input.sentinel,input.flags,input.original)):checked;
}});
const ones=n=>Array(n).fill(1);
const fields=Object.fromEntries(Array.from({length:64},(_,i)=>[`f${i}`,D.integer]));
const values=Object.fromEntries(Array.from({length:64},(_,i)=>[`f${i}`,i]));
const nested=D.struct({items:D.nullable(D.array(D.struct({value:D.integer})))});
const cases=[['array3',D.array(D.integer),ones(3)],['array128',D.array(D.integer),ones(128)],
 ['array256',D.array(D.integer),ones(256)],['lateInvalid',D.array(D.integer),[...ones(127),'late-invalid']],
 ['struct64',D.struct(fields),{...values,extra:'drop-me'}],['nullableNull',nested,{items:null}],
 ['nestedValid',nested,{items:[{value:1},{value:2}]}],['nestedMissing',nested,{items:[{value:1},{}]}]];
function actual(root,operation,name,codec,raw){
 const Value=Descriptor.ConstructedComponent(wrap(codec))('Value');
 const Resource=Descriptor.ConstructedResource(wrap(codec))('Resource');
 const Marker=Descriptor.TransientComponent()('Marker');
 const G=Schema.bind(Schema.fragment({components:{Value,Marker},resources:{Resource}}),Schema.defineRoot(root));
 const seedRaw=name.startsWith('array')||name==='lateInvalid'?[]:name==='struct64'?values:{items:null};
 const made=G.Runtime.make({resources:{Resource:owner(seedRaw,[555,666],[false,true])},debug:true});
 if(!made.ok)throw Error('runtime make refused');
 const runtime=made.value;let id,checked;
 const tick=(...steps)=>{const result=runtime.tick(G.Schedule(...steps));if(!result.ok)throw Error(JSON.stringify(result));};
 tick(G.System('seed',{},({commands})=>{
  id=commands.spawn(G.Command.spawn([Value,owner(9,[333,444],[false,true])]));
 }),G.Schedule.applyDeferred());
 tick(G.System('queue',{},({commands})=>{commands.insert(id,[Marker,1]);}));
 const incoming=owner(raw),original=clone(incoming),before=clone(runtime.debug.dump());
 const selection=G.Query({selection:{value:G.Query.write(Value)}});
 if(operation==='insert')tick(G.System('replace',{queries:{selection}},({queries})=>{
  const rows=queries.selection.each();if(rows.length!==1)throw Error('seed selection differs');
  checked=queries.selection.each()[0].data.value.setRaw(incoming);
 }));
 else if(operation==='resource')tick(G.System('resource',{resources:{resource:G.System.writeResource(Resource)}},({resources})=>{checked=resources.resource.setRaw(incoming);}));
 else tick(G.System('spawn',{},({commands})=>{
  checked=G.Command.entryRaw(Value,incoming);
  if(checked.ok)commands.spawn(G.Command.spawn(checked.value));
 }));
 const after=clone(runtime.debug.dump());tick(G.Schedule.applyDeferred());
 return {root,operation,name,original,checked:clone(checked),incomingAfter:clone(incoming),before,after,flushed:clone(runtime.debug.dump())};
}

export function run(){
 const traces=[];for(const operation of ['insert','spawn','resource'])for(const [name,codec,raw] of cases)traces.push(actual('Workshop',operation,name,codec,raw));
 for(const [name,codec,raw] of cases)traces.push(actual('Garden','insert',name,codec,raw));
 return traces;
}
