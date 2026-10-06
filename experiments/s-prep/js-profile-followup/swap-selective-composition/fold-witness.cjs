'use strict';
// Trusted emitted-helper representation witness, not a public constructor/capability API.
const fs=require('fs'),acorn=require('internal/deps/acorn/acorn/dist/acorn'),assert=require('node:assert/strict');
const[input,output,schema]=process.argv.slice(2);assert(['motion','health'].includes(schema)&&!fs.existsSync(output));
const s=fs.readFileSync(input,'utf8'),ast=acorn.parse(s,{ecmaVersion:'latest'}),defs=ast.body.filter(n=>n.type==='FunctionDeclaration'),isCandidate=s.includes('function __fold_state_reuse_0(');
const unique=part=>{const xs=defs.filter(n=>n.id.name.includes(part));assert.equal(xs.length,1,part);return xs[0].id.name;};
const key=schema==='motion'?'flatfold_motion':'journalledger_health',step=isCandidate?'__fold_state_reuse_0':unique('held$045adapter$058prototype_packed_prototype_'+key+'_step$'),returned=isCandidate?'__fold_state_reuse_4':unique('held$045adapter$058prototype_packed_prototype_'+key+'_returned$'),flush=unique('held$045adapter$058prototype_pending_flush$'),get=unique('cached$045payload$058prototype_slot_'+(schema==='motion'?'position':'vitals')+'_get$');
const strings=[];function walk(n){if(!n||typeof n!=='object')return;if(n.type==='Literal'&&typeof n.value==='string')strings.push(n.value);for(const v of Object.values(n))if(Array.isArray(v))v.forEach(walk);else if(v&&typeof v==='object')walk(v);}walk(ast);
const tag=short=>{const xs=[...new Set(strings.filter(x=>x.endsWith('/'+short)))];assert.equal(xs.length,1,short);return xs[0];};
const tags=Object.fromEntries(['held-adapter.PrototypeFlatFold','cached-payload.Prototype'+(schema==='motion'?'Motion':'Health')+'MainSlot','storage.MetadataColumns','storage.Handle','types.Four','types.LedgerView','transaction.PrototypeFlatEnd','transaction.PrototypeFlatMarksEnd','cache.Cache',schema==='motion'?'types.MotionLedger':'held-adapter.PrototypeJournalLedger',schema==='motion'?'types.MotionOn':'types.HealthOn',schema==='motion'?'types.Velocity':'types.Armor'].map(x=>[x,tag(x)]));
const footer='cli(process.argv.slice(1));\nio_exit($main$, null);';assert.equal(s.split(footer).length,2);
const harness=`
const assert=require('node:assert/strict'),tags=${JSON.stringify(tags)},schema=${JSON.stringify(schema)},candidate=${isCandidate};
const t=x=>tags[x],some=value=>({$:'Some',value}),nil=()=>({$:'Nil'}),none=()=>({$:'None'}),four=(a,b,c,d)=>({$:t('types.Four'),a,b,c,d});
function state(length,kind){
 const slots=Array.from({length:8},(_,id)=>({$:t('cached-payload.Prototype'+(schema==='motion'?'Motion':'Health')+'MainSlot'),...(schema==='motion'?{coordinates:Array.from({length},(_,i)=>100+id*10+i),rawframe:4,cachedframe:77}:{levels:Array.from({length},(_,i)=>100+id*10+i),rawreserve:4,rawclass:5,cachedreserve:77,cachedclass:88}),a:999+id,b:200,c:300,d:400}));
 const retained=${get}(slots[0]);slots[0]=retained.fst;Object.freeze(retained.snd[schema==='motion'?'coordinates':'levels']);Object.freeze(retained.snd);
 const view={$:t('types.LedgerView'),totals:four(900,901,902,903),epoch:88};Object.freeze(view.totals);Object.freeze(view);
 const ledger=schema==='motion'?{$:t('cache.Cache'),raw:{$:t('types.MotionLedger'),totals:[10,11,12,13,14,15,16,17],epoch:6},cached:view}:{$:t('held-adapter.PrototypeJournalLedger'),totals:[10,11,12,13,14,15,16,17],epoch:6,cached:view};
 const live=[true,true,true,true,false,false,false,false],columns=slots.map(some);if(kind==='dead')live[0]=false;if(kind==='missing')columns[0]=none();
 return {owner:{$:t('held-adapter.PrototypeFlatFold'),namespace:7,next:9,columns,aux:Array.from({length:8},(_,i)=>some(schema==='motion'?{$:t('types.Velocity'),rates:[i,2,3,4,5,6,7,8],moving:true}:{$:t('types.Armor'),layers:[i,2,3,4,5,6,7,8],grade:19})),metadata:{$:t('storage.MetadataColumns'),live,flags:Array.from({length:8},none),added:[1,2,3,4,5,6,7,8],changed:[8,7,6,5,4,3,2,1]},capacity:8,depth:3,high:4,pending:nil(),ledger:kind==='no-ledger'?none():some(ledger),mode:{$:t(schema==='motion'?'types.MotionOn':'types.HealthOn')},selected:{$:t('storage.Handle'),namespace:7,id:1},undo:{$:t('transaction.PrototypeFlatEnd')},commands:nil(),pings:{$:'Con',head:29,tail:nil()},marks:{$:t('transaction.PrototypeFlatMarksEnd')},total:123},retained:retained.snd,ledgerView:view};
}
for(const length of [1,2,4,8])for(const kind of ['valid','foreign','zero','capacity','high','dead','missing','no-ledger']){
 const f=state(length,kind),view=JSON.stringify(f.retained),lv=JSON.stringify(f.ledgerView);let owner=f.owner;
 const handle={$:t('storage.Handle'),namespace:kind==='foreign'?8:7,id:kind==='zero'?0:kind==='capacity'?9:kind==='high'?5:1};
 for(let repeat=0;repeat<2;repeat++){
  const routeBefore=candidate&&typeof __swap_route_counts!=="undefined"?{...__swap_route_counts}:null;const input=owner;owner=${step}(handle,owner);if(routeBefore){assert.equal(__swap_route_counts.ingress-routeBefore.ingress,1);assert.equal(__swap_route_counts.take-routeBefore.take,['valid','missing'].includes(kind)?1:0);assert.equal(__swap_route_counts.returned-routeBefore.returned,kind==='valid'?1:0);}if(candidate&&kind==='valid')assert.equal(owner,input);
  assert.equal(JSON.stringify(f.retained),view);assert.equal(JSON.stringify(f.ledgerView),lv);
  if(kind==='valid'){
   const slot=owner.columns[0].value,arr=schema==='motion'?slot.coordinates:slot.levels;assert.deepEqual(arr,[1000+repeat,...Array.from({length:length-1},(_,i)=>101+i)]);
   const ledger=owner.ledger.value,totals=schema==='motion'?ledger.raw.totals:ledger.totals;assert.deepEqual(totals,[901+repeat,11,12,13,14,15,16,17]);assert.equal(schema==='motion'?ledger.raw.epoch:ledger.epoch,6);assert.equal(owner.undo.main_old,repeat===0?100:1000);assert.equal(owner.undo.ledger_old,repeat===0?10:901);
  }
  console.log(JSON.stringify({schema,length,kind,repeat,owner,retained:f.retained,ledgerView:f.ledgerView}));
 }
}
// Controlled terminal RHS exception: ordinary emitted arrays/records, no proxy/accessor.
// The same array restoration precedes pending-flush; no state-field assignments may precede its throw.
const oldFlush=${flush};${flush}=function(){throw Error('pending-flush-canary')};
const f=state(8,'valid'),before=JSON.stringify(f.owner),row={...f.owner.columns[0].value,...(schema==='motion'?{ledger_raw:f.owner.ledger.value.raw,ledger_cached:f.ledgerView}:{totals:f.owner.ledger.value.totals,epoch:6,ledger_cached:f.ledgerView}),handle:f.owner.selected,undo:{$:'ignored'},marks:f.owner.marks};
const st=f.owner;let message='';try{${returned}({$:'Tuple',fst:row,snd:55},st.namespace,st.next,st.columns,st.aux,st.metadata,st.capacity,st.depth,st.high,st.pending,st.mode,st.commands,st.pings,st.total${isCandidate?', st':''});}catch(e){message=e.message;}
assert.equal(message,'pending-flush-canary');assert.equal(JSON.stringify(st),before);${flush}=oldFlush;console.log(JSON.stringify({schema,kind:'exception-order',message,owner:st}));
`;
const result=s.replace(footer,()=>harness);acorn.parse(result,{ecmaVersion:'latest'});fs.writeFileSync(output,result,{flag:'wx'});
