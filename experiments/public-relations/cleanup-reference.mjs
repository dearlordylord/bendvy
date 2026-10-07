import {Schema,Descriptor as D} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const configs=[
 {name:'ordinary',kinds:[false],edges:[[1,3,1],[1,2,1]],destroy:1},
 {name:'ordinary-source',kinds:[false],edges:[[1,3,1],[1,2,1]],destroy:3},
 {name:'hierarchy',kinds:[true],edges:[[1,3,1],[1,2,1],[1,4,2]],destroy:1},
 {name:'cycle-one',kinds:[true,true],edges:[[1,1,2],[2,2,1]],destroy:1},
 {name:'cycle-two',kinds:[true,true],edges:[[1,1,2],[2,2,1]],destroy:2},
];
for(const root of ['Workshop','Other'])for(const config of configs){
 const Payload=D.Component()('Payload');
 const relations=config.kinds.map((hierarchy,i)=>(hierarchy?D.Hierarchy('R'+(i+1),'Sources'+(i+1)):D.Relation('R'+(i+1),'Sources'+(i+1))).relation);
 const G=Schema.bind(Schema.fragment({components:{Payload},relations:Object.fromEntries(relations.map((r,i)=>['R'+(i+1),r]))}),Schema.defineRoot(root+config.name));
 const runtime=G.Runtime.make({});const ids=[];const records=[];let phase='';
 const ownerQuery=G.Query({selection:{payload:G.Query.read(Payload)}});
 const observer=G.System('observe',{queries:{owners:ownerQuery},removed:{payload:G.System.readRemoved(Payload)},despawned:{entities:G.System.readDespawned()}},({lookup,queries,removed,despawned})=>{
  const edges=[];for(let k=0;k<relations.length;k++)for(const source of ids){const value=lookup.related(source,relations[k]);if(value.ok&&value.value!==null)edges.push([k+1,source.value,value.value.value]);}
  records.push({root,case:config.name,phase,owners:queries.owners.each().map(x=>[x.entity.id.value,[...x.data.payload.get().cells]]),edges,removed:removed.payload.all().map(x=>x.value),despawned:despawned.entities.all().map(x=>x.value)});
 });
 const tick=(...steps)=>{const r=runtime.tick(G.Schedule(...steps));if(!r.ok)throw Error(JSON.stringify(r));};
 tick(observer);
 tick(G.System('spawn',{},({commands})=>{[[100,10],[200,20,21],[300,30,31,32,33],[400,40,41,42,43,44,45,46,47]].forEach(cells=>ids.push(commands.spawn(G.Command.spawn([Payload,{cells}]))));}),G.Schedule.applyDeferred());
 tick(G.System('relate',{},({commands})=>{for(const[k,s,t]of config.edges)commands.relate(ids[s-1],relations[k-1],ids[t-1]);}),G.Schedule.applyDeferred());
 phase='before';tick(observer);
 phase='queued';tick(G.System('despawn',{},({commands})=>commands.despawn(ids[config.destroy-1])),observer);
 phase='after';tick(G.Schedule.applyDeferred(),observer);
 for(const record of records.filter(x=>x.phase))console.log(JSON.stringify(record));
}
