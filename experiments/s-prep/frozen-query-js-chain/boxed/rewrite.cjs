// Generated-code causal probe only. No general alias-safety claim.
const fs=require('node:fs'), crypto=require('node:crypto');
const acorn=require('internal/deps/acorn/acorn/dist/acorn');
const [input,output,schemaOnly,mode]=process.argv.slice(2); if(mode&&mode!=='--suppressed-main')throw Error('mode'); if(schemaOnly&&!['motion','health'].includes(schemaOnly))throw Error('schema'); const schemas=schemaOnly?[schemaOnly]:['motion','health']; if(!input||!output||fs.existsSync(output))throw Error('fresh output required');
const source=fs.readFileSync(input,'utf8'), tree=acorn.parse(source,{ecmaVersion:'latest'});
const inputSHA=crypto.createHash('sha256').update(source).digest('hex');
const pin=JSON.parse(fs.readFileSync(__dirname+'/input-pins.json'))[inputSHA];
if(!pin||pin.schema!==schemaOnly||pin.mode!==(mode?'suppressed':'normal'))throw Error('exact boxed source/input pin');
for(const [name,digest] of Object.entries(pin.sourcePins))if(crypto.createHash('sha256').update(fs.readFileSync(pin.sourceRoot+'/'+name)).digest('hex')!==digest)throw Error('actual source pin '+name);
const actualSource=fs.readFileSync(pin.sourceRoot+'/held-adapter.bend','utf8');
if(source.includes('__boxed_reuse_'))throw Error('reserved binder namespace');
const defs=tree.body.filter(n=>n.type==='FunctionDeclaration'), edits=[], catalog=[];
const txt=n=>source.slice(n.start,n.end);
const assert=(v,m)=>{if(!v)throw Error(m)};
const fields=['world','main','ledger','handle','undo','commands','pings','marks'];
function find(s){const xs=defs.filter(n=>n.id.name.endsWith('held$045adapter$058'+s+'$'));assert(xs.length===1,'unique '+s);return xs[0]}
function obj(n,keys,tag){assert(n.type==='ObjectExpression','object'); assert(n.properties.every(p=>p.type==='Property'&&!p.computed&&p.kind==='init'),'plain properties');assert(JSON.stringify(n.properties.map(p=>p.key.value??p.key.name))===JSON.stringify(['$',...keys]),'field order');assert(n.properties[0].value.type==='Literal'&&(n.properties[0].value.value===tag.slice(1)||n.properties[0].value.value.endsWith(tag)),'tag '+tag);return Object.fromEntries(n.properties.map(p=>[p.key.value??p.key.name,p.value]));}
function ret(n){const rs=n.body.body.filter(x=>x.type==='ReturnStatement');assert(rs.length===1&&n.body.body.at(-1)===rs[0],'one final return');return rs[0]}
function scope(n){assert(n.params.every(p=>p.type==='Identifier')&&new Set(n.params.map(p=>p.name)).size===n.params.length,'plain unique parameters');const available=new Set(n.params.map(p=>p.name));for(const st of n.body.body.slice(0,-1)){assert(st.type==='VariableDeclaration'&&st.kind==='const'&&st.declarations.length===1,'only preceding const bindings');const d=st.declarations[0];assert(d.id.type==='Identifier'&&!available.has(d.id.name),'fresh local binding');function projection(x){if(x.type==='Identifier'){assert(available.has(x.name),'local reference in scope');return}assert(x.type==='MemberExpression'&&x.computed&&x.property.type==='Literal'&&typeof x.property.value==='string','pure preceding projection');projection(x.object)}projection(d.init);available.add(d.id.name)}return available}

