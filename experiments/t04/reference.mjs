import {Descriptor, Schema} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const Position=Descriptor.Component()('Position'), Items=Descriptor.Component()('Items');
const G=Schema.bind(Schema.fragment({components:{Position,Items}}));
const runtime=G.Runtime.make({services:G.Runtime.services(),resources:{}});
const labels=new Map();
const Spawn=G.System('Spawn',{},({commands})=>{
  for(const [label,x,value] of [['a',0,10],['b',10,20]]) {
    const id=commands.spawn(G.Command.spawn([Position,{x}],[Items,{items:Array(4).fill(value)}]));
    if(labels.has(id.value)) throw Error('duplicate ID');
    labels.set(id.value,label);
  }
});
let checkpoint='setup';
const Read=G.System('Read',{queries:{rows:G.Query({selection:{position:G.Query.read(Position),payload:G.Query.read(Items)}})}},({queries})=>{
  const text=queries.rows.each().map(m=>{
    const label=labels.get(m.entity.id.value);
    if(label===undefined) throw Error('unknown entity');
    return `${label}:${m.data.position.get().x}:[${m.data.payload.get().items.join(',')}];`;
  }).join('');
  console.log(checkpoint+':'+text);
});
const Step=G.System('Step',{queries:{rows:G.Query({selection:{payload:G.Query.write(Items)}})}},({queries})=>{
  for(const m of queries.rows.each()) m.data.payload.update(p=>{
    const items=p.items.slice(); items[1]+=3; return {items};
  });
});
runtime.tick(G.Schedule(Spawn,G.Schedule.applyDeferred(),Read));
checkpoint='read-again'; runtime.tick(G.Schedule(Read));
const sequence=G.Schedule(Step,Read);
for(let i=1;i<=3;i++) {checkpoint='step'+i; runtime.tick(sequence);}
checkpoint='final-read'; runtime.tick(G.Schedule(Read));
