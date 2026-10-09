// Preparation only: parent admission is required before running this reference.
import {Schema,Descriptor,Decode as D,Result} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const clone=value=>JSON.parse(JSON.stringify(value,(_key,value)=>value===undefined?{undefined:true}:value));
const owner=(value,sentinel=[111,222])=>({value,sentinel});
const wrap=codec=>({result:input=>{
 const checked=codec.result(input.value);
 return checked.ok?Result.success(owner(checked.value,input.sentinel)):checked;
},decode:input=>{
 const checked=codec.decode(input.value);
 return checked.ok?Result.success(owner(checked.value,input.sentinel)):checked;
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
 const made=G.Runtime.make({resources:{Resource:owner(seedRaw,[555,666])},debug:true});
 if(!made.ok)throw Error('runtime make refused');
 const runtime=made.value;let id,checked;
 const tick=(...steps)=>{const result=runtime.tick(G.Schedule(...steps));if(!result.ok)throw Error(JSON.stringify(result));};
 tick(G.System('seed',{},({commands})=>{
  id=commands.spawn(G.Command.spawn([Value,owner(9,[333,444])]));
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
function foreignWorld(){
 const Value=Descriptor.ConstructedComponent(wrap(D.struct(fields)))('Value');
 const Marker=Descriptor.TransientComponent()('Marker');
 const G=Schema.bind(Schema.fragment({components:{Value,Marker}}),Schema.defineRoot('ForeignWorkshop'));
 const create=()=>G.Runtime.make({resources:{},debug:true});
 const first=create(),second=create();let firstId,secondId;
 const tick=(runtime,...steps)=>{const r=runtime.tick(G.Schedule(...steps));if(!r.ok)throw Error(JSON.stringify(r));};
 tick(first,G.System('first-seed',{},({commands})=>{firstId=commands.spawn(G.Command.spawn([Value,owner('first',[777,888])]));}),G.Schedule.applyDeferred());
 tick(second,G.System('second-seed',{},({commands})=>{secondId=commands.spawn(G.Command.spawn([Value,owner(9,[333,444])]));}),G.Schedule.applyDeferred());
 const foreign=G.Entity.handle(firstId,Value);
 tick(second,G.System('queue',{},({commands})=>{commands.insert(secondId,[Marker,1]);}));
 const original=owner({...values,extra:'drop-me'}),before={first:clone(first.debug.dump()),second:clone(second.debug.dump())};
 const query=G.Query({selection:{value:G.Query.write(Value)}});let lookupResult,checked;
 tick(second,G.System('foreign-replace',{queries:{query}},({lookup})=>{
  const found=lookup.getHandle(foreign,query);
  lookupResult=found.ok?{ok:true,id:found.value.entity.id.value}:clone(found);
  if(found.ok)checked=found.value.data.value.setRaw(original);
 }));
 const after={first:clone(first.debug.dump()),second:clone(second.debug.dump())};
 tick(second,G.Schedule.applyDeferred());
 return {firstId:firstId.value,secondId:secondId.value,foreign:clone(foreign),original:clone(original),lookup:lookupResult,checked:clone(checked),before,after,flushed:{first:clone(first.debug.dump()),second:clone(second.debug.dump())}};
}
function selectors(){
 const integer=D.integer,bool=D.boolean;
 const descriptor=Descriptor.ConstructedResource({result:integer.result,decode:bool.decode})('Selected');
 const Plain=Descriptor.Resource()('Plain'),Transient=Descriptor.TransientResource()('Transient');
 const G=Schema.bind(Schema.fragment({resources:{Selected:descriptor,Plain,Transient}}),Schema.defineRoot('Selectors'));
 return {initializeBoolean:G.Runtime.make({resources:{Selected:true}}),initializeInteger:G.Runtime.make({resources:{Selected:7},debug:true}),
  plain:G.Runtime.make({resources:{Plain:'plain-value'},debug:true}).debug.dump().resources.Plain==='plain-value',transient:G.Runtime.make({resources:{Transient:false},debug:true}).debug.dump().resources.Transient===false,
  loadBoolean:Descriptor.decoderOf(descriptor)(true),fallbackBoolean:Descriptor.decoderOf(Descriptor.ConstructedResource({result:integer.result})('Fallback'))(true),
  literalReady:D.struct({kind:D.literal('ready')}).decode({kind:'ready',extra:99}),
  literalBusy:D.struct({kind:D.literal('ready')}).decode({kind:'busy'}),
  handles:[{kind:'EntityHandle',value:1,namespace:1},{kind:'EntityHandle',value:1,namespace:2},{kind:'EntityHandle',value:0},'not-handle'].map(value=>D.struct({target:D.handle('Selectors')}).decode({target:value}))};
}
// Runtime values contain methods; initializeInteger is reduced to its complete public dump.
const selected=selectors();if(selected.initializeInteger.ok)selected.initializeInteger={ok:true,dump:clone(selected.initializeInteger.value.debug.dump())};
const traces=[];for(const operation of ['insert','spawn','resource'])for(const [name,codec,raw] of cases)traces.push(actual('Workshop',operation,name,codec,raw));
for(const [name,codec,raw] of cases)traces.push(actual('Garden','insert',name,codec,raw));
process.stdout.write(JSON.stringify({traces,selectors:selected,foreign:foreignWorld()},(_key,value)=>value===undefined?{undefined:true}:value)+'\n');
