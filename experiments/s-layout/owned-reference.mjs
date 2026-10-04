import {Descriptor,Fx,Schema} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const Payload=Descriptor.Component()('Payload');
const G=Schema.bind(Schema.fragment({components:{Payload}}));
const Read=G.Query({selection:{p:G.Query.read(Payload)}}),Write=G.Query({selection:{p:G.Query.write(Payload)}});
function setup(){const r=G.Runtime.make({services:G.Runtime.services()}),ids=[];r.tick(G.Schedule(G.System('Spawn',{},({commands})=>{for(const value of [10,20])ids.push(commands.spawn(G.Command.spawn([Payload,{items:[value,value,value,value]}])));}),G.Schedule.applyDeferred()));return{r,ids};}
function probe(schema){const {r,ids}=setup();let label='',target=0,success=true;const value=schema==='motion'?19:23;
 const read=G.System('Read',{queries:{q:Read}},({queries})=>{let x=queries.q.each().find(x=>x.entity.id.value===ids[target]?.value);console.log(label+(x?x.data.p.get().items[1]:'MissingEntity'));});
 const step=G.System('Step',{queries:{q:Write}},({queries})=>{const x=queries.q.each().find(x=>x.entity.id.value===ids[target].value);const old=x.data.p.get().items;const first=old.slice();first[1]=value-2;x.data.p.set({items:first});const items=first.slice();items[1]=value;x.data.p.set({items});console.log(label+old[1]+'->'+x.data.p.get().items[1]);if(!success)return Fx.fail(7);});
 const snapshot=name=>r.tick(G.Schedule(G.System('Snapshot',{queries:{q:Read}},({queries})=>{const rows=queries.q.each();console.log(schema+':'+name+':'+ids.map(id=>{const row=rows.find(x=>x.entity.id.value===id.value);return row?'['+row.data.p.get().items.join(',')+']':'vacant';}).join(';'));})));
 const get=(name,id)=>{label=schema+':'+name+':';target=id;r.tick(G.Schedule(read));};
 const put=(name,id,ok)=>{label=schema+':'+name+':';target=id;success=ok;r.tick(G.Schedule(step));};
 if(schema==='motion'){
  get('setup',0);put('commit-own',0,true);put('failed-own',1,false);get('earlier-commit',0);get('restored',1);snapshot('full-restored');put('retry-own',1,true);get('retry-visible',1);
  target=1;label='motion:remove:';r.tick(G.Schedule(G.System('Remove',{queries:{q:Read}},({queries,commands})=>{const x=queries.q.each().find(x=>x.entity.id.value===ids[1].value);console.log(label+'disposed:'+x.data.p.get().items[1]);commands.remove(ids[1],Payload);}),G.Schedule.applyDeferred()));get('vacant',1);snapshot('full-after-remove');get('bound',2);get('max-bound',4294967295);
 }else{put('commit-own',1,true);put('failed-own',0,false);get('restored',0);get('committed',1);}
}
probe('motion');probe('health');
