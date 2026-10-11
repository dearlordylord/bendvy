import {Descriptor,Schema,Fx} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const First=Descriptor.Event()('First'),Second=Descriptor.Event()('Second'),Unused=Descriptor.Event()('Unused');
const G=Schema.bind(Schema.fragment({events:{First,Second,Unused}}));
const rt=G.Runtime.make({services:G.Runtime.services(),debug:true});
let failPublish=false,failRead=false,completion=null;
const reader=(name,descriptor)=>G.System(name,{events:{selected:G.System.readEvent(descriptor)}},({events})=>{
 const reading={values:[...events.selected.all()],lagged:events.selected.lagged()};
 completion={kind:descriptor===First?'First':'Second',failed:failRead,reading};
 return failRead?Fx.fail('ReadFailed'):undefined;
});
const fast=reader('first',First),slow=reader('slow',First),second=reader('second',Second);
const publisher=G.System('publisher',{events:{first:G.System.writeEvent(First),second:G.System.writeEvent(Second)}},({events})=>{
 events.first.emit(7);events.second.emit(true);events.first.emit(8);completion={kind:'Published',failed:failPublish};
 return failPublish?Fx.fail('Aborted'):undefined;
});
const rows=[];
function observe(label,ok){for(const enabled of [false,true,true,false])rows.push({label,enabled,ok,completion,inventory:enabled?rt.debug.describe().events.map(x=>x.name):null,streams:enabled?rt.debug.streams():null,physicalStreams:rt.debug.streams()});}
function step(label,system,readFailure=false,publishFailure=false){failRead=readFailure;failPublish=publishFailure;completion=null;const result=rt.tick(G.Schedule(...(system?[system]:[])));if(!system)completion={kind:'Framed'};observe(label,result.ok);}
observe('initial',true);
step('activate-fast',fast);step('activate-slow',slow);step('activate-second',second);step('publish',publisher);step('fast-read',fast);step('publish-abort',publisher,false,true);step('second-failed',second,true);step('second-retry',second);step('publish-retry',publisher);step('slow-failed',slow,true);step('slow-retry',slow);step('fast-read-again',fast);step('second-read-again',second);step('frame',null);step('frame-again',null);step('fast-empty',fast);step('second-empty',second);
console.log(JSON.stringify({format:1,rows}));
