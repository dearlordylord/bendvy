'use strict';
const fs=require('fs'),acorn=require('internal/deps/acorn/acorn/dist/acorn'),assert=require('assert/strict');const[input,output]=process.argv.slice(2);assert(!fs.existsSync(output));const s=fs.readFileSync(input,'utf8'),ast=acorn.parse(s,{ecmaVersion:'latest'}),defs=ast.body.filter(n=>n.type==='FunctionDeclaration');const names=suffix=>{const xs=defs.filter(n=>n.id.name.endsWith(suffix)||n.id.name.includes(suffix+'$126'));assert.equal(xs.length,1,suffix);return xs[0].id.name};const go=names('query$058prototype_cursor_struct_idx_go'),advance=names('query$058prototype_cursor_struct_idx_advance');let strings=new Set();function w(n){if(!n||typeof n!=='object')return;if(n.type==='Literal'&&typeof n.value==='string')strings.add(n.value);for(const v of Object.values(n))if(Array.isArray(v))v.forEach(w);else if(v&&typeof v==='object')w(v)}w(ast);const tag=x=>{const xs=[...strings].filter(s=>s.endsWith('/'+x));assert.equal(xs.length,1,x);return xs[0]};const tags={state:tag('query.StructColsState'),required:tag('query.Required'),any:tag('query.Present'),without:tag('query.Absent')};const footer='cli(process.argv.slice(1));\nio_exit($main$, null);';assert.equal(s.split(footer).length,2);
const harness=`
const assert=require('node:assert/strict'),tags=${JSON.stringify(tags)};
const arr=(n,f)=>Array.from({length:n},(_,i)=>f(i));
const values=Object.freeze({$:"Con",head:99,tail:Object.freeze({$:"Nil"})});
const snapshot=Object.freeze({$:"MainView",full:Object.freeze([900,901,902,903])});
let records=0;
for(const length of [1,2,4,8])for(const selectionTag of [tags.required,tags.any,tags.without])for(const space of [7,91]){
 const payloads=arr(length,i=>({raw:arr(length,j=>100+i+j),frame:i,reserve:i+50,class:i+80,snapshot}));
 const main=payloads.map((p,i)=>i%4===2?{$:"None"}:{$:"Some",value:p}),aux=arr(length,i=>({$:"Some",value:{raw:arr(length,j=>500+i+j),snapshot}}));
 const live=arr(length,i=>i%4!==1),flags=arr(length,i=>i%2?{$:"None"}:{$:"Some",value:{$:"Tag",group:i+1}}),added=arr(length,i=>11+i),changed=arr(length,i=>21+i);
 const state={$:tags.state,main,aux,live,flags,added,changed,values};
 const before=JSON.stringify({main,aux,live,flags,added,changed}),oldData=JSON.stringify(values),retained=JSON.stringify(snapshot);
 const result=${go}(length,1,length,0,length,{$:selectionTag},space,state);
 assert.equal(JSON.stringify({main:result.fst.main,aux:result.fst.aux,live:result.fst.metadata.live,flags:result.fst.metadata.flags,added:result.fst.metadata.added,changed:result.fst.metadata.changed}),before);assert.equal(JSON.stringify(values),oldData);assert.equal(JSON.stringify(snapshot),retained);
 const ids=[];let xs=result.snd;while(xs.$==="Con"){ids.push(xs.head);xs=xs.tail}assert.equal(xs.$,"Nil");
 const expected=[99];for(let i=0;i<length;i++)if(live[i]&&main[i].$==="Some"&&(selectionTag===tags.required||selectionTag===tags.any&&flags[i].$==="Some"||selectionTag===tags.without&&flags[i].$==="None"))expected.push(i+1);assert.deepEqual(ids,expected);
 console.log(JSON.stringify({length,selection:selectionTag,space,rows:result.fst,ids,retained:snapshot}));records++;
}
// Invalid capacity branches must return the same affine fields without touching cells.
for(const id of [0,9]){const state={$:tags.state,main:[{$:"Some",value:{raw:[10,11],snapshot}}],aux:[],live:[false],flags:[{$:"None"}],added:[5],changed:[6],values};const before=JSON.stringify(state);const result=${advance}(false,id,7,{$:tags.any},state);assert.equal(JSON.stringify(result),before);console.log(JSON.stringify({invalid:id,result}));records++;}
assert.equal(records,26);
`;
const result=s.replace(footer,()=>harness);acorn.parse(result,{ecmaVersion:'latest'});fs.writeFileSync(output,result);
