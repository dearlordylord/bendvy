#!/usr/bin/env node
// Exact closed-program call-edge diagnostic; no source/compiler rewrite.
const fs=require('node:fs'),crypto=require('node:crypto');
const acorn=require('internal/deps/acorn/acorn/dist/acorn');
const [catalogPath,inputPath,outputPath,receiptPath]=process.argv.slice(2);
const hash=s=>crypto.createHash('sha256').update(s).digest('hex');
const assert=(x,m)=>{if(!x)throw Error(m);};
assert(!fs.existsSync(outputPath),'output exists');
const source=fs.readFileSync(inputPath,'utf8'),catalog=JSON.parse(fs.readFileSync(catalogPath));
const pin=catalog.inputs[hash(source)];assert(pin,'unapproved JS input');
for(const [p,h] of Object.entries(catalog.source29Pins))assert(hash(fs.readFileSync(p))===h,'source pin changed '+p);
assert(Object.keys(catalog.source29Pins).length===29,'source closure size');
const ast=acorn.parse(source,{ecmaVersion:'latest',sourceType:'script'}),prefix='__bendvy_publish_edge_probe';assert(!source.includes(prefix),'counter namespace collision');
const funcs=ast.body.filter(n=>n.type==='FunctionDeclaration');
const pick=suffix=>{const a=funcs.filter(n=>n.id.name.endsWith(suffix));assert(a.length===1,'unique function '+suffix);return a[0];};
const reserve=pick('commands$058reserve$'),reserved=pick('commands$058reserved$'),publish=pick('storage$058publish$');
for(const f of [reserve,reserved,publish])assert(f.params.length===2&&f.params.every(x=>x.type==='Identifier'),'function signature');
const calls=[];function walk(n,owner){if(!n||typeof n!=='object')return;if(n.type==='FunctionDeclaration')owner=n.id.name;if(n.type==='CallExpression'&&n.callee.type==='Identifier'&&n.callee.name===publish.id.name)calls.push({node:n,owner});for(const [k,v] of Object.entries(n)){if(k==='start'||k==='end')continue;if(Array.isArray(v))v.forEach(x=>walk(x,owner));else if(v&&typeof v==='object')walk(v,owner);}}
walk(ast,null);assert(calls.length===1&&calls[0].owner===reserved.id.name&&calls[0].node.arguments.length===2,'exact original-publish edge');
const absentQueue=funcs.filter(n=>/commands\$058queue_(checked|owned)\$/.test(n.id.name));assert(absentQueue.length===0,'queue path unexpectedly emitted');
const edits=[{at:0,text:`const ${prefix}={reserve:0,reserved:0,publish:0,edge:0};process.on('exit',()=>process.stderr.write('BENDVY_PUBLISH_EDGES '+JSON.stringify(${prefix})+'\\n'));\n`}];
for(const [f,label] of [[reserve,'reserve'],[reserved,'reserved'],[publish,'publish']])edits.push({at:f.body.start+1,text:`${prefix}.${label}++;`});
const call=calls[0].node;edits.push({at:call.start,text:`(${prefix}.edge++,`},{at:call.end,text:')'});
edits.sort((a,b)=>b.at-a.at);let out=source;for(const e of edits)out=out.slice(0,e.at)+e.text+out.slice(e.at);
acorn.parse(out,{ecmaVersion:'latest',sourceType:'script'});fs.writeFileSync(outputPath,out,{flag:'wx'});
fs.writeFileSync(receiptPath,JSON.stringify({schema:pin.schema,inputSHA256:hash(source),outputSHA256:hash(out),recipeSHA256:hash(fs.readFileSync(__filename)),functions:[reserve.id.name,reserved.id.name,publish.id.name],edge:{caller:calls[0].owner,callee:publish.id.name},queueCheckedEmitted:false,scope:'Diagnostic JS entry/call edge counts; generated fields/args/work unchanged. No Native runtime attribution or elapsed result.'},null,2)+'\n',{flag:'wx'});
