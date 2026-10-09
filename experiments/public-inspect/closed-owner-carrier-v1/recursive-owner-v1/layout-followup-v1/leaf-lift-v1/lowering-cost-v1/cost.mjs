// Observational counters only: no layout graph serialization on hot paths.
import {performance} from 'node:perf_hooks';
const rows=new Map(),stack=[];
let deadline=Infinity,checks=0,cutoffStack=null;
function row(key){let r=rows.get(key);if(!r){r={key,bodyCalls:0,entries:0,completed:0,aborted:0,wallNsInclusive:0,userUsInclusive:0,systemUsInclusive:0,wallNsSelf:0,userUsSelf:0,systemUsSelf:0,valTo:0,cacheHits:0,cacheMisses:0,lines:0,chars:0};rows.set(key,r);}return r;}
function clock(){const cpu=process.cpuUsage();return {wall:Number(process.hrtime.bigint()),user:cpu.user,system:cpu.system};}
function add(r,from,to,suffix){r['wallNs'+suffix]+=to.wall-from.wall;r['userUs'+suffix]+=to.user-from.user;r['systemUs'+suffix]+=to.system-from.system;}
export function arm(milliseconds){deadline=performance.now()+milliseconds;}
export function check(){if(performance.now()>=deadline){cutoffStack ??=stack.map(s=>s.key);throw new Error('cooperative lowering cutoff');}}
export function enter(key){check();const r=row(key);const parent=stack.at(-1);if(parent?.key===key)return null;const now=clock();if(parent)add(row(parent.key),parent.last,now,'Self');r.entries++;const token={key,start:now,last:now};stack.push(token);return token;}
export function leave(token,completed){if(token===null)return;const now=clock();if(stack.at(-1)!==token)throw new Error('diagnostic stack mismatch');stack.pop();const r=row(token.key);add(r,token.start,now,'Inclusive');add(r,token.last,now,'Self');r[completed?'completed':'aborted']++;if(stack.length)stack.at(-1).last=now;}
export function count(name,key=stack.at(-1)?.key ?? ''){const r=row(key);r[name]++;if((++checks&1023)===0)check();}
export function line(text,key){const r=row(key);r.lines++;r.chars+=text.length;}
export function body(key){row(key).bodyCalls++;if((++checks&1023)===0)check();}
export function snapshot(){return {scope:'instrumented copied compiler; actual compile_book done_defs intervals include emit_open+emit_body and nested lowering; per-definition val_to/body/line counters use fl.def, cache counters use active root interval; inclusive spans overlap; self spans subtract nested definition spans; line/char counters count pushes including discarded/repeated code; not final C size or installed/runtime cost',cutoffStack,active:stack.map(s=>s.key),rows:[...rows.values()]};}
