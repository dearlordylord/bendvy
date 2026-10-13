const fs=require('fs'),vm=require('vm'),assert=require('assert'),crypto=require('crypto');
const prefix='/workspace/formal-proofs/bendvy-worktrees/observable-query-boundaries/experiments/public-inspect/promotion-stage/missing-resource-v1/direct-inspector-v1/component-query-v1/matched-timing-v1/dispatch-equivalent-v2/';
function load(file){let s=fs.readFileSync(file,'utf8'); const hash=crypto.createHash('sha256').update(s).digest('hex');s=s.replace(/^#!.*\n/,'').replace(/^import \* as (\w+) from "([^"]+)";$/gm,(_,n,m)=>`var ${n}=require(${JSON.stringify(m)});`).replaceAll('import.meta.url',JSON.stringify('file://'+file)).replaceAll('import.meta.require','require');const end=s.lastIndexOf('\nif (true) {');assert(end>0);s=s.slice(0,end);const c=vm.createContext({require,process,console,Buffer,URL,setTimeout,clearTimeout});vm.runInContext(s,c,{timeout:2000});return{c,hash};}
const cases=[
['warm-self',`[['Many',ADT('T',[])]]`,true],
['warm-word-self',`[['Many',ADT('U32',[])],['Many',ADT('T',[])]]`,true],
['warm-var-self',`[['Many',Var('A',0)],['Many',ADT('T',[])]]`,true],
['erased-other-self',`[['None',ADT('Other',[])],['Many',ADT('T',[])]]`,true],
['other-before-self',`[['Many',ADT('Other',[])],['Many',ADT('T',[])]]`,false],
['no-self',`[['Many',ADT('U32',[])]]`,false],
['erased-self',`[['None',ADT('T',[])]]`,false]
];
let results=[];
for(const [name,expr,positive]of cases){let runs=[];for(const kind of ['old','new']){const file=prefix+(kind==='old'?'ctr-take-outline-v1':'operation-interval-v1/timed-v1/direct-recursive-box-v1')+'/compiler/candidate.mjs';const {c,hash}=load(file);const result=vm.runInContext(`(()=>{TELES.clear();LAYS.clear();const T={};const book={tlds:{T:{$:'ADT',c:[{T,n:99,k:'T.make'}]},Other:{$:'ADT',c:[]}},ctrs:{}};const rows=${expr}.map(([q,F])=>[{$:q},'x',F]);const ctor=book.tlds.T.c[0];ctor.n=rows.length;TELES.set(T,{doms:rows});const t=ADT('T',[]);const probe=typeof lay_direct_self==='function'?lay_direct_self(book,t):null;const lay=lay_of(book,t);return {probe,box:lay===BOX,keys:[...LAYS.keys()],shape:JSON.stringify(lay)};})()`,c,{timeout:1000});runs.push({kind,hash,...result});}assert.equal(runs[0].shape,runs[1].shape,name);assert.equal(runs[1].probe,positive,name);if(positive){assert(runs[0].box&&runs[1].box,name);assert.equal(runs[1].keys.length,0,name);}results.push({name,runs});}
const extras=[
 ['cold-metadata',`const T=All({$:"Many"},'tail',0,ADT('T',[]),()=>ADT('T',[]));const book={tlds:{T:{$:'ADT',c:[{T,n:1,k:'T.make'}]}},ctrs:{}};const t=ADT('T',[]);`],
 ['changed-constructor-type',`const oldT={};TELES.set(oldT,{doms:[[{$:'Many'},'tail',ADT('T',[])]]});const T=All({$:'Many'},'word',0,ADT('U32',[]),()=>ADT('T',[]));const book={tlds:{T:{$:'ADT',c:[{T,n:1,k:'T.make'}]}},ctrs:{}};const t=ADT('T',[]);`],
 ['preceding-throw',`const T={};const bad=Var('bad',-1,undefined,{$:'Let',k:[],v:[],f:()=>{throw Error('EXPECTED_FORCE');}});TELES.set(T,{doms:[[{$:'Many'},'bad',bad],[{$:'Many'},'tail',ADT('T',[])]]});const book={tlds:{T:{$:'ADT',c:[{T,n:2,k:'T.make'}]}},ctrs:{}};const t=ADT('T',[]);`],
 ['renamed-self',`const T={};TELES.set(T,{doms:[[{$:'Many'},'tail',ADT('Renamed',[])]]});const book={tlds:{Renamed:{$:'ADT',c:[{T,n:1,k:'Renamed.make'}]}},ctrs:{}};const t=ADT('Renamed',[]);`]
];
for(const[name,setup]of extras){let runs=[];for(const kind of ['old','new']){const file=prefix+(kind==='old'?'ctr-take-outline-v1':'operation-interval-v1/timed-v1/direct-recursive-box-v1')+'/compiler/candidate.mjs';const {c,hash}=load(file);const r=vm.runInContext(`(()=>{TELES.clear();LAYS.clear();${setup}const probe=typeof lay_direct_self==='function'?lay_direct_self(book,t):null;try{const lay=lay_of(book,t);return{probe,box:lay===BOX,shape:JSON.stringify(lay)}}catch(e){return{probe,error:e.message}}})()`,c,{timeout:1000});runs.push({kind,hash,...r});}assert.equal(runs[0].shape,runs[1].shape,name);assert.equal(runs[0].error,runs[1].error,name);if(name==='preceding-throw')assert.equal(runs[0].error,'EXPECTED_FORCE');assert.equal(runs[1].probe,name==='renamed-self',name);results.push({name,runs});}
console.log(JSON.stringify({status:'PASS',scope:'actual compiler function differential synthetic warm telescope boundaries; no full consumer qualification',cases:results},null,2));
