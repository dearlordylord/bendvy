'use strict';
const fs=require('fs'),path=require('path'),crypto=require('crypto'),acorn=require('internal/deps/acorn/acorn/dist/acorn');const sha=x=>crypto.createHash('sha256').update(x).digest('hex');
const[input,output]=process.argv.slice(2);if(!input||!output||(fs.existsSync(output)||fs.existsSync(output+'.recipe.json')))throw Error('fresh output required');const s=fs.readFileSync(input,'utf8'),cat=JSON.parse(fs.readFileSync(path.join(__dirname,'input-pins.json'))),pin=cat[sha(s)];if(!pin)throw Error('unknown input');for(const [p,h]of Object.entries(pin.files))if(sha(fs.readFileSync(p))!==h)throw Error('provenance changed '+p);
const ast=acorn.parse(s,{ecmaVersion:'latest'}),nodes=[],parent=new Map();function walk(n,p){if(!n||typeof n!=='object')return;if(n.type){nodes.push(n);parent.set(n,p)}for(const[k,v]of Object.entries(n))if(!['start','end'].includes(k)){if(Array.isArray(v))v.forEach(x=>walk(x,n));else if(v&&typeof v==='object')walk(v,n)}}walk(ast,null);const text=n=>s.slice(n.start,n.end),prefix='__restore_envelope_',owner=prefix+'owner';if(s.includes(prefix))throw Error('reserved prefix');
for(const n of nodes)if(n.type==='WithStatement'||n.type==='UnaryExpression'&&n.operator==='delete'||n.type==='Identifier'&&['eval','Proxy','Reflect','arguments'].includes(n.name)||n.type==='MemberExpression'&&['prototype','constructor','__proto__','defineProperty','setPrototypeOf','getPrototypeOf','getOwnPropertyDescriptor','getOwnPropertyDescriptors','caller','callee'].includes(n.computed&&n.property.type==='Literal'?n.property.value:!n.computed?n.property.name:undefined))throw Error('reflection/unknown effects');
const defs=ast.body.filter(n=>n.type==='FunctionDeclaration'),byName=new Map(defs.map(n=>[n.id.name,n]));if(byName.size!==defs.length)throw Error('duplicate declaration');const family=pin.family,fields=['namespace','next','columns','aux','metadata','capacity','depth','high','pending','ledger','mode','selected','undo','commands','pings','marks','total'];if(family.length!==5)throw Error('frontier cardinality');
for(const [name,h]of Object.entries(pin.bodyPins)){const n=byName.get(name);if(!n||sha(text(n))!==h||n.params.some(p=>p.type!=='Identifier')||n.async||n.generator)throw Error('body/signature changed');}
const cloneNames=new Map(family.map((name,i)=>[name,prefix+i]));const advance=byName.get(family[0]);if(advance.params.length!==2||advance.params[1].name!=='_state_0')throw Error('advance owner shape');
// The pinned pack/fallback creates a fresh Type Fold; the Cursor loop exclusively moves it through the private chain.
const caller=byName.get(pin.caller);if(!caller||sha(text(caller))!==pin.callerSHA256)throw Error('cursor caller changed');const hook=nodes.filter(n=>n.type==='CallExpression'&&n.callee.type==='Identifier'&&n.callee.name===family[0]&&n.start>=caller.start&&n.end<=caller.end);if(hook.length!==1||hook[0].arguments.length!==2||hook[0].arguments[1].type!=='Identifier'||hook[0].arguments[1].name!=='_state_0')throw Error('unique owner ingress');
const ownUses=nodes.filter(n=>n.type==='Identifier'&&n.name==='_state_0'&&n.start>=advance.body.start&&n.end<=advance.body.end);for(const n of ownUses){const p=parent.get(n);
 if(p.type!=='MemberExpression'||p.object!==n||!p.computed||p.property.type!=='Literal'||!fields.includes(p.property.value)||parent.get(p)?.type==='AssignmentExpression'&&parent.get(p).left===p||parent.get(p)?.type==='UpdateExpression')throw Error('whole owner escape/write');}
