// Bounded direct literal Tuple -> known projection-only receiver diagnosis.
const fs=require('node:fs');
const acorn=require('internal/deps/acorn/acorn/dist/acorn');
function scan(source){
 const ast=acorn.parse(source,{ecmaVersion:'latest',locations:true});
 const parent=new Map(),owner=new Map(),nodes=[],functions=new Map(),bindings=new Map(),writes=new Set();let ordinal=0;
 const construction=new Map();
 function walk(n,p=null,fn=null){if(!n||typeof n!=='object'||!n.type)return;parent.set(n,p);nodes.push(n);if(n.type==='FunctionDeclaration')fn=n;owner.set(n,fn);
  if(['ObjectExpression','ArrayExpression','ArrowFunctionExpression','FunctionExpression'].includes(n.type)&&(n.type!=='FunctionExpression'||source.slice(n.start).startsWith('function')))construction.set(n,ordinal++);
  if(n.type==='FunctionDeclaration'&&n.id){const l=functions.get(n.id.name)||[];l.push(n);functions.set(n.id.name,l);}
  for(const [k,v]of Object.entries(n)){if(['loc','start','end'].includes(k))continue;if(Array.isArray(v))v.forEach(x=>walk(x,n,fn));else if(v&&typeof v==='object')walk(v,n,fn);}
 }
 walk(ast);
 function bound(n){if(!n)return;if(n.type==='Identifier'){const l=bindings.get(n.name)||[];l.push(n);bindings.set(n.name,l);}else for(const [k,v]of Object.entries(n)){if(['loc','start','end'].includes(k))continue;if(Array.isArray(v))v.forEach(bound);else if(v&&typeof v==='object')bound(v);}}
 for(const n of nodes){if(['FunctionDeclaration','FunctionExpression','ArrowFunctionExpression'].includes(n.type)){if(n.id)bound(n.id);n.params.forEach(bound);}if(n.type==='VariableDeclarator')bound(n.id);if(n.type==='CatchClause')bound(n.param);if(n.type==='AssignmentExpression'&&n.left.type==='Identifier')writes.add(n.left.name);if(n.type==='UpdateExpression'&&n.argument.type==='Identifier')writes.add(n.argument.name);}
 const threats=nodes.filter(n=>(n.type==='Identifier'&&['eval','Proxy','Reflect','Function'].includes(n.name))||(n.type==='MemberExpression'&&['caller','callee'].includes(n.computed?n.property.value:n.property.name))); 
 const rejected=[],eligible=[],cache=new Map();
 function key(p){return p.key?.name??p.key?.value;}
 function tuple(n){return n.type==='ObjectExpression'&&n.properties.length===3&&n.properties.every((p,i)=>p.type==='Property'&&p.kind==='init'&&!p.computed&&!p.method&&!p.shorthand&&key(p)===['$','fst','snd'][i])&&n.properties[0].value.type==='Literal'&&n.properties[0].value.value==='Tuple';}
 function check(fn,index){const ck=fn.start+':'+index;if(cache.has(ck))return cache.get(ck);let reason=null;const refs=[];const pair=fn.params[index];
  if(fn.async||fn.generator||fn.params.some(p=>p.type!=='Identifier')||new Set(fn.params.map(p=>p.name)).size!==fn.params.length)reason='non-simple receiver parameters';
  if(!reason&&((bindings.get(pair.name)||[]).filter(n=>n.start>=fn.start&&n.end<=fn.end).length!==1))reason='duplicate or shadowed pair binding';
  function visit(n,depth=0){if(!n||typeof n!=='object'||!n.type)return;if(n!==fn&&['FunctionDeclaration','FunctionExpression','ArrowFunctionExpression'].includes(n.type))depth++;
   if(n.type==='Identifier'&&n.name==='arguments')reason='arguments reflection';if(n.type==='ThisExpression'||n.type==='MetaProperty')reason='receiver context reflection';
   if(n.type==='Identifier'&&n.name===pair?.name&&n!==pair){const p=parent.get(n);if(p?.type==='MemberExpression'&&p.property===n&&!p.computed)return;
    if(p?.type==='Property'&&p.key===n&&!p.computed&&!p.shorthand)return;
    if(depth)reason='captured pair reference';
    else if(p?.type!=='MemberExpression'||p.object!==n||p.optional||!((!p.computed&&p.property.type==='Identifier'&&['fst','snd'].includes(p.property.name))||(p.computed&&p.property.type==='Literal'&&['fst','snd'].includes(p.property.value))))reason='whole-pair escape/tag/unknown use';
    else {const q=parent.get(p);if((q?.type==='AssignmentExpression'&&q.left===p)||(q?.type==='UpdateExpression'&&q.argument===p)||(q?.type==='UnaryExpression'&&q.operator==='delete')||(q?.type==='CallExpression'&&q.callee===p)||(q?.type==='TaggedTemplateExpression'&&q.tag===p))reason='pair write or method receiver';else refs.push({start:p.start,end:p.end,field:p.computed?p.property.value:p.property.name});}
   }
   for(const [k,v]of Object.entries(n)){if(['loc','start','end'].includes(k))continue;if(Array.isArray(v))v.forEach(x=>visit(x,depth));else if(v&&typeof v==='object')visit(v,depth);}
  }
  if(!reason)visit(fn.body);if(!reason&&!refs.length)reason='unused pair (not projection-only receiver)';const r={reason,refs,pair:pair?.name};cache.set(ck,r);return r;
 }
 for(const n of nodes){if(n.type!=='CallExpression'||n.optional||n.callee.type!=='Identifier')continue;const candidates=functions.get(n.callee.name)||[];if(candidates.length!==1)continue;const fn=candidates[0];
  for(let index=0;index<n.arguments.length;index++){const t=n.arguments[index];if(!tuple(t))continue;let reason=null;
   if(parent.get(fn)?.type!=='Program')reason='non-top-level receiver may capture context';else if(threats.length)reason='global eval/Proxy/Reflect/Function threat';else if((bindings.get(fn.id.name)||[]).length!==1||writes.has(fn.id.name))reason='nonunique/shadowed/written receiver';else if(n.arguments.length!==fn.params.length||n.arguments.some(a=>a.type==='SpreadElement'))reason='arity/spread mismatch';
   const c=reason?{reason}:check(fn,index);reason=reason||c.reason;
   const record={receiver:fn.id.name,pairIndex:index,tupleStart:t.start,tupleEnd:t.end,callStart:n.start,callEnd:n.end,line:t.loc.start.line,literalOrdinal:construction.get(t),caller:owner.get(n)?.id?.name??'(top-level)',pairParameter:c.pair,projections:c.refs?.length};
   if(reason)rejected.push({...record,reason});else eligible.push({...record,projectionRanges:c.refs,receiverStart:fn.start,receiverEnd:fn.end});
  }
 }
 return {ast,functions,eligible,rejected,threats:threats.map(n=>({name:n.name||'caller/callee reflection',line:n.loc.start.line})),parserVersion:acorn.version};
}
module.exports={scan};
if(require.main===module){const [input,output]=process.argv.slice(2);const source=fs.readFileSync(input,'utf8');const x=scan(source);const result={status:'STATIC_DIRECT_TUPLE_DIAGNOSIS',parserVersion:x.parserVersion,eligibleSites:x.eligible,rejectedSites:x.rejected,threats:x.threats};fs.writeFileSync(output,JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify({eligibleSites:x.eligible.length,receivers:new Set(x.eligible.map(x=>x.receiver+':'+x.pairIndex)).size,rejectedSites:x.rejected.length,threats:x.threats.length}));}
