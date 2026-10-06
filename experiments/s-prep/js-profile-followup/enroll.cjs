'use strict';
// Trusted exact-input catalog construction, not a runtime admission fallback.
const fs=require('fs'),path=require('path'),crypto=require('crypto'),acorn=require('internal/deps/acorn/acorn/dist/acorn');
const ROOT='/workspace/formal-proofs/bendvy',sha=s=>crypto.createHash('sha256').update(s).digest('hex');
const base=JSON.parse(fs.readFileSync(ROOT+'/experiments/s-prep/js-descending-cursor-transport/row-input-pins.json'));
const evidencePath='/tmp/bendvy-descending-generated-frozen-v1/evidence.json',evidence=JSON.parse(fs.readFileSync(evidencePath));if(evidence.status!=='FROZEN_TEN_EXACT_CHAIN_PROGRAMS_PASS')throw Error('parent receipt');
const catalog={};
for(const program of evidence.programs){
 const prior=base[program.sourceSHA256];if(!prior)throw Error('prior source provenance');const s=fs.readFileSync(program.finalPath,'utf8');if(sha(s)!==program.finalSHA256)throw Error('changed first-stage program');
 const ast=acorn.parse(s,{ecmaVersion:'latest'}),defs=ast.body.filter(n=>n.type==='FunctionDeclaration'),schema=prior.schema,key=schema==='motion'?'flatfold_motion':'journalledger_health';
 const unique=part=>{const xs=defs.filter(n=>n.id.name.includes(part));if(xs.length!==1)throw Error('unique '+part+' '+xs.length);return xs[0]};
 const family=['step','guard','live','taken','returned'].map(op=>unique('held$045adapter$058prototype_packed_prototype_'+key+'_'+op+'$'));
 const caller=unique('held$045adapter$058prototype_cursor_flatfold_'+schema+'_loop$');
 const frontier=defs.filter(n=>n.id.name.includes('held$045adapter$058prototype_packed_prototype_'+key+'_')||n.id.name===caller.id.name||n.id.name.includes('held$045adapter$058prototype_cursor_flatfold_'+schema+'$'));
 const files={...prior.provenancePins,[evidencePath]:sha(fs.readFileSync(evidencePath))};for(const [rel,h]of Object.entries(prior.sourcePins))files[path.join(prior.sourceRoot,rel)]=h;
 for(const suffix of ['row','pool','tuple']){const p=program.finalPath.replace('-tuple.js','-'+suffix+'.js.recipe.json');if(fs.existsSync(p))files[p]=sha(fs.readFileSync(p));}
 catalog[sha(s)]={inputPath:program.finalPath,label:program.label,schema,sourceRoot:prior.sourceRoot,sourcePins:prior.sourcePins,files,family:family.map(n=>n.id.name),bodyPins:Object.fromEntries(family.map(n=>[n.id.name,sha(s.slice(n.start,n.end))])),confinementPins:Object.fromEntries(frontier.map(n=>[n.id.name,sha(s.slice(n.start,n.end))])),caller:caller.id.name,callerSHA256:sha(s.slice(caller.start,caller.end)),stateTag:prior.ownerTag.replace(/PrototypePacked(?:Motion|Health)RowOwner$/,'PrototypeFlatFold')};
}
if(Object.keys(catalog).length!==10)throw Error('catalog cardinality');fs.writeFileSync(path.join(__dirname,'input-pins.json'),JSON.stringify(catalog,null,2)+'\n',{flag:'wx'});
