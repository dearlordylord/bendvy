import assert from 'node:assert/strict';
import {Descriptor as D,Schema,Result} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
import * as C from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/Command.ts';
const calls=[];
const A=D.ConstructedComponent({result(raw){calls.push('A');return Result.success(raw.map(x=>x+1000));}})('A');
const B=D.ConstructedComponent({result(raw){calls.push('B');return Result.success(raw.map(x=>x+1000));}})('B');
const Value=D.ConstructedComponent({result(raw){calls.push('Value');return raw.valid?Result.success(raw.value):Result.failure('bad-value');}})('Value');
const Tag=D.Tag('Tag');
const G=Schema.bind(Schema.fragment({components:{A,B,Value,Tag}}));
const invalid=C.spawn(C.entryRaw(A,[11,12]),C.entryRaw(Value,{valid:false,value:17}),[Tag,{}],C.entryRaw(B,[41,42]));
assert.deepEqual(invalid.error,[null,'bad-value',null,null]);assert.deepEqual(calls,['A','Value','B']);
const valid=C.spawn(C.entryRaw(A,[11,12]),C.entryRaw(A,[31,32]),C.entryRaw(B,[41,42]),[Tag,{}],C.entryRaw(Value,{valid:true,value:17}));
assert.equal(valid.ok,true);
const q=G.Query({selection:{a:G.Query.read(A),b:G.Query.read(B),tag:G.Query.read(Tag),value:G.Query.read(Value)}});
const rows=[];const observe=G.System('observe',{queries:{q}},({queries})=>{rows.push([...queries.q.each()].map(({entity,data})=>({id:entity.id.value,a:data.a.get(),b:data.b.get(),tag:data.tag.get(),value:data.value.get()})));});
const rt=G.Runtime.make();const spawn=G.System('spawn',{},({commands})=>{commands.spawn(valid.value);});
assert.equal(rt.tick(G.Schedule(spawn,G.Schedule.applyDeferred(),observe)).ok,true);
assert.deepEqual(rows[0],[{id:1,a:[1031,1032],b:[1041,1042],tag:{},value:17}]);
// Explicit raw-JS defect boundary, not ordinary typed construction failure.
const defectDraft=C.spawn([A,[71,72]],[B,[81,82]],[Tag,{}],[Value,19]);
Object.defineProperty(defectDraft,'relations',{get(){throw new Error('after-install-defect');}});
const defect=G.System('defect',{},({commands})=>{commands.spawn(defectDraft);});let thrown;
try{rt.tick(G.Schedule(defect,G.Schedule.applyDeferred()));}catch(e){thrown=e.message;}
assert.equal(thrown,'after-install-defect');assert.equal(rt.tick(G.Schedule(observe)).ok,true);
assert.deepEqual(rows[1],[{id:1,a:[1031,1032],b:[1041,1042],tag:{},value:17},{id:2,a:[71,72],b:[81,82],tag:{},value:19}]);
console.log(JSON.stringify({invalid:invalid.error,calls,rows,thrown,boundary:'raw-JS getter defect after actual spawn installation; no capacity-error analogue'}));
