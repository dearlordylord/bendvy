import * as D from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/Decode.ts';
const ones = n => Array(n).fill(1);
const fields = Object.fromEntries(Array.from({length:64},(_,i)=>[`f${i}`,D.integer]));
const object = Object.fromEntries(Array.from({length:64},(_,i)=>[`f${i}`,i]));
const nested = D.struct({items:D.nullable(D.array(D.struct({value:D.integer})))});
const cases = [
 ['normal',D.array(D.integer),ones(3)],
 ['array128',D.array(D.integer),ones(128)],
 ['array256',D.array(D.integer),ones(256)],
 ['lateInvalid',D.array(D.integer),[...ones(127),'late-invalid']],
 ['struct64',D.struct(fields),{...object,extra:'drop-me'}],
 ['nestedNull',nested,{items:null}],
 ['nestedValid',nested,{items:[{value:1},{value:2}]}],
 ['nestedMissing',nested,{items:[{value:1},{}]}]
];
const records=cases.map(([name,codec,input])=>({name,input,result:codec.decode(input)}));
process.stdout.write(JSON.stringify(records,(_,v)=>v===undefined?{undefined:true}:v)+'\n');
