/** Actual pinned bevy-ts public API oracle; no Bend engine imports. */
import { Descriptor as D, Schema, Fx } from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
const Position=D.Component()('Position'), Velocity=D.Component()('Velocity'), Health=D.Component()('Health'), Armor=D.Component()('Armor'), Tag=D.Component()('Tag');
const Dt=D.Resource()('Dt'), Hit=D.Event()('Hit'), Death=D.Event()('Death');
const G=Schema.bind(Schema.fragment({components:{Position,Velocity,Health,Armor,Tag},resources:{Dt},events:{Hit,Death}}));
const rt=G.Runtime.make({services:G.Runtime.services(),resources:{Dt:1}}), ids=[], checkpoints=[];
const read=G.Query({selection:{position:G.Query.optional(Position),velocity:G.Query.optional(Velocity),health:G.Query.optional(Health),armor:G.Query.optional(Armor),tag:G.Query.optional(Tag)}});
const moving=G.Query({selection:{position:G.Query.write(Position),velocity:G.Query.read(Velocity)}});
const combat=G.Query({selection:{health:G.Query.write(Health),armor:G.Query.optional(Armor)}});
const tagged=G.Query({selection:{position:G.Query.read(Position)},with:[Tag],without:[Velocity]});
let lastEvents={hit:[],death:[]};
const observe=G.System('observe',{queries:{all:read,filtered:tagged},resources:{dt:G.System.readResource(Dt)},events:{hit:G.System.readEvent(Hit),death:G.System.readEvent(Death)}},({queries,resources,events})=>{
 lastEvents={hit:events.hit.all().map(e=>({...e,id:e.id.value})),death:events.death.all().map(e=>({id:e.id.value}))};
 checkpoints.push({label:label,entities:queries.all.each().map(({entity,data})=>({id:entity.id.value,...Object.fromEntries(['position','velocity','health','armor','tag'].map(k=>[k,data[k].present?structuredClone(data[k].get()):null]))})),dt:resources.dt.get(),filtered:queries.filtered.each().map(({entity})=>entity.id.value),events:lastEvents});
});
let label='';
function tick(...systems){const r=rt.tick(G.Schedule(...systems));if(!r.ok)throw Error(JSON.stringify(r));}
function snap(name){label=name;tick(observe);}
const spawn=G.System('spawn',{},({commands})=>{
 ids.push(commands.spawn(G.Command.spawn([Position,{x:0,trail:[10,11]}],[Velocity,{dx:2,history:[20]}],[Health,{hp:5,history:[50]}],[Armor,{value:1}],[Tag,{}])));
 ids.push(commands.spawn(G.Command.spawn([Position,{x:10,trail:[12]}],[Velocity,{dx:-1,history:[21]}],[Health,{hp:3,history:[51]}])));
 ids.push(commands.spawn(G.Command.spawn([Position,{x:20,trail:[13]}],[Health,{hp:9,history:[52]}],[Tag,{}])));
});
const move=G.System('movement',{queries:{moving},resources:{dt:G.System.readResource(Dt)}},({queries,resources})=>{for(const {data} of queries.moving.each())data.position.update(p=>({...p,x:p.x+data.velocity.get().dx*resources.dt.get()}));});
const damage=G.System('damage',{queries:{combat},events:{hit:G.System.writeEvent(Hit),death:G.System.writeEvent(Death)}},({queries,events,commands})=>{
 for(const {entity,data} of queries.combat.each()) {const h=data.health.get(),amount=2-(data.armor.present?data.armor.get().value:0),hp=h.hp-amount;data.health.set({...h,hp});events.hit.emit({id:entity.id,amount,hp});if(hp<=0){events.death.emit({id:entity.id});commands.despawn(entity.id);}}
});
let fail=true;
const retry=G.System('retry',{queries:{moving},resources:{dt:G.System.writeResource(Dt)},events:{hit:G.System.writeEvent(Hit)}},({queries,resources,events,commands})=>{
 if(fail){for(const {data} of queries.moving.each())data.position.update(p=>({...p,x:999}));resources.dt.set(9);events.hit.emit({id:999,amount:999,hp:999});commands.spawn(G.Command.spawn([Position,{x:999,trail:[999]}]));return Fx.fail('Rejected');}
 resources.dt.set(1);return Fx.succeed(undefined);
});
snap('empty');tick(spawn);snap('spawn-pending');tick(G.Schedule.applyDeferred());snap('spawn-visible');
for(let n=1;n<=3;n++){
 tick(move);snap(`tick${n}-movement`);
 if(n===1){const r=rt.tick(G.Schedule(retry));checkpoints.push({label:'failed-result',ok:r.ok,error:r.error});snap('failed-rollback');tick(G.Schedule.applyDeferred());snap('failed-barrier-no-ghost');fail=false;tick(retry);snap('same-instance-retry');}
 tick(damage);snap(`tick${n}-damage-before-barrier`);tick(G.Schedule.applyDeferred());snap(`tick${n}-after-barrier`);
}
const insert=G.System('insert',{},({commands})=>{commands.insert(ids[2],[Velocity,{dx:3,history:[23]}],[Armor,{value:2}]);});
tick(insert);snap('insert-pending');tick(G.Schedule.applyDeferred());snap('insert-visible');
const remove=G.System('remove',{},({commands})=>{commands.remove(ids[0],Velocity);});tick(remove);snap('remove-pending');tick(G.Schedule.applyDeferred());snap('remove-visible');
// Root brands are compile-time TS boundaries; same-schema runtime handles have no world nonce.
const foreign=G.Runtime.make({services:G.Runtime.services(),resources:{Dt:1}});let foreignId;
const foreignSpawn=G.System('foreign-spawn',{},({commands})=>{foreignId=commands.spawn(G.Command.spawn([Position,{x:777,trail:[77]}]));});
foreign.tick(G.Schedule(foreignSpawn,G.Schedule.applyDeferred()));
const foreignLookup=G.System('foreign-lookup',{},({lookup})=>{const r=lookup.getHandle(G.Entity.handle(foreignId),read);checkpoints.push({label:'foreign-collision-reference',foreignId:foreignId.value,localId:ids[0].value,ok:r.ok,position:r.ok?r.value.data.position.get():null});});tick(foreignLookup);
const despawn=G.System('despawn',{},({commands})=>{commands.despawn(ids[2]);});tick(despawn);snap('despawn-pending');tick(G.Schedule.applyDeferred());snap('despawn-visible');
const result={format:1,checkpoints};
if(process.argv.includes('--verify')){const expected=JSON.parse(readFileSync(fileURLToPath(new URL('./expected.json',import.meta.url))));if(JSON.stringify(result)!==JSON.stringify(expected))throw Error('Reference checkpoint mismatch');console.log(JSON.stringify({status:'PASS',checkpoints:checkpoints.length}));}
else console.log(JSON.stringify(result,null,2));
