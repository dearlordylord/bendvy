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
for(const name of ['base.bend','bendtt.lean','effs'])assert.equal(fs.realpathSync(new URL('compiler/'+name,here)),fs.realpathSync("/workspace/formal-proofs/bendvy-worktrees/inspector54-coherent-cost-diagnostic/experiments/public-inspect/ordinary-declaration-v1/canonical-full-consumer-v1/stock-format-owner-v1/callback-forwarding-v1/owner-forwarding-v1/boxed-diagnostic-v1/coherent-callback-v1/execution-callback-v1/actual-frame-v1/graph-only-v1/execution-source-v1/compiler-lookup-v1/compiler/"+name));
console.log(JSON.stringify({exactPatchInverse:true,literalELFEmbedding:true,sameRuntime:true,mechanicalPatchCount:spec.patches.length}));
