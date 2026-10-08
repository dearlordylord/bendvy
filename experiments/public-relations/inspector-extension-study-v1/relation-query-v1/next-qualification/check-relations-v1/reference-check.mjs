import {Descriptor as D,Schema,Entity} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
// Full independently authored observations; expectations are never imported.
const modes=['optional-both','required-out','required-in','required-both','with-out','without-out','with-in','without-in'];
const schemas=[];
for(const [schema,base] of [['Workshop',0],['Garden',100]]){
 const Stock=D.Component()(schema+'/Stock'),Title=D.Component()(schema+'/Title'),Owned=D.Resource()(schema+'/Owned');
 const {relation:Link}=D.Relation(schema+'/Link',schema+'/LinkedBy');
 const G=Schema.bind(Schema.fragment({components:{Stock,Title},resources:{Owned},relations:{Link}}),Schema.defineRoot(schema));
 const runtime=G.Runtime.make({resources:{Owned:[[base+31],[base+32]]}}),foreign=G.Runtime.make({resources:{Owned:[[base+1031],[base+1032]]}});
 const ids=[],alienIds=[];
 const tick=(rt,...steps)=>{const r=rt.tick(G.Schedule(...steps));if(!r.ok)throw Error(JSON.stringify(r));};
 const seed=(rt,store,offset)=>tick(rt,G.System(schema+'/Seed'+offset,{},({commands})=>{
   for(let i=1;i<=4;i++){const components=[];if(i!==3)components.push([Stock,[offset+10+i]]);if(i!==1)components.push([Title,[offset+20+i]]);store.push(commands.spawn(G.Command.spawn(...components)));}
   store.push(commands.spawn(G.Command.spawn()));
 }),G.Schedule.applyDeferred(),G.System(schema+'/Stale'+offset,{},({commands})=>{commands.despawn(store[4]);}),G.Schedule.applyDeferred());
 seed(runtime,ids,base);seed(foreign,alienIds,base+1000);
 const definitions=[],queries={};
 for(const [stockRequired,titleRequired] of [[false,false],[true,false],[false,true],[true,true]])for(const mode of modes){
   const selection={stock:(stockRequired?G.Query.read:G.Query.optional)(Stock),title:(titleRequired?G.Query.read:G.Query.optional)(Title)},options={selection};
   if(['optional-both','required-both','required-out'].includes(mode))selection.out=(mode==='optional-both'?G.Query.optionalRelation:G.Query.readRelation)(Link);
   if(['optional-both','required-both','required-in'].includes(mode))selection.in=(mode==='optional-both'?G.Query.optionalRelated:G.Query.readRelated)(Link);
   if(mode==='with-out')options.withRelations=[Link];if(mode==='without-out')options.withoutRelations=[Link];
   if(mode==='with-in')options.withRelated=[Link];if(mode==='without-in')options.withoutRelated=[Link];
   const key='q'+definitions.length;definitions.push({key,stockRequired,titleRequired,mode});queries[key]=G.Query(options);
 }
 const encodeRow=(r,d)=>({entity:r.entity.id.value,stock:d.stockRequired||r.data.stock.present?r.data.stock.get()[0]:null,title:d.titleRequired||r.data.title.present?String(r.data.title.get()[0]):null,cells:[
   ...(['optional-both','required-both','required-out'].includes(d.mode)?[{key:'out',end:'outgoing',value:d.mode!=='optional-both'||r.data.out.present?{target:r.data.out.get().value}:null}]:[]),
   ...(['optional-both','required-both','required-in'].includes(d.mode)?[{key:'in',end:'incoming',value:d.mode!=='optional-both'||r.data.in.present?{sources:r.data.in.get().map(x=>x.value)}:null}]:[])
 ]});
 const error=r=>({error:r.error._tag,...(r.error._tag==='MultipleEntities'?{count:r.error.count}:{})});
 const owners=(ctx)=>({stock:ctx.queries.q0.each().filter(r=>r.data.stock.present).map(r=>r.data.stock.get()[0]),title:ctx.queries.q0.each().filter(r=>r.data.title.present).map(r=>String(r.data.title.get()[0])),resources:ctx.resources.owned.get().map(a=>[...a])});
 const phases=[];let currentLabel='initial',retained,collect=true,allow=true,bodyMarkers=0;const gateChecks=[];
 const check=G.Condition.check(schema+'/Relations',{queries,resources:{owned:G.System.readResource(Owned)}},ctx=>{
   const ownersBefore=owners(ctx);const observations=definitions.map(d=>{
     const q=ctx.queries[d.key],each=q.each().map(r=>encodeRow(r,d));
     const get=[...ids.slice(0,4),Entity.makeEntityId(0),ids[4],alienIds[0]].map((id,i)=>{const r=q.get(id);return {entity:id.value,...(i===6?{foreign:true}:{}),...(r.ok?{row:encodeRow(r.value,d)}:error(r))};});
     const one=q.single(),maybe=q.singleOptional();return {stockRequired:d.stockRequired,titleRequired:d.titleRequired,mode:d.mode,each,get,single:one.ok?{row:encodeRow(one.value,d)}:error(one),singleOptional:maybe.ok?{row:maybe.value===undefined?null:encodeRow(maybe.value,d)}:error(maybe)};
   });
   if(currentLabel==='initial')retained=ctx.queries.q0.get(ids[1]).value.data.in.get();
   const result={phase:currentLabel,queries:observations,ownersBefore,ownersAfter:owners(ctx)};if(collect)phases.push(result);else gateChecks.push(result);return allow;
 });
 tick(runtime,G.System(schema+'/Initial',{},({commands})=>{commands.relate(ids[0],Link,ids[1]);commands.relate(ids[2],Link,ids[1]);commands.relate(ids[1],Link,ids[3]);}),G.Schedule.applyDeferred());
 tick(runtime,G.Schedule.when([check],G.System(schema+'/Observe'+currentLabel,{},()=>{})));currentLabel='queued';tick(runtime,G.System(schema+'/Change',{},({commands})=>{commands.relate(ids[0],Link,ids[3]);commands.unrelate(ids[2],Link);}));tick(runtime,G.Schedule.when([check],G.System(schema+'/Observe'+currentLabel,{},()=>{})));
 currentLabel='barrier';tick(runtime,G.Schedule.applyDeferred());tick(runtime,G.Schedule.when([check],G.System(schema+'/Observe'+currentLabel,{},()=>{})));
 collect=false;const gateBody=G.System(schema+'/GatedBody',{},()=>{bodyMarkers++;});tick(runtime,G.Schedule.when([check],gateBody));allow=false;tick(runtime,G.Schedule.when([check],gateBody));
 const last=phases[2].queries[0].each;
 schemas.push({schema,phases,bodyMarkers,gateChecks,retainedInitialInverse:retained.map(x=>x.value),currentInverse2:last.find(r=>r.entity===2).cells.find(c=>c.key==='in').value?.sources??[],currentInverse4:last.find(r=>r.entity===4).cells.find(c=>c.key==='in').value?.sources??[]});
}
console.log(JSON.stringify({schemas,scope:'finite TS relation actual Check counterpart; foreign raw-ID aliasing is recorded separately'}));
