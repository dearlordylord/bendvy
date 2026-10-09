import assert from 'node:assert/strict';
import {Schema,Descriptor,Entity,Fx} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const observations=[];
const expectedFailures=[{operation:'relate',relation:'Parent',source:1,target:1,error:{_tag:'SelfRelationNotAllowed',entityId:1,relation:'Parent'}},{operation:'relate',relation:'Parent',source:1,target:99,error:{_tag:'MissingTargetEntity',entityId:1,targetId:99,relation:'Parent'}}];
for(const root of ['ReadersAlpha','ReadersBeta']) {
 const {relation:Parent}=Descriptor.Hierarchy('Parent','Children');
 const {relation:ParentB}=Descriptor.Hierarchy('ParentB','ChildrenB');
 const Left=Descriptor.Component()('Left'),Right=Descriptor.Component()('Right'),Baseline=Descriptor.Resource()('Baseline'),Ordinary=Descriptor.Event()('Ordinary');
 const G=Schema.bind(Schema.fragment({components:{Left,Right},resources:{Baseline},events:{Ordinary},relations:{Parent,ParentB}}),Schema.defineRoot(root));
 const runtime=G.Runtime.make({debug:true,resources:{Baseline:[301,302]}});let id,label,fail=false;
 const deliveries=[];
 // TS has no affine Array/private-owner API: this explicit adapter retains
 // actual array identity across failure and recovery, separately from ECS data.
 const privateOwners={fast:[101,102],slow:[201,202]};const mailbox=[];
 const encode=f=>({operation:f.operation,relation:f.relation.name,source:f.source.value,target:f.target.value,error:f.error});
 const reader=name=>G.System(name,{relationFailures:{p:G.System.readRelationFailures(Parent)},events:{ordinary:G.System.writeEvent(Ordinary)}},({relationFailures,events})=>{
  deliveries.push({label,who:name,lagged:relationFailures.p.lagged(),failures:relationFailures.p.all().map(encode)});
  if(name==='slow'&&fail){events.ordinary.emit(999);mailbox.push(privateOwners.slow);return Fx.fail(77);}
 });
 const fast=reader('fast'),slow=reader('slow');
 const tick=(...steps)=>assert.equal(runtime.tick(G.Schedule(...steps)).ok,true);
 const capture=()=>observations.push({root,label,world:structuredClone(runtime.debug.dump()),streams:structuredClone(runtime.debug.streams()),deliveries:structuredClone(deliveries),privateOwners:structuredClone(privateOwners),mailbox:structuredClone(mailbox)});
 const flush=G.Schedule.applyDeferred();
 tick(G.System('seed',{},({commands})=>{id=commands.spawn(G.Command.spawn([Left,[11,12]],[Right,[21,22]]));}),flush);
 label='register';tick(fast,slow);capture();
 tick(G.System('queue',{},({commands})=>{commands.relate(id,Parent,id);commands.relate(id,Parent,Entity.makeEntityId(99));commands.relate(id,ParentB,id);}));
 label='before-barrier';tick(fast,slow);capture();
 label='published';tick(flush,fast);capture();
 label='failure';fail=true;assert.equal(runtime.tick(G.Schedule(slow)).ok,false);capture();
 label='retry';fail=false;const returned=mailbox.pop();assert.equal(returned,privateOwners.slow);privateOwners.slow=returned;tick(slow);capture();
 label='fast-empty';tick(fast);capture();
 label='aged';tick();tick();capture();
 assert.deepEqual(deliveries,[
  {label:'register',who:'fast',lagged:false,failures:[]},{label:'register',who:'slow',lagged:false,failures:[]},
  {label:'before-barrier',who:'fast',lagged:false,failures:[]},{label:'before-barrier',who:'slow',lagged:false,failures:[]},
  {label:'published',who:'fast',lagged:false,failures:expectedFailures},{label:'failure',who:'slow',lagged:false,failures:expectedFailures},
  {label:'retry',who:'slow',lagged:false,failures:expectedFailures},{label:'fast-empty',who:'fast',lagged:false,failures:[]}
 ]);
 assert.equal(runtime.debug.streams().find(s=>s.stream==='Parent').size,0);
 assert.ok(observations.filter(x=>x.root===root).every(x=>x.streams.filter(s=>s.stream==='Ordinary').every(s=>s.size===0))); 
 assert.equal(runtime.debug.streams().find(s=>s.stream==='ParentB').size,0);
}
export const result = {developmentOnly:true,observations};
