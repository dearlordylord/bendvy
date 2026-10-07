import {Descriptor,Schema,Fx} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const Ping=Descriptor.Event()('Ping'), G=Schema.bind(Schema.fragment({events:{Ping}}));
const rt=G.Runtime.make({services:G.Runtime.services(),debug:true});
let enabled=true,readFail=false,publishFail=false,emitted=[],reads=[];
const permitted=G.Condition.check('enabled',{},()=>enabled);
const fast=G.System('fast',{events:{ping:G.System.readEvent(Ping)},when:[permitted]},({events})=>{reads.push({reader:'fast',values:[...events.ping.all()],lagged:events.ping.lagged()});return readFail?Fx.fail('ReadFailed'):undefined;});
const slow=G.System('slow',{events:{ping:G.System.readEvent(Ping)}},({events})=>{reads.push({reader:'slow',values:[...events.ping.all()],lagged:events.ping.lagged()});return readFail?Fx.fail('ReadFailed'):undefined;});
const publish=G.System('publish',{events:{ping:G.System.writeEvent(Ping)}},({events})=>{for(const x of emitted)events.ping.emit(x);return publishFail?Fx.fail('PublishFailed'):undefined;});

const checkpoints=[];
function step(label,...systems){reads=[];const r=rt.tick(G.Schedule(...systems));const s=rt.debug.streams().find(x=>x.kind==='event'&&x.stream==='Ping');checkpoints.push({label,ok:r.ok,reads,stored:rt.inspect(G.Inspector(`inspect-${label}`,{events:{ping:G.System.readEvent(Ping)}},({events})=>[...events.ping.all()])),retainedSize:s?.size??0,readers:(s?.readers??[]).map(x=>({name:x.system,unread:x.unread,lagged:x.lagged}))});}
step('register',fast,slow);
emitted=[10,11];step('publish-fast',publish,fast);
step('slow-retains-first');step('slow-retains-second');
readFail=true;step('failed-read',slow);readFail=false;step('retry-read',slow);
step('cleanup-passed');
emitted=[20];enabled=false;step('publish-skip',publish,fast);enabled=true;step('after-skip',fast);step('slow-after-skip',slow);
emitted=[999];publishFail=true;step('failed-publication',publish);publishFail=false;emitted=[21];step('retry-publication',publish);step('both-read-retry',fast,slow);
emitted=Array(65535).fill(30);step('capacity-first-batch',publish);emitted=[40,41];step('capacity-second-batch',publish);step('capacity-enforced');step('lagged-readers',fast,slow);step('cleanup-after-lag');
console.log(JSON.stringify({format:1,checkpoints}));
