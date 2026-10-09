// Metadata-only V8 evaluation of exact wrapper tails; no Node/consumer child.
async function runSoftFailureControls(tails) {
  let checks=0;
  for(const [mode,tail] of Object.entries(tails)) {
    for(const site of ['cli','io_exit'])for(const stopFails of [false,true]) {
      const events=[],writes=[],logs=[];
      const primary=new Error('controlled '+site+' failure');
      const secondary=new Error('controlled stop failure');
      let finish;
      const done=new Promise(resolve=>finish=resolve);
      const process={argv:['node','fixture'],exit:code=>finish(code)};
      class Session {
        connect(){events.push('connect');}
        disconnect(){events.push('disconnect');}
        post(method,params,callback){
          events.push(method);
          if(method==='Profiler.stop'||method==='HeapProfiler.stopSampling') {
            if(stopFails)return callback(secondary);
            return callback(null,{profile:{retained:true}});
          }
          callback(null,{});
        }
      }
      const require=name=>name==='node:inspector'?{Session}:name==='node:fs'?{writeFileSync:(path,data,options)=>writes.push({path,data:JSON.parse(data),options})}:(()=>{throw Error('unexpected module');})();
      const cli=()=>{if(site==='cli')throw primary;};
      const io_exit=()=>{if(site==='io_exit')throw primary;};
      const console={error:(...args)=>logs.push(args)};
      new Function('require','process','cli','io_exit','$main$','console',tail)(require,process,cli,io_exit,{},console);
      const exit=await done;
      if(exit!==1||logs[0][0]!==primary)throw Error('original primary error not preserved');
      const stop=mode==='cpu'?'Profiler.stop':'HeapProfiler.stopSampling';
      if(events.filter(x=>x===stop).length!==1||events[events.length-1]!=='disconnect')throw Error('active sampler stop/final disconnect missing');
      if(stopFails) {
        if(writes.length!==0||logs[1][1]!==secondary)throw Error('secondary stop error replaced primary or fabricated profile');
      } else {
        if(writes.length!==1||writes[0].options.flag!=='wx'||writes[0].options.mode!==0o600)throw Error('exclusive raw profile capture missing');
        const data=writes[0].data;
        if(data.zeroExits!==0||data.invocations!==1||data.mode!==mode||data.applicationError!==String(primary)||data.profile.retained!==true)throw Error('failure audit invented success or lost partial profile');
      }
      checks++;
    }
  }
  return {status:'EXACT_TAIL_SOFT_FAILURE_PASS',checks,primaryPreserved:true,stopAndPartialCapture:true,actualZeroExitAudit:true,nodeChildren:0};
}
