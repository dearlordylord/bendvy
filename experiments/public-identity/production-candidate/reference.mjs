import {Descriptor as D,Schema} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const Stock=D.Component()('Stock'),Recipe=D.Component()('Recipe'),Queue=D.Component()('Queue'),Enabled=D.Component()('Enabled'),Locked=D.Component()('Locked');
const W=Schema.bind(Schema.fragment({components:{Stock,Recipe,Queue,Enabled,Locked}}));
const make=()=>W.Runtime.make({services:W.Runtime.services()}),sender=make(),receiver=make();
const all=W.Query({selection:{stock:W.Query.optional(Stock),recipe:W.Query.optional(Recipe),queue:W.Query.optional(Queue),enabled:W.Query.optional(Enabled),locked:W.Query.optional(Locked)}});
const ensure=r=>{if(!r.ok)throw Error(JSON.stringify(r));};let foreign,local;
const payload=n=>({value:n,owned:[n,n+1,n+2]});
const entries=n=>[[Stock,payload(n)],[Recipe,payload(n)],[Queue,payload(n)],[Enabled,{}],[Locked,{}]];
function seed(rt,value,receive){ensure(rt.tick(W.Schedule(W.System('seed-'+value,{},({commands})=>{receive(commands.spawn(W.Command.spawn(...entries(value))));}),W.Schedule.applyDeferred())));}
function rows(rt){return rt.inspect(W.Inspector('snapshot',{queries:{all}},({queries})=>queries.all.each().map(({entity,data})=>({id:entity.id.value,stock:structuredClone(data.stock.get()),recipe:structuredClone(data.recipe.get()),queue:structuredClone(data.queue.get()),enabled:data.enabled.present,locked:data.locked.present}))));}
seed(sender,10,id=>foreign=id);seed(receiver,20,id=>local=id);const before={sender:rows(sender),receiver:rows(receiver)};let lookup;
ensure(receiver.tick(W.Schedule(W.System('foreign-lookup',{queries:{all}},({queries})=>{const result=queries.all.get(foreign);lookup={ok:result.ok,stock:result.ok?structuredClone(result.value.data.stock.get()):null};}))));
ensure(receiver.tick(W.Schedule(W.System('foreign-despawn',{},({commands})=>commands.despawn(foreign)),W.Schedule.applyDeferred())));
console.log(JSON.stringify({before,foreignId:foreign.value,localId:local.value,lookup,after:{sender:rows(sender),receiver:rows(receiver)},scope:'Actual TS independent same-schema runtimes resolve equal numeric IDs; Bend MissingEntity is the approved foreign-world difference. No failed-reservation policy observation.'},null,2));
