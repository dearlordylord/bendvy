import assert from 'node:assert/strict';
import {Descriptor as D,Schema} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const Cells=D.Component()('Cells'),Resource=D.Resource()('Resource'),Host=D.Service()('Host'),Event=D.Event()('Event');
const G=Schema.bind(Schema.fragment({components:{Cells},resources:{Resource},services:{Host},events:{Event}}));
const output=[];
function scenario(mode){
 let cw=0,rw=0,host=0,conditions=0,queue=0,component=[10,99],resource=[20,120],events=[],trace=[];
 const supplied={};if(mode!=='service-missing'&&mode!=='condition-missing'&&mode!=='both-missing')supplied.Host=mode==='service-malformed'?null:()=>{host++;};
 const rt=G.Runtime.make({resources:(mode==='resource-missing'||mode==='both-missing')?{}:{Resource:resource},services:supplied});
 const q=G.Query({selection:{cells:G.Query.write(Cells)}});
 const seed=G.System('seed',{},({commands})=>{commands.spawn(G.Command.spawn([Cells,component]));});
 assert.equal(rt.tick(G.Schedule(seed,G.Schedule.applyDeferred())).ok,true);
 const spec={queries:{all:q},resources:{r:G.System.writeResource(Resource)},services:{host:G.System.service(Host)},events:{event:G.System.writeEvent(Event)}};
 const make=(name,id)=>G.System(name,spec,({queries,resources,services,events:bus,commands})=>{
  for(const {data} of queries.all.each()){data.cells.set([id,99]);component=[id,99];cw++;}
  resources.r.set([id,120]);resource=[id,120];rw++;
  services.host();bus.event.emit(id);events.push(id);commands.spawn(G.Command.spawn());queue++;trace.push(id);
 });
 const yes=G.Condition.check('yes',{},()=>{conditions++;return true;});
 const A=make('A',1),B=make('B',2);
 const phase=name=>G.System('phase-'+name,{},()=>{});
 const no=G.Condition.check('no',{services:{host:G.System.service(Host)}},()=>{conditions++;return false;});
 let plan;
 if(mode==='duplicate'){
  assert.throws(()=>G.Schedule(A,G.Schedule(G.Schedule(),A)),/Duplicate system step/);
  output.push({mode,status:'invalid',cw,rw,host,conditions,events,queue,trace,component,resource});return;
 }
 if(mode==='condition-missing')plan=G.Schedule(phase('before'),G.Schedule(G.Schedule(),G.Schedule.when([no],B)));
 else if(mode==='empty')plan=G.Schedule(G.Schedule(),G.Schedule(phase('empty'),G.Schedule()));
 else plan=G.Schedule(phase('before'),G.Schedule(G.Schedule(G.Schedule.when([yes],A),G.Schedule()),G.Schedule(phase('inner'),G.Schedule.when([yes],B))));
 const cellsInspector=G.Inspector('cells-snapshot',{queries:{all:G.Query({selection:{cells:G.Query.read(Cells)}})}},({queries})=>queries.all.each().map(({data})=>structuredClone(data.cells.get())));
 const resourceInspector=G.Inspector('resource-snapshot',{resources:{r:G.System.readResource(Resource)}},({resources})=>structuredClone(resources.r.get()));
 const flattened=plan.steps.map(step=>step.name??step.kind);
 const requirements=plan.requirements.map(r=>`${r.kind}:${r.name}`);
 let result;
 try{result=rt.tryTick(plan);}catch(error){result={threw:error.constructor.name,message:error.message};}
 const actualCells=rt.inspect(cellsInspector)[0];
 const actualResource=(mode==='resource-missing'||mode==='both-missing')?null:rt.inspect(resourceInspector);
 const record={mode,status:result.ok===true?'ok':result.ok===false?'missing':'body-threw',requirements,flattened,cw,rw,host,conditions,events,queue,trace,component:actualCells,resource:actualResource};
 if(result.ok===false)record.missing=result.error.requirements;
 if(result.threw)record.exception=result.threw;
 output.push(record);
}
for(const mode of ['positive','resource-missing','service-missing','duplicate','condition-missing','empty','both-missing','service-malformed'])scenario(mode);
assert.deepEqual(output[0].requirements,['service:Host','resource:Resource']);
assert.deepEqual(output[0].flattened,['phase-before','A','phase-inner','B']);
assert.equal(output[0].cw,2);assert.equal(output[0].rw,2);assert.equal(output[0].host,2);assert.deepEqual(output[0].events,[1,2]);
for(const mode of ['resource-missing','service-missing','condition-missing','both-missing']){const v=output.find(x=>x.mode===mode);assert.equal(v.status,'missing');assert.equal(v.cw+v.rw+v.host+v.conditions+v.queue+v.events.length,0);assert.deepEqual(v.component,[10,99]);}
assert.equal(output.at(-1).status,'body-threw');assert.equal(output.at(-1).cw,1);assert.equal(output.at(-1).rw,1);assert.equal(output.at(-1).host,0);
console.log(JSON.stringify(output));
