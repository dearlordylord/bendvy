import assert from 'node:assert/strict';
import {Descriptor, Schema, Fx} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const Counter = Descriptor.Resource()('Counter');
const Logger = Descriptor.Service()('Logger');
const G = Schema.bind(Schema.fragment({resources:{Counter}}));
const Begin = G.System('Begin', {}, () => { console.log('Begin'); });
const Notify = G.System('Notify', {resources:{counter:G.System.readResource(Counter)},services:{logger:G.System.service(Logger)}}, ({resources,services}) => { services.logger.log('Notify:'+resources.counter.get()); });
const Fail = G.System('Fail', {}, () => Fx.fail({code:7}));
const After = G.System('After', {}, () => { console.log('After'); });
const rt = (resource, service) => G.Runtime.make({resources:resource?{Counter:42}:{},services:service?G.Runtime.services(G.Runtime.service(Logger,{log:console.log})):G.Runtime.services()});
const schedule = G.Schedule(Begin, G.Schedule(Notify, Fail), After);
const runtime=rt(true,true);
for(let i=0;i<2;i++) {
 const result=runtime.tryTick(schedule);
 assert.deepEqual(result,{ok:false,error:{kind:'SystemFailure',system:'Fail',error:{code:7}}});
 console.log('failure:'+result.error.system+':'+result.error.error.code);
}
for(const [resource,service,kind,label] of [[false,true,'resource','missing-resource'],[true,false,'service','missing-service']]) {
 const result=rt(resource,service).tryTick(schedule);
 assert.deepEqual(result,{ok:false,error:{kind:'MissingRuntimeRequirements',requirements:[{kind,name:resource?'Logger':'Counter'}]}});
 console.log(label);
}
const success=G.Schedule(Begin,G.Schedule(Notify,G.System('Fail',{},()=>{})),After);
for(let i=0;i<2;i++) { assert.deepEqual(runtime.tryTick(success),{ok:true,value:undefined}); console.log('complete'); }
for(const [resource,service,label] of [[false,true,'missing-resource'],[true,false,'missing-service']]) {
 assert.equal(rt(resource,service).tryTick(success).ok,false); console.log(label);
}
