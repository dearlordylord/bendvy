// Actual public TS runtime, common lossless full-field tuple forcing; no timed expected-state guards.
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {createHash} from 'node:crypto';
import {Descriptor,Schema,Fx} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
import {encode,fold} from './failure-quiet-codec.mjs';
const original=readFileSync('/workspace/formal-proofs/bendvy/experiments/s-integrate/measurement-reference.mjs');
assert.equal(createHash('sha256').update(original).digest('hex'),'039edf1ec9905ad39c94bf4fcd9850610615251bd8b72e044b93fb7aa7c90376');
const schema=process.argv[2],count=Number(process.argv[3]),iterations=64;
assert.ok(['Motion','Health'].includes(schema));assert.ok([64,256,1024].includes(count));
const Main=Descriptor.Component()(schema==='Motion'?'Position':'Vitals'),Aux=Descriptor.Component()(schema==='Motion'?'Velocity':'Armor'),Flag=Descriptor.Component()(schema==='Motion'?'Selected':'Tracked'),Ledger=Descriptor.Resource()(schema+'Ledger'),Ping=Descriptor.Event()(schema+'Ping'),Audit=Descriptor.Service()('Audit');
const G=Schema.bind(Schema.fragment({components:{Main,Aux,Flag},resources:{[Ledger.name]:Ledger},events:{Ping}}));
const effects=[],events=[],ids=[],failed=[];
const runtime=G.Runtime.make({resources:{[Ledger.name]:{totals:[0,101,102,103],epoch:4}},services:G.Runtime.services(G.Runtime.service(Audit,{log:value=>effects.push(JSON.stringify(value))})),debug:true});
// Logical owner correspondence: this one freshly created runtime is namespace1,
// matching the one-factory Bend fixture. No claim about a public TS numeric namespace.
const namespace=1;
const four=xs=>({a:xs[0],b:xs[1],c:xs[2],d:xs[3]});
const mainView=x=>schema==='Motion'?{coordinates:four(x.coordinates),frame:x.frame}:{levels:four(x.levels),reserve:x.reserve,class:x.class};
const auxView=x=>schema==='Motion'?{rates:four(x.rates),moving:x.moving}:{layers:four(x.layers),grade:x.grade};
const ledgerView=x=>({totals:four(x.totals),epoch:x.epoch});
const main=(j,tail=[j+1,j+2,j+3])=>schema==='Motion'?{coordinates:[j,...tail],frame:7}:{levels:[j,...tail],reserve:9,class:2};
const aux=()=>schema==='Motion'?{rates:[1,2,3,4],moving:true}:{layers:[1,2,3,4],grade:3};
const cells=x=>schema==='Motion'?x.coordinates:x.levels;
const replace=(old,value)=>schema==='Motion'?{coordinates:[value,...old.coordinates.slice(1)],frame:old.frame}:{levels:[value,...old.levels.slice(1)],reserve:old.reserve,class:old.class};
const entity=id=>({namespace,id:id.value});
const Q=G.Query({selection:{main:G.Query.read(Main),aux:G.Query.optional(Aux),flag:G.Query.optional(Flag)}}),Write=G.Query({selection:{main:G.Query.write(Main)}});
const row=r=>({handle:entity(r.entity.id),main:mainView(r.data.main.get()),aux:r.data.aux.present?auxView(r.data.aux.get()):null,flag:r.data.flag.present?structuredClone(r.data.flag.get()):null});
const access=result=>result.ok?{kind:'Found',value:row(result.value)}:{kind:result.error._tag==='MissingEntity'?'Missing':'Mismatch'};
const ownMain=r=>({kind:'Main',value:{kind:'Found',value:schema==='Motion'?{kind:'MotionMain',position:mainView(r.data.main.get())}:{kind:'HealthMain',vitals:mainView(r.data.main.get())}}});
const ownLedger=resource=>({kind:'Ledger',value:ledgerView(resource.get())});
const ownLookup=result=>({kind:'ReservedLookup',value:result.ok?{kind:'Found',value:schema==='Motion'?{kind:'MotionMain',position:mainView(result.value.data.main.get())}:{kind:'HealthMain',vitals:mainView(result.value.data.main.get())}}:{kind:result.error._tag==='MissingEntity'?'Missing':'Mismatch'}});
const captures={A:0,B:0,PublicationObserver:0,Observe:0,DisposeTransient:0,Seed:0};
let iteration=0,mode='prime',phase='prime',p=null,q=null,r=null,awaitingReader=null;
runtime.debug.observe(event=>{if(event.type==='system'&&awaitingReader&&event.system===awaitingReader.system){awaitingReader.tick=event.tick;awaitingReader.frame=event.frame;awaitingReader=null;}});
const read=(system,input)=>{const observed={kind:'FailureRead',iteration,system,count:captures[system],messages:structuredClone(input.all()),lag:input.lagged(),tick:null,frame:null};events.push(observed);awaitingReader=observed;};
const reserved=(label,id,payload)=>events.push({kind:'Reserved',step:mode,worldName:schema.toLowerCase(),label,handle:entity(id),components:{main:mainView(payload),aux:null,flag:null}});
const writes=(system,views)=>events.push({kind:'OwnWrites',step:mode,system,views});
const Seed=G.System('Seed',{},({commands})=>{captures.Seed++;for(let j=0;j<count;j++){const entries=[[Main,main(j)]];if(j%3===0)entries.push([Aux,aux()]);if(j%3===1)entries.push([Flag,{group:8}]);ids.push(commands.spawn(G.Command.spawn(...entries)));}});
const A=G.System('A',{queries:{write:Write},resources:{ledger:G.System.writeResource(Ledger)},events:{out:G.System.writeEvent(Ping)},services:{audit:G.System.service(Audit)}},({queries,resources,events:io,commands,services,lookup})=>{
 captures.A++;const found=queries.write.get(ids[0]);if(!found.ok)throw Error('actual A access failed');const target=found.value,old=target.data.main.get();target.data.main.set(replace(old,cells(old)[0]+1));
 const l=resources.ledger.get();resources.ledger.set({totals:[l.totals[0]+1,...l.totals.slice(1)],epoch:l.epoch});
 const views=[ownMain(target),ownLedger(resources.ledger)];io.out.emit({code:2*iteration});const payload=main(iteration,[20,30,40]);p=commands.spawn(G.Command.spawn([Main,payload]));
 const own=lookup.getHandle(G.Entity.handle(p),Q);views.push(ownLookup(own));services.audit.log({who:'A',iteration,capture:captures.A});reserved('p',p,payload);writes('A',views);
});
const B=G.System('B',{queries:{write:Write},resources:{ledger:G.System.writeResource(Ledger)},events:{input:G.System.readEvent(Ping),out:G.System.writeEvent(Ping)},services:{audit:G.System.service(Audit)}},({queries,resources,events:io,commands,services,lookup})=>{
 captures.B++;read('B',io.input);if(mode==='prime')return;
 const found=queries.write.get(ids[1]);if(!found.ok)throw Error('actual B access failed');const target=found.value,old=target.data.main.get(),x=cells(old)[0];
 target.data.main.set(replace(old,x+10));const views=[ownMain(target)];target.data.main.set(replace(old,x+30));views.push(ownMain(target));
 const l=resources.ledger.get();resources.ledger.set({totals:[l.totals[0]+100,...l.totals.slice(1)],epoch:l.epoch});views.push(ownLedger(resources.ledger));
 const payload=main(iteration,[200,300,400]),id=commands.spawn(G.Command.spawn([Main,payload]));if(mode==='fail')q=id;else r=id;
 views.push(ownLookup(lookup.getHandle(G.Entity.handle(id),Q)));io.out.emit({code:2*iteration+1});services.audit.log({who:'B',iteration,capture:captures.B});reserved(mode==='fail'?'q':'r',id,payload);writes('B',views);
 if(mode==='fail')return Fx.fail({code:7});
});
const Publications=G.System('PublicationObserver',{events:{input:G.System.readEvent(Ping)}},({events:io})=>{captures.PublicationObserver++;read('PublicationObserver',io.input);});
const Observe=G.System('Observe',{queries:{q:Q},resources:{ledger:G.System.readResource(Ledger)}},({queries,resources,lookup})=>{
 captures.Observe++;const rows=queries.q.each().map(row);const handles=[p,q,r].filter(Boolean).concat([...failed].reverse());
 const lookups=handles.map(id=>({label:'',handle:entity(id),result:access(lookup.getHandle(G.Entity.handle(id),Q))}));
 events.push({kind:'FailureObserved',schema,iteration,phase,rows,ledger:ledgerView(resources.ledger.get()),lookups});
});
const Dispose=G.System('DisposeTransient',{},({commands})=>{captures.DisposeTransient++;commands.despawn(p);commands.despawn(r);});
const tick=(label,...steps)=>{const value=runtime.tick(G.Schedule(...steps));const outcome=value.ok?{kind:'Complete'}:value.error.kind==='SystemFailure'?{kind:'SystemFailure',system:value.error.system,code:value.error.error.code}:{kind:'SetupRejected',reason:JSON.stringify(value.error)};events.push({kind:'FailureResult',label,outcome});return value;};
tick('seed',Seed,G.Schedule.applyDeferred());tick('prime',B,Publications);
const start=performance.now();
for(iteration=0;iteration<iterations;iteration++){
 r=null;mode='fail';tick('fail',A,B);failed.push(q);phase='failed-before-barrier';tick(phase,Observe);tick('failed-publications',Publications);
 mode='retry';tick('retry',B);phase='retry-before-barrier';tick(phase,Observe);tick('retry-publications',Publications);
 tick('apply',G.Schedule.applyDeferred());phase='applied-FIFO';tick(phase,Observe);tick('dispose',Dispose,G.Schedule.applyDeferred());phase='disposed';tick(phase,Observe);
}
const tuple=encode(schema,events,effects),checksum=fold(tuple);
console.log('FAILURE-FOLD:'+checksum);
const elapsed=performance.now()-start;
console.log('FAILURE-TIMING:'+elapsed);
console.log('FAILURE-TUPLE:'+JSON.stringify(tuple));
console.log('FAILURE-CAPTURE:'+JSON.stringify(captures));