for(const [name,h]of Object.entries(pin.confinementPins)){const n=byName.get(name);if(!n||sha(text(n))!==h)throw Error('producer/consumer frontier changed');}
for(const n of nodes)if(n.type==='ObjectExpression'&&n.properties[0]?.value?.value===pin.stateTag){if(n.properties.length!==18||n.properties.some(p=>p.type!=='Property'||p.kind!=='init'||p.method||p.computed||p.shorthand)||n.properties.map(p=>p.key.name??p.key.value).join(',')!==['$',...fields].join(','))throw Error('nonplain state producer');}
// Prove the closed call frontier has no function-value escape, shadow replacement, or unsaturated application.
for(const [index,name]of family.entries()){
 const expected=index===0?pin.caller:family[index-1],fn=byName.get(name);let count=0;
 for(const n of nodes)if(n.type==='Identifier'&&n.name===name){const p=parent.get(n);if(p===fn&&p.id===n)continue;if(p.type!=='CallExpression'||p.callee!==n||p.arguments.length!==fn.params.length||p.optional)throw Error('family value escape/arity');const enclosing=defs.filter(d=>n.start>=d.body.start&&n.end<=d.body.end);if(enclosing.length!==1||enclosing[0].id.name!==expected)throw Error('unknown incoming edge');count++;}
 if(count!==1)throw Error('private incoming edge cardinality');
}
const heldPaths=Object.keys(pin.files).filter(p=>p.endsWith('/held-adapter.bend'));if(heldPaths.length!==1)throw Error('source type fact');const sourceType=fs.readFileSync(heldPaths[0],'utf8');const typeFact='type PrototypeFlatFold<-Schema:Data,-M:Type,-A:Type,-F:Data,-L:Type,-Mode:Data> is Type:\n  PrototypeFlatFold{namespace:U32,next:U32,columns:Array<Maybe<M>>,aux:Array<Maybe<A>>,metadata:S.MetadataColumns<F>,capacity:U32,depth:Nat,high:U32,pending:List<S.Command<M,A,F>>,ledger:Maybe<L>,mode:Mode,selected:S.Handle<Schema>,undo:X.PrototypeFlatInverse<Schema>,commands:List<S.Command<M,A,F>>,pings:List<&2,U32>,marks:X.PrototypeFlatMark<Schema>,total:U32}';if(!sourceType.includes(typeFact)||sourceType.split(typeFact).length!==2)throw Error('affine Type/field fact changed');
const cachePaths=Object.keys(pin.files).filter(p=>p.endsWith('/cache.bend')),payloadPaths=Object.keys(pin.files).filter(p=>p.endsWith('/cached-payload.bend'));if(cachePaths.length!==1||payloadPaths.length!==1)throw Error('Type source facts');
if(!fs.readFileSync(cachePaths[0],'utf8').includes('type Cache<-Raw:Type,-View:Data> is Type:\n  Cache{raw:Raw,cached:View}')||!sourceType.includes('type PrototypeJournalLedger<-LV:Data> is Type:\n  PrototypeJournalLedger{totals:Array<U32>,epoch:U32,cached:LV}'))throw Error('owning ledger / immutable Data fact');
const payloadType=fs.readFileSync(payloadPaths[0],'utf8');if(!payloadType.includes('type PrototypeMotionMainSlot is Type:\n  PrototypeMotionMainSlot{coordinates:Array<U32>,rawframe:U32,a:U32,b:U32,c:U32,d:U32,cachedframe:U32}')||!payloadType.includes('type PrototypeHealthMainSlot is Type:\n  PrototypeHealthMainSlot{levels:Array<U32>,rawreserve:U32,rawclass:U32,a:U32,b:U32,c:U32,d:U32,cachedreserve:U32,cachedclass:U32}'))throw Error('owning Main slot fact');
// Constructor-local exclusive affine envelopes: only field projections enter the callback.
const taken=byName.get(family[3]);
for(const n of nodes.filter(n=>n.type==='Identifier'&&n.start>=taken.body.start&&n.end<=taken.body.end&&['_t_1','_ledger_0'].includes(n.name))){
 const p=parent.get(n);if(p.type==='VariableDeclarator'&&p.id===n)continue;
 if(n.name==='_ledger_0'&&p.type==='Property'&&(p.key.name??p.key.value)==='value'&&parent.get(p).type==='ObjectExpression'&&parent.get(p).properties[0]?.value?.value==='Some')continue;
 if(p.type!=='MemberExpression'||p.object!==n||!p.computed||p.property.type!=='Literal'||parent.get(p)?.type==='AssignmentExpression')throw Error('envelope escape or mutation '+n.name+' '+p.type+' '+text(p));
}
for(const n of nodes)if(n.type==='MemberExpression'&&n.object.type==='Identifier'&&n.object.name==='Object'&&['freeze','seal','preventExtensions','assign'].includes(n.computed?n.property.value:n.property.name)){
 const call=parent.get(n),arg=call?.arguments?.[0],decl=parent.get(call);const allowed=pin.schema==='motion'?['types.PositionToken','types.MotionLedgerToken']:['types.VitalsToken','types.HealthLedgerToken'];
 if((n.computed?n.property.value:n.property.name)!=='freeze'||call.type!=='CallExpression'||call.arguments.length!==1||decl.type!=='VariableDeclarator'||!['__pool_token_0','__pool_token_1'].includes(decl.id.name)||arg?.type!=='ObjectExpression'||arg.properties.length!==1||!allowed.some(t=>(arg.properties[0].value?.value===t||arg.properties[0].value?.value?.endsWith('/'+t))))throw Error('frozen or unknown producer');
}
for(const n of nodes.filter(n=>n.type==='Identifier'&&n.name==='_t_0'&&n.start>=taken.body.start&&n.end<=taken.body.end)){
 const p=parent.get(n);if(p.type==='VariableDeclarator'&&p.id===n)continue;if(p.type!=='MemberExpression'||p.object!==n||(!p.computed&&p.property.name!=='$')||(p.computed&&p.property.value!=='value'))throw Error('Main Some escapes or is observed');
}
const edits=[{start:hook[0].callee.start,end:hook[0].callee.end,value:cloneNames.get(family[0])}],clones=[];let terminalCount=0,edges=0;const certificates=[];
const ledgerContext=prefix+'ledger',mainContext=prefix+'main';
for(const [index,name]of family.entries()){
 const fn=byName.get(name),local=[];local.push({start:fn.id.start,end:fn.id.end,value:cloneNames.get(name)});
 const extra=index===2||index===3?[ledgerContext]:index===4?[mainContext,ledgerContext]:[];
 if(extra.length)local.push({start:fn.params.at(-1).end,end:fn.params.at(-1).end,value:', '+extra.join(', ')});
 const own=nodes.filter(n=>n.start>=fn.body.start&&n.end<=fn.body.end);
 if(own.some(n=>['FunctionDeclaration','FunctionExpression','AwaitExpression','YieldExpression','ThisExpression','TryStatement','ThrowStatement'].includes(n.type)))throw Error('capture/exception uncertainty');
 for(const n of own)if(n.type==='ArrowFunctionExpression'){const p=parent.get(n);if(n.async||n.params.length||n.body.type!=='Identifier'||p.type!=='CallExpression'||p.callee.type!=='Identifier'||p.callee.name!=='array_rmw'||p.arguments[2]!==n||n.body.name!=='_x_1')throw Error('unknown closure');}
 for(const n of own)if(n.type==='CallExpression'&&n.callee.type==='Identifier'&&cloneNames.has(n.callee.name)){
  if(n.optional||n.arguments.some(x=>x.type==='SpreadElement')||n.arguments.length!==byName.get(n.callee.name).params.length)throw Error('non saturated edge');
  local.push({start:n.callee.start,end:n.callee.end,value:cloneNames.get(n.callee.name)});
  const args=index===1?['_ledger_0']:index===2?[ledgerContext]:index===3?['_t_0',ledgerContext]:[];
  if(args.length)local.push({start:n.end-1,end:n.end-1,value:', '+args.join(', ')});edges++;
 }
 if(index===4){
  const mainDecl=own.filter(n=>n.type==='VariableDeclarator'&&n.id.name==='_x_1');if(mainDecl.length!==1)throw Error('main declaration');
  const main=mainDecl[0].init;assertPlain(main,['$','value'],'Some');const slot=main.properties[1].value;
  const mainFields=pin.schema==='motion'?['coordinates','rawframe','a','b','c','d','cachedframe']:['levels','rawreserve','rawclass','a','b','c','d','cachedreserve','cachedclass'];
  assertPlain(slot,['$',...mainFields]);if(!slot.properties[0].value.value.endsWith('cached-payload.Prototype'+(pin.schema==='motion'?'Motion':'Health')+'MainSlot'))throw Error('slot Type tag');
  for(const p of slot.properties.slice(1))if(p.value.type!=='Identifier')throw Error('main constructor-local effects');
  let mainText='';slot.properties.slice(1).forEach((p,i)=>mainText+='const '+prefix+'main_rhs_'+i+' = ('+text(p.value)+');\n');
  mainFields.forEach((f,i)=>mainText+=mainContext+'["value"]['+JSON.stringify(f)+'] = '+prefix+'main_rhs_'+i+';\n');
  const stmt=parent.get(mainDecl[0]);if(stmt.type!=='VariableDeclaration'||stmt.kind!=='const'||stmt.declarations.length!==1)throw Error('main statement');
  mainText+='const _x_1 = '+mainContext+';';local.push({start:stmt.start,end:stmt.end,value:mainText});
  const terminal=own.filter(n=>n.type==='ReturnStatement'&&n.argument?.type==='ObjectExpression'&&n.argument.properties[0]?.value.value===pin.stateTag);if(terminal.length!==1)throw Error('Fold terminal');
  const ret=terminal[0],fold=ret.argument;assertPlain(fold,['$',...fields],pin.stateTag);const ledger=fold.properties.find(p=>(p.key.name??p.key.value)==='ledger').value;assertPlain(ledger,['$','value'],'Some');
  const record=ledger.properties[1].value,ledgerFields=pin.schema==='motion'?['raw','cached']:['totals','epoch','cached'];assertPlain(record,['$',...ledgerFields]);
  const recordTag=record.properties[0].value.value;if(!recordTag.endsWith(pin.schema==='motion'?'cache.Cache':'held-adapter.PrototypeJournalLedger'))throw Error('ledger Type tag');
  record.properties.slice(1).forEach(p=>{if(p.value.type!=='Identifier')throw Error('ledger constructor-local effects');});
  // Ledger fields evaluated at their original Fold-property position; publication waits until all original RHS succeed.
  let replacement='';fold.properties.slice(1).forEach((p,i)=>{
   const f=p.key.name??p.key.value;
   if(f==='ledger')record.properties.slice(1).forEach((q,j)=>replacement+='const '+prefix+'ledger_rhs_'+j+' = ('+text(q.value)+');\n');
   replacement+='const '+prefix+'fold_rhs_'+i+' = ('+(f==='ledger'?ledgerContext:text(p.value))+');\n';
  });ledgerFields.forEach((f,i)=>replacement+=ledgerContext+'["value"]['+JSON.stringify(f)+'] = '+prefix+'ledger_rhs_'+i+';\n');
  replacement+='return {$: '+JSON.stringify(pin.stateTag)+', '+fields.map((f,i)=>JSON.stringify(f)+': '+prefix+'fold_rhs_'+i).join(', ')+'};';
  local.push({start:ret.start,end:ret.end,value:replacement});terminalCount++;
  // Plain writable producers are compiler-generated owning Type nodes; all matching producer literals retain exactly the same fields.
  for(const n of nodes)if(n.type==='ObjectExpression'&&[slot.properties[0].value.value,recordTag].includes(n.properties[0]?.value?.value))assertPlain(n,['$',...(n.properties[0].value.value===recordTag?ledgerFields:mainFields)]);
  certificates.push({mainTag:slot.properties[0].value.value,mainFields,ledgerTag:recordTag,ledgerFields,mainRHS:slot.properties.slice(1).map(p=>text(p.value)),ledgerRHS:record.properties.slice(1).map(p=>text(p.value)),foldRHS:fold.properties.slice(1).map(p=>({field:p.key.name??p.key.value,expression:text(p.value)})),mainMutation:'at original nested constructor, before original columns publication',ledgerMutation:'after every original Fold RHS including pending_flush succeeds',callbackIngress:'only projected raw arrays/scalars/immutable Data, never envelopes',sourceType:'Main slot and Ledger record owning Type; immutable cached Data values replaced whole'});
 }
 let body=text(fn);for(const e of local.sort((a,b)=>b.start-a.start))body=body.slice(0,e.start-fn.start)+e.value+body.slice(e.end-fn.start);clones.push(body);
}
function assertPlain(n,keys,tag){if(n.type!=='ObjectExpression'||n.properties.length!==keys.length||n.properties.some(p=>p.type!=='Property'||p.kind!=='init'||p.method||p.computed||p.shorthand)||n.properties.map(p=>p.key.name??p.key.value).join(',')!==keys.join(',')||tag&&n.properties[0].value.value!==tag)throw Error('plain envelope fields/tag');}
if(terminalCount!==1||edges!==4)throw Error('frontier edge count');let result=s;for(const e of edits.sort((a,b)=>b.start-a.start))result=result.slice(0,e.start)+e.value+result.slice(e.end);result+='\n'+clones.join('\n\n')+'\n';acorn.parse(result,{ecmaVersion:'latest'});fs.writeFileSync(output,result,{flag:'wx'});fs.writeFileSync(output+'.recipe.json',JSON.stringify({status:'STRICT_PRIVATE_RESTORE_ENVELOPES_DERIVED',inputSHA256:sha(s),outputSHA256:sha(result),recipeSHA256:sha(fs.readFileSync(__filename)),catalogSHA256:sha(fs.readFileSync(path.join(__dirname,'input-pins.json'))),schema:pin.schema,sourceRoot:pin.sourceRoot,sourcePins:pin.sourcePins,provenancePins:pin.files,family,terminalCount,edges,certificates,scope:'Exact exclusive private Type envelopes; cached Data never mutated; original Fold stays fresh; no general alias proof'},null,2)+'\n',{flag:'wx'});console.log(JSON.stringify({status:'STRICT_PRIVATE_RESTORE_ENVELOPES_DERIVED',outputSHA256:sha(result)}));
