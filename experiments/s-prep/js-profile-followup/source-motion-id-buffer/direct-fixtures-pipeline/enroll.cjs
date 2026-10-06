// Exact current handoff lifecycle subjects; no old cursor-controller admission.
const fs=require('node:fs'),crypto=require('node:crypto'),acorn=require('internal/deps/acorn/acorn/dist/acorn');
const sha=x=>crypto.createHash('sha256').update(x).digest('hex'),root='/tmp/bendvy-slot-host-motion-id-buffer-direct-v1',H=__dirname;
const o=JSON.parse(fs.readFileSync(root+'/overlay.json')),c=JSON.parse(fs.readFileSync(root+'/cache-specialization.json')),pins=o.sources;
if(Object.keys(pins).length!==29||JSON.stringify(o.cacheSpecialization)!==JSON.stringify(c)||sha(JSON.stringify(Object.fromEntries(Object.entries(pins).sort())))!=='84b808cee2c1a657569888229241dd95ae59f314025512c20159d951f4a1db2c')throw Error('exact coherent concrete v3 closure');
for(const[n,h]of Object.entries(pins))if(sha(fs.readFileSync(root+'/'+n))!==h)throw Error('source '+n);
const dirs={one:'/tmp/bendvy-split-direct-retained-one-r1','one-raw':'/tmp/bendvy-split-direct-retained-one-raw-r1',two:'/tmp/bendvy-split-direct-retained-two-r1','two-raw':'/tmp/bendvy-split-direct-retained-two-raw-r1'},catalog={};
for(const[role,dir]of Object.entries(dirs))for(const schema of ['motion']){
 const evidence=JSON.parse(fs.readFileSync(dir+'/evidence.json'));
 if(evidence.status!=='ACTUAL_HANDOFF_ENUMERATION_PRE_POST_ROLLBACK_BOTH_PASS'||JSON.stringify(evidence.sourcePins)!==JSON.stringify(pins))throw Error('actual independent concrete v3 evidence '+role);
 const input=dir+'/'+schema+'/fallback.js',entry=dir+'/'+schema+'/fallback.bend',stored=dir+'/'+schema+'/fallback.js.jsonl',source=fs.readFileSync(input,'utf8');
 const observed=evidence.cases.filter(x=>x.schema===schema&&x.backend==='JS'&&x.status==='PASS');
 if(observed.length!==1||observed[0].records!==8||observed[0].programSHA256!==sha(source)||observed[0].sourceSHA256!==sha(fs.readFileSync(entry)))throw Error('fresh fixture build/observation '+role+schema);
 const ast=acorn.parse(source,{ecmaVersion:'latest'}),defs=ast.body.filter(n=>n.type==='FunctionDeclaration'),prefix=schema==='motion'?'prototype_packed_row_':'prototype_packed_prototype_journalledger_health_',ops={get:'get',ledger:'ledger',set:'set',setDone:schema==='motion'?'set_done':'set_fused_done',setledger:'setledger',setledgerDone:'setledger_done'},helpers={};
 for(const[k,v]of Object.entries(ops)){const ds=defs.filter(n=>n.id.name.endsWith('held$045adapter$058'+prefix+v+'$'));if(ds.length!==1)throw Error('unique '+k);helpers[k]={name:ds[0].id.name,sha256:sha(source.slice(ds[0].start,ds[0].end))};}
 const get=defs.find(n=>n.id.name===helpers.get.name),owner=get.body.body.at(-1).argument.properties[1].value,fields=owner.properties.slice(1).map(p=>p.key.value??p.key.name),ownerTag=owner.properties[0].value.value;
 const tokenNames=schema==='motion'?['PositionToken','MotionLedgerToken']:['VitalsToken','HealthLedgerToken'],tokenTags=[];
 for(const name of tokenNames){const found=new Set();(function walk(n){if(!n||typeof n!=='object')return;if(n.type==='ObjectExpression'&&n.properties.length===1){const p=n.properties[0];if((p.key.value??p.key.name)==='$'&&typeof p.value.value==='string'&&p.value.value.endsWith('types.'+name))found.add(p.value.value);}for(const v of Object.values(n))if(Array.isArray(v))v.forEach(walk);else if(v&&typeof v==='object')walk(v);})(ast);if(found.size!==1)throw Error('unique schema Data token '+name);tokenTags.push([...found][0]);}
 catalog[sha(source)]={label:role+'-'+schema,schema,mode:'handoff-fixture',inputPath:input,storedOutput:stored,sourceRoot:root,sourcePins:pins,provenancePins:Object.fromEntries([root+'/overlay.json',root+'/cache-specialization.json',dir+'/evidence.json',entry,stored].map(p=>[p,sha(fs.readFileSync(p))])),helpers,fields,ownerTag,tokenTags};
}
fs.writeFileSync(H+'/row-input-pins.json',JSON.stringify(catalog,null,2)+'\n');console.log(JSON.stringify({status:'EXACT_FOUR_DIRECT_MOTION_LIFECYCLE_INPUTS_ADMITTED',programs:Object.keys(catalog).length,records:32}));
