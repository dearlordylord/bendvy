import fs from 'node:fs';
const target=process.env.BENDVY_CHECK_BOUNDARY_PATH;
if(!target || !target.startsWith('/'))throw new Error('absolute boundary output required');
const descriptor=fs.openSync(target,'wx');
const block=Buffer.alloc(4096,32);
let sequence=0,lastCompleted=null;
export function mark(phase,key='') {
 if(phase==='definition-end')lastCompleted=key;
 const text=Buffer.from(JSON.stringify({sequence:++sequence,phase,key,lastCompleted,monotonicNs:process.hrtime.bigint().toString()})+'\n');
 if(text.length>block.length)throw new Error('boundary exceeds fixed record');
 block.fill(32);text.copy(block);
 let offset=0;
 while(offset<block.length) {
  const count=fs.writeSync(descriptor,block,offset,block.length-offset,offset);
  if(!Number.isInteger(count)||count<=0)throw new Error('boundary write made no progress');
  offset+=count;
 }
}
