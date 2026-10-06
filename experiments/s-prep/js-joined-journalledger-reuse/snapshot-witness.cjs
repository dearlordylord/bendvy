// Finite trusted emitted-helper witness: retained immutable Data, not a public raw-owner API.
const fs=require('node:fs'),vm=require('node:vm'),assert=require('node:assert/strict');
const acorn=require('internal/deps/acorn/acorn/dist/acorn');
const [input,output,schema]=process.argv.slice(2);assert(['motion','health'].includes(schema));assert(!fs.existsSync(output));
const source=fs.readFileSync(input,'utf8'),tree=acorn.parse(source,{ecmaVersion:'latest'}),defs=tree.body.filter(n=>n.type==='FunctionDeclaration');
function fn(op){const found=defs.filter(n=>n.id.name.endsWith('held$045adapter$058'+(schema==='health'?'prototype_journalledger_':'prototype_flatrows_')+schema+'_'+op+'$'));assert.equal(found.length,1);return found[0].id.name}
const tags=new Set();function walk(x){if(!x||typeof x!=='object')return;if(x.type==='Literal'&&typeof x.value==='string')tags.add(x.value);for(const v of Object.values(x))if(Array.isArray(v))v.forEach(walk);else if(v&&typeof v==='object')walk(v)}walk(tree);
function tag(suffix){const xs=[...tags].filter(x=>x===suffix.slice(1)||x.endsWith(suffix));assert.equal(xs.length,1,suffix);return xs[0]}
const T={held:tag(schema==='health'?'/held-adapter.PrototypeJournalLedgerRowOwner':'/held-adapter.PrototypeFlatRowOwner'),cache:tag('/cache.Cache'),raw:tag('/types.'+(schema==='motion'?'Position':'Vitals')),view:tag('/types.'+(schema==='motion'?'PositionView':'VitalsView')),ledgerRaw:tag('/types.'+(schema==='motion'?'MotionLedger':'HealthLedger')),ledgerView:tag('/types.LedgerView'),four:tag('/types.Four'),handle:tag('/storage.Handle'),end:tag('/transaction.PrototypeFlatEnd'),marksEnd:tag('/transaction.PrototypeFlatMarksEnd')};
const field=schema==='motion'?'coordinates':'levels',footer='cli(process.argv.slice(1));\nio_exit($main$, null);';assert.equal(source.split(footer).length,2);
const harness=`
const assert = require('node:assert/strict'),tags=${JSON.stringify(T)},field=${JSON.stringify(field)},schema=${JSON.stringify(schema)};
const four=(a,b,c,d)=>({$:tags.four,a,b,c,d});
const view={$:tags.view,[field]:four(10,11,12,13),...(schema==='motion'?{frame:7}:{reserve:9,class:2})};
const ledgerView={$:tags.ledgerView,totals:four(100,101,102,103),epoch:4};
const main={$:tags.cache,raw:{$:tags.raw,[field]:[10,11,12,13],...(schema==='motion'?{frame:7}:{reserve:9,class:2})},cached:view};
const ledger={$:tags.cache,raw:{$:tags.ledgerRaw,totals:[100,101,102,103],epoch:4},cached:ledgerView};
const owner={$:tags.held,main_raw:main.raw,main_cached:view,...(schema==='health'?{totals:ledger.raw.totals,epoch:ledger.raw.epoch}:{ledger_raw:ledger.raw}),ledger_cached:ledgerView,handle:{$:tags.handle,namespace:1,id:1},undo:{$:tags.end},commands:{$:'Nil'},pings:{$:'Nil'},marks:{$:tags.marksEnd}};
Object.freeze(view[field]);Object.freeze(view);Object.freeze(ledgerView.totals);Object.freeze(ledgerView);
const oldMain=JSON.stringify(view),oldLedger=JSON.stringify(ledgerView),read=${fn('get')}(owner,{}),readLedger=${fn('ledger')}(read.fst,{});
assert.equal(read.snd.value,view);assert.equal(readLedger.snd.value,ledgerView);
const written=${fn('set')}(readLedger.fst,{},99),writtenLedger=${fn('setledger')}(written,{},999);
assert.equal(JSON.stringify(view),oldMain);assert.equal(JSON.stringify(ledgerView),oldLedger);
assert.equal(writtenLedger.main_cached[field].a,99);assert.equal(writtenLedger.ledger_cached.totals.a,999);
assert.notEqual(writtenLedger.main_cached,view);assert.notEqual(writtenLedger.ledger_cached,ledgerView);
assert.deepEqual(writtenLedger.main_raw[field],[99,11,12,13]);assert.deepEqual((schema==='health'?writtenLedger.totals:writtenLedger.ledger_raw.totals),[999,101,102,103]);
assert.equal(writtenLedger.undo.old,100);assert.equal(writtenLedger.undo.tail.old,10);assert.equal(writtenLedger.marks.id,1);
if(${source.includes('__row_reuse_owner')}){assert.equal(read.fst,owner);assert.equal(writtenLedger,owner);}
console.log(JSON.stringify({schema,status:'RETAINED_FROZEN_DATA_VIEWS_UNCHANGED_NEW_VIEWS_AND_TRUEOLD_PASS',oldMain:JSON.parse(oldMain),oldLedger:JSON.parse(oldLedger),newMain:writtenLedger.main_cached,newLedger:writtenLedger.ledger_cached,inverseOld:[writtenLedger.undo.old,writtenLedger.undo.tail.old]}));
`;
const derived=source.replace(footer,()=>harness);acorn.parse(derived,{ecmaVersion:'latest'});fs.writeFileSync(output,derived);
