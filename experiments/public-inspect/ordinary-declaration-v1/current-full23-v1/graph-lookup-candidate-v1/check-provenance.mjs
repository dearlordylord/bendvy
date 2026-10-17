import fs from 'node:fs';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
const here=new URL('.',import.meta.url),spec=JSON.parse(fs.readFileSync(new URL('LINEAGE.json',here),'utf8'));
const sha=x=>createHash('sha256').update(x).digest('hex');
const original=fs.readFileSync(spec.original,'utf8'),candidate=fs.readFileSync(spec.candidate,'utf8');
assert.equal(sha(original),spec.originalSHA256);assert.equal(sha(candidate),spec.candidateSHA256);
let forward=original;for(const p of spec.transforms){assert.equal(forward.split(p.before).length-1,1);forward=forward.replace(p.before,p.after);}assert.equal(forward,candidate);
let inverse=candidate;for(const p of [...spec.transforms].reverse()){assert.equal(inverse.split(p.after).length-1,1);inverse=inverse.replace(p.after,p.before);}assert.equal(inverse,original);
const elf=fs.readFileSync(spec.elf);assert.equal(sha(elf),spec.elfSHA256);assert.ok(elf.indexOf(Buffer.from(original))>=0);
assert.equal(fs.readFileSync(spec.wrapper,'utf8'),spec.wrapperSource);assert.equal(sha(fs.readFileSync(spec.wrapper)),spec.wrapperSHA256);
assert.ok(spec.wrapperSource.includes('exec '+spec.elf+' '+spec.candidate+' "$@"'));assert.ok(spec.wrapperSource.includes('export BUN_BE_BUN=1'));assert.ok(spec.wrapperSource.includes('unset BUN_OPTIONS'));
function fn(text,name){const start=text.indexOf('function '+name+'(');assert.ok(start>=0);const end=text.indexOf('\nfunction ',start+1);assert.ok(end>start);return text.slice(start,end);}
function js(text){return text.slice(text.indexOf('function js_sat('),text.indexOf('function a32_ops('));}
assert.equal(js(original),js(candidate));assert.equal(fn(original,'cli_emit'),fn(candidate,'cli_emit'));
assert.equal(original.split('graph_close(').length-1,4);assert.equal(fn(original,'compile_book').split('graph_close(').length-1,3);
for(const name of ['base.bend','bendtt.lean'])assert.equal(sha(fs.readFileSync(spec.resourceRoot+'/'+name)),sha(fs.readFileSync('/home/node/.bend/bend2/'+name)));
console.log(JSON.stringify({exactForward:true,exactInverse:true,literalELFEmbedding:true,transforms:3,wrapperTargetExact:true,jsBackendAndBranchExact:true,graphCallsNativeOnly:true,scope:'Unadopted current candidate provenance, no performance or runtime correctness claim.'}));
