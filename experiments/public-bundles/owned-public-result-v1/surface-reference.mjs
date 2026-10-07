import assert from 'node:assert/strict';
import {Descriptor as D,Schema,Result,Fx} from '../../../.references/bevy-ts/packages/core/src/index.ts';
import * as C from '../../../.references/bevy-ts/packages/core/src/Command.ts';
function run(schema,mode){
 const calls=[];
 const Stock=D.ConstructedComponent({result(raw){calls.push(0);return Result.success(raw.map(x=>x+1000));}})('Stock');
 const Value=D.ConstructedComponent({result(raw){calls.push(1);return raw.valid?Result.success(raw.value):Result.failure('bad-1');}})('Value');
 const Queue=D.ConstructedComponent({result(raw){calls.push(3);return raw.valid?Result.success({front:raw.front.map(x=>x+1000),back:raw.back.map(x=>x+1000),queued:raw.queued}):Result.failure('bad-3');}})('Queue');
 const Back=D.Component()('Back'),Tag=D.Tag('Tag');
 const G=Schema.bind(Schema.fragment({components:{Stock,Value,Queue,Back,Tag}}));
 const runtime=G.Runtime.make(),checkpoints=[];
 const input=(replacement=false,invalid=false)=>({stock:replacement?[71,72]:[11,12],value:{valid:true,value:replacement?27:17},tag:{},queue:{valid:!invalid,front:replacement?[91,92]:[31,32],back:replacement?[101,102]:[41,42],queued:[replacement?[111,112]:[51,52]]}});
 const construct=raw=>C.spawn(C.entryRaw(Stock,raw.stock),C.entryRaw(Value,raw.value),[Tag,raw.tag],C.entryRaw(Queue,raw.queue));
 const flatten=draft=>{
  const get=d=>draft.components.find(([descriptor])=>descriptor===d)[1],q=get(Queue);
  return [[Stock,get(Stock)],[Stock,q.front],[Back,q.back],[Tag,get(Tag)],[Value,get(Value)]];
 };
 const read=G.Query({selection:{stock:G.Query.read(Stock),back:G.Query.read(Back),tag:G.Query.read(Tag),value:G.Query.read(Value)}});
 const write=G.Query({selection:{stock:G.Query.write(Stock)}});
 const observe=label=>G.System(schema+'-'+mode+'-'+label,{queries:{q:read}},({queries})=>{checkpoints.push({label,rows:[...queries.q.each()].map(({entity,data})=>({id:entity.id.value,stock:data.stock.get(),back:data.back.get(),tag:data.tag.get(),value:data.value.get()}))});});
 const seed=G.System(schema+'-'+mode+'-seed',{},({commands})=>{const draft=construct(input());assert.equal(draft.ok,true);commands.spawn(C.spawn(...flatten(draft.value)));});
 assert.equal(runtime.tick(G.Schedule(seed,G.Schedule.applyDeferred())).ok,true);
 let refusal=null,handles=null,retryIdentity=null;
 const work=G.System(schema+'-'+mode+'-work',{queries:{q:write}},({queries,commands})=>{
  for(const {data} of queries.q.each())data.stock.set([501,502]);
  const raw=input(false,mode.startsWith('invalid'));
  const original={stock:raw.stock,front:raw.queue.front,back:raw.queue.back,queued:raw.queue.queued};
  let draft=construct(raw);
  if(!draft.ok){
   refusal={errors:draft.error,raw:JSON.parse(JSON.stringify(raw))};
   if(mode==='invalid-return')return;
   raw.queue.valid=true;
   retryIdentity=raw.stock===original.stock&&raw.queue.front===original.front&&raw.queue.back===original.back&&raw.queue.queued===original.queued;
   assert.equal(retryIdentity,true);draft=construct(raw);
  }
  assert.equal(draft.ok,true);
  const spawned=commands.spawn(C.spawn(...flatten(draft.value)));
  if(mode==='cleanup')commands.despawn(spawned);
  const replacement=construct(input(true));assert.equal(replacement.ok,true);
  const inserted=commands.insert(spawned,...flatten(replacement.value));
  handles={spawned:spawned.value,inserted:inserted.value};assert.equal(handles.spawned,handles.inserted);
  if(mode==='rollback')return Fx.fail('body-failed');
 });
 const workResult=runtime.tick(G.Schedule(work));
 assert.equal(workResult.ok,mode!=='rollback');
 assert.equal(runtime.tick(G.Schedule(observe('before'),G.Schedule.applyDeferred(),observe('after'))).ok,true);
 return {schema,mode,work:{ok:workResult.ok,...(!workResult.ok?{kind:workResult.error.kind,error:workResult.error.error}:{})},refusal,handles,retryIdentity,calls,checkpoints};
}
console.log(JSON.stringify(['A','B'].flatMap(schema=>['spawn-insert','invalid-return','invalid-retry','rollback','cleanup'].map(mode=>run(schema,mode)))));
