import {Descriptor,Schema} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const Position=Descriptor.Component()('Position'),Tag=Descriptor.Component()('Tag');
const G=Schema.bind(Schema.fragment({components:{Position,Tag}}));
const make=()=>G.Runtime.make({services:G.Runtime.services(),resources:{}});
const W=make(), V=make(), ids=new Map(), labels=new Map();
const selection={position:G.Query.read(Position),tag:G.Query.optional(Tag)};
const specs={Required:G.Query({selection}),Present:G.Query({selection,with:[Tag]}),Absent:G.Query({selection,without:[Tag]}),Optional:G.Query({selection})};
function text(m){const label=labels.get(m.entity.id.value);if(label===undefined)throw Error('unmapped id');return `${label}:${m.data.position.get().x}:${m.data.tag.present?'present{}':'absent'};`;}
let checkpoint='pending';
const Read=G.System('Read',{queries:specs},({queries,lookup})=>{
  for(const name of Object.keys(specs))console.log(`${checkpoint}:${name}:`+queries[name].each().map(text).join(''));
  for(const label of ['a','b'])for(const name of ['Required','Present']){
    const r=lookup.getHandle(G.Entity.handle(ids.get(label)),specs[name]);
    console.log(`${checkpoint}:lookup-${label}-${name}:`+(r.ok?'match:'+text(r.value):r.error._tag));
  }
});
const Spawn=G.System('Spawn',{},({commands})=>{for(const [label,x] of [['a',1],['b',2]]){const id=commands.spawn(G.Command.spawn([Position,{x}]));if(labels.has(id.value))throw Error('duplicate reservation');ids.set(label,id);labels.set(id.value,label);}});
function run(name,...systems){checkpoint=name;W.tick(G.Schedule(...systems,Read));}
run('pending',Spawn);run('next-schedule');run('live',G.Schedule.applyDeferred());
const Insert=G.System('Insert',{},({commands})=>{commands.insert(ids.get('b'),[Tag,{}]);commands.insert(ids.get('a'),[Tag,{}]);});
run('insert-pending',Insert);run('inserted',G.Schedule.applyDeferred());
const Remove=G.System('Remove',{},({commands})=>{commands.remove(ids.get('a'),Tag);});
run('remove-pending',Remove);run('removed',G.Schedule.applyDeferred());
const Despawn=G.System('Despawn',{},({commands})=>{commands.despawn(ids.get('a'));commands.insert(ids.get('a'),[Tag,{}]);});
run('despawn-pending',Despawn);run('stale',G.Schedule.applyDeferred());run('empty-marker',G.Schedule.applyDeferred());
// Same schema, different runtime, colliding first reservation. No adapter guard.
let foreign;
const ForeignSpawn=G.System('ForeignSpawn',{},({commands})=>{foreign=G.Entity.handle(commands.spawn(G.Command.spawn([Position,{x:99}])));});
V.tick(G.Schedule(ForeignSpawn,G.Schedule.applyDeferred()));
const ForeignRead=G.System('ForeignRead',{},({lookup})=>{const r=lookup.getHandle(foreign,specs.Required);console.log('foreign:lookup:'+ (r.ok?'match:'+text(r.value):r.error._tag));});
// W's first entity is stale here, so recreate the collision in a third runtime.
const Collision=make();let local;
const LocalSpawn=G.System('LocalSpawn',{},({commands})=>{local=commands.spawn(G.Command.spawn([Position,{x:7}]));});
Collision.tick(G.Schedule(LocalSpawn,G.Schedule.applyDeferred()));
const CollisionRead=G.System('CollisionRead',{},({lookup})=>{const r=lookup.getHandle(foreign,specs.Required);console.log('foreign-collision:lookup:'+(r.ok?'match:local:'+r.value.data.position.get().x:r.error._tag));});
W.tick(G.Schedule(ForeignRead));Collision.tick(G.Schedule(CollisionRead));
