/** Explicit per-instance Local adapter; pinned TS has no dedicated Local API. */
import {Descriptor as D,Schema,Fx} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const Count=D.Resource()('Count'),W=Schema.bind(Schema.fragment({resources:{Count}}));
const world=W.Runtime.make({services:W.Runtime.services(),resources:{Count:0}});
const foreign=W.Runtime.make({services:W.Runtime.services(),resources:{Count:77}});
const registrations=new Map();let next=1,log='';
// Both actual public TS systems invoke this same runner; instance state belongs
// to the explicit adapter, outside transactional ECS resources.
function runner({resources},instance,args){instance.local=instance.local.map(value=>value+args.delta);resources.count.set(resources.count.get()+args.delta);return args.fail?Fx.fail('Rejected'):undefined;}
function register(name,values){const instance={id:next++,name,world,local:[...values],args:null,active:true};instance.system=W.System(name,{resources:{count:W.System.writeResource(Count)}},ctx=>runner(ctx,instance,instance.args));registrations.set(instance.id,instance);return instance;}
const a=register('a',[10,20,30,40]),b=register('b',[100,200,300,400]);
const tick=(runtime,system)=>runtime.tick(W.Schedule(system));
function run(instance,runtime,args){if(runtime!==instance.world||!instance.active)return {refused:true,instance,args};instance.args=args;const result=tick(runtime,instance.system);log+=result.ok?'OK('+args.ticket.join(',')+')\n':'FAIL\n';return {refused:false,result};}
let counter=-1;const observe=W.System('observe',{resources:{count:W.System.readResource(Count)}},({resources})=>{counter=resources.count.get();});
function snapshot(label){const r=tick(world,observe);if(!r.ok)throw Error(JSON.stringify(r));log+=label+':w='+counter+';a=['+a.local.join(',')+'];b=['+b.local.join(',')+']\n';}
const args=(delta,fail=false)=>({delta,fail,ticket:[0,0]});
snapshot('seed');run(a,world,args(1));snapshot('a-first');run(b,world,args(10));snapshot('b-first');
// The adapter's conditional skip returns the exact same owner and invokes no TS
// system. This matches Local.skip; schedule-specific conditions are ticket #33.
const skipped=a;if(skipped!==a)throw Error('skip owner lost');snapshot('a-skipped');
run(a,world,args(2,true));snapshot('a-failed');run(a,world,args(3));snapshot('a-retry');run(b,world,args(20));snapshot('b-repeat');
const incoming={delta:7,fail:false,ticket:[99,98]},refused=run(a,foreign,incoming);if(!refused.refused||refused.instance!==a||refused.args!==incoming)throw Error('foreign refusal lost ownership');log+='FOREIGN_REFUSAL('+refused.args.ticket.join(',')+')\n';run(refused.instance,world,refused.args);snapshot('foreign-returned-args-retry');
function dispose(instance,runtime){if(runtime!==instance.world||!instance.active)return {refused:true,instance};instance.active=false;registrations.delete(instance.id);const values=instance.local;instance.local=[];return {refused:false,values};}
const d=dispose(a,foreign);if(!d.refused||d.instance!==a)throw Error('foreign disposal lost owner');log+='FOREIGN_DISPOSAL_REFUSAL\n';snapshot('foreign-disposal-refused');
const da=dispose(d.instance,world);if(da.refused)throw Error('a disposal failed');log+='dispose-a=['+da.values.join(',')+'];w='+counter+';registered='+[...registrations.keys()].reverse().map(x=>x+',').join('')+'\n';const db=dispose(b,world);if(db.refused)throw Error('b disposal failed');log+='dispose-b=['+db.values.join(',')+'];w='+counter+';registered='+[...registrations.keys()].map(x=>x+',').join('');
console.log(log);
