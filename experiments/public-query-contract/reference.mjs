import {Descriptor as D,Schema} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const Stock=D.Component()('Stock'),Recipe=D.Component()('Recipe'),Queue=D.Component()('Queue'),Enabled=D.Component()('Enabled'),Locked=D.Component()('Locked');
const W=Schema.bind(Schema.fragment({components:{Stock,Recipe,Queue,Enabled,Locked}})),rt=W.Runtime.make({services:W.Runtime.services()}),ids=[],points=[];
const all=W.Query({selection:{stock:W.Query.optional(Stock),recipe:W.Query.optional(Recipe),queue:W.Query.optional(Queue),enabled:W.Query.optional(Enabled),locked:W.Query.optional(Locked)}}),empty=W.Query({selection:{}}),work=W.Query({selection:{stock:W.Query.write(Stock),recipe:W.Query.read(Recipe),queue:W.Query.optional(Queue)},with:[Enabled],without:[Locked]}),duplicate=W.Query({selection:{a:W.Query.write(Stock),b:W.Query.write(Stock),r:W.Query.read(Stock)}});
const logical=new Map([[99,99]]); // Explicit invalid-request label; real labels come from actual reservations.
function remember(id){ids.push(id);logical.set(id.value,ids.length);return id;}
function logicalId(raw){if(!logical.has(raw))throw Error('unmapped entity identity '+raw);return logical.get(raw);}
const payload=n=>({value:n,owned:[n,n+1,n+2]});
const tick=s=>{const r=rt.tick(W.Schedule(s));if(!r.ok)throw Error(JSON.stringify(r));};
function record(label,result){tick(W.System('snap-'+label,{queries:{all}},({queries})=>{points.push({label,result,entities:queries.all.each().map(({entity,data})=>({id:logicalId(entity.id.value),...Object.fromEntries(Object.entries(data).map(([k,c])=>[k,c.present?structuredClone(c.get()):null]))}))});}));}
function normalize(r){if(r.ok)return {ok:true,value:null};return {ok:false,error:r.error._tag,...(r.error.entityId!==undefined?{entityId:logicalId(r.error.entityId)}:{}),...(r.error.count!==undefined?{count:r.error.count}:{})};}
function check(label,kind,target){let value;tick(W.System(label,{queries:{empty,work,duplicate}},({queries})=>{
if(kind==='count-all')value=queries.empty.each().length;
else if(kind==='count')value=queries.work.each().length;
else if(kind==='alias'){const r=queries.duplicate.get(target);if(!r.ok)throw Error(JSON.stringify(r));const {data}=r.value;data.a.set(payload(70));const afterA=structuredClone(data.b.get());data.b.set(payload(71));value={ok:true,value:{label:"duplicate-family-reference",afterA,afterB:structuredClone(data.r.get()),readHasSet:typeof data.r.set==='function'}};}
else {const r=kind==='single'?queries.work.single():queries.work.get(target);value=normalize(r);if(r.ok){const {data}=r.value,s=data.stock.get();data.stock.set({value:s.value+data.recipe.get().value,owned:[...s.owned,data.queue.present?data.queue.get().value:0]});}}
}));record(label,value);}
check('count-zero','count-all');check('single-zero','single');check('missing-zero','get',{value:99});
tick(W.System('seed',{},({commands})=>{
remember(commands.spawn(W.Command.spawn([Stock,payload(10)],[Recipe,payload(20)],[Queue,payload(30)],[Enabled,{}])));
remember(commands.spawn(W.Command.spawn([Stock,payload(11)],[Recipe,payload(21)],[Enabled,{}])));
remember(commands.spawn(W.Command.spawn([Stock,payload(12)],[Queue,payload(32)],[Enabled,{}])));
remember(commands.spawn(W.Command.spawn([Stock,payload(13)],[Recipe,payload(23)],[Queue,payload(33)],[Enabled,{}],[Locked,{}])));
remember(commands.spawn(W.Command.spawn([Stock,payload(14)],[Recipe,payload(24)],[Queue,payload(34)])));
remember(commands.spawn(W.Command.spawn()));}));tick(W.Schedule.applyDeferred());record('seed',null);
check('count-all','count-all');check('count-work','count');check('single-multiple','single');check('get-mismatch','get',ids[3]);check('get-missing','get',{value:99});check('get-write','get',ids[0]);
const unique=W.Query({selection:{stock:W.Query.write(Stock),recipe:W.Query.read(Recipe),queue:W.Query.read(Queue)},with:[Enabled],without:[Locked]});
let one;tick(W.System('single-one-write',{queries:{unique}},({queries})=>{const r=queries.unique.single();one=normalize(r);if(!r.ok)throw Error(JSON.stringify(r));const {data}=r.value,s=data.stock.get();data.stock.set({value:s.value+data.recipe.get().value,owned:[...s.owned,data.queue.get().value]});}));record('single-one-write',one);
check('get-alias','alias',ids[0]);
tick(W.System('churn',{},({commands})=>{commands.despawn(ids[1]);remember(commands.spawn(W.Command.spawn([Stock,payload(16)],[Recipe,payload(26)],[Enabled,{}])));commands.insert(ids[0],[Recipe,payload(27)]);}));tick(W.Schedule.applyDeferred());record('churn',null);check('get-stale','get',ids[1]);check('count-after-churn','count');
const foreign=W.Runtime.make({services:W.Runtime.services()});let foreignId;
const fs=W.System('foreign-seed',{},({commands})=>{foreignId=commands.spawn(W.Command.spawn());});
foreign.tick(W.Schedule(fs,W.Schedule.applyDeferred()));
let foreignLookup;tick(W.System('foreign-lookup',{queries:{work}},({queries})=>{foreignLookup=normalize(queries.work.get(foreignId));}));record('get-foreign',foreignLookup);
console.log(JSON.stringify(points));
