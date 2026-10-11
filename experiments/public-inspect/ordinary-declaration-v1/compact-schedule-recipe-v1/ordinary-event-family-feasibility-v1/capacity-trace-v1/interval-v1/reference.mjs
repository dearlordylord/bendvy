import {reset,begin,end,capture,finish} from './ts-timing.mjs';
import {Descriptor,Schema,Fx} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const First=Descriptor.Event()('First'),Second=Descriptor.Event()('Second'),Unused=Descriptor.Event()('Unused');
const G=Schema.bind(Schema.fragment({events:{First,Second,Unused}}));
const rt=G.Runtime.make({services:G.Runtime.services(),debug:true});
let count=2;let failPublish=false,failRead=false,completion=null;
const reader=(name,descriptor)=>G.System(name,{events:{selected:G.System.readEvent(descriptor)}},({events})=>{
 const reading={values:[...events.selected.all()],lagged:events.selected.lagged()};
 completion={kind:descriptor===First?'First':'Second',failed:failRead,reading};
 return failRead?Fx.fail('ReadFailed'):undefined;
});
const fast=reader('first',First),slow=reader('slow',First),second=reader('second',Second);
const publisher=G.System('publisher',{events:{first:G.System.writeEvent(First),second:G.System.writeEvent(Second)}},({events})=>{
 for(let i=0;i<count;i++)events.first.emit(30);events.second.emit(true);completion={kind:'Published',failed:failPublish};
 return failPublish?Fx.fail('Aborted'):undefined;
});
const retained=(label)=>rt.inspect(G.Inspector('capacity-observer-'+label,{events:{first:G.System.readEvent(First),second:G.System.readEvent(Second)}},({events})=>({first:[...events.first.all()],second:[...events.second.all()]})));
const rows=[];
function observe(label,ok){for(const enabled of [true])rows.push({label,enabled,ok,completion,inventory:enabled?rt.debug.describe().events.map(x=>x.name):null,streams:enabled?rt.debug.streams():null,physicalStreams:rt.debug.streams(),retainedValues:retained(label)});}
function step(label,system,readFailure=false,publishFailure=false){failRead=readFailure;failPublish=publishFailure;completion=null;begin(label);const result=rt.tick(G.Schedule(...(system?[system]:[])));end();if(!system)completion={kind:'Framed'};observe(label,result.ok);}
reset();observe('initial',true);
step('activate-fast',fast);step('activate-slow',slow);step('activate-second',second);
count=65535;step('publish-65535',publisher);count=2;step('publish-2',publisher);step('capacity-trim',null);step('slow-lagged',slow);step('fast-lagged',fast);step('second-independent',second);step('cleanup',null);step('cleanup-again',null);
capture(JSON.stringify({format:1,rows}));finish();
