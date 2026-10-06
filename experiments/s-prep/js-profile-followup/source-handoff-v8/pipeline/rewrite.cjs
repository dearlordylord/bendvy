// Exact-input generated-JS causal probe. No compiler or source changes.
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto');
const acorn=require('internal/deps/acorn/acorn/dist/acorn');const {scan}=require('./analyze.cjs');
const sha=x=>crypto.createHash('sha256').update(x).digest('hex');
function derive(source){
 if(source.includes('__direct_tuple_'))throw Error('occupied private namespace');const x=scan(source);if(x.threats.length)throw Error('reflection/eval threat');
 if(!x.eligible.length)throw Error('no guarded direct literal edge');const callMultiplicity=new Map();x.eligible.forEach(s=>callMultiplicity.set(s.callStart,(callMultiplicity.get(s.callStart)||0)+1));if([...callMultiplicity.values()].some(n=>n!==1))throw Error('multiple eligible pair arguments on one call unsupported');
 const groups=new Map();for(const s of x.eligible){const key=s.receiver+':'+s.pairIndex;if(!groups.has(key))groups.set(key,{id:groups.size,site:s,sites:[]});groups.get(key).sites.push(s);}
 const edits=[],clones=[],receipts=[];
 for(const g of groups.values()){
  const fn=x.functions.get(g.site.receiver)[0],fst='__direct_tuple_fst_'+g.id,snd='__direct_tuple_snd_'+g.id,name='__direct_tuple_helper_'+g.id;
  let body=source.slice(fn.body.start,fn.body.end);for(const r of [...g.site.projectionRanges].sort((a,b)=>b.start-a.start))body=body.slice(0,r.start-fn.body.start)+(r.field==='fst'?fst:snd)+body.slice(r.end-fn.body.start);
  const params=fn.params.map(p=>p.name);params.splice(g.site.pairIndex,1,fst,snd);clones.push(`\nfunction ${name}(${params.join(', ')}) ${body}\n`);
  for(const s of g.sites){const node=find(x.ast,n=>n.type==='CallExpression'&&n.start===s.callStart);if(!node)throw Error('unique call missing');const tuple=node.arguments[s.pairIndex];if(tuple.start!==s.tupleStart)throw Error('tuple argument mismatch');
   const a=tuple.properties[1].value,b=tuple.properties[2].value;edits.push({start:node.callee.start,end:node.callee.end,text:name},{start:tuple.start,end:tuple.end,text:`(${source.slice(a.start,a.end)}), (${source.slice(b.start,b.end)})`});
  }
  receipts.push({originalReceiver:g.site.receiver,pairParameter:g.site.pairParameter,pairIndex:g.site.pairIndex,clone:name,directEdges:g.sites.length,projections:g.site.projections});
 }
 let output=source;const ordered=edits.sort((a,b)=>b.start-a.start);for(let i=1;i<ordered.length;i++)if(ordered[i].end>ordered[i-1].start)throw Error('overlapping edits');for(const e of ordered)output=output.slice(0,e.start)+e.text+output.slice(e.end);output+='\n// Private scalar receivers for exact direct Tuple edges only.\n'+clones.join('');acorn.parse(output,{ecmaVersion:'latest'});
 return {output,receipts,eligible:x.eligible,rejected:x.rejected};
}
function find(root,predicate){let result=null;function walk(n){if(!n||typeof n!=='object'||!n.type)return;if(predicate(n)){if(result)throw Error('ambiguous AST match');result=n;}for(const[k,v]of Object.entries(n)){if(['loc','start','end'].includes(k))continue;if(Array.isArray(v))v.forEach(walk);else if(v&&typeof v==='object')walk(v);}}walk(root);return result;}
module.exports={derive};
if(require.main===module){
 const[input,output]=process.argv.slice(2);if(!input||!output)throw Error('usage input output');if(fs.existsSync(output)||fs.existsSync(output+'.recipe.json'))throw Error('output must be absent');const here=__dirname,catalogPath=path.join(here,'input-pins.json'),source=fs.readFileSync(input,'utf8'),hash=sha(source),catalog=JSON.parse(fs.readFileSync(catalogPath,'utf8')),pin=catalog[hash];if(!pin)throw Error('unapproved exact input');
 if(fs.realpathSync(input)!==fs.realpathSync(pin.inputPath))throw Error('pinned input path mismatch');if(Object.keys(pin.sourcePins).length!==29)throw Error('source closure not29');for(const[n,h]of Object.entries(pin.sourcePins))if(sha(fs.readFileSync(path.join(pin.sourceRoot,n)))!==h)throw Error('source pin mismatch '+n);
 for(const[n,h]of Object.entries(pin.fixtureExtraPins||{}))if(sha(fs.readFileSync(path.join(pin.sourceRoot,n)))!==h)throw Error('fixture extra pin mismatch '+n);
 for(const[n,h]of Object.entries(pin.provenancePins))if(sha(fs.readFileSync(n))!==h)throw Error('producer provenance changed '+n);
 const r=derive(source);if(r.eligible.length!==pin.expectedEligible||r.receipts.length!==pin.expectedReceivers)throw Error('eligible edge catalog changed');
 fs.writeFileSync(output,r.output);const receipt={status:'PINNED_DIRECT_TUPLE_SCALAR_RECEIVERS_DERIVED',scope:'Closed emitted-JS causal probe only; no source/compiler/Native/universal refinement/adoption claim',schema:pin.schema,mode:pin.mode,inputSHA256:hash,outputSHA256:sha(r.output),sourceRoot:pin.sourceRoot,sourcePins:pin.sourcePins,fixtureExtraPins:pin.fixtureExtraPins||{},provenancePins:pin.provenancePins,recipeSHA256:sha(fs.readFileSync(__filename)),analysisSHA256:sha(fs.readFileSync(path.join(here,'analyze.cjs'))),catalogSHA256:sha(fs.readFileSync(catalogPath)),clones:r.receipts,eligibleSites:r.eligible,rejectedSites:r.rejected,perCallClosuresAdded:0};fs.writeFileSync(output+'.recipe.json',JSON.stringify(receipt,null,2)+'\n');console.log(JSON.stringify({clones:r.receipts.length,directEdges:r.eligible.length,outputSHA256:receipt.outputSHA256}));
}
