// Bounded AST diagnosis, no generated code mutation.
const fs=require('node:fs'),crypto=require('node:crypto');
const acorn=require('internal/deps/acorn/acorn/dist/acorn');
const [input,catalogPath,countsPath,output]=process.argv.slice(2);
if(!input||!catalogPath||!countsPath||!output||fs.existsSync(output))throw Error('four arguments and absent output required');
const source=fs.readFileSync(input,'utf8'),tree=acorn.parse(source,{ecmaVersion:'latest',locations:true});
const tuples=[],localCandidates=[],contexts={};
function walk(n,parent=null,owner='(top-level)'){
 if(!n||typeof n!=='object')return;
 if(n.type==='FunctionDeclaration')owner=n.id.name;
 if(n.type==='ObjectExpression'&&n.properties.some(p=>p.type==='Property'&&(p.key.value??p.key.name)==='$'&&p.value.type==='Literal'&&p.value.value==='Tuple')){
  const context=parent?.type||'(root)';contexts[context]=(contexts[context]||0)+1;
  const site={function:owner,line:n.loc.start.line,parent:context,source:source.slice(n.start,Math.min(n.end,n.start+180))};tuples.push(site);
  if(parent?.type==='VariableDeclarator'&&parent.init===n)localCandidates.push(site);
 }
 for(const[k,v]of Object.entries(n))if(!['loc','start','end'].includes(k)){if(Array.isArray(v))v.forEach(x=>walk(x,n,owner));else if(v&&typeof v==='object')walk(v,n,owner);}
}
walk(tree);
// This diagnostic deliberately refuses to masquerade as a rewrite if its zero-site premise changes.
if(localCandidates.length!==0)throw Error('Local Tuple candidate found: ownership/reference analysis required before rewriting');
const catalog=JSON.parse(fs.readFileSync(catalogPath)),count=JSON.parse(fs.readFileSync(countsPath));
const emitted=catalog.sites.filter(x=>x.kind==='object:Tuple');if(emitted.length!==tuples.length)throw Error('Tuple catalog mismatch');
for(let i=0;i<tuples.length;i++)if(tuples[i].source!==emitted[i].source||tuples[i].function!==emitted[i].function)throw Error('Tuple catalog order/source/function mismatch');
const sha=p=>crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
fs.writeFileSync(output,JSON.stringify({scope:'Exact local Tuple literal diagnosis only; no generated rewrite, refinement or performance qualification',parserVersion:acorn.version,inputSHA256:sha(input),catalogSHA256:sha(catalogPath),countsSHA256:sha(countsPath),scannerSHA256:sha(__filename),tupleLiteralSites:tuples.length,tupleParentContexts:contexts,localTupleInitializerSites:0,safelyEligibleExecutedTupleSites:0,predictedConstructorDelta:0,priorBaselineObservedTupleExecutions:count.byKind['object:Tuple'],priorCountScope:count.scope,sites:tuples},null,2)+'\n');
