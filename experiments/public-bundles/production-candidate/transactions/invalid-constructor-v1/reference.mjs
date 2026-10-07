import assert from 'node:assert/strict';
import {Descriptor as D,Schema,Result} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
import * as C from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/Command.ts';
function run(schema,action,retry){
 const calls=[];
 const Stock=D.ConstructedComponent({result(raw){calls.push(0);return Result.success(raw.map(x=>x+1000));}})('Stock');
 const Value=D.ConstructedComponent({result(raw){calls.push(1);return raw.valid?Result.success(raw.value):Result.failure('bad-1');}})('Value');
 const Queue=D.ConstructedComponent({result(raw){calls.push(3);return raw.valid?Result.success({front:raw.front.map(x=>x+1000),back:raw.back.map(x=>x+1000),queued:raw.queued}):Result.failure('bad-3');}})('Queue');
 const Back=D.Component()('Back'),Tag=D.Tag('Tag');
 const G=Schema.bind(Schema.fragment({components:{Stock,Value,Queue,Back,Tag}}));
 const runtime=G.Runtime.make();let id;const checkpoints=[];
 const raw=(a,b,value,validValue=true,validQueue=true)=>({stock:a,value:{valid:validValue,value},tag:{},queue:{valid:validQueue,front:b[0],back:b[1],queued:[b[2]]}});
 const initial=()=>raw([11,12],[[31,32],[41,42],[51,52]],17);
 const replacement=()=>raw([71,72],[[91,92],[101,102],[111,112]],27);
 const construct=input=>C.spawn(C.entryRaw(Stock,input.stock),C.entryRaw(Value,input.value),[Tag,input.tag],C.entryRaw(Queue,input.queue));
 const flatten=draft=>{
  const get=d=>draft.components.find(([descriptor])=>descriptor===d)[1];const q=get(Queue);
  return [[Stock,get(Stock)],[Stock,q.front],[Back,q.back],[Tag,get(Tag)],[Value,get(Value)]];
 };
 const read=G.Query({selection:{stock:G.Query.read(Stock),back:G.Query.read(Back),tag:G.Query.read(Tag),value:G.Query.read(Value)}});
 const write=G.Query({selection:{stock:G.Query.write(Stock)}});
 const observe=label=>G.System(schema+'-'+action+'-'+retry+'-'+label,{queries:{q:read}},({queries})=>{checkpoints.push({label,rows:[...queries.q.each()].map(({entity,data})=>({id:entity.id.value,stock:data.stock.get(),back:data.back.get(),tag:data.tag.get(),value:data.value.get()}))});});
 const seed=G.System(schema+'-'+action+'-'+retry+'-seed',{},({commands})=>{const result=construct(initial());assert.equal(result.ok,true);id=commands.spawn(C.spawn(...flatten(result.value)));});
 assert.equal(runtime.tick(G.Schedule(seed,G.Schedule.applyDeferred())).ok,true);
 let refusal,retried=null;
 const work=G.System(schema+'-'+action+'-'+retry+'-work',{queries:{q:write}},({queries,commands})=>{
  for(const {data} of queries.q.each())data.stock.set([501,502]);
  const prior=construct(replacement());assert.equal(prior.ok,true);commands.insert(id,...flatten(prior.value));
  const input=initial();input.value.valid=action==='insert';input.queue.valid=false;
  const original={stock:input.stock,front:input.queue.front,back:input.queue.back,queued:input.queue.queued};
  const invalid=construct(input);assert.equal(invalid.ok,false);
  const errors=action==='spawn'?[null,'bad-1',null,'bad-3']:[null,null,null,'bad-3'];assert.deepEqual(invalid.error,errors);
  refusal={errors:invalid.error,calls:[...calls],raw:JSON.parse(JSON.stringify(input))};
  // Invalid Result never reaches the actual command queue. The same caller's
  // actual raw objects remain available; JS identity is not affine ownership.
  if(retry){
   input.value.valid=true;input.queue.valid=true;
   assert.equal(input.stock,original.stock);assert.equal(input.queue.front,original.front);assert.equal(input.queue.back,original.back);assert.equal(input.queue.queued,original.queued);
   const fixed=construct(input);assert.equal(fixed.ok,true);
   const target=action==='spawn'?commands.spawn(C.spawn(...flatten(fixed.value))):commands.insert(id,...flatten(fixed.value));
   retried={sameRawObjects:true,id:target.value,calls:[...calls],raw:JSON.parse(JSON.stringify(input))};
  }
 });
 assert.equal(runtime.tick(G.Schedule(work,observe('before'),G.Schedule.applyDeferred(),observe('after'))).ok,true);
 return {schema,action,retry,refusal,retried,checkpoints};
}
console.log(JSON.stringify(['A','B'].flatMap(schema=>['spawn','insert'].flatMap(action=>[run(schema,action,false),run(schema,action,true)]))));
