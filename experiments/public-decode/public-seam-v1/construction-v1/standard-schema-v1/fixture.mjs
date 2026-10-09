import * as Host from './adapter.mjs';
import * as TS from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/Descriptor.ts';

// Source-only until this exact reference command/input closure is admitted.
// Both sides consume the same independent scenario, never each other's output.
const schema = validate => ({'~standard':{version:1,vendor:'fixture',validate}});
const symbol=Symbol('opaque-path');
const encode = value => {
  if(value === undefined)return {kind:'undefined'};
  if(typeof value==='symbol')return {kind:'symbol',description:value.description};
  if(Array.isArray(value))return value.map(encode);
  if(value !== null && typeof value==='object')return Object.fromEntries(Object.entries(value).map(([k,v])=>[k,encode(v)]));
  return value;
};
const cases=[
  ['transform',schema(value=>({value:{count:value.count+1}})),{count:7}],
  ['undefined',schema(()=>({value:undefined})),null],
  ['null',schema(()=>({value:null})),0],
  ['empty-issues',schema(()=>({issues:[]})),0],
  ['nested-issues',schema(()=>({issues:[{message:'nested',path:['items',1,{key:'value'},{key:symbol},symbol]}]})),{}],
  ['resolved-promise',schema(()=>Promise.resolve({value:7})),0],
  ['rejected-promise',schema(()=>Promise.reject(new Error('discarded'))),0],
  ['thenable',schema(()=>({then(){},value:9})),0],
];
const observe = (name, adapter, s, input) => {
  const constructor=adapter(s);
  const result=constructor.result(input);
  return {name,sameFunctions:constructor.result===constructor.decode,result:encode(result)};
};
const host=cases.map(([n,s,i])=>observe(n,Host.fromStandardSchema,s,i));
const ts=cases.map(([n,s,i])=>observe(n,TS.fromStandardSchema,s,i));
const issues=[{message:'same-owner',path:[symbol]}];
const identitySchema=schema(()=>({issues}));
const issueIdentity={host:Host.fromStandardSchema(identitySchema).decode(0).error===issues,
  ts:TS.fromStandardSchema(identitySchema).decode(0).error===issues};
const dispatch=[
  {result:()=>({ok:true,value:'result'}),decode:()=>({ok:true,value:'decode'})},
  {result:()=>({ok:true,value:'fallback'})},
  {result:()=>({ok:true,value:'nonfunction-fallback'}),decode:0},
].map((constructor,index)=>({index,
  host:Host.constructorDecoderOf(constructor)(0),
  ts:TS.decoderOf(TS.ConstructedComponent(constructor)(`dispatch-${index}`))(0)}));
const thrown=[];
for(const [name,adapter] of [['host',Host.fromStandardSchema],['ts',TS.fromStandardSchema]]){
  const sentinel=new Error('validator-throw');let same=false;
  try{adapter(schema(()=>{throw sentinel;})).decode(0);}catch(error){same=error===sentinel;}
  thrown.push({name,same});
}
const number=value=>({$:'Number',value});
const boundary={input:raw=>raw.value,output:number,issues:errors=>({$:'Text',value:errors.map(x=>x.message).join('|')})};
const accepted=Host.typedRawConstructor(schema(value=>({value:value+1})),boundary).decode(number(7));
const incoming=number(7);
const refused=Host.typedRawConstructor(identitySchema,boundary).decode(incoming);
const typed={accepted:encode(accepted),acceptedFrozen:Object.isFrozen(accepted.value),
  refused:{ok:refused.ok,input:refused.input,error:refused.error,issues:encode(refused.issues)},
  detached:refused.input!==incoming,unchanged:incoming.value===7,issuesIdentity:refused.issues===issues};
// Actual representation/provider boundaries, including handle namespace retention.
const valid=[{$:'Missing'},{$:'Null'},number(0),number(0xffffffff),
  {$:'SignedInteger',negative:true,magnitude:2**48-1},{$:'Float',value:Math.fround(1.1)},
  {$:'Binary64',high:0x80000000,low:0},{$:'Text',value:'x'},{$:'Utf16Text',units:[0xd800]},
  {$:'Boolean',value:false},{$:'Handle',namespace:2,id:1},{$:'Array',items:[number(1)]},
  {$:'Object',fields:[{$:'Field',name:'x',value:number(7)}]}];
const cycle={$:'Array',items:[]};cycle.items.push(cycle);
const accessor={$:'Number'};Object.defineProperty(accessor,'value',{get(){throw new Error('must not execute');},enumerable:true});
const invalid=[null,{$:'Unknown'},{$:'Number',value:-1},{$:'Number',value:2**32},
  {$:'SignedInteger',negative:false,magnitude:2**48},{$:'Float',value:1.1},
  {$:'Handle',namespace:2,id:1,extra:0},{$:'Array',items:Array(1)},cycle,accessor,
  Object.assign(Object.create({}),number(1))];
const representation={valid:valid.map(raw=>({raw:encode(raw),same:Host.checkedRaw(raw)===raw})),
  invalid:invalid.map((raw,index)=>{try{Host.checkedRaw(raw);return {index,rejected:false};}catch(error){return {index,rejected:error instanceof TypeError};}})};
const badProviders=[];
for(const [name,b] of [['output',{...boundary,output:()=>({$:'Number',value:-1})}],
  ['issues',{...boundary,issues:()=>({$:'Unknown'})}]]){
  try{Host.typedRawConstructor(name==='output'?schema(()=>({value:1})):identitySchema,b).decode(number(7));badProviders.push({name,rejected:false});}
  catch(error){badProviders.push({name,rejected:error instanceof TypeError});}
}
// Allow the adapter's attached Promise catch handlers to settle before output.
await Promise.resolve();
process.stdout.write(JSON.stringify({host,ts,issueIdentity,dispatch,thrown,typed,representation,badProviders})+'\n');
