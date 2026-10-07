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
emitted=Array(65537).fill(7);step('before-readers',publish);step('dropped-before-first-run');step('first-fast-after-drop',fast);emitted=[10,11];step('before-slow-first-run',publish);step('first-slow-backlog',slow);step('fast-backlog',fast);step('late-cleanup');
console.log(JSON.stringify({format:1,checkpoints}));