function walk(x,fn){if(!x||typeof x!=='object')return;fn(x);for(const v of Object.values(x))if(Array.isArray(v))v.forEach(y=>walk(y,fn));else if(v&&typeof v==='object')walk(v,fn)}
function calls(n){const xs=[];walk(n,x=>{if(x.type==='CallExpression'&&x.callee.type==='Identifier')xs.push(x.callee.name)});return xs}
function specialized(s){const xs=defs.filter(n=>n.id.name.includes('held$045adapter$058'+s+'$126'));assert(xs.length===1,'unique reached specialization '+s);return xs[0]}
function sourceDef(s){const at=actualSource.indexOf('def '+s+'(');assert(at>=0,'actual source def '+s);const next=actualSource.indexOf('\ndef ',at+1);return actualSource.slice(at,next<0?actualSource.length:next)}
const reachability=[];
for(const schema of schemas){
 const fieldsChecked=specialized(schema+'_fields_checked'),taken=specialized('prototype_boxed_'+schema+'_taken'),invoke=specialized('prototype_boxed_'+schema+'_invoke');
 assert(calls(fieldsChecked).filter(x=>x===taken.id.name).length===1,'fields_checked reaches boxed taken');
 assert(calls(taken).filter(x=>x===invoke.id.name).length===1,'boxed taken reaches boxed invoke');
 const sourceFields=sourceDef(schema+'_fields_checked'),sourceTaken=sourceDef('prototype_boxed_'+schema+'_taken'),sourceInvoke=sourceDef('prototype_boxed_'+schema+'_invoke');
 assert(sourceFields.includes('prototype_boxed_'+schema+'_taken(~client,'),'source fields->boxed taken');
 assert(sourceTaken.includes('prototype_boxed_'+schema+'_invoke(~client,'),'source taken->boxed invoke');
 const seen=new Set(),byName=new Map(defs.map(n=>[n.id.name,n]));function visit(n){if(seen.has(n.id.name))return;seen.add(n.id.name);for(const c of calls(n))if(byName.has(c))visit(byName.get(c))}visit(invoke);
 const selected=[];for(const op of ['get','ledger','set','setledger']){const n=find('prototype_boxed_'+schema+'_'+op);assert(seen.has(n.id.name),'live boxed family '+op);assert(sourceInvoke.includes('prototype_boxed_'+schema+'_'+op),'source selected boxed family '+op);selected.push(n.id.name)}
 reachability.push({schema,fieldsChecked:fieldsChecked.id.name,taken:taken.id.name,invoke:invoke.id.name,selected,sourceHeldAdapterSHA256:pin.sourcePins['held-adapter.bend']});
}

