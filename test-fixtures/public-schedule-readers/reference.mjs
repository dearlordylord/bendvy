import {readFileSync} from "node:fs";
/** #35 composed public schedule oracle; no source-derived checkpoints. */
import {Descriptor as D,Schema,Fx} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const Stock=D.Component()('Stock'),Aux=D.Component()('Aux'),Ping=D.Event()('Ping');
const G=Schema.bind(Schema.fragment({components:{Stock,Aux},events:{Ping}}));
const rt=G.Runtime.make({services:G.Runtime.services(),debug:true}),ids=[],checkpoints=[];
let enabled=true,failPublisher=false,failEvent=false,failChange=false,failRemoval=false,ownWrite=false,values=[],reads=[];
const condition=G.Condition.check('enabled',{},()=>enabled);
const event=(name,conditional)=>G.System(name,{events:{ping:G.System.readEvent(Ping)},...(conditional?{when:[condition]}:{})},({events})=>{reads.push({kind:'event',name,values:[...events.ping.all()],lagged:events.ping.lagged()});return failEvent?Fx.fail('EventFailed'):undefined;});
const query=G.Query({selection:{stock:G.Query.write(Stock)},filters:[G.Query.changed(Stock)]});
const change=(name,conditional)=>G.System(name,{queries:{q:query},...(conditional?{when:[condition]}:{})},({queries})=>{const rows=queries.q.each();reads.push({kind:'change',name,values:rows.map(({entity,data})=>({id:entity.id.value,...structuredClone(data.stock.get())}))});if(ownWrite)for(const{data}of rows){const p=data.stock.get();data.stock.set({value:p.value+1,owned:[...p.owned,p.value+1]});}return failChange?Fx.fail('ChangeFailed'):undefined;});
const removal=(name,conditional)=>G.System(name,{removed:{stock:G.System.readRemoved(Stock),aux:G.System.readRemoved(Aux)},despawned:{entity:G.System.readDespawned()},...(conditional?{when:[condition]}:{})},({removed,despawned})=>{reads.push({kind:'removal',name,stock:removed.stock.all().map(x=>x.value),aux:removed.aux.all().map(x=>x.value),despawned:despawned.entity.all().map(x=>x.value)});return failRemoval?Fx.fail('RemovalFailed'):undefined;});
const ef=event('event-fast',true),es=event('event-slow',false),cf=change('change-fast',true),cs=change('change-slow',false),rf=removal('removal-fast',true),rs=removal('removal-slow',false);
const seed=G.System('seed',{},({commands})=>{ids.push(commands.spawn(G.Command.spawn([Stock,{value:10,owned:[10,11,12]}],[Aux,{owned:[20,21]}])));ids.push(commands.spawn(G.Command.spawn([Stock,{value:30,owned:[30,31,32]}],[Aux,{owned:[40,41]}])));});
const publish=G.System('publish',{events:{ping:G.System.writeEvent(Ping)}},({events,commands})=>{for(const v of values)events.ping.emit(v);commands.remove(ids[0],Aux);return failPublisher?Fx.fail('PublishFailed'):undefined;});
const edit=G.System('edit',{events:{ping:G.System.writeEvent(Ping)}},({commands,events})=>{events.ping.emit(5);commands.insert(ids[0],[Stock,{value:50,owned:[50,51,52,53]}]);commands.remove(ids[0],Aux);});
const churn=G.System('churn',{},({commands})=>{commands.remove(ids[0],Stock);commands.despawn(ids[1]);});
const all=G.Query({selection:{stock:G.Query.optional(Stock),aux:G.Query.optional(Aux)}});
function snap(label,result){const entities=rt.inspect(G.Inspector('snapshot',{queries:{all}},({queries})=>queries.all.each().map(({entity,data})=>({id:entity.id.value,stock:data.stock.present?structuredClone(data.stock.get()):null,aux:data.aux.present?structuredClone(data.aux.get()):null}))));const streams=rt.debug.streams();checkpoints.push({label,ok:result.ok,reads,entities,events:rt.inspect(G.Inspector('events',{events:{ping:G.System.readEvent(Ping)}},({events})=>[...events.ping.all()])),readers:streams.filter(s=>s.kind==='event').flatMap(s=>s.readers.map(r=>({name:r.system,unread:r.unread,lagged:r.lagged}))) });}
function step(label,...systems){reads=[];snap(label,rt.tick(G.Schedule(...systems)));}
step('seed',seed,G.Schedule.applyDeferred());step('register',ef,es,cf,cs,rf,rs);
values=[1,2];step('publish-pending',publish,ef,cf,rf);enabled=false;step('skip-all',edit,ef,cf,rf);step('barrier-skipped',G.Schedule.applyDeferred(),ef,cf,rf);enabled=true;step('resume-fast',ef,cf,rf);
failEvent=true;step('event-fail',es);failEvent=false;step('event-retry',es);
failChange=true;ownWrite=true;step('change-fail-own-write',cs);failChange=false;step('change-retry-own-write',cs);step('change-own-write-consumed',cs);ownWrite=false;
step('churn-pending',churn,rf);step('churn-visible',G.Schedule.applyDeferred());failRemoval=true;step('removal-fail',rs);failRemoval=false;step('removal-retry',rs);step('removal-consumed',rs);
values=[3];step('earlier-commit',publish);values=[999];failPublisher=true;step('failed-publisher',publish,G.Schedule.applyDeferred(),ef);failPublisher=false;step('earlier-command-survives',G.Schedule.applyDeferred(),ef,rf);values=[4];step('publisher-retry',publish,es);
values=Array(65535).fill(7);step('lag-batch',publish);values=[8,9];step('lag-overflow',publish);step('lag-retention');step('lag-readers',ef,es);step('after-lag');
const result={format:1,checkpoints};
if(process.argv.includes("--verify")){const expected=JSON.parse(readFileSync(new URL("./expected.json",import.meta.url)));if(JSON.stringify(result)!==JSON.stringify(expected))throw Error("Reference drift");console.log(JSON.stringify({status:"PASS",checkpoints:checkpoints.length}));}else console.log(JSON.stringify(result));
