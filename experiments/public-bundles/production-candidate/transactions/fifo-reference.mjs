import assert from 'node:assert/strict';
import {Descriptor as D,Schema} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
import * as C from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/Command.ts';
function run(name){
 const A=D.Component()('A'),B=D.Component()('B'),Tag=D.Tag('Tag'),Value=D.Component()('Value');
 const G=Schema.bind(Schema.fragment({components:{A,B,Tag,Value}}));
 const runtime=G.Runtime.make();let id;const rows=[];
 const query=G.Query({selection:{a:G.Query.read(A),b:G.Query.read(B),tag:G.Query.read(Tag),value:G.Query.read(Value)}});
 const observe=label=>G.System(name+'-'+label,{queries:{q:query}},({queries})=>{rows.push({label,rows:[...queries.q.each()].map(({data})=>({a:data.a.get(),b:data.b.get(),tag:data.tag.get(),value:data.value.get()}))});});
 const seed=G.System(name+'-seed',{},({commands})=>{id=commands.spawn(C.spawn([A,[1031,1032]],[B,[1041,1042]],[Tag,{}],[Value,17]));});
 assert.equal(runtime.tick(G.Schedule(seed,G.Schedule.applyDeferred())).ok,true);
 const interleave=G.System(name+'-interleave',{},({commands})=>{
  commands.insert(id,[A,[1071,1072]],[A,[1091,1092]],[B,[1101,1102]],[Tag,{}],[Value,27]);
  commands.insert(id,[Value,99]);
  commands.insert(id,[A,[1171,1172]],[A,[1191,1192]],[B,[1201,1202]],[Tag,{}],[Value,37]);
 });
 assert.equal(runtime.tick(G.Schedule(interleave,observe('before'),G.Schedule.applyDeferred(),observe('after'))).ok,true);
 assert.deepEqual(rows,[{label:'before',rows:[{a:[1031,1032],b:[1041,1042],tag:{},value:17}]},{label:'after',rows:[{a:[1191,1192],b:[1201,1202],tag:{},value:37}]}]);
 return {schema:name,rows};
}
console.log(JSON.stringify([run('A'),run('B')]));
