// Exact pinned constant Array.swap -> projection-only receiver causal probe.
const fs=require('node:fs'),crypto=require('node:crypto');
const acorn=require('internal/deps/acorn/acorn/dist/acorn');
const [input,output]=process.argv.slice(2),sha=s=>crypto.createHash('sha256').update(s).digest('hex');
function requireThat(v,m){if(!v)throw Error(m)}
requireThat(input&&output&&!fs.existsSync(output),'input and absent output required');
const source=fs.readFileSync(input,'utf8'),pins=JSON.parse(fs.readFileSync(__dirname+'/input-pins.json'));
const pin=pins[sha(source)];if(pin?.runtimeSourcePins){requireThat(Object.keys(pin.runtimeSourcePins).length===29,'29 source pins');for(const[n,d]of Object.entries(pin.runtimeSourcePins))requireThat(sha(fs.readFileSync(pin.sourceRoot+'/'+n))===d,'actual source pin '+n);}
requireThat(pins[sha(source)],'unsupported source hash');requireThat(!source.includes('__swap_')&&!source.includes('__swap_split')&&!source.includes('__swap_fst')&&!source.includes('__swap_snd'),'reserved names');
requireThat(source.includes('function array_rmw(a, i, f) {\n  const at = i % a.length;\n  const old = a[at];\n  a[at] = f(old);\n  return {$: \"Tuple\", fst: a, snd: old};\n}'),'exact runtime rmw');
const ast=acorn.parse(source,{ecmaVersion:'latest',locations:true}),defs=new Map(),bound=[],writes=new Set();
function walk(n,visit,parent=null,owner=null){if(!n||typeof n!=='object')return;if(['FunctionDeclaration','FunctionExpression','ArrowFunctionExpression'].includes(n.type))owner=n;visit(n,parent,owner);for(const[k,v]of Object.entries(n))if(!['loc','start','end'].includes(k)){if(Array.isArray(v))v.forEach(x=>walk(x,visit,n,owner));else if(v&&typeof v==='object')walk(v,visit,n,owner);}}
for(const n of ast.body)if(n.type==='FunctionDeclaration'){requireThat(!defs.has(n.id.name),'duplicate top function');defs.set(n.id.name,n);}
walk(ast,(n,p)=>{if(n.type==='VariableDeclarator'&&n.id.type==='Identifier')bound.push(n.id.name);if(n.type==='FunctionDeclaration'&&p!==ast)bound.push(n.id.name);if(['FunctionDeclaration','FunctionExpression','ArrowFunctionExpression'].includes(n.type))for(const x of n.params)if(x.type==='Identifier')bound.push(x.name);if(n.type==='AssignmentExpression'&&n.left.type==='Identifier')writes.add(n.left.name);if(n.type==='UpdateExpression'&&n.argument.type==='Identifier')writes.add(n.argument.name);});
function pattern(n){if(!n)return;if(n.type==='Identifier'){bound.push(n.name);return;}if(n.type==='RestElement')return pattern(n.argument);if(n.type==='AssignmentPattern')return pattern(n.left);if(n.type==='ArrayPattern')return n.elements.forEach(pattern);if(n.type==='ObjectPattern')return n.properties.forEach(p=>pattern(p.type==='RestElement'?p.argument:p.value));throw Error('unsupported binding pattern');}
walk(ast,(n)=>{if(n.type==='VariableDeclarator')pattern(n.id);if(['FunctionDeclaration','FunctionExpression','ArrowFunctionExpression'].includes(n.type))n.params.forEach(pattern);if(n.type==='CatchClause')pattern(n.param);if(n.type==='ImportDeclaration')n.specifiers.forEach(x=>pattern(x.local));});
walk(ast,(n)=>{requireThat(!(n.type==='Property'&&['get','set'].includes(n.kind)),'accessor unsupported');requireThat(!(n.type==='Identifier'&&['Proxy','Reflect','defineProperty','setPrototypeOf'].includes(n.name)),'proxy/reflection unsupported');});
const parentOf=new Map();walk(ast,(n,p)=>{if(p)parentOf.set(n,p)});
const boundNames=new Set(bound),receiverInfo=new Map(),edges=[];
function checkReceiver(d){
 if(receiverInfo.has(d.id.name))return receiverInfo.get(d.id.name);
 let bad=d.async||d.generator||d.params.some(p=>p.type!=='Identifier'),refs=[],binders=d.params.map(x=>x.name),pair=d.params.at(-1)?.name;
 walk(d.body,(n,p)=>{
  if(['FunctionDeclaration','FunctionExpression','ThisExpression','MetaProperty','Super','AwaitExpression','YieldExpression','DebuggerStatement'].includes(n.type))bad=true;
  if(n.type==='ArrowFunctionExpression' && !(n.params.length===0&&!n.async&&n.body.type==='Identifier'&&n.body.name!==pair))bad=true;
  if(n.type==='VariableDeclarator'){if(n.id.type!=='Identifier')bad=true;else binders.push(n.id.name);}
  if(n.type==='CatchClause')bad=true;
  if(n.type==='Identifier'&&['arguments','eval'].includes(n.name))bad=true;
  if(n.type==='Identifier'&&n.name===pair){const member=p?.type==='MemberExpression'&&!p.optional&&p.object===n&&((p.computed&&p.property.type==='Literal')||(!p.computed&&p.property.type==='Identifier'));if(member&&['fst','snd'].includes(p.property.value??p.property.name))refs.push(p);else bad=true;}
  if(n.type==='AssignmentExpression'||n.type==='UpdateExpression'||n.type==='UnaryExpression'&&n.operator==='delete'){const x=n.left||n.argument;if(x?.type==='MemberExpression'&&x.object.name===pair)bad=true;}
 });
 if(new Set(binders).size!==binders.length)bad=true;
 const info=!bad&&refs.length?{d,pair,refs}:null;receiverInfo.set(d.id.name,info);return info;
}
walk(ast,(n,p,owner)=>{
 if(n.type!=='CallExpression'||n.optional||n.callee.type!=='Identifier'||!defs.has(n.callee.name)||boundNames.has(n.callee.name)||writes.has(n.callee.name))return;
 // Only calls within a uniquely named top-level generated function. No nested scope.
 if(!owner||owner.type!=='FunctionDeclaration'||defs.get(owner.id.name)!==owner)return;
 const o=n.arguments.at(-1);if(o?.type!=='CallExpression'||o.callee.type!=='Identifier'||o.callee.name!=='array_rmw'||o.arguments.length!==3)return;
 if(boundNames.has('array_rmw')||writes.has('array_rmw'))return;
 const [fst,index,arrow]=o.arguments;
 if(fst.type!=='Identifier'||index.type!=='Identifier'||arrow.type!=='ArrowFunctionExpression'||arrow.params.length||arrow.async||arrow.body.type!=='Identifier')return;
 const val=arrow.body.name,bindings=[];let mutation=owner.params.some(x=>x.name===val);
 walk(owner,(x,p,scope)=>{if(x.type==='VariableDeclarator'&&x.id.type==='Identifier'&&x.id.name===val)bindings.push({x,p});if(x.type==='AssignmentExpression'&&x.left.type==='Identifier'&&x.left.name===val||x.type==='UpdateExpression'&&x.argument.type==='Identifier'&&x.argument.name===val)mutation=true;});
 if(bindings.length!==1||bindings[0].p.type!=='VariableDeclaration'||bindings[0].p.kind!=='const'||bindings[0].x.start>=o.start||mutation)return;
 let unique=true;for(const name of [fst.name,index.name,val]){let count=owner.params.filter(x=>x.name===name).length;walk(owner.body,(x)=>{if(x.type==='VariableDeclarator'&&x.id.type==='Identifier'&&x.id.name===name)count++;if(['FunctionDeclaration','FunctionExpression','ArrowFunctionExpression'].includes(x.type))for(const p of x.params)if(p.name===name)count++;if(x.type==='CatchClause'&&x.param?.name===name)count++;});if(count!==1)unique=false;}if(!unique)return;
 const declaration=bindings[0].p,block=parentOf.get(declaration);let scope=o,dominates=false;while(scope&&scope!==owner){if(scope===block){dominates=true;break;}scope=parentOf.get(scope);}if(!dominates||block.type!=='BlockStatement')return;
 const indexDefs=[];walk(owner.body,(x)=>{if(x.type==='VariableDeclarator'&&x.id.name===index.name)indexDefs.push(x);});if(indexDefs.some(x=>['ObjectExpression','ArrayExpression','NewExpression','FunctionExpression','ArrowFunctionExpression'].includes(x.init?.type)))return;
 const snd=arrow.body;
 const d=defs.get(n.callee.name);if(d.params.length!==n.arguments.length)return;const info=checkReceiver(d);if(!info)return;
 edges.push({call:n,tuple:o,fst,snd,index,info,owner});
});
requireThat(edges.length>0,'no supported edges');
const text=n=>source.slice(n.start,n.end),edits=[];
for(const e of edges){edits.push([e.call.callee.start,e.call.callee.end,e.info.d.id.name+'__swap_split']);edits.push([e.tuple.start,e.tuple.end,'('+text(e.fst)+'), ('+text(e.index)+'), ('+text(e.snd)+')']);}
function apply(start,end,changes){let s=source.slice(start,end),last=end;for(const[a,b,t]of changes.filter(x=>x[0]>=start&&x[1]<=end).sort((a,b)=>b[0]-a[0])){requireThat(b<=last,'overlapping edits');s=s.slice(0,a-start)+t+s.slice(b-start);last=a;}return s;}
let derived='';const receivers=[...new Map(edges.map(e=>[e.info.d.id.name,e.info])).values()];
for(const info of receivers){const d=info.d,params=d.params.slice(0,-1).map(text).concat(['__swap_fst','__swap_index','__swap_value']);const projections=info.refs.map(n=>[n.start,n.end,(n.property.value??n.property.name)==='fst'?'__swap_fst':'__swap_snd']);const body=apply(d.body.start,d.body.end,[...edits,...projections]);derived+='\nfunction '+d.id.name+'__swap_split('+params.join(', ')+') '+'{\n const __swap_at = __swap_index % __swap_fst.length;\n const __swap_snd = __swap_fst[__swap_at];\n __swap_fst[__swap_at] = __swap_value;\n'+body.slice(1)+'\n';}
const changed=apply(0,source.length,edits)+'\n'+derived;acorn.parse(changed,{ecmaVersion:'latest'});
fs.writeFileSync(output,changed);fs.writeFileSync(output+'.recipe.json',JSON.stringify({scope:'Pinned generated-JS constant Array.swap direct-call product split; no general optimizer/refinement/qualification',parserVersion:acorn.version,inputSHA256:sha(source),outputSHA256:sha(changed),recipeSHA256:sha(fs.readFileSync(__filename)),catalogSHA256:sha(fs.readFileSync(__dirname+'/input-pins.json')),sourcePins:pin?.runtimeSourcePins,edges:edges.map(e=>({caller:e.owner.id.name,receiver:e.info.d.id.name,line:e.tuple.loc.start.line,source:text(e.tuple),projectionReads:e.info.refs.length})),derivedReceivers:receivers.length,removedClosureSites:edges.length,addedClosures:0},null,2)+'\n');
