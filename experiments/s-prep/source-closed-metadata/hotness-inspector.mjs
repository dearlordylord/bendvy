import fs from 'node:fs';
import crypto from 'node:crypto';
import {Session} from 'node:inspector';
import * as Bend from '/workspace/formal-proofs/bendvy/.references/bend2/bend2/bend.ts';
import * as Comp from '/workspace/formal-proofs/bendvy/.references/bend2/bend2/comp.ts';
const [entry,expectedC,output] = process.argv.slice(2);
const sha=p=>crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const compiler='/workspace/formal-proofs/bendvy/.references/bend2/bend2/comp.ts';
const pins={compiler:sha(compiler),entry:sha(entry),base:sha(Bend.BASE_BEND),expectedC:sha(expectedC)};
const session=new Session();session.connect();
const post=(method,params={})=>new Promise((resolve,reject)=>session.post(method,params,(e,r)=>e?reject(e):resolve(r)));
const bySeed=new Map();let pauses=0,missing=0;
session.on('Debugger.paused',message=>{
 pauses++;const frames=[];
 for(const frame of message.params.callFrames.slice(0,4)){
  let response;
  const expression=`(()=>{const shape=t=>t?{tag:t.$,name:t.k,index:t.i,span:t.s?{beg:t.s.beg,end:t.s.end}:null}:null;return JSON.stringify({def:typeof fl==='undefined'?null:fl.def,force:typeof force==='undefined'?null:force,local:typeof local==='undefined'?null:local,w:typeof w==='undefined'?null:shape(w),dom:typeof dom==='undefined'||!dom?null:{quant:dom[0].$,name:dom[1],type:shape(dom[2])},callee:typeof k==='undefined'?null:k,argument:typeof a==='undefined'?null:shape(a),wildcardPresent:typeof fl==='undefined'?null:fl.hot.has('*')});})()`;
  session.post('Debugger.evaluateOnCallFrame',{callFrameId:frame.callFrameId,expression,returnByValue:true,silent:true},(e,r)=>{response=e?{error:String(e)}:r;});
  let value=null;try{value=JSON.parse(response.result.value);}catch{}
  frames.push({name:frame.functionName,location:frame.location,value});
 }
 const value=frames[0].value;
 if(value){const key=JSON.stringify([value.def,value.w,value.dom,value.local]);let prior=bySeed.get(key);if(!prior){prior={firstSequence:pauses,hits:0,frames};bySeed.set(key,prior);}prior.hits++;}else missing++;
 session.post('Debugger.resume');
});
console.log('CHECK_BEGIN');const book=Bend.book_nil();await Bend.book_load(book,entry,'',new Map());Bend.book_valid(book);console.log('CHECK_PASS_EMIT_BEGIN');
await post('Debugger.enable');
await post('Debugger.setBreakpointByUrl',{urlRegex:'/bend2/comp\\.ts$',lineNumber:1427});
const c=Comp.compile_book(book);fs.writeFileSync(output+'.c',c);await post('Debugger.disable');session.disconnect();
const after={compiler:sha(compiler),entry:sha(entry),base:sha(Bend.BASE_BEND),expectedC:sha(expectedC)};
const generatedCSHA256=sha(output+'.c');
const receipt={status:JSON.stringify(pins)===JSON.stringify(after)&&generatedCSHA256===pins.expectedC&&!missing?'ALL_WILDCARD_BRANCHES_PINNED_C_OBSERVED':'INCOMPLETE',pins,after,generatedCSHA256,pauses,missing,uniqueSeeds:bySeed.size,seeds:[...bySeed.values()],scope:'All executed conservative wildcard branches in this emission, including already-hot repeats; distinct potential seeds are not independent first causes. No compiler mutation or performance metric.'};
fs.writeFileSync(output+'.json',JSON.stringify(receipt,null,2)+'\n');console.log(JSON.stringify({status:receipt.status,pauses,uniqueSeeds:bySeed.size,generatedCSHA256}));if(receipt.status==='INCOMPLETE')process.exitCode=1;
