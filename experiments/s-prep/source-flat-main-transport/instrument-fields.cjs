// Diagnostic literal/closure execution counters; Node's bundled parser, no install.
const fs=require('node:fs');
const acorn=require('internal/deps/acorn/acorn/dist/acorn');
const [input,output]=process.argv.slice(2);
const source=fs.readFileSync(input,'utf8');
const ast=acorn.parse(source,{ecmaVersion:'latest',locations:true});
const sites=[];const edits=[];
function walk(node,owner='(top-level)') {
 if(!node||typeof node!=='object')return;
 if(node.type==='FunctionDeclaration')owner=node.id?.name||owner;
 if(['ObjectExpression','ArrayExpression','ArrowFunctionExpression','FunctionExpression'].includes(node.type) && (node.type!=='FunctionExpression'||source.slice(node.start).startsWith('function'))){
  let kind=node.type;
  if(node.type==='ObjectExpression'){
   const tag=node.properties.find(p=>p.type==='Property'&&(p.key?.value??p.key?.name)==='$');
   kind='object:'+(tag?.value?.type==='Literal'?tag.value.value:'untagged');
  }
  const id=sites.length;sites.push({id,kind,propertyCount:node.type==='ObjectExpression'?node.properties.length:0,function:owner,line:node.loc.start.line,source:source.slice(node.start,Math.min(node.end,node.start+180))});
  edits.push({at:node.start,text:`__allocation_literal(${id}, (`},{at:node.end,text:'))'});
 }
 for(const [k,value] of Object.entries(node)){
  if(['loc','start','end'].includes(k))continue;
  if(Array.isArray(value))value.forEach(v=>walk(v,owner));
  else if(value&&typeof value==='object')walk(value,owner);
 }
}
walk(ast);
let changed=source;
for(const edit of edits.sort((a,b)=>b.at-a.at))changed=changed.slice(0,edit.at)+edit.text+changed.slice(edit.at);
const prelude=`let __allocation_active=false;\nconst __allocation_counts=new Float64Array(${sites.length});\nfunction __allocation_literal(site,value){if(__allocation_active)__allocation_counts[site]++;return value;}\nfunction __allocation_phase(phase){if(phase==='start')__allocation_active=true;else {__allocation_active=false;console.error('ALLOCATION-COUNTS:'+JSON.stringify(Array.from(__allocation_counts)));}}\n`;
acorn.parse(prelude+changed,{ecmaVersion:'latest'});
fs.writeFileSync(output,prelude+changed);
fs.writeFileSync(output+'.sites.json',JSON.stringify({parserVersion:acorn.version,scope:'Executed literal/closure construction sites, not exact physical heap allocations/bytes; instrumentation changes escape optimization and JIT',sites},null,2)+'\n');
