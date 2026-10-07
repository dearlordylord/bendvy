import inspector from 'node:inspector';
import fs from 'node:fs';
import {pathToFileURL} from 'node:url';
const session=new inspector.Session();session.connect();
const post=(method,params={})=>new Promise((resolve,reject)=>session.post(method,params,(error,result)=>error?reject(error):resolve(result)));
await post('HeapProfiler.enable');
await post('HeapProfiler.startSampling',{samplingInterval:32768,includeObjectsCollectedByMajorGC:true,includeObjectsCollectedByMinorGC:true});
process.on('exit',()=>session.post('HeapProfiler.stopSampling',{},(error,result)=>{if(error)throw error;fs.writeFileSync(process.argv[3],JSON.stringify(result.profile));session.disconnect();}));
await import(pathToFileURL(process.argv[2]).href);
