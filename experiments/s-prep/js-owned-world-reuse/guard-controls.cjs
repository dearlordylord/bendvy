// Synthetic guard failures under a test-only copy of the pin catalog; no live bypass option.
const fs=require('node:fs'),path=require('node:path'),os=require('node:os'),cp=require('node:child_process'),crypto=require('node:crypto'),assert=require('node:assert/strict');
const acorn=require('internal/deps/acorn/acorn/dist/acorn');
const [input,output]=process.argv.slice(2);assert(!fs.existsSync(output));fs.mkdirSync(output);const original=fs.readFileSync(input,'utf8'),tree=acorn.parse(original,{ecmaVersion:'latest'}),defs=tree.body.filter(n=>n.type==='FunctionDeclaration'),hash=s=>crypto.createHash('sha256').update(s).digest('hex'),pin=JSON.parse(fs.readFileSync(__dirname+'/input-pins.json'))[hash(original)];assert(pin);
function fn(s){const x=defs.filter(n=>n.id.name.endsWith('held$045adapter$058'+s+'$'));assert.equal(x.length,1);return x[0]}
const restore=fn('prototype_boxed_motion_return_world'),taken=defs.find(n=>n.id.name.includes('held$045adapter$058prototype_boxed_motion_taken$126')),select=defs.find(n=>n.id.name.endsWith('measurement$045bend$058motion_select$'));
function editFn(n,old,replacement){const body=original.slice(n.start,n.end);assert.equal(body.split(old).length,2);return original.slice(0,n.start)+body.replace(old,replacement)+original.slice(n.end)}
const mutations=[
 ['select-identity',editFn(select,'"pings": _pings_0','"pings": _marks_0'),'select exact identity pings'],
 ['world-identity',editFn(restore,'"pending": _pending_0','"pending": _mode_0'),'unchanged world pending'],
 ['rows-identity',editFn(restore,'"aux": _aux_0','"aux": _meta_0'),'unchanged rows aux'],
 ['ordered-fields',editFn(restore,'"depth": _depth_0','"depthBAD": _depth_0'),'ordered fields'],
 ['reserved-namespace',original+'\nconst __owned_reuse_reserved = 0;','reserved binders'],
 ['unique-restore-caller',original+'\nfunction injected_caller(){return '+restore.id.name+'();}','unique restore caller'],
 ['restore-prefix-side-effect',original.slice(0,restore.body.start+1)+'\nconst evil = side_effect();'+original.slice(restore.body.start+1),'recognized restore prefix'],
 ['reached-family',original.replace(taken.id.name+'(','not_the_boxed_taken('),'fields->boxed taken'],
];
const records=[];for(const [label,source,error]of mutations){const dir=path.join(output,label);fs.mkdirSync(dir);fs.writeFileSync(path.join(dir,'rewrite.cjs'),fs.readFileSync(__dirname+'/rewrite.cjs'));fs.writeFileSync(path.join(dir,'input-pins.json'),JSON.stringify({[hash(source)]:pin}));const file=path.join(dir,'input.js'),rewritten=path.join(dir,'output.js');fs.writeFileSync(file,source);const run=cp.spawnSync(process.execPath,['--expose-internals',path.join(dir,'rewrite.cjs'),file,rewritten,'motion'],{encoding:'utf8',timeout:5000});assert.notEqual(run.status,0,label);assert(run.stderr.includes(error),run.stderr);assert(!fs.existsSync(rewritten),label);fs.writeFileSync(path.join(dir,'diagnostic.txt'),run.stdout+run.stderr);records.push({label,exit:run.status,intendedDiagnostic:error,inputSHA256:hash(source),outputAbsent:true})}
fs.writeFileSync(path.join(output,'evidence.json'),JSON.stringify({scope:'Synthetic AST mutations on a test-only copied input-pin catalog exercise guards beyond initial hash rejection. The shipping recipe/catalog have no bypass; source/core/compiler/oracle unchanged.',cpu:8,runtimeLimitSeconds:5,records},null,2)+'\n');console.log('EIGHT_WORLD_AST_GUARDS_REFUSE_BEFORE_OUTPUT');
