import fs from 'node:fs';
import {createHash} from 'node:crypto';
import {Session} from 'node:inspector';
let state;
export function writeAll(bytes,write) {
  for(let offset=0;offset<bytes.length;) {
    const remaining=bytes.length-offset,n=write(bytes,offset,remaining);
    if(!Number.isInteger(n)||n<=0||n>remaining)throw new Error('profile transport made invalid progress');
    offset+=n;
  }
}
function publish(path,bytes) {
  const fd=fs.openSync(path,fs.constants.O_WRONLY|fs.constants.O_CREAT|fs.constants.O_EXCL|fs.constants.O_NOFOLLOW,0o600);
  try {
    const before=fs.fstatSync(fd);if(!before.isFile())throw new Error('profile publication is not regular');
    writeAll(bytes,(buffer,offset,remaining)=>fs.writeSync(fd,buffer,offset,remaining));fs.fsyncSync(fd);
    const after=fs.fstatSync(fd);
    if(before.dev!==after.dev||before.ino!==after.ino||after.size!==bytes.length)throw new Error('profile FD identity/size changed');
    return {path,device:after.dev,inode:after.ino,bytes:bytes.length,sha256:createHash('sha256').update(bytes).digest('hex')};
  } finally {fs.closeSync(fd);}
}
export function due(active,started,now) {return active && now-started>=15000;}
export function start(path=process.env.BENDVY_CPU_PROFILE_PATH) {
  if(state!==undefined)throw new Error('profile sampler may start only once');
  if(typeof path!=='string'||!path.startsWith('/'))throw new Error('profile path must be absolute');
  if(fs.existsSync(path)||fs.existsSync(path+'.metadata.json'))throw new Error('profile output exists');
  const session=new Session();session.connect();session.post('Profiler.enable');
  session.post('Profiler.setSamplingInterval',{interval:1000});session.post('Profiler.start');
  state={session,path,started:performance.now(),active:true,completed:0};
}
export function finish(reason) {
  if(state===undefined||!state.active)return;
  state.active=false;const stopped=performance.now();
  const result=state.session.post('Profiler.stop');
  if(result===undefined||result===null||typeof result.profile!=='object')throw new Error('synchronous profiler result absent');
  const profile=result.profile,bytes=Buffer.from(JSON.stringify(profile)+'\n');
  const metadata={...publish(state.path,bytes),reason,intervalMicroseconds:1000,completedDefinitions:state.completed,hookStartMs:state.started,hookStopMs:stopped,scope:'Copied instrumented compiler sample only; flush overhead and later/interrupted interval unmeasured'};
  publish(state.path+'.metadata.json',Buffer.from(JSON.stringify(metadata)+'\n'));
  state.session.disconnect();return metadata;
}
export function checkpoint() {
  if(state===undefined||!state.active)return;
  state.completed++;if(due(state.active,state.started,performance.now()))finish('completed-definition-after-15s');
}
export function compile(book,originalCompile) {
  let value;
  try {value=originalCompile(book);} catch(error) {
    try {finish('compiler-error');} catch(observationError) {
      const bytes=Buffer.from('BENDVY_PROFILE_OBSERVATION_FAILED '+String(observationError)+'\n');
      writeAll(bytes,(buffer,offset,remaining)=>fs.writeSync(2,buffer,offset,remaining));
    }
    throw error;
  }
  finish('normal-compile-exit');return value;
}
