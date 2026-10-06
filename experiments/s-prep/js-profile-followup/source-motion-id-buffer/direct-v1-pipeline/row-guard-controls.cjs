const fs=require('node:fs'),crypto=require('node:crypto'),assert=require('node:assert/strict'),a=require('internal/deps/acorn/acorn/dist/acorn');const {derive}=require('./row-rewrite.cjs'),sha=x=>crypto.createHash('sha256').update(x).digest('hex');const catalog=JSON.parse(fs.readFileSync(__dirname+'/row-input-pins.json')),checks=[];
for(const[hash,pin]of Object.entries(catalog)){
 const source=fs.readFileSync(pin.inputPath,'utf8'),schema=pin.schema;assert.equal(sha(source),hash);assert.equal(derive(source,pin).selected.length,4);checks.push({schema,name:'exact-source-four-helper-positive',status:'PASS'});
 function test(name,change,pattern,refresh=false){const s=change(source),p=JSON.parse(JSON.stringify(pin));if(refresh){const tree=a.parse(s,{ecmaVersion:'latest'});for(const v of Object.values(p.helpers)){const ds=tree.body.filter(n=>n.type==='FunctionDeclaration'&&n.id.name===v.name);assert.equal(ds.length,1);v.sha256=sha(s.slice(ds[0].start,ds[0].end));}}assert.throws(()=>derive(s,p),pattern);checks.push({schema,name,status:'REFUSED'});}
 function getBody(s){const tree=a.parse(s,{ecmaVersion:'latest'}),n=tree.body.find(n=>n.type==='FunctionDeclaration'&&n.id.name===pin.helpers.get.name);return n;}
 test('changed-private-helper-body',s=>{const n=getBody(s);return s.slice(0,n.body.start+1)+' /* changed */ '+s.slice(n.body.start+1)},/pinned helper/);
 test('nonidentity-owner-field',s=>{const n=getBody(s),r=n.body.body.at(-1).argument.properties[1].value,p=r.properties.find(p=>(p.key.value??p.key.name)==='a');return s.slice(0,p.value.start)+'_b_0'+s.slice(p.value.end)},/identity owner projection/,true);
 test('missing-full-owner-field',s=>{const n=getBody(s),r=n.body.body.at(-1).argument.properties[1].value,last=r.properties.at(-1),before=r.properties.at(-2);return s.slice(0,before.end)+s.slice(last.end)},/ordered full fields/,true);
 test('nonprojection-read-prelude',s=>{const n=getBody(s),v=n.body.body[0].declarations[0].init;return s.slice(0,v.start)+'unknownRead()'+s.slice(v.end)},/plain projection/,true);
 test('unknown-duplicate-done-consumer',s=>s+'\n'+pin.helpers.setDone.name+'();\n',/single done consumer/);
 for(const name of ['Proxy','Reflect','eval','Function'])test(name+'-scope',s=>s+'\nconst __diagnostic_'+name+' = '+name+';\n',/reflection/);
 test('caller-reflection',s=>s+'\n'+pin.helpers.set.name+'.caller;\n',/reflection/);
 test('occupied-private-namespace',s=>s+'\nconst __packed_row_reuse_occupied=1;\n',/occupied namespace/);
}
fs.writeFileSync(process.argv[2],JSON.stringify({status:'EXACT_PACKED_ROW_SHAPE_SCOPE_REFUSALS_PASS',scope:'Finite exact helper/body/shape guards, not universal affine-node reuse safety',checks},null,2)+'\n');console.log(JSON.stringify({status:'PASS',checks:checks.length}));
