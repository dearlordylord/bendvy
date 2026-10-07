import fs from 'node:fs';
import vm from 'node:vm';
import assert from 'node:assert/strict';
import {fileURLToPath} from 'node:url';
const here=fileURLToPath(new URL('.',import.meta.url));
const cases=[[],[''],['plain','two lines\nthird'],['\0','é','😀','\ud800'],[Array.from({length:4096},(_,i)=>String.fromCharCode(i)).join('')]];
function oracle(lines){
 const bytes=Buffer.from(lines.map(s=>s+'\n').join(''),'utf8');
 let digest=2166136261;
 for(let i=0;i<bytes.length;i++)digest=Math.imul(digest^bytes[i],16777619)>>>0;
 return {hex:bytes.toString('hex'),bytes:bytes.length,digest};
}
function bend(role,lines){
 const output={1:[],2:[]};let tick=0n;
 const context=vm.createContext({process:{hrtime:{bigint:()=>++tick}},CID:x=>String(x),Unit:'Unit',begin:'begin',capture:'capture',end:'end',io_eff:()=>{},io_bytes:s=>Buffer.from(s,'utf8'),io_out:(fd,b)=>output[fd].push(Buffer.from(b))});
 vm.runInContext(fs.readFileSync(here+role+'/timing.js','utf8'),context);
 assert.throws(()=>vm.runInContext('io_feature_capture("bad")',context),/outside/);
 vm.runInContext('io_feature_begin()',context);
 assert.throws(()=>vm.runInContext('io_feature_begin()',context),/nested/);
 for(const line of lines){context.line=line;vm.runInContext('io_feature_capture(line)',context);}
 vm.runInContext('io_feature_end()',context);
 assert.throws(()=>vm.runInContext('io_feature_end()',context),/without/);
 const {bytes,digest}=JSON.parse(Buffer.concat(output[2]));
 return {hex:Buffer.concat(output[1]).toString('hex'),bytes,digest};
}
async function ts(role,lines){
 const {timed}=await import(new URL('./'+role+'/capture.mjs',import.meta.url));
 const out=[],err=[];const stdout=process.stdout.write,stderr=process.stderr.write;
 try{
  process.stdout.write=b=>{out.push(Buffer.from(b));return true;};
  process.stderr.write=b=>{err.push(Buffer.from(b));return true;};
  await timed(async()=>{for(const line of lines)console.log(line);});
 }finally{process.stdout.write=stdout;process.stderr.write=stderr;}
 const {bytes,digest}=JSON.parse(Buffer.concat(err));
 return {hex:Buffer.concat(out).toString('hex'),bytes,digest};
}
for(const lines of cases)for(const role of ['baseline','candidate']){
 assert.deepEqual(bend(role,lines),oracle(lines));
 assert.deepEqual(await ts(role,lines),oracle(lines));
}
console.log('PASS: 20 complete byte/count/digest comparisons; Bend timer refusal controls');
