// Trusted emitted helper finite witness; not a public owner/capability API.
const fs=require('node:fs'),acorn=require('internal/deps/acorn/acorn/dist/acorn'),assert=require('node:assert/strict');
const[input,output,schema]=process.argv.slice(2);assert(['motion','health'].includes(schema));assert(!fs.existsSync(output));const source=fs.readFileSync(input,'utf8'),ast=acorn.parse(source,{ecmaVersion:'latest'}),defs=ast.body.filter(n=>n.type==='FunctionDeclaration');const prefix=schema==='motion'?'prototype_packed_row_':'prototype_packed_prototype_journalledger_health_';
function fn(op){const ds=defs.filter(n=>n.id.name.endsWith('held$045adapter$058'+prefix+op+'$'));assert.equal(ds.length,1);return ds[0].id.name}
const strings=new Set();function walk(n){if(!n||typeof n!=='object')return;if(n.type==='Literal'&&typeof n.value==='string')strings.add(n.value);for(const v of Object.values(n))if(Array.isArray(v))v.forEach(walk);else if(v&&typeof v==='object')walk(v)}walk(ast);
function tag(short){const xs=[...strings].filter(s=>s.endsWith('/'+short));assert.equal(xs.length,1,short);return xs[0]}
const tags={owner:tag('held-adapter.PrototypePacked'+(schema==='motion'?'Motion':'Health')+'RowOwner'),pending:tag('held-adapter.PrototypePendingUndo'),end:tag('transaction.PrototypeFlatEnd'),marksEnd:tag('transaction.PrototypeFlatMarksEnd'),handle:tag('storage.Handle'),four:tag('types.Four'),ledgerView:tag('types.LedgerView'),ledgerRaw:schema==='motion'?tag('types.MotionLedger'):null};
const footer='cli(process.argv.slice(1));\nio_exit($main$, null);';assert.equal(source.split(footer).length,2);
const harness=`
const assert=require('node:assert/strict'),tags=${JSON.stringify(tags)},schema=${JSON.stringify(schema)};
const four=(a,b,c,d)=>({$:tags.four,a,b,c,d});
for(const length of [1,2,4,8]){
 const array=Array.from({length},(_,i)=>100+i),totals=[10,11,12,13,14,15,16,17];
 const ledgerView={$:tags.ledgerView,totals:four(900,901,902,903),epoch:88};Object.freeze(ledgerView.totals);Object.freeze(ledgerView);
 let owner={$:tags.owner,...(schema==='motion'?{coordinates:array,rawframe:4,cachedframe:77,ledger_raw:{$:tags.ledgerRaw,totals,epoch:6}}:{levels:array,rawreserve:4,rawclass:5,cachedreserve:77,cachedclass:88,totals,epoch:6}),a:999,b:200,c:300,d:400,ledger_cached:ledgerView,handle:{$:tags.handle,namespace:7,id:3},undo:{$:tags.pending,pending:false,namespace:0,id:0,old:0,tail:{$:tags.end}},marks:{$:tags.marksEnd}};
 let read=${fn('get')}(owner,{});owner=read.fst;const retained=read.snd.value;Object.freeze(retained[schema==='motion'?'coordinates':'levels']);Object.freeze(retained);
 let ledger=${fn('ledger')}(owner,{});owner=ledger.fst;assert.equal(ledger.snd.value,ledgerView);const snapshot=JSON.stringify(retained),ledgerSnapshot=JSON.stringify(ledgerView);
 owner=${fn('set')}(owner,{},500);owner=${fn('setledger')}(owner,{},700);owner=${fn('set')}(owner,{},600);owner=${fn('setledger')}(owner,{},800);
 const current=${fn('get')}(owner,{});owner=current.fst;const currentLedger=${fn('ledger')}(owner,{});owner=currentLedger.fst;
 assert.equal(JSON.stringify(retained),snapshot);assert.equal(JSON.stringify(ledgerView),ledgerSnapshot);const arr=schema==='motion'?owner.coordinates:owner.levels;assert.deepEqual(arr,[600,...Array.from({length:length-1},(_,i)=>101+i)]);assert.equal(current.snd.value[schema==='motion'?'coordinates':'levels'].a,600);assert.equal(owner.undo.pending,false);assert.equal(owner.undo.tail.main_old,500);assert.equal(owner.undo.tail.ledger_old,700);assert.equal(owner.undo.tail.tail.main_old,100);assert.equal(owner.undo.tail.tail.ledger_old,10);
 console.log(JSON.stringify({schema,length,array:arr,scalars:schema==='motion'?[owner.rawframe,owner.cachedframe]:[owner.rawreserve,owner.rawclass,owner.cachedreserve,owner.cachedclass],retained,current:current.snd.value,ledger:currentLedger.snd.value,rawLedger:schema==='motion'?owner.ledger_raw.totals:owner.totals,epoch:schema==='motion'?owner.ledger_raw.epoch:owner.epoch,inverse:owner.undo,marks:owner.marks}));
}
`;
const out=source.replace(footer,()=>harness);acorn.parse(out,{ecmaVersion:'latest'});fs.writeFileSync(output,out);
