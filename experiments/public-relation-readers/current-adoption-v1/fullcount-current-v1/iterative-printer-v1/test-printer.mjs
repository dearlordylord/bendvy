import assert from 'node:assert/strict';
import {show_val as original} from './original-printer.mjs';
import {show_val as iterative} from './printer.mjs';
import {f32_show,show_chr} from './primitive-helpers.mjs';
globalThis.f32_show=f32_show;globalThis.show_chr=show_chr;
const D=[0,1,2,3,4,5],N=[];
function adt(rows){const d=D.length;D.push(7,1,rows.length);for(const[name,style,fields]of rows){let n=N.indexOf(name);if(n<0){n=N.length;N.push(name);}D.push(n,0,fields.length,style);for(const f of fields)D.push(0,f);}return d;}
const list=D.length;adt([['Nil',1,[]],['Con',1,[0,list]]]);
const pair=adt([['Tuple',2,[list,4]]]);
const record=adt([['Record',0,[pair,1,2,3,5]]]);
const bool=adt([['False',0,[]],['True',0,[]]]);
const array=D.length;D.push(6,list);
const xs=n=>{let r={$:'Nil'};for(let i=n-1;i>=0;i--)r={$:'Con',head:i,tail:r};return r;};
let cases=0;
for(let n=0;n<80;n++)for(const [d,v]of [[list,xs(n)],[pair,{$:'Tuple',fst:xs(n),snd:'\n"雪'}],[record,{$:'Record',a:{$:'Tuple',fst:xs(n),snd:'x'},b:1.5,c:17,d:'\n',e:{}}],[array,[xs(n),xs(0)]],[bool,n%2===0]]){assert.equal(iterative(D,N,d,v,0),original(D,N,d,v,0));cases++;}
for(const [d,values]of [[0,[0,-0,4294967295]],[1,[NaN,Infinity,-Infinity,-0,1.5]],[2,[0,65537]],[3,['\n','雪',"'"]],[4,['','\n"\\','雪']]])for(const v of values){assert.equal(iterative(D,N,d,v,0),original(D,N,d,v,0));cases++;}
const large=iterative(D,N,list,xs(65536),0);assert.equal(large,'['+Array.from({length:65536},(_,i)=>String(i)).join(', ')+']');
assert.notEqual(iterative(D,N,list,{$:'Con',head:9,tail:xs(2)},0),iterative(D,N,list,xs(3),0));
assert.notEqual(iterative(D,N,pair,{$:'Tuple',fst:xs(2),snd:'last'},0),iterative(D,N,pair,{$:'Tuple',fst:xs(2),snd:'wrong'},0));
console.log(JSON.stringify({boundedDifferentialCases:cases,fullOrderedList:65536,mutationsRejected:2,scope:'Synthetic printer controls; no ECS application qualification'}));