for(const schema of schemas)for(const op of ['get','ledger']){
 const n=find('prototype_boxed_'+schema+'_'+op),r=ret(n);scope(n);assert(n.params.length===2&&n.params[0].name==='_owner_0','getter owner');const t=obj(r.argument,['fst','snd'],'Tuple');const h=obj(t.fst,fields,'/held.Held');obj(h[op==='get'?'main':'ledger'],['raw','cached'],'/cache.Cache');
 const bindings={};for(const st of n.body.body.slice(0,-1)){assert(st.type==='VariableDeclaration'&&st.kind==='const'&&st.declarations.length===1,'read constants');const b=st.declarations[0];assert(b.id.type==='Identifier'&&b.init.type==='MemberExpression'&&b.init.computed&&b.init.property.type==='Literal','read projection');bindings[b.id.name]=b.init;}
 function path(x){if(x.type==='Identifier'){if(x.name==='_owner_0')return [];assert(bindings[x.name],'projection binder');return path(bindings[x.name]);}assert(x.type==='MemberExpression'&&x.computed&&x.property.type==='Literal','projection expression');return [...path(x.object),x.property.value];}
 const selected=op==='get'?'main':'ledger';for(const f of fields){if(f===selected){const cc=obj(h[f],['raw','cached'],'/cache.Cache');for(const k of ['raw','cached'])assert(JSON.stringify(path(cc[k]))===JSON.stringify([f,k]),'cache identity');}else assert(JSON.stringify(path(h[f]))===JSON.stringify([f]),'owner identity');}
 assert(t.snd.type==='ObjectExpression'&&t.snd.properties.length===2&&t.snd.properties[1].key.value==='value'&&JSON.stringify(path(t.snd.properties[1].value))===JSON.stringify([selected,'cached']),'view identity');edits.push([t.fst.start,t.fst.end,'_owner_0']);catalog.push({helper:n.id.name,kind:'read',removedObjects:2});
}
for(const schema of schemas)for(const op of ['set','setledger']){
 const n=find('prototype_boxed_'+schema+'_'+op),r=ret(n),d=find('prototype_boxed_'+schema+'_'+op+'_fused_done'),dr=ret(d);scope(n);scope(d);assert(n.params.length===3&&n.params[0].name==='_owner_0','setter owner');const suppressed=!!mode&&op==='set',arity=suppressed?8:10;assert(r.argument.type==='CallExpression'&&r.argument.callee.name===d.id.name&&r.argument.arguments.length===arity,'done call');assert(d.params.length===arity,'done params');
 let calls=0;function walk(x){if(!x||typeof x!=='object')return;if(x.type==='CallExpression'&&x.callee.type==='Identifier'&&x.callee.name===d.id.name)calls++;for(const v of Object.values(x))if(Array.isArray(v))v.forEach(walk);else if(v&&typeof v==='object')walk(v);}walk(tree);assert(calls===1,'unique done caller');
 const h=obj(dr.argument,fields,'/held.Held'),selected=op==='set'?'main':'ledger',c=obj(h[selected],['raw','cached'],'/cache.Cache');assert(c.raw.type==='Identifier'&&c.cached.type===(suppressed?'Identifier':'CallExpression'),'cache raw+patch');if(!suppressed){assert(c.cached.callee.type==='Identifier'&&c.cached.callee.name.includes('cached$045payload$058')&&c.cached.callee.name.endsWith('_patch$'),'selected immutable patch helper');const patch=defs.filter(x=>x.id.name===c.cached.callee.name);assert(patch.length===1,'unique immutable patch definition');scope(patch[0]);assert(ret(patch[0]).argument.type==='ObjectExpression','patch creates new Data record');}assert(!source.includes('__boxed_reuse_owner'),'reserved binder');
 edits.push([r.argument.end-1,r.argument.end-1,', _owner_0']);const pos=source.indexOf(')',d.id.end);assert(pos<d.body.start,'parameter close');edits.push([pos,pos,', __boxed_reuse_owner']);
 // Evaluate all original expressions in original order before changing affine containers.
 let code='';for(const f of fields){if(f===selected){code+='const __boxed_reuse_raw = '+txt(c.raw)+';\nconst __boxed_reuse_cached = '+txt(c.cached)+';\n';}else code+='const __boxed_reuse_'+f+' = '+txt(h[f])+';\n';}
 code+='const __boxed_reuse_cache = __boxed_reuse_owner['+JSON.stringify(selected)+'];\n__boxed_reuse_cache.raw = __boxed_reuse_raw;\n__boxed_reuse_cache.cached = __boxed_reuse_cached;\n';
 for(const f of fields)code+='__boxed_reuse_owner['+JSON.stringify(f)+'] = '+(f===selected?'__boxed_reuse_cache':'__boxed_reuse_'+f)+';\n';code+='return __boxed_reuse_owner;';edits.push([dr.start,dr.end,code]);catalog.push({helper:n.id.name,done:d.id.name,kind:'write',removedObjects:2,selected});
}
edits.sort((a,b)=>b[0]-a[0]);let out=source,last=source.length;for(const [a,b,s]of edits){assert(b<=last,'overlapping edits');out=out.slice(0,a)+s+out.slice(b);last=a;}acorn.parse(out,{ecmaVersion:'latest'});fs.writeFileSync(output,out);const sha=s=>crypto.createHash('sha256').update(s).digest('hex');fs.writeFileSync(output+'.recipe.json',JSON.stringify({sourcePins:pin.sourcePins,sourceRoot:pin.sourceRoot,inputCatalogSHA256:sha(fs.readFileSync(__dirname+'/input-pins.json')),reachability,mode:mode||'normal',scope:'generated affine owner reuse causal probe; no universal alias proof',inputSHA256:sha(source),outputSHA256:sha(out),recipeSHA256:sha(fs.readFileSync(__filename)),catalog},null,2)+'\n');
