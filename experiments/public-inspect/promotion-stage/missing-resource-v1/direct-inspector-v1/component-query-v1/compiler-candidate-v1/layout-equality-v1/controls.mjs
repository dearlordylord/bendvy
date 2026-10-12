import fs from 'node:fs';
import vm from 'node:vm';
import assert from 'node:assert/strict';
import crypto from 'node:crypto';
const candidate=process.argv[2];
const source=fs.readFileSync(candidate,'utf8');
assert.equal(crypto.createHash('sha256').update(source).digest('hex'),'917ef1a88a143ab12f89213fe3f765548a74314b1a8febcc85d3eca67147d729');
const region=(start,end)=>source.slice(source.indexOf(start),source.indexOf(end,source.indexOf(start)));
// Extract the primitive declarations alone; unrelated constants are excluded.
const constants=source.match(/var W32 =[^]*?var WIDE = \d+;/)[0];
const helpers=region('function lay_of(','function lay_el(')+region('function lay_pack(','function lay_c(')+region('function memo(m,','function memo_gc(');
const reset=region('  LAY_FINAL = new WeakSet([W32, BOX, W64]);','  "FID_EXIT FID_ENTER');
const context={assert};
vm.createContext(context);
vm.runInContext(constants+`
var LAYS=new Map(), NODES=new Map(), LAY_IDS=new Map();
var LAY_FINAL=new WeakSet([W32,BOX,W64]), LAY_EQ_PAIRS=new WeakMap();
var TELES=new Map(), SRCS=new Map(), LOOPS=new Map(), FLATS=new Map(), FUNS=new Map(), BRWS=new Map(), IDS=new Map(), TAKEN=new Set();
function ty_adt(book,A){return A;}
function term_lower(A){return A;}
function term_key(A){return JSON.stringify(A);}
function ctr_doms(book,c){return c.fields;}
function ty_holds(book,F,visit){return visit(F)===true;}
`+helpers+`
function reset_file_caches(){${reset}}
const jsonEq=(a,b)=>a===b||JSON.stringify(a)===JSON.stringify(b);
const eq=(a,b)=>assert.equal(lay_eq(a,b),jsonEq(a,b));
const final=(arms)=>lay_final(lay_pack(arms));
const a=final([['A',[W32]],['B',[BOX]]]);
const reversed=final([['B',[BOX]],['A',[W32]]]);
assert.equal(lay_eq(a,reversed),false);
assert.equal(lay_eq(final([['ADT.One',[W32]]]),final([['ADT.Two',[W32]]])),false);
const shared=final([['Shared',[W32,BOX]]]);
const dag1=final([['D',[shared,shared,shared]]]);
const copy=final([['Shared',[W32,BOX]]]);
const dag2=final([['D',[copy,copy,copy]]]);
assert.equal(lay_eq(dag1,dag2),true);
const unfinal=lay_pack([['Mutable',[W32]]]);
const same=final([['Mutable',[W32]]]);
assert.equal(lay_eq(unfinal,same),true);
assert.equal(LAY_EQ_PAIRS.has(unfinal),false);
unfinal.ks.push('box');
assert.equal(lay_eq(unfinal,same),false);
const book={tlds:{},ctrs:{Pad:{fields:Array(248).fill({k:'U32',x:[]})}}};
const padded=lay_node(book,'Pad');
assert.equal(padded.ks.length,256);
assert.equal(LAY_FINAL.has(padded),true);
const rawpad=lay_pack([['Pad',Array(248).fill(W32)]]);
assert.equal(LAY_FINAL.has(rawpad),false);
assert.equal(lay_eq(rawpad,padded),false);
const wide={k:'Wide',x:[]};
book.tlds.Wide={$:'ADT',c:[{k:'Wide.Make',fields:Array(248).fill({k:'U32',x:[]})}]};
assert.equal(lay_of(book,wide),BOX);
const rec={$:'ADT',k:'Recursive',x:[]};
book.tlds.Recursive={$:'ADT',c:[{k:'Recursive.Make',fields:[rec]}]};
assert.equal(lay_of(book,rec),BOX);
const layouts=[W32,BOX,W64,a,reversed,dag1,dag2,padded,rawpad,unfinal,same,final([])];
for(let i=0;i<8;i++)layouts.push(final([['K'+i,[i%2?W32:BOX,shared]]]));
for(const x of layouts)for(const y of layouts)eq(x,y);
const oldPairs=LAY_EQ_PAIRS, oldFinal=LAY_FINAL;
LAY_IDS.set(shared,17);LAYS.set('sentinel',shared);NODES.set('sentinel',shared);
reset_file_caches();
assert.notEqual(LAY_EQ_PAIRS,oldPairs);assert.notEqual(LAY_FINAL,oldFinal);
assert.equal(LAYS.size,0);assert.equal(NODES.size,0);assert.equal(LAY_IDS.size,0);
assert.equal(LAY_FINAL.has(shared),false);assert.equal(LAY_FINAL.has(BOX),true);
eq(a,reversed);eq(dag1,dag2);
`,context);
console.log(JSON.stringify({status:'PASS',candidateSHA256:'917ef1a88a143ab12f89213fe3f765548a74314b1a8febcc85d3eca67147d729',controls:['JSON differential on actual helper-produced dense layouts','ordered arms','distinct ADT keys','shared child DAG','unfinalized mutation bypass','actual lay_node padding before final mark','actual lay_of WIDE/recursive BOX with explicit type stubs','actual file_book cache-reset block twice-domain comparison'],limits:'Standalone extracts actual helper bodies and reset block; type helpers use explicit stubs. It does not execute complete file_book/type inference or validate arbitrary mutable terms. Full ordinary consumer remains required.'}));
