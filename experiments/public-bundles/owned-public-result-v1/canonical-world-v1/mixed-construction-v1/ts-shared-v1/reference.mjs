import assert from 'node:assert/strict';
import {Descriptor as D,Schema,Result} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
import * as C from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/Command.ts';
function run(schema){
 const calls=[],heads=[],snapshots=[];
 const Head=D.ConstructedComponent({result(raw){calls.push('head');if(typeof raw.wire!=='number'||!Number.isFinite(raw.wire))return Result.failure('ValidationFiniteNumber');if(raw.fail)return Result.failure('ConstructorBlocked');const cooked={owned:raw.owned,number:raw.wire};heads.push(cooked);return Result.success(cooked);}})('constructed-array');
 const Tail=D.ConstructedComponent({result(raw){calls.push('tail');return raw.scalar===31?Result.failure('ConstructorBlocked'):Result.success(raw);}})('canonical-tail');
 const Tag=D.Tag('canonical-tag'),Data=D.Component()('canonical-data');
 Schema.bind(Schema.fragment({components:{Head,Tail,Tag,Data}}));
 const raw={head:{owned:[11,12],wire:7,fail:false},tail:{owned:[21,22,23,24],tag:true,scalar:31},tag:{},data:101};
 const originals={head:raw.head.owned,tail:raw.tail.owned};
 function construct(label,input){
  const before=calls.length,result=C.spawn(C.entryRaw(Head,input.head),C.entryRaw(Tail,input.tail),C.entry(Tag,input.tag),C.entry(Data,input.data));
  assert.deepEqual(calls.slice(before),['head','tail']);
  if(input===raw){assert.equal(input.head.owned,originals.head);assert.equal(input.tail.owned,originals.tail);}
  snapshots.push({label,calls:[...calls],raw:{head:{owned:[...input.head.owned],wire:input.head.wire,fail:input.head.fail},tail:{owned:[...input.tail.owned],tag:input.tail.tag,scalar:input.tail.scalar},tag:{},data:input.data},positions:result.ok?[null,null,null,null]:result.error,cooked:result.ok?result.value.components.map(([descriptor,value])=>({family:descriptor.name,value})):null,retainedSuccessfulHeads:heads.map(owner=>({owned:[...owner.owned],number:owner.number}))});return result;
 }
 const first=construct('refused-prefix',raw);assert.equal(first.ok,false);assert.deepEqual(first.error,[null,'ConstructorBlocked',null,null]);assert.equal(heads[0].owned,originals.head);
 raw.head.wire='bad';const second=construct('refused-both',raw);assert.equal(second.ok,false);assert.deepEqual(second.error,['ValidationFiniteNumber','ConstructorBlocked',null,null]);
 raw.head.wire=9;raw.tail.scalar=32;assert.equal(construct('repaired',raw).ok,true);
 const replacement={head:{owned:[41,42],wire:17,fail:false},tail:{owned:[51,52,53,54],tag:false,scalar:61},tag:{},data:202};assert.equal(construct('replacement',replacement).ok,true);
 return {schema,snapshots};
}
console.log(JSON.stringify([run('A'),run('B')]));
