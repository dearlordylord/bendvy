import fs from "node:fs";
import {performance} from "node:perf_hooks";
const path=process.env.BENDVY_EMIT_BOUNDARY;
const size=16384, page=Buffer.alloc(size,32);
let fd=null, iteration=0, started=performance.now(), began=0, count=0, slow=[];
export function mark(boundary,name="",extra={}){
 if(!path)return;
 const now=performance.now();
 if(boundary==="iteration-begin")iteration++;
 if(boundary==="definition-begin")began=now;
 if(boundary==="definition-end"){
  count++;slow.push({name:name.slice(0,512),ms:now-began,iteration});
  slow.sort((a,b)=>b.ms-a.ms);slow.length=Math.min(slow.length,16);
 }
 let resource;
 try{resource={usage:process.resourceUsage(),cpu:process.cpuUsage(),memory:process.memoryUsage(),pid:process.pid};}
 catch(error){resource={captureError:String(error)};}
 const value={boundary,name:name.slice(0,512),iteration,completedDefinitions:count,elapsedMs:now-started,slow,resource,...extra};
 const raw=Buffer.from(JSON.stringify(value));
 if(raw.length>=size)throw new Error("bounded observation page overflow");
 page.fill(32);raw.copy(page);
 if(fd===null){fd=fs.openSync(path,"wx");fs.ftruncateSync(fd,size);}
 fs.writeSync(fd,page,0,size,0);
}

mark("observer-loaded");
