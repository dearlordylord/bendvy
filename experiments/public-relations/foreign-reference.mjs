import {Schema,Descriptor as D} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
for(const root of ['Workshop','Other']){
 const Payload=D.Component()('Payload');const {relation:Link}=D.Relation('Link','LinkedBy');const G=Schema.bind(Schema.fragment({components:{Payload},relations:{Link}}),Schema.defineRoot(root));const runtimes=[G.Runtime.make({}),G.Runtime.make({})];const ids=[[],[]];const output=[];
 const q=G.Query({selection:{payload:G.Query.read(Payload)}});
 const tick=(rt,...steps)=>{const r=rt.tick(G.Schedule(...steps));if(!r.ok)throw Error(JSON.stringify(r));};
 for(let world=0;world<2;world++)tick(runtimes[world],G.System('seed'+world,{},({commands})=>{for(let i=1;i<=2;i++)ids[world].push(commands.spawn(G.Command.spawn([Payload,{cells:[world*10+i,world*10+i+100]}])));}),G.Schedule.applyDeferred());
 const snapshot=(world,phase)=>G.System('observe'+phase+world,{queries:{q},relationFailures:{r:G.System.readRelationFailures(Link)}},({queries,lookup,relationFailures})=>{output.push({world,phase,rows:queries.q.each().map(({entity,data})=>({id:entity.id.value,cells:[...data.payload.get().cells],target:lookup.related(entity.id,Link),sources:lookup.relatedSources(entity.id,Link)})),failures:relationFailures.r.all().map(f=>({source:f.source.value,target:f.target.value,error:f.error}))});});
 tick(runtimes[0],snapshot(0,'before'));tick(runtimes[1],snapshot(1,'before'));
 tick(runtimes[1],G.System('foreign-source',{},({commands})=>commands.relate(ids[0][0],Link,ids[1][1])),snapshot(1,'queued'),G.Schedule.applyDeferred(),snapshot(1,'applied'));
 tick(runtimes[0],snapshot(0,'after'));
 console.log(JSON.stringify({root,observations:output}));
}
