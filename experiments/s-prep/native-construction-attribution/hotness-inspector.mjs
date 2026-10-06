import fs from 'node:fs';
import crypto from 'node:crypto';
import {Session} from 'node:inspector';
import * as Bend from '/workspace/formal-proofs/bendvy/.references/bend2/bend2/bend.ts';
import * as Comp from '/workspace/formal-proofs/bendvy/.references/bend2/bend2/comp.ts';
const [entry,output] = process.argv.slice(2);
const sha=p=>crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const compiler='/workspace/formal-proofs/bendvy/.references/bend2/bend2/comp.ts';
const pins={compiler:sha(compiler),entry:sha(entry),base:sha(Bend.BASE_BEND)};
const session=new Session(); session.connect();
const post=(method,params={})=>new Promise((resolve,reject)=>session.post(method,params,(e,r)=>e?reject(e):resolve(r)));
await post('Debugger.enable');
const points=[];
points.push(await post('Debugger.setBreakpointByUrl',{urlRegex:'/bend2/comp\\.ts$',lineNumber:1437,condition:'w.$ === "ADT" && w.k.endsWith("storage:World") && !fl.hot.has("t:" + w.k)'}));
points.push(await post('Debugger.setBreakpointByUrl',{urlRegex:'/bend2/comp\\.ts$',lineNumber:1427,condition:'!fl.hot.has("*")'}));
const observations=[];
session.on('Debugger.paused',message=>{
 const params=message.params;const frames=[];
 for(const frame of params.callFrames.slice(0,16)) {
  let value;
  session.post('Debugger.evaluateOnCallFrame',{callFrameId:frame.callFrameId,expression:`(()=>{const seen=new WeakSet();return JSON.stringify({def:typeof fl==='undefined'?null:fl.def,force:typeof force==='undefined'?null:force,local:typeof local==='undefined'?null:local,w:typeof w==='undefined'?null:w,B:typeof B==='undefined'?null:B,b:typeof b==='undefined'?null:{n:b.n,A:b.A},a:typeof a==='undefined'?null:a,k:typeof k==='undefined'?null:k,dom:typeof dom==='undefined'?null:dom,p:typeof p==='undefined'?null:p,A:typeof A==='undefined'?null:A,n:typeof n==='undefined'?null:n,hotStar:typeof fl==='undefined'?null:fl.hot.has('*')},(key,value)=>{if(key==='book'||key==='file')return undefined;if(typeof value==='function')return '[function]';if(typeof value==='object'&&value!==null){if(seen.has(value))return '[cycle]';seen.add(value);}return value;});})()`,returnByValue:true,silent:true},(e,r)=>{value=e?{error:String(e)}:r;});
  frames.push({name:frame.functionName,url:frame.url,location:frame.location,value});
 }
 observations.push({reason:params.reason,hitBreakpoints:params.hitBreakpoints,frames});
 for(const breakpointId of params.hitBreakpoints) session.post('Debugger.removeBreakpoint',{breakpointId});
 session.post('Debugger.resume');
});
const book=Bend.book_nil(); const seen=new Map();
console.log('CHECK_BEGIN');
await Bend.book_load(book,entry,'',seen);
Bend.book_valid(book);
console.log('CHECK_PASS_EMIT_BEGIN');
// Input already passed exact Bend checker. This read-only emission probe writes no proof/check verdict.
const c=Comp.compile_book(book);fs.writeFileSync(output+'.c',c);
await post('Debugger.disable');session.disconnect();
if(sha(output+'.c')!=='01683bcb4ca6691a31603f26bbe444fb1b02ad0ad59c93ebaf5edfaf2d7957c4')throw Error('Generated C differs from installed baseline');
const after={compiler:sha(compiler),entry:sha(entry),base:sha(Bend.BASE_BEND)};
if(JSON.stringify(pins)!==JSON.stringify(after))throw Error('Read-only input changed');
fs.writeFileSync(output+'.json',JSON.stringify({status:observations.length?'FIRST_HOTNESS_DEBUGGER_OBSERVED':'NO_MATCH_INCOMPLETE',scope:'Read-only pinned compiler via exported APIs in Node; no compiler monkeypatch; checker15/emitter30 bounded externally; byte-identical generated C verifies installed baseline equivalence',pins,after,generatedCSHA256:sha(output+'.c'),observations},null,2)+'\n');
console.log(JSON.stringify({observations:observations.length,pins,generatedCSHA256:sha(output+'.c')}));
