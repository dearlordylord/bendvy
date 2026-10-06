'use strict';
// Inject controlled exceptions at exact constructor/publication/flush positions, after derivation.
const fs=require('fs'),cp=require('child_process'),acorn=require('internal/deps/acorn/acorn/dist/acorn'),assert=require('assert/strict'),path=require('path');
const[input,output,schema]=process.argv.slice(2);assert(!fs.existsSync(output));const temp=output+'.base';cp.execFileSync(process.execPath,['--expose-internals',path.join(__dirname,'fold-witness.cjs'),input,temp,schema]);let s=fs.readFileSync(temp,'utf8');const inputCandidate=s.includes('function __fold_state_reuse_0(');const cut=s.indexOf('for(const length of [1,2,4,8])for(const kind'),cloneStart=s.indexOf('function __fold_state_reuse_0(');assert(cut>=0);s=s.slice(0,cut)+(cloneStart>=0?'\n'+s.slice(cloneStart):'');
const ast=acorn.parse(s,{ecmaVersion:'latest'}),defs=ast.body.filter(n=>n.type==='FunctionDeclaration'),candidate=s.includes('function __fold_state_reuse_0('),family=schema==='motion'?'flatfold_motion':'journalledger_health';const fn=defs.find(n=>candidate?n.id.name==='__fold_state_reuse_4':n.id.name.includes('prototype_packed_prototype_'+family+'_returned$'));assert(fn);assert.equal(candidate,inputCandidate);const edits=[{start:fn.body.start+1,end:fn.body.start+1,value:'\n__returnedCount++;\n'}],stages=[];const text=n=>s.slice(n.start,n.end),key=p=>p.key.name??p.key.value;
function hook(n,label){edits.push({start:n.start,end:n.end,value:'__envelope_boundary('+JSON.stringify(label)+', ('+text(n)+'))'});stages.push(label);}
function walk(n,visit){if(!n||typeof n!=='object')return;if(n.type)visit(n);for(const[k,v]of Object.entries(n))if(!['start','end'].includes(k)){if(Array.isArray(v))v.forEach(x=>walk(x,visit));else if(v&&typeof v==='object')walk(v,visit);}}
const nodes=[];walk(fn,n=>nodes.push(n));
assert(candidate);for(const n of nodes)if(n.type==='VariableDeclarator'&&n.id.name==='__fold_state_reuse_rhs_12')hook(n.init,'flush');else if(n.type==='VariableDeclarator'&&n.id.name==='__fold_state_reuse_rhs_16')hook(n.init,'total');
// The before-publication hook is nested inside the column-after expression edit.
for(const e of edits)if(e.value.includes('"column-after"')){assert(e.value.includes('= _x_1'));e.value=e.value.replace('= _x_1','= __envelope_boundary("column-before", _x_1)');stages.push('column-before');}
for(const e of edits.sort((a,b)=>b.start-a.start))s=s.slice(0,e.start)+e.value+s.slice(e.end);
const flush=defs.filter(n=>n.id.name.includes('held$045adapter$058prototype_pending_flush$'));assert.equal(flush.length,1);stages.push('flush-inside');
const args=', st';
s+=`
let __active,__throwStage,__returnedCount=0;const __events=[];
function __envelope_boundary(label,value){const visible={columns:__active.owner.columns,ledger:__active.owner.ledger,retained:__active.retained,ledgerView:__active.ledgerView};__events.push({label,visible:JSON.parse(JSON.stringify(visible))});if(label===__throwStage)throw Error('boundary:'+label);return value;}
const __originalFlush=${flush[0].id.name};${flush[0].id.name}=function(value){__envelope_boundary('flush-inside',value);return __originalFlush(value);};
for(const stage of ${JSON.stringify(stages)}){
 const f=state(8,'valid'),st=f.owner,savedMain=st.columns[0],savedLedger=st.ledger,oldLedger=JSON.stringify(savedLedger),oldData=JSON.stringify([f.retained,f.ledgerView]);st.columns[0]=none();__active=f;__throwStage=stage;__events.length=0;__returnedCount=0;
 const view={$:t('types.LedgerView'),totals:four(700,701,702,703),epoch:77};Object.freeze(view.totals);Object.freeze(view);
 const row={...savedMain.value,...(schema==='motion'?{rawframe:19,cachedframe:20,a:1000,ledger_raw:{$:t('types.MotionLedger'),totals:[55,56,57,58,59,60,61,62],epoch:22},ledger_cached:view}:{rawreserve:19,rawclass:21,cachedreserve:20,cachedclass:23,a:1000,totals:[55,56,57,58,59,60,61,62],epoch:22,ledger_cached:view}),handle:st.selected,undo:{$:t('held-adapter.PrototypePendingUndo'),pending:false,namespace:0,id:0,old:0,tail:st.undo},marks:st.marks};
 let error='';try{${fn.id.name}({$:'Tuple',fst:row,snd:55},st.namespace,st.next,st.columns,st.aux,st.metadata,st.capacity,st.depth,st.high,st.pending,st.mode,st.commands,st.pings,st.total${args});}catch(e){error=e.message;}
 assert.equal(__returnedCount,1);assert.equal(error,'boundary:'+stage);assert.equal(JSON.stringify(st.ledger),oldLedger);assert.equal(st.total,123);assert.equal(st.selected.id,1);assert.equal(st.marks.$,t('transaction.PrototypeFlatMarksEnd'));assert.equal(st.columns[0].value.a,1000);assert.equal(JSON.stringify([f.retained,f.ledgerView]),oldData);
 console.log(JSON.stringify({schema,stage,error,events:__events,columns:st.columns,ledger:st.ledger,retained:f.retained,ledgerView:f.ledgerView}));
}
`;
// PendingUndo was not part of the old literal witness's tag catalog.
const vals=[];walk(ast,n=>{if(n.type==='Literal'&&typeof n.value==='string'&&n.value.endsWith('/held-adapter.PrototypePendingUndo'))vals.push(n.value)});assert.equal(new Set(vals).size,1);s=s.replace("t('held-adapter.PrototypePendingUndo')",JSON.stringify(vals[0]));acorn.parse(s,{ecmaVersion:'latest'});fs.writeFileSync(output,s,{flag:'wx'});fs.writeFileSync(output+'.route.json',JSON.stringify({candidate,inputCandidate,selectedReturned:fn.id.name,stages,requiredRuntimeInvocationsPerStage:1},null,2)+'\n',{flag:'wx'});
