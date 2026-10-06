// Generated-code causal probe only. No general alias-safety claim.
const fs=require('node:fs'), crypto=require('node:crypto');
const acorn=require('internal/deps/acorn/acorn/dist/acorn');
const [input,output,schemaOnly,mode]=process.argv.slice(2); if(mode&&mode!=='--suppressed-main')throw Error('mode'); if(schemaOnly&&!['motion','health'].includes(schemaOnly))throw Error('schema'); const schemas=schemaOnly?[schemaOnly]:['motion','health']; if(!input||!output||fs.existsSync(output))throw Error('fresh output required');
const source=fs.readFileSync(input,'utf8'), tree=acorn.parse(source,{ecmaVersion:'latest'});
if(mode){const pins=JSON.parse(fs.readFileSync(__dirname+'/suppressed-pins.json'));const pin=pins[crypto.createHash('sha256').update(source).digest('hex')];if(!pin||pin.schema!==schemaOnly)throw Error('suppressed source pin');}
const defs=tree.body.filter(n=>n.type==='FunctionDeclaration'), edits=[], catalog=[];
const txt=n=>source.slice(n.start,n.end);
const assert=(v,m)=>{if(!v)throw Error(m)};
const fields=['world','main','ledger','handle','undo','commands','pings','marks'];
function find(s){const xs=defs.filter(n=>n.id.name.endsWith('held$045adapter$058'+s+'$'));assert(xs.length===1,'unique '+s);return xs[0]}
function obj(n,keys,tag){assert(n.type==='ObjectExpression','object'); assert(n.properties.every(p=>p.type==='Property'&&!p.computed&&p.kind==='init'),'plain properties');assert(JSON.stringify(n.properties.map(p=>p.key.value??p.key.name))===JSON.stringify(['$',...keys]),'field order');assert(n.properties[0].value.type==='Literal'&&(n.properties[0].value.value===tag.slice(1)||n.properties[0].value.value.endsWith(tag)),'tag '+tag);return Object.fromEntries(n.properties.map(p=>[p.key.value??p.key.name,p.value]));}
function ret(n){const rs=n.body.body.filter(x=>x.type==='ReturnStatement');assert(rs.length===1&&n.body.body.at(-1)===rs[0],'one final return');return rs[0]}
for(const schema of schemas)for(const op of ['get','ledger']){
 const n=find(schema+'_'+op),r=ret(n);assert(n.params.length===2&&n.params[0].name==='_owner_0','getter owner');const t=obj(r.argument,['fst','snd'],'Tuple');const h=obj(t.fst,fields,'/held.Held');obj(h[op==='get'?'main':'ledger'],['raw','cached'],'/cache.Cache');
 const bindings={};for(const st of n.body.body.slice(0,-1)){assert(st.type==='VariableDeclaration'&&st.kind==='const'&&st.declarations.length===1,'read constants');const b=st.declarations[0];assert(b.id.type==='Identifier'&&b.init.type==='MemberExpression'&&b.init.computed&&b.init.property.type==='Literal','read projection');bindings[b.id.name]=b.init;}
 function path(x){if(x.type==='Identifier'){if(x.name==='_owner_0')return [];assert(bindings[x.name],'projection binder');return path(bindings[x.name]);}assert(x.type==='MemberExpression'&&x.computed&&x.property.type==='Literal','projection expression');return [...path(x.object),x.property.value];}
 const selected=op==='get'?'main':'ledger';for(const f of fields){if(f===selected){const cc=obj(h[f],['raw','cached'],'/cache.Cache');for(const k of ['raw','cached'])assert(JSON.stringify(path(cc[k]))===JSON.stringify([f,k]),'cache identity');}else assert(JSON.stringify(path(h[f]))===JSON.stringify([f]),'owner identity');}
 assert(t.snd.type==='ObjectExpression'&&t.snd.properties.length===2&&t.snd.properties[1].key.value==='value'&&JSON.stringify(path(t.snd.properties[1].value))===JSON.stringify([selected,'cached']),'view identity');edits.push([t.fst.start,t.fst.end,'_owner_0']);catalog.push({helper:n.id.name,kind:'read',removedObjects:2});
}
for(const schema of schemas)for(const op of ['set','setledger']){
 const n=find(schema+'_'+op),r=ret(n),d=find(schema+'_'+op+'_fused_done'),dr=ret(d);assert(n.params.length===3&&n.params[0].name==='_owner_0','setter owner');const suppressed=!!mode&&op==='set',arity=suppressed?8:10;assert(r.argument.type==='CallExpression'&&r.argument.callee.name===d.id.name&&r.argument.arguments.length===arity,'done call');assert(d.params.length===arity,'done params');
 let calls=0;function walk(x){if(!x||typeof x!=='object')return;if(x.type==='CallExpression'&&x.callee.type==='Identifier'&&x.callee.name===d.id.name)calls++;for(const v of Object.values(x))if(Array.isArray(v))v.forEach(walk);else if(v&&typeof v==='object')walk(v);}walk(tree);assert(calls===1,'unique done caller');
 const h=obj(dr.argument,fields,'/held.Held'),selected=op==='set'?'main':'ledger',c=obj(h[selected],['raw','cached'],'/cache.Cache');assert(c.raw.type==='Identifier'&&c.cached.type===(suppressed?'Identifier':'CallExpression'),'cache raw+patch');assert(!source.includes('__reuse_owner'),'reserved binder');
 edits.push([r.argument.end-1,r.argument.end-1,', _owner_0']);const pos=source.indexOf(')',d.id.end);assert(pos<d.body.start,'parameter close');edits.push([pos,pos,', __reuse_owner']);
 // Evaluate all original expressions in original order before changing affine containers.
 let code='';for(const f of fields){if(f===selected){code+='const __reuse_raw = '+txt(c.raw)+';\nconst __reuse_cached = '+txt(c.cached)+';\n';}else code+='const __reuse_'+f+' = '+txt(h[f])+';\n';}
 code+='const __reuse_cache = __reuse_owner['+JSON.stringify(selected)+'];\n__reuse_cache.raw = __reuse_raw;\n__reuse_cache.cached = __reuse_cached;\n';
 for(const f of fields)code+='__reuse_owner['+JSON.stringify(f)+'] = '+(f===selected?'__reuse_cache':'__reuse_'+f)+';\n';code+='return __reuse_owner;';edits.push([dr.start,dr.end,code]);catalog.push({helper:n.id.name,done:d.id.name,kind:'write',removedObjects:2,selected});
}
edits.sort((a,b)=>b[0]-a[0]);let out=source,last=source.length;for(const [a,b,s]of edits){assert(b<=last,'overlapping edits');out=out.slice(0,a)+s+out.slice(b);last=a;}acorn.parse(out,{ecmaVersion:'latest'});fs.writeFileSync(output,out);const sha=s=>crypto.createHash('sha256').update(s).digest('hex');fs.writeFileSync(output+'.recipe.json',JSON.stringify({mode:mode||'normal',scope:'generated affine owner reuse causal probe; no universal alias proof',inputSHA256:sha(source),outputSHA256:sha(out),recipeSHA256:sha(fs.readFileSync(__filename)),catalog},null,2)+'\n');
