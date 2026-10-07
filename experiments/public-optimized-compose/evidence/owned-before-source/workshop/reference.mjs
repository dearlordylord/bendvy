/** Independent Workshop application, actual pinned public API only. */
import {Descriptor as D,Schema,Fx} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
import {readFileSync} from 'node:fs';
const Stock=D.Component()('Stock'), Recipe=D.Component()('Recipe'), Queue=D.Component()('Queue'), Enabled=D.Component()('Enabled'), Locked=D.Component()('Locked');
const W=Schema.bind(Schema.fragment({components:{Stock,Recipe,Queue,Enabled,Locked}}));
const rt=W.Runtime.make({services:W.Runtime.services()}), ids=[], checkpoints=[];
const all=W.Query({selection:{stock:W.Query.optional(Stock),recipe:W.Query.optional(Recipe),queue:W.Query.optional(Queue),enabled:W.Query.optional(Enabled),locked:W.Query.optional(Locked)}});
const compose=W.Query({selection:{stock:W.Query.write(Stock),recipe:W.Query.read(Recipe),queue:W.Query.optional(Queue)},with:[Enabled],without:[Locked]});
const triple=W.Query({selection:{stock:W.Query.write(Stock),recipe:W.Query.write(Recipe),queue:W.Query.write(Queue)},with:[Enabled],without:[Locked]});
const empty=W.Query({selection:{}}), contradict=W.Query({selection:{},with:[Enabled],without:[Enabled]});
const duplicates=W.Query({selection:{a:W.Query.write(Stock),b:W.Query.write(Stock),r:W.Query.read(Stock)}});
let label='';
const clone=structuredClone;
const observe=W.System('observe',{queries:{all,compose,empty,contradict}},({queries})=>{checkpoints.push({label,entities:queries.all.each().map(({entity,data})=>({id:entity.id.value,...Object.fromEntries(Object.entries(data).map(([k,c])=>[k,c.present?clone(c.get()):null]))})),composed:queries.compose.each().map(({entity,data})=>({id:entity.id.value,stock:clone(data.stock.get()),recipe:clone(data.recipe.get()),queue:data.queue.present?clone(data.queue.get()):null})),empty:queries.empty.each().map(({entity,data})=>({id:entity.id.value,data})),contradict:queries.contradict.each().map(({entity})=>entity.id.value)});});
function tick(...systems){const r=rt.tick(W.Schedule(...systems));if(!r.ok)throw Error(JSON.stringify(r));}
function snap(name){label=name;tick(observe);}
const payload=n=>({value:n,owned:[n,n+1,n+2]});
const spawn=W.System('seed',{},({commands})=>{
 ids.push(commands.spawn(W.Command.spawn([Stock,payload(10)],[Recipe,payload(20)],[Queue,payload(30)],[Enabled,{}])));
 ids.push(commands.spawn(W.Command.spawn([Stock,payload(11)],[Recipe,payload(21)],[Enabled,{}])));
 ids.push(commands.spawn(W.Command.spawn([Stock,payload(12)],[Queue,payload(32)],[Enabled,{}])));
 ids.push(commands.spawn(W.Command.spawn([Stock,payload(13)],[Recipe,payload(23)],[Queue,payload(33)],[Enabled,{}],[Locked,{}])));
 ids.push(commands.spawn(W.Command.spawn([Stock,payload(14)],[Recipe,payload(24)],[Queue,payload(34)])));
 ids.push(commands.spawn(W.Command.spawn()));
});
const work=W.System('produce',{queries:{compose}},({queries})=>{for(const {data} of queries.compose.each()){const s=data.stock.get();data.stock.set({value:s.value+data.recipe.get().value,owned:[...s.owned, data.queue.present?data.queue.get().value:0]});}});
let fail=true;
const retry=W.System('retry',{queries:{triple}},({queries,commands})=>{for(const {data} of queries.triple.each())for(const key of ['stock','recipe','queue'])data[key].set(payload(fail?900:100));commands.insert(ids[1],[Queue,payload(fail?999:31)]);return fail?Fx.fail('Rejected'):Fx.succeed(undefined);});
snap('empty');tick(spawn);snap('spawn-pending');tick(W.Schedule.applyDeferred());snap('seed-visible');
tick(work);snap('work-first');tick(work);snap('work-repeat');
const failed=rt.tick(W.Schedule(retry));checkpoints.push({label:'failed-result',ok:failed.ok,error:failed.error});snap('rollback-three-families');tick(W.Schedule.applyDeferred());snap('rollback-no-command');fail=false;tick(retry);snap('retry-committed-command-pending');tick(W.Schedule.applyDeferred());snap('retry-command-visible');
const insert=W.System('insert',{},({commands})=>{commands.insert(ids[2],[Recipe,payload(22)]);commands.insert(ids[4],[Enabled,{}]);});tick(insert);snap('insert-pending');tick(W.Schedule.applyDeferred());snap('insert-visible');
const remove=W.System('remove',{},({commands})=>{commands.remove(ids[3],Locked);commands.remove(ids[0],Recipe);});tick(remove);snap('remove-pending');tick(W.Schedule.applyDeferred());snap('remove-visible');
const churn=W.System('churn',{},({commands})=>{commands.despawn(ids[1]);ids.push(commands.spawn(W.Command.spawn([Stock,payload(16)],[Recipe,payload(26)],[Enabled,{}])));commands.insert(ids[0],[Recipe,payload(27)]);});tick(churn);snap('churn-pending');tick(W.Schedule.applyDeferred());snap('churn-visible');tick(work);snap('work-after-churn');
const dup=W.System('duplicate-declarations',{queries:{duplicates}},({queries})=>{const {data}=queries.duplicates.each()[0];data.a.set(payload(70));const afterA=clone(data.b.get());data.b.set(payload(71));checkpoints.push({label:'duplicate-family-reference',afterA,afterB:clone(data.r.get()),readHasSet:typeof data.r.set==='function'});});tick(dup);snap('duplicate-final-world');
// Separate advanced lifecycle composition observation; not structural acceptance.
const advanced=W.Query({selection:{stock:W.Query.read(Stock),queue:W.Query.optional(Queue)},with:[Enabled],without:[Locked],filters:[W.Query.added(Recipe),W.Query.changed(Stock)]});
let advancedLabel='advanced-first';
const advancedReader=W.System('advanced-reader',{queries:{advanced}},({queries})=>{checkpoints.push({label:advancedLabel,ids:queries.advanced.each().map(({entity})=>entity.id.value)});});
tick(advancedReader);advancedLabel='advanced-repeat';tick(advancedReader);
const addChange=W.System('advanced-insert',{},({commands})=>{commands.insert(ids[2],[Recipe,payload(88)],[Stock,payload(89)]);});
tick(addChange,W.Schedule.applyDeferred());advancedLabel='advanced-replacement';tick(advancedReader);
// Explicit approved world-identity divergence; never compare as Bend acceptance.
const foreign=W.Runtime.make({services:W.Runtime.services()});let foreignId;
const foreignSeed=W.System('foreign-seed',{},({commands})=>{foreignId=commands.spawn(W.Command.spawn([Stock,payload(777)]));});
foreign.tick(W.Schedule(foreignSeed,W.Schedule.applyDeferred()));
const foreignLookup=W.System('foreign-lookup',{},({lookup})=>{const found=lookup.getHandle(W.Entity.handle(foreignId),all);checkpoints.push({label:'foreign-collision-reference',foreignId:foreignId.value,ok:found.ok,stock:found.ok?clone(found.value.data.stock.get()):null});});tick(foreignLookup);
const result={format:1,application:'Workshop',checkpoints};
if(process.argv.includes('--verify')){const expected=JSON.parse(readFileSync(new URL('./expected.json',import.meta.url)));if(JSON.stringify(result)!==JSON.stringify(expected))throw Error('Reference mismatch');console.log(JSON.stringify({status:'PASS',checkpoints:checkpoints.length}));}else console.log(JSON.stringify(result,null,2));
