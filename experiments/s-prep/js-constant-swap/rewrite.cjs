'use strict';
const fs=require('fs'), crypto=require('crypto'), path=require('path');
const acorn=require('internal/deps/acorn/acorn/dist/acorn');
const sha=x=>crypto.createHash('sha256').update(x).digest('hex');
const [input,output]=process.argv.slice(2);if(!input||!output||fs.existsSync(output))throw Error('fresh output required');
const s=fs.readFileSync(input,'utf8'), pins=JSON.parse(fs.readFileSync(path.join(__dirname,'input-pins.json'))),pin=pins[sha(s)];if(!pin)throw Error('unknown input');
for(const [p,h] of Object.entries(pin.files))if(sha(fs.readFileSync(p))!==h)throw Error('changed provenance '+p);
const ast=acorn.parse(s,{ecmaVersion:'latest',locations:true}),parents=new Map(),nodes=[];
function walk(n,p){if(!n||typeof n!=='object')return;if(n.type){nodes.push(n);parents.set(n,p);}for(const [k,v]of Object.entries(n))if(!['loc','start','end'].includes(k)){if(Array.isArray(v))for(const x of v)walk(x,n);else if(v&&typeof v==='object')walk(v,n);}}walk(ast,null);
const text=n=>s.slice(n.start,n.end),up=(n,t)=>{for(let x=n;x;x=parents.get(x))if(x.type===t)return x;return null;};
const prefix='__constant_swap_';if(s.includes(prefix))throw Error('reserved namespace');
const runtime=nodes.filter(n=>n.type==='FunctionDeclaration'&&n.id.name==='array_rmw');if(runtime.length!==1||sha(text(runtime[0]))!==pin.runtimeSHA256)throw Error('runtime body changed');
const expected='function array_rmw(a, i, f) {\n  const at = i % a.length;\n  const old = a[at];\n  a[at] = f(old);\n  return {$: "Tuple", fst: a, snd: old};\n}';if(text(runtime[0])!==expected)throw Error('unsupported runtime');
for(const n of nodes){if(n.type==='WithStatement'||n.type==='Identifier'&&['eval','Proxy','Reflect'].includes(n.name))throw Error('reflection');if(n.type==='MemberExpression'&&!n.computed&&['caller','callee','__proto__','prototype','constructor','defineProperty','setPrototypeOf'].includes(n.property.name))throw Error('reflection/property effects');}
for(const n of nodes){if(n.type==='VariableDeclarator'&&n.id.type==='Identifier'&&n.id.name==='array_rmw'||['FunctionExpression','ArrowFunctionExpression','FunctionDeclaration'].includes(n.type)&&n.params.some(p=>p.type==='Identifier'&&p.name==='array_rmw')||n.type==='AssignmentExpression'&&n.left.type==='Identifier'&&n.left.name==='array_rmw'||n.type==='UpdateExpression'&&n.argument.type==='Identifier'&&n.argument.name==='array_rmw')throw Error('runtime binding shadow/write');}
for(const n of nodes)if(n.type==='Identifier'&&n.name==='array_rmw'){const p=parents.get(n);if(!(p.type==='FunctionDeclaration'&&p.id===n||p.type==='CallExpression'&&p.callee===n))throw Error('runtime identity/escape');}
const edits=[],sites=[];
for(const call of nodes.filter(n=>n.type==='CallExpression'&&n.callee.type==='Identifier'&&n.callee.name==='array_rmw')){
 if(call.optional||call.arguments.length!==3||call.arguments.some(x=>x.type==='SpreadElement'))throw Error('unsupported swap arity');
 const arrow=call.arguments[2];if(arrow.type!=='ArrowFunctionExpression'||arrow.params.length||arrow.async||arrow.body.type!=='Identifier')throw Error('nonconstant arrow');
 const block=up(call,'BlockStatement'),fn=up(call,'FunctionDeclaration'),name=arrow.body.name;if(!block||!fn)throw Error('missing local block');
 const defs=block.body.filter(n=>n.type==='VariableDeclaration').flatMap(n=>n.declarations.map(d=>({decl:n,d}))).filter(x=>x.d.id.type==='Identifier'&&x.d.id.name===name);
 if(defs.length!==1||defs[0].decl.kind!=='const'||!defs[0].d.init||defs[0].decl.end>=call.start)throw Error('not dominating same-block const');
 let st=call;while(parents.get(st)!==block&&parents.get(st))st=parents.get(st);if(!block.body.includes(st)||block.body.indexOf(defs[0].decl)>=block.body.indexOf(st))throw Error('not earlier same-block statement');
 // Bindings along the lexical path must resolve exactly to this const; no duplicate binder or parameter.
 for(let scope=call;scope&&scope!==fn;scope=parents.get(scope))if(scope.type==='ArrowFunctionExpression'&&scope!==arrow||scope.type==='FunctionExpression'||scope.type==='FunctionDeclaration')throw Error('nested scope uncertainty');
 const relevant=nodes.filter(n=>n.start>=fn.start&&n.end<=fn.end);
 const binders=relevant.filter(n=>n.type==='VariableDeclarator'&&n.id.type==='Identifier'&&[name,'array_rmw'].includes(n.id.name));
 if(binders.filter(n=>n.id.name===name).length!==1||binders.some(n=>n.id.name==='array_rmw')||fn.params.some(n=>n.type!=='Identifier'||[name,'array_rmw'].includes(n.name)))throw Error('shadow/duplicate binding');
 for(const n of relevant)if(n.type==='AssignmentExpression'&&n.left.type==='Identifier'&&[name,'array_rmw'].includes(n.left.name)||n.type==='UpdateExpression'&&n.argument.type==='Identifier'&&[name,'array_rmw'].includes(n.argument.name))throw Error('binding write');
 edits.push({start:call.callee.start,end:call.callee.end,value:prefix+'value'},{start:arrow.start,end:arrow.end,value:name});sites.push({line:call.loc.start.line,caller:fn.id.name,callSHA256:sha(text(call)),bindingSHA256:sha(text(defs[0].decl)),arrowSHA256:sha(text(arrow))});
}
if(!sites.length||sites.length!==pin.expectedSites)throw Error('site cardinality');
let result=s;for(const e of edits.sort((a,b)=>b.start-a.start))result=result.slice(0,e.start)+e.value+result.slice(e.end);
result+='\n'+expected.replace('array_rmw(a, i, f)','__constant_swap_value(a, i, value)').replace('f(old)','value')+'\n';
fs.writeFileSync(output,result,{flag:'wx'});fs.writeFileSync(output+'.recipe.json',JSON.stringify({status:'STRICT_CONSTANT_SWAP_PASS',inputSHA256:sha(s),outputSHA256:sha(result),recipeSHA256:sha(fs.readFileSync(__filename)),sourceClosure:pin.sourceClosure,sites,scope:'Generated closed program causal probe only; original runtime and fresh Tuple retained'},null,2)+'\n',{flag:'wx'});
console.log(JSON.stringify({status:'STRICT_CONSTANT_SWAP_PASS',sites:sites.length,outputSHA256:sha(result)}));
