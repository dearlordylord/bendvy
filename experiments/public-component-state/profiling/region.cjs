'use strict';
// Diagnostic preload: exact workload remains untouched; profiler commands are synchronous.
const inspector=require('node:inspector'),fs=require('node:fs');
const session=new inspector.Session();session.connect();
function post(method,params={}){let done=false,value,error;session.post(method,params,(e,r)=>{error=e;value=r;done=true;});if(!done)throw Error('Inspector command was not synchronous');if(error)throw error;return value;}
const mode=process.env.STATE_PROFILE_MODE,out=process.env.STATE_PROFILE_OUTPUT;
if(!['cpu','alloc'].includes(mode)||!out||fs.existsSync(out))throw Error('Invalid fresh profile request');
const clock=process.hrtime.bigint.bind(process.hrtime);let calls=0,profile;
if(mode==='cpu'){post('Profiler.enable');post('Profiler.setSamplingInterval',{interval:100});}
else post('HeapProfiler.enable');
process.hrtime.bigint=function(){
 calls++;
 if(calls===1){
  if(mode==='cpu')post('Profiler.start');
  else post('HeapProfiler.startSampling',{samplingInterval:512,includeObjectsCollectedByMajorGC:true,includeObjectsCollectedByMinorGC:true});
  return clock();
 }
 if(calls===2){
  const end=clock();
  profile=mode==='cpu'?post('Profiler.stop').profile:post('HeapProfiler.stopSampling').profile;
  process.hrtime.bigint=clock;
  fs.writeFileSync(out,JSON.stringify({mode,calls,parameters:mode==='cpu'?{intervalMicroseconds:100}:{samplingIntervalBytes:512,includeObjectsCollectedByMajorGC:true,includeObjectsCollectedByMinorGC:true},profile}));
  session.disconnect();return end;
 }
 throw Error('Unexpected clock call');
};
process.on('exit',()=>{if(calls!==2||!profile){process.exitCode=1;fs.writeSync(2,'Missing complete profiled region\n');}});
