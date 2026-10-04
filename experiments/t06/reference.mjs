import {Descriptor, Fx, Schema} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const Position=Descriptor.Component()('Position'), Payload=Descriptor.Component()('Payload'), Tag=Descriptor.Component()('Tag');
const Score=Descriptor.Resource()('Score'), Ping=Descriptor.Event()('Ping');
const G=Schema.bind(Schema.fragment({components:{Position,Payload,Tag},resources:{Score},events:{Ping}}));
const runtime=G.Runtime.make({services:G.Runtime.services(),resources:{Score:2},debug:true});
let entity;
const Spawn=G.System('Spawn',{},({commands})=>{entity=commands.spawn(G.Command.spawn([Position,1],[Payload,[10,10,10,10]],[Tag,{}]));commands.spawn(G.Command.spawn([Position,1]));});
runtime.tick(G.Schedule(Spawn,G.Schedule.applyDeferred()));
const query=G.Query({selection:{position:G.Query.write(Position),payload:G.Query.write(Payload)}});
const spec={queries:{row:query},resources:{score:G.System.writeResource(Score)},events:{ping:G.System.writeEvent(Ping)}};
function view(m, resources){return `${m.data.position.get()}:${resources.score.get()}:${m.data.payload.get()[1]}`;}
function set(m, resources, position, score, payload){m.data.position.set(position);resources.score.set(score);m.data.payload.update(a=>{const copy=a.slice();copy[1]=payload;return copy;});}
const Good=G.System('Good',spec,({queries,resources,events,commands})=>{
  const m=queries.row.each()[0];set(m,resources,5,7,13);if(process.argv[2]==='good')console.log('good:own:'+view(m,resources));
  events.ping.emit(1);commands.remove(entity,Tag);
});
const Fail=G.System('Fail',spec,({queries,resources,events,commands})=>{
  const m=queries.row.each()[0];console.log('fail:before:'+view(m,resources));
  set(m,resources,9,11,17);console.log('fail:own1:'+view(m,resources));
  set(m,resources,12,13,19);console.log('fail:own2:'+view(m,resources));
  console.log('host:failure-effect');events.ping.emit(9);commands.insert(entity,[Tag,{}]);return Fx.fail(7);
});
const Second=G.System('Second',spec,({queries,resources,events,commands})=>{
  const m=queries.row.each()[0];
  set(m,resources,9,11,17);
  set(m,resources,12,13,19);
  events.ping.emit(9);commands.insert(entity,[Tag,{}]);
});
// Cumulative observed committed publications, not a claim about physical retention.
const published=[];let checkpoint='initial';
const readSpec={queries:{row:G.Query({selection:{position:G.Query.read(Position),payload:G.Query.read(Payload)}})},resources:{score:G.System.readResource(Score)},events:{ping:G.System.readEvent(Ping)}};
const Read=G.System('Read',readSpec,({queries,resources,events})=>{
  published.push(...events.ping.all());const m=queries.row.each()[0];
  // The public dump exposes command tag/system, not target. This finite input
  // queues exactly one command per publishing system; target labels are inputs.
  const slots={Good:0,Second:0};
  const queue=runtime.debug.dump().pendingCommands.map(c=>{if(!Object.hasOwn(slots,c.system))throw Error('unexpected publisher '+c.system);return c.tag+':'+slots[c.system]+',';}).join('');
  console.log(`${checkpoint}:`+view(m,resources)+':events='+published.map(x=>x+',').join('')+':commands='+queue);
});
function observe(name){checkpoint=name;runtime.tick(G.Schedule(Read));}
function result(name,r){console.log(name+':'+(r.ok?'Success':r.error.system+':'+r.error.error));}
if(process.argv[2]==='good')observe('initial');
const goodResult=runtime.tick(G.Schedule(Good));
if(process.argv[2]==='good')result('good:result',goodResult);
observe('committed');
if(process.argv[2]==='control'){result('second:result',runtime.tick(G.Schedule(Second)));observe('final');}
else if(process.argv[2]!=='good'){result('fail:result',runtime.tick(G.Schedule(Fail)));observe('restored');}

console.log("full:"+runtime.debug.dump().entities[0].components.Payload.join(",")+":other-position="+runtime.debug.dump().entities[1].components.Position);
