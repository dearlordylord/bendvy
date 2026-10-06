// Finite trusted emitted-helper witness: retained immutable Data, not a public raw-owner API.
const fs=require('node:fs'),vm=require('node:vm'),assert=require('node:assert/strict');
const acorn=require('internal/deps/acorn/acorn/dist/acorn');
const [input,output,schema,recipePath]=process.argv.slice(2);const recipe=JSON.parse(fs.readFileSync(recipePath)),mainEdge=recipe.catalog.find(x=>x.getter.includes("_get$")),ledgerEdge=recipe.catalog.find(x=>x.getter.includes("_ledger$"));assert(mainEdge&&ledgerEdge);assert(['motion','health'].includes(schema));assert(!fs.existsSync(output));
const source=fs.readFileSync(input,'utf8'),tree=acorn.parse(source,{ecmaVersion:'latest'}),defs=tree.body.filter(n=>n.type==='FunctionDeclaration');
function fn(op){const found=defs.filter(n=>n.id.name.endsWith('held$045adapter$058prototype_boxed_'+schema+'_'+op+'$'));assert.equal(found.length,1);return found[0].id.name}
const tags=new Set();function walk(x){if(!x||typeof x!=='object')return;if(x.type==='Literal'&&typeof x.value==='string')tags.add(x.value);for(const v of Object.values(x))if(Array.isArray(v))v.forEach(walk);else if(v&&typeof v==='object')walk(v)}walk(tree);
function tag(suffix){const xs=[...tags].filter(x=>x===suffix.slice(1)||x.endsWith(suffix));assert.equal(xs.length,1,suffix);return xs[0]}
const T={held:tag('/held.Held'),cache:tag('/cache.Cache'),raw:tag('/types.'+(schema==='motion'?'Position':'Vitals')),view:tag('/types.'+(schema==='motion'?'PositionView':'VitalsView')),ledgerRaw:tag('/types.'+(schema==='motion'?'MotionLedger':'HealthLedger')),ledgerView:tag('/types.LedgerView'),four:tag('/types.Four'),handle:tag('/storage.Handle'),box:tag('/held-adapter.PrototypeWorldRoot')};
const field=schema==='motion'?'coordinates':'levels',footer='cli(process.argv.slice(1));\nio_exit($main$, null);';assert.equal(source.split(footer).length,2);
const harness=`
const assert = require('node:assert/strict'),tags=${JSON.stringify(T)},field=${JSON.stringify(field)},schema=${JSON.stringify(schema)};
const four=(a,b,c,d)=>({$:tags.four,a,b,c,d});
const view={$:tags.view,[field]:four(10,11,12,13),...(schema==='motion'?{frame:7}:{reserve:9,class:2})};
const ledgerView={$:tags.ledgerView,totals:four(100,101,102,103),epoch:4};
const main={$:tags.cache,raw:{$:tags.raw,[field]:[10,11,12,13],...(schema==='motion'?{frame:7}:{reserve:9,class:2})},cached:view};
const ledger={$:tags.cache,raw:{$:tags.ledgerRaw,totals:[100,101,102,103],epoch:4},cached:ledgerView};
const owner={$:tags.held,world:{$:tags.box,world:null},main,ledger,handle:{$:tags.handle,namespace:1,id:1},undo:{$:'Nil'},commands:{$:'Nil'},pings:{$:'Nil'},marks:{$:'Nil'}};
Object.freeze(view[field]);Object.freeze(view);Object.freeze(ledgerView.totals);Object.freeze(ledgerView);
const oldMain=JSON.stringify(view),oldLedger=JSON.stringify(ledgerView),read=${fn('get')}(owner,{}),readLedger=${fn('ledger')}(read.fst,{});
assert.equal(read.snd.value,view);assert.equal(readLedger.snd.value,ledgerView);
const written=${fn('set')}(readLedger.fst,{},99),writtenLedger=${fn('setledger')}(written,{},999);
assert.equal(JSON.stringify(view),oldMain);assert.equal(JSON.stringify(ledgerView),oldLedger);
assert.equal(writtenLedger.main.cached[field].a,99);assert.equal(writtenLedger.ledger.cached.totals.a,999);
assert.notEqual(writtenLedger.main.cached,view);assert.notEqual(writtenLedger.ledger.cached,ledgerView);
assert.deepEqual(writtenLedger.main.raw[field],[99,11,12,13]);assert.deepEqual(writtenLedger.ledger.raw.totals,[999,101,102,103]);
assert.equal(writtenLedger.undo.head.old,100);assert.equal(writtenLedger.undo.tail.head.old,10);assert.equal(writtenLedger.marks.head.id,1);
if(${source.includes('__boxed_reuse_owner')}){assert.equal(read.fst,owner);assert.equal(writtenLedger,owner);assert.equal(writtenLedger.main,main);assert.equal(writtenLedger.ledger,ledger);}
const priorMain=writtenLedger.main.cached,priorLedger=writtenLedger.ledger.cached;Object.freeze(priorMain[field]);Object.freeze(priorMain);Object.freeze(priorLedger.totals);Object.freeze(priorLedger);const savedPriorMain=JSON.stringify(priorMain),savedPriorLedger=JSON.stringify(priorLedger),order=[];
const ownerArg=()=>{order.push('owner');return writtenLedger},tokenArg=()=>{order.push('token');return {}},prefixArg=()=>{order.push('prefix');return 19};
const fused=${source.includes(mainEdge.getterClone)?mainEdge.getterClone+'(ownerArg(),tokenArg())':mainEdge.receiver+'('+mainEdge.getter+'(ownerArg(),tokenArg()))'};
assert.deepEqual(order,['owner','token']);assert.equal(fused.fst,writtenLedger);assert.equal(fused.snd,135);assert.equal(fused.fst.main.raw[field][0],100);assert.equal(fused.fst.main.cached[field].a,100);assert.equal(fused.fst.ledger.raw.totals[0],1000);assert.equal(fused.fst.ledger.cached.totals.a,1000);assert.equal(fused.fst.undo.head.old,999);assert.equal(fused.fst.undo.tail.head.old,99);
order.length=0;const ledgerResult=${source.includes(ledgerEdge.getterClone)?ledgerEdge.getterClone+'(prefixArg(),ownerArg(),tokenArg())':ledgerEdge.receiver+'(prefixArg(),'+ledgerEdge.getter+'(ownerArg(),tokenArg()))'};assert.deepEqual(order,['prefix','owner','token']);assert.equal(ledgerResult.snd,19);assert.equal(ledgerResult.fst.ledger.raw.totals[0],1001);assert.equal(ledgerResult.fst.undo.head.old,1000);
assert.equal(JSON.stringify(view),oldMain);assert.equal(JSON.stringify(ledgerView),oldLedger);assert.equal(JSON.stringify(priorMain),savedPriorMain);assert.equal(JSON.stringify(priorLedger),savedPriorLedger);assert.equal(owner.world.world,null);assert.equal(owner.handle.id,1);assert.equal(owner.handle.namespace,1);assert.equal(owner.commands.$,'Nil');assert.equal(owner.pings.$,'Nil');
console.log(JSON.stringify({schema,status:'ACTUAL_CLIENT_FUSION_FULL_FIELDS_FROZEN_HISTORY_ARGUMENT_ORDER_PASS',mainOrder:['owner','token'],ledgerOrder:order,oldMain:JSON.parse(oldMain),oldLedger:JSON.parse(oldLedger),priorMain:JSON.parse(savedPriorMain),priorLedger:JSON.parse(savedPriorLedger),newMain:owner.main.cached,newLedger:owner.ledger.cached,result:fused.snd,inverseOld:[owner.undo.head.old,owner.undo.tail.head.old,owner.undo.tail.tail.head.old]}));
`;
const derived=source.replace(footer,()=>harness);acorn.parse(derived,{ecmaVersion:'latest'});fs.writeFileSync(output,derived);
