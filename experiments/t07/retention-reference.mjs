import {Descriptor,Schema} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const Ping=Descriptor.Event()('Ping'), G=Schema.bind(Schema.fragment({events:{Ping}}));
const make=()=>G.Runtime.make({services:G.Runtime.services()});
const emit=values=>G.System('Emit'+values.join('-'),{events:{ping:G.System.writeEvent(Ping)}},({events})=>{for(const x of values)events.ping.emit(x);});
const reader=(name,label)=>G.System(name,{events:{ping:G.System.readEvent(Ping)}},({events})=>console.log(label()+':'+events.ping.all().map(x=>x+',').join('')+':'+events.ping.lagged()));
let r=make();r.tick(G.Schedule(emit([8])));r.tick(G.Schedule());r.tick(G.Schedule());r.tick(G.Schedule(reader('Late',()=> 'unregistered:late')));
r=make();let label='holder:init';const held=reader('Holder',()=>label);r.tick(G.Schedule(held));r.tick(G.Schedule(emit([7])));r.tick(G.Schedule());r.tick(G.Schedule());label='holder:first';r.tick(G.Schedule(reader('New',()=> 'holder:new'),held));
