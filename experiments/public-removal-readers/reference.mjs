import {Descriptor as D,Schema,Fx} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const A=D.Component()('A'),B=D.Component()('B');
const W=Schema.bind(Schema.fragment({components:{A,B}}));
const rt=W.Runtime.make({services:W.Runtime.services()}),ids=[];
const tick=(...items)=>rt.tick(W.Schedule(...items));
const ensure=(r)=>{if(!r.ok)throw Error(JSON.stringify(r));};
const spawn=W.System('spawn',{},({commands})=>{ids.push(commands.spawn(W.Command.spawn([A,{owned:[11]}],[B,{owned:[21]}])));ids.push(commands.spawn(W.Command.spawn([A,{owned:[12]}],[B,{owned:[22]}])));});
ensure(tick(spawn,W.Schedule.applyDeferred()));
let failed=false,log='';
const spec={removed:{a:W.System.readRemoved(A),b:W.System.readRemoved(B)},despawned:{d:W.System.readDespawned()}};
const read=({removed,despawned})=>{if(failed){log+='[FAIL]';return Fx.fail('Rejected');}const txt=removed.a.all().map(x=>'A'+x.value+';').join('')+removed.b.all().map(x=>'B'+x.value+';').join('')+despawned.d.all().map(x=>'D'+x.value+';').join('');log+='['+txt+']';};
const fast=W.System('fast',spec,read),slow=W.System('slow',spec,read);
// Register slow without adding a fixture observation.
ensure(tick(slow));log='';
const remove=W.System('remove',{},({commands})=>{commands.remove(ids[0],A);});
const despawn=W.System('despawn',{},({commands})=>{commands.despawn(ids[1]);commands.despawn(ids[1]);});
const failedRemove=W.System('failed-remove',{},({commands})=>{commands.remove(ids[0],A);return Fx.fail('Rejected');});
ensure(tick(fast));if(tick(failedRemove).ok)throw Error("initial failure not reached");ensure(tick(W.Schedule.applyDeferred()));ensure(tick(fast));ensure(tick(remove));ensure(tick(fast));ensure(tick(W.Schedule.applyDeferred()));ensure(tick(fast));ensure(tick(fast));
// Slow reader is genuinely omitted from these schedules and retains its position.
ensure(tick(despawn));ensure(tick(fast));ensure(tick(W.Schedule.applyDeferred()));failed=true;if(tick(fast).ok)throw Error('failure not reached');failed=false;ensure(tick(fast));ensure(tick(slow));ensure(tick(slow));ensure(tick(remove,W.Schedule.applyDeferred()));ensure(tick(fast));if(tick(failedRemove).ok)throw Error('command failure not reached');ensure(tick(W.Schedule.applyDeferred()));ensure(tick(fast));
console.log(log);
const q=W.Query({selection:{a:W.Query.optional(A),b:W.Query.optional(B)}});let values;
const observe=W.System('observe',{queries:{q}},({queries})=>{const rows=queries.q.each();values='A='+ids.map(id=>{const r=rows.find(x=>x.entity.id.value===id.value);return r?.data.a.present?r.data.a.get().owned[0]:'-';}).join(',')+';B='+ids.map(id=>{const r=rows.find(x=>x.entity.id.value===id.value);return r?.data.b.present?r.data.b.get().owned[0]:'-';}).join(',');});ensure(tick(observe));console.log(values);
