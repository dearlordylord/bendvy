import fs from 'node:fs';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
const here=new URL('.',import.meta.url);
const spec=JSON.parse(fs.readFileSync(new URL('LINEAGE.json',here),'utf8'));
const sha=x=>createHash('sha256').update(x).digest('hex');
let actual=fs.readFileSync(new URL('compiler/installed-cli-coarse.mjs',here),'utf8');
assert.equal(sha(actual),spec.instrumentedSHA256);
for(const p of [...spec.patches].reverse()){assert.equal(actual.split(p.replacement).length-1,1);actual=actual.replace(p.replacement,p.original);}
assert.equal(sha(actual),spec.originalSHA256);
assert.equal(actual,fs.readFileSync(spec.original,'utf8'));
assert.equal(actual,fs.readFileSync(new URL('compiler/installed-cli-unmodified.mjs',here),'utf8'));
const elf=fs.readFileSync(spec.elf);assert.equal(sha(elf),spec.elfSHA256);assert.ok(elf.indexOf(Buffer.from(actual))>=0);
for(const name of ['base.bend','bendtt.lean','effs'])assert.equal(fs.realpathSync(new URL('compiler/'+name,here)),fs.realpathSync('/home/node/.bend/bend2/'+name));
console.log(JSON.stringify({exactPatchInverse:true,literalELFEmbedding:true,sameRuntime:true,mechanicalPatchCount:spec.patches.length}));
