import assert from 'node:assert/strict';
import {Descriptor as D,Schema,Result} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
import * as C from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/Command.ts';
function run(schema){
 const calls=[],snapshots=[];
 const Head=D.Component()('supplied-array');
 const Tail=D.ConstructedComponent({result(raw){calls.push('tail');return raw.scalar===31?Result.failure('ConstructorBlocked'):Result.success(raw);}})('canonical-tail');
 const Tag=D.Tag('canonical-tag'),Data=D.Component()('canonical-data');
 Schema.bind(Schema.fragment({components:{Head,Tail,Tag,Data}}));
 const owner={owned:[11,12],number:7},tail={owned:[21,22,23,24],tag:true,scalar:32};
 const base=C.spawn(C.entry(Tag,{}),C.entry(Data,101));
 const components=draft=>draft.components.map(([descriptor,value])=>({family:descriptor.name,value}));
 function construct(label,input,provided,data){
  const before=calls.length,head=C.entryResult(Head,provided),t=C.entryRaw(Tail,input.tail);
  const result=C.spawn(head,t,C.entry(Tag,{}),C.entry(Data,data));
  const inserted=C.insert(base,head,t);
  assert.deepEqual(calls.slice(before),['tail']);
  snapshots.push({label,calls:[...calls],supplied:{state:provided.ok?'Ready':'Rejected',owner:input.head,error:provided.ok?null:provided.error},raw:{head:input.head,tail:input.tail,tag:{},data},positions:result.ok?[null,null,null,null]:result.error,cooked:result.ok?components(result.value):null,insertPositions:inserted.ok?[null,null]:inserted.error,inserted:inserted.ok?components(inserted.value):null,retainedBase:components(base)});
  return result;
 }
 const first=construct('refused',{head:owner,tail},Result.failure('ConstructorBlocked'),101);assert.equal(first.ok,false);assert.deepEqual(first.error,['ConstructorBlocked',null,null,null]);
 const repaired=construct('repaired',{head:owner,tail},Result.success(owner),101);assert.equal(repaired.ok,true);assert.equal(repaired.value.components[0][1],owner);assert.equal(owner.owned[0],11);
 const next={owned:[41,42],number:17},nextTail={owned:[51,52,53,54],tag:false,scalar:61};assert.equal(construct('replacement',{head:next,tail:nextTail},Result.success(next),202).ok,true);
 return {schema,snapshots};
}
console.log(JSON.stringify([run('A'),run('B')]));
