// Source-only actual pinned bevy-ts comparator; no executable results yet.
import {pathToFileURL} from 'node:url';
import {Descriptor as D,Schema,Fx} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const clone=value=>JSON.parse(JSON.stringify(value));
const defs=[
 {name:'enterPlay1',phase:'enter',to:'Play',delta:1000},
 {name:'exitBoot0',phase:'exit',from:'Boot',delta:1},
 {name:'transitionBootPause',phase:'transition',from:'Boot',to:'Pause',delta:20},
 {name:'enterPlay0',phase:'enter',to:'Play',delta:100},
 {name:'exitBoot1',phase:'exit',from:'Boot',delta:10},
 {name:'transitionBootPlay',phase:'transition',from:'Boot',to:'Play',delta:30},
 {name:'enterPause',phase:'enter',to:'Pause',delta:200},
 {name:'inactiveExitPause',phase:'exit',from:'Pause',delta:10000},
];
function application(schema,current='Boot',extra=true,failure=null){
 const Cells=D.Component()('Cells'),Structural=D.Component()('Structural'),Owned=D.Resource()('Owned'),Extra=D.Resource()('Extra');
 const G=Schema.bind(Schema.fragment({components:{Cells,Structural},resources:{Owned,Extra}}));
 const Flow=G.StateMachine('Flow',['Boot','Play','Pause']);
 const runtime=G.Runtime.make({services:G.Runtime.services(),resources:{Owned:[0,19],...(extra?{Extra:[5,29]}:{})},machines:G.Runtime.machines(G.Runtime.machine(Flow,current)),debug:true});
 const locals=Array(8).fill(0),attempts=[],prefix=[],deliveries=[],history=[];
 const cells=G.Query({selection:{cells:G.Query.write(Cells)}});
 const reader=G.System('reader',{transitionEvents:{flow:G.System.readTransitionEvent(Flow)}},ctx=>{deliveries.push(...clone(ctx.transitionEvents.flow.all()));});
 const hooks=defs.map((def,id)=>G.System(def.name,{
  queries:{cells},resources:{owned:G.System.writeResource(Owned),...(id===7?{extra:G.System.readResource(Extra)}:{})},
  machines:{flow:G.System.machine(Flow)},transitions:{active:G.System.transition(Flow)},
  ...(id===0?{nextMachines:{flow:G.System.nextState(Flow)}}:{}),
 },ctx=>{
  locals[id]++;attempts.push(def.name);
  for(const {data} of ctx.queries.cells.each()){const [a,b]=data.cells.get();data.cells.set([a+def.delta,b]);}
  ctx.resources.owned.update(([a,b])=>[a+def.delta,b]);
  ctx.commands.spawn(G.Command.spawn([Structural,[id+1,def.delta]]));
  if(def.name===failure&&locals[id]===1)return Fx.fail('failed:'+def.name);
  if(id===0)ctx.nextMachines.flow.set('Pause');
  prefix.push(def.name);
 }));
 const schedules=defs.map((def,id)=>def.phase==='exit'?G.Schedule.onExit(Flow,def.from,[hooks[id]]):def.phase==='enter'?G.Schedule.onEnter(Flow,def.to,[hooks[id]]):G.Schedule.onTransition(Flow,[def.from,def.to],[hooks[id]]));
 const bundle=G.Schedule.transitions(schedules[0],G.Schedule.transitions(schedules[1],schedules[2],schedules[3]),schedules[4],schedules[5],schedules[6],schedules[7]);
 const names={Owned:'owned',Flow:'machine',Extra:'extra'};
 const requirements=bundle.requirements.map(value=>names[value.name]);
 if(JSON.stringify(requirements)!==JSON.stringify(['owned','machine','extra']))throw new Error('actual nested requirement order mismatch');
 const seed=G.System('seed',{},({commands})=>{commands.spawn(G.Command.spawn([Cells,[0,7]]));});
 const seeded=runtime.tick(G.Schedule(seed,G.Schedule.applyDeferred(),reader));if(!seeded.ok)throw new Error('seed failed');
 let last={ok:true},outcome='idle',missing=[];
 const record=(label,result)=>history.push({label,result:clone(result),world:clone(runtime.debug.dump()),streams:clone(runtime.debug.streams()),hostLocal:clone(locals),attempts:clone(attempts),prefix:clone(prefix),deliveries:clone(deliveries)});
 record('seed',seeded);
 function queue(value,skip=false){
  const command=G.System('queue',{nextMachines:{flow:G.System.nextState(Flow)}},ctx=>{skip?ctx.nextMachines.flow.setIfChanged(value):ctx.nextMachines.flow.set(value);});
  const result=runtime.tick(G.Schedule(command));if(!result.ok)throw new Error('queue failed');record('queue',result);
 }
 function marker(){
  last=runtime.tryTick(G.Schedule(G.Schedule.applyStateTransitions(bundle)));
  if(last.ok){outcome='ok';missing=[];}else if(last.error.kind==='MissingRuntimeRequirements'){outcome='requirements';missing=last.error.requirements.map(value=>names[value.name]);}else{
   const error=last.error;
   if(error.kind!=='SystemFailure'||!defs.some(def=>def.name===error.system)||typeof error.error!=='string'||error.error!=='failed:'+error.system)throw new Error('unexpected actual system failure payload');
   outcome=error.error;missing=[];
  }
  record('marker',last);
 }
 function read(){const result=runtime.tick(G.Schedule(reader));if(!result.ok)throw new Error('reader failed');record('read',result);}
 function observe(){
  const world=clone(runtime.debug.dump()),stream=clone(runtime.debug.streams());
  const ownedEntity=world.entities.filter(entity=>Object.hasOwn(entity.components,'Cells'));if(ownedEntity.length!==1)throw new Error('component owner count');
  const state=world.machines.Flow;
  const common={component:ownedEntity[0].components.Cells,resource:world.resources.Owned,extraPresent:Object.hasOwn(world.resources,'Extra'),extraPayload:world.resources.Extra??null,current:state.current,previous:state.previous??null,locals:clone(locals),attempts:clone(attempts),prefix:clone(prefix),pendingStructural:world.pendingCommands.length,structuralApplied:world.entities.filter(entity=>Object.hasOwn(entity.components,'Structural')).length,deliveries:clone(deliveries),requirements:clone(requirements),missing:clone(missing),outcome,pending:state.pending??null};
  return {common,raw:{world,streams:stream,result:clone(last),history:clone(history)}};
 }
 return {schema,queue,marker,read,observe};
}
export function run(schema){
 const rows={};const point=(name,app)=>{if(Object.hasOwn(rows,name))throw new Error('duplicate checkpoint');rows[name]=app.observe();};
 for(const target of ['Play','Pause']){
  const app=application(schema);app.queue(target);point('boot_'+target+'_queued',app);app.marker();app.read();point('boot_'+target+'_applied',app);
 }
 {const app=application(schema);app.queue('Play');app.marker();app.read();app.marker();app.read();point('self_queued_next',app);}
 for(const current of ['Boot','Play'])for(const skip of [false,true]){const app=application(schema,current);app.queue(current,skip);app.marker();app.read();point('same_'+current+'_'+skip,app);}
 for(const failure of ['exitBoot0','exitBoot1','transitionBootPlay','enterPlay1','enterPlay0']){
  const app=application(schema,'Boot',true,failure);app.queue('Play');app.marker();point('failed_'+failure,app);app.marker();app.read();point('later_'+failure,app);
 }
 {const app=application(schema,'Boot',false);app.queue('Play');point('missing_queued',app);app.marker();point('inactive_missing',app);}
 return rows;
}
export const observation={status:'ACTUAL_PINNED_TS_BUNDLE_COMMON_WITH_COMPLETE_RAW',schemas:{A:run('A'),B:run('B')}};
if(import.meta.url===pathToFileURL(process.argv[1]).href)console.log(JSON.stringify(observation));
