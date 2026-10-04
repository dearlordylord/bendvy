// Experimental TS lane. Original reference remains immutable.
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {createHash} from 'node:crypto';
const sourcePath='/workspace/formal-proofs/bendvy/experiments/s-integrate/measurement-reference.mjs';
const original=readFileSync(sourcePath,'utf8');
assert.equal(createHash('sha256').update(original).digest('hex'),'039edf1ec9905ad39c94bf4fcd9850610615251bd8b72e044b93fb7aa7c90376');
let code=original.slice(0,original.indexOf('function execute('))+original.slice(original.indexOf('function transactions('),original.indexOf("if(process.argv[2]==='--all')"));
code=code.replace("const self=fileURLToPath(import.meta.url), iterations=64;","const self='experimental', iterations=64;");
code=code.replace("new URL('../../.references/sources.json',import.meta.url)","'/workspace/formal-proofs/bendvy/.references/sources.json'");
code=code.replace("from '/workspace/formal-proofs/bendvy/.references/","from 'file:///workspace/formal-proofs/bendvy/.references/");
// Retain actual complete rows, just as the deferred Bend journal does; hash after interval.
code=code.replace('rowsSha256:sha(JSON.stringify(rows))','rowsSha256:null,fullRows:rows');
// Match Bend registration: one real Dispose descriptor, actual current handles at invocation.
const dispose="const Dispose=G.System('Dispose',{},({commands})=>{commands.despawn(aSpawn);commands.despawn(bRetry);});";
assert.equal(code.split(dispose).length,2);
code=code.replace(dispose,'');
const loop='  for(iteration=0;iteration<iterations;iteration++){';
assert.equal(code.split(loop).length,2);
code=code.replace(loop,'  '+dispose+'\n  const innerStart=performance.now();\n'+loop);
const ending='  assert.equal(effects.length,3*iterations);';
code=code.replace(ending,"  const innerMs=performance.now()-innerStart;\n  for(const record of audit){record.rowsSha256=sha(JSON.stringify(record.fullRows));delete record.fullRows;}\n"+ending);
code=code.replace("captures,reservations,reads,diagnostics,audit,effects,retainedLiveCount:","innerMs,captures,reservations,reads,diagnostics,audit,effects,retainedLiveCount:");
code+='\nexport {transactions};\n';
const {transactions}=await import('data:text/javascript;base64,'+Buffer.from(code).toString('base64'));
const schema=process.argv[2], count=Number(process.argv[3]);
assert.ok(['Motion','Health'].includes(schema));assert.ok([64,256,1024].includes(count));
const value=transactions(schema,count);
console.log(JSON.stringify({...value,experimentalAlignment:'Full rows retained; SHA outside interval; Dispose registered once. Other original checks and actual operations preserved. Not yet a fair Bend ratio.'}));
