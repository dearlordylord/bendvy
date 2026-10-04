import {Descriptor,Entity,Schema} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const Value=Descriptor.Component()('Value'),Tag=Descriptor.Component()('Tag');
const G=Schema.bind(Schema.fragment({components:{Value,Tag}}));
const make=()=>G.Runtime.make({services:G.Runtime.services(),resources:{}});
const W=make(),V=make(),ids=[];
const selection={value:G.Query.read(Value),tag:G.Query.optional(Tag)};
const Q={any:G.Query({selection}),present:G.Query({selection,with:[Tag]}),absent:G.Query({selection,without:[Tag]})};
const WQ=G.Query({selection:{value:G.Query.write(Value)}});
let phase='empty';
const text=m=>`${m.entity.id.value}:${m.data.value.get().x}:${m.data.tag.present?1:0};`;
const Read=G.System('Read',{queries:Q},({queries,lookup})=>{
 for(const mode of ['any','present','absent'])console.log(`${phase}:${mode}:`+queries[mode].each().map(text).join(''));
 for(const [slot,name,mode] of [[1,'lookup1','any'],[2,'lookup2-present','present'],[4,'lookup4','any']]){
  const r=lookup.getHandle(G.Entity.handle(Entity.makeEntityId(slot)),Q[mode]);
  console.log(`${phase}:${name}:`+(r.ok?'match:'+text(r.value):r.error._tag));
 }
});
const Spawn=G.System('Spawn',{},({commands})=>{for(const x of [1,2,3])ids.push(commands.spawn(G.Command.spawn([Value,{x}])));});
function run(label,...systems){phase=label;W.tick(G.Schedule(...systems,Read));}
run('empty');run('pending',Spawn);run('next-schedule');run('live',G.Schedule.applyDeferred());
const Update=G.System('Update',{queries:{rows:WQ}},({queries,commands})=>{
 for(const m of queries.rows.each())if(m.entity.id.value===2)m.data.value.set({x:m.data.value.get().x+1});
 commands.insert(ids[0],[Tag,{}]);commands.insert(ids[1],[Tag,{}]);
});
run('immediate-and-pending',Update);run('inserted',G.Schedule.applyDeferred());
let foreign;
V.tick(G.Schedule(G.System('ForeignSpawn',{},({commands})=>{foreign=commands.spawn(G.Command.spawn([Value,{x:99}]));}),G.Schedule.applyDeferred()));
W.tick(G.Schedule(G.System('ForeignLookup',{},({lookup})=>{
 const r=lookup.getHandle(G.Entity.handle(foreign),Q.any);
 console.log('foreign-collision:lookup:'+(r.ok?'match:'+text(r.value):r.error._tag));
})));
const Noncommuting=G.System('Noncommuting',{},({commands})=>{
 commands.insert(ids[0],[Tag,{}]);commands.remove(ids[0],Tag);commands.despawn(Entity.makeEntityId(7));
});
run('noncommuting-pending',Noncommuting);run('removed',G.Schedule.applyDeferred());
const Destroy=G.System('Destroy',{},({commands})=>{commands.despawn(ids[0]);commands.insert(ids[0],[Tag,{}]);});
run('despawn-pending',Destroy);run('stale',G.Schedule.applyDeferred());
run('respawn-pending',G.System('Respawn',{},({commands})=>{ids.push(commands.spawn(G.Command.spawn([Value,{x:4}])));}));
run('new-live',G.Schedule.applyDeferred());
// Public reference collision command is observed on an isolated third runtime;
// the reference does not carry Bendvy namespace authority. No adapter guard.
const C=make();
C.tick(G.Schedule(G.System('CollisionSpawn',{},({commands})=>{commands.spawn(G.Command.spawn([Value,{x:7}]));}),G.Schedule.applyDeferred()));
C.tick(G.Schedule(G.System('ForeignCommand',{},({commands})=>{commands.despawn(foreign);}),G.Schedule.applyDeferred(),G.System('ObserveCollision',{queries:{q:Q.any}},({queries})=>{
 console.log('foreign-command-collision:remaining:'+queries.q.each().length);
})));
