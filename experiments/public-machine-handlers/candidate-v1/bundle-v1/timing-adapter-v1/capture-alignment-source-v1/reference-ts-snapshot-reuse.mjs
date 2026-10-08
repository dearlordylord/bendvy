// Source-only same-owner timing adapter; no timing execution or acceptance yet.
import {pathToFileURL} from 'node:url';
import ledger from '../operations.json' with {type:'json'};
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
export function application(schema,current='Boot',extra=true,failure=null){
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
 function project(snapshot){
  const world=snapshot.world;
  const ownedEntity=world.entities.filter(entity=>Object.hasOwn(entity.components,'Cells'));if(ownedEntity.length!==1)throw new Error('component owner count');
  const state=world.machines.Flow;
  return {component:clone(ownedEntity[0].components.Cells),resource:clone(world.resources.Owned),extraPresent:Object.hasOwn(world.resources,'Extra'),extraPayload:clone(world.resources.Extra??null),current:state.current,previous:state.previous??null,locals:clone(snapshot.hostLocal),attempts:clone(snapshot.attempts),prefix:clone(snapshot.prefix),pendingStructural:world.pendingCommands.length,structuralApplied:world.entities.filter(entity=>Object.hasOwn(entity.components,'Structural')).length,deliveries:clone(snapshot.deliveries),requirements:clone(requirements),missing:clone(missing),outcome,pending:state.pending??null};
 }
 const record=(label,result)=>{
  const snapshot={label,result:clone(result),world:clone(runtime.debug.dump()),streams:clone(runtime.debug.streams()),hostLocal:clone(locals),attempts:clone(attempts),prefix:clone(prefix),deliveries:clone(deliveries)};
  history.push(snapshot);return {raw:clone(snapshot),common:project(snapshot)};
 };
 const results={seed:seeded};
 function queue(value,skip=false){
  const command=G.System('queue',{nextMachines:{flow:G.System.nextState(Flow)}},ctx=>{skip?ctx.nextMachines.flow.setIfChanged(value):ctx.nextMachines.flow.set(value);});
  const result=runtime.tick(G.Schedule(command));if(!result.ok)throw new Error('queue failed');results.queue=result;
 }
 function marker(){
  last=runtime.tryTick(G.Schedule(G.Schedule.applyStateTransitions(bundle)));
  if(last.ok){outcome='ok';missing=[];}else if(last.error.kind==='MissingRuntimeRequirements'){outcome='requirements';missing=last.error.requirements.map(value=>names[value.name]);}else{
   const error=last.error;
   if(error.kind!=='SystemFailure'||!defs.some(def=>def.name===error.system)||typeof error.error!=='string'||error.error!=='failed:'+error.system)throw new Error('unexpected actual system failure payload');
   outcome=error.error;missing=[];
  }
  results.marker=last;
 }
 function read(){const result=runtime.tick(G.Schedule(reader));if(!result.ok)throw new Error('reader failed');results.read=result;}
 function observe(snapshot){
  const world=clone(snapshot.world),stream=clone(snapshot.streams);
  const ownedEntity=world.entities.filter(entity=>Object.hasOwn(entity.components,'Cells'));if(ownedEntity.length!==1)throw new Error('component owner count');
  const state=world.machines.Flow;
  const common={component:ownedEntity[0].components.Cells,resource:world.resources.Owned,extraPresent:Object.hasOwn(world.resources,'Extra'),extraPayload:world.resources.Extra??null,current:state.current,previous:state.previous??null,locals:clone(locals),attempts:clone(attempts),prefix:clone(prefix),pendingStructural:world.pendingCommands.length,structuralApplied:world.entities.filter(entity=>Object.hasOwn(entity.components,'Structural')).length,deliveries:clone(deliveries),requirements:clone(requirements),missing:clone(missing),outcome,pending:state.pending??null};
  return {common,raw:{world,streams:stream,result:clone(last),history:clone(history)}};
 }
 return {schema,queue,marker,read,observe,capture:label=>record(label,results[label])};
}
export function run(schema,clock=()=>0n){
 const rows={},samples=[],captures=[];
 const measure=(kind,action)=>{const start=clock();const result=action();const end=clock();samples.push({kind,nanoseconds:(end-start).toString()});return result;};
 for(const descriptor of ledger.scenarios){
  const failure=descriptor.failureId===0?null:defs[descriptor.failureId-1].name;
  const app=measure('setup',()=>application(schema,descriptor.current,descriptor.extra,failure));
  const seed=app.capture('seed');
  const records=[{kind:'setup',checkpoint:null,...seed}];
  for(const step of descriptor.steps){
   measure('steady:'+step.kind,()=>step.kind==='queue'?app.queue(step.value,step.skip):app[step.kind]());
   const captured=app.capture(step.kind);
   records.push({kind:step.kind,checkpoint:step.checkpoint??null,...captured});
   if(step.checkpoint!==undefined){if(Object.hasOwn(rows,step.checkpoint))throw new Error('duplicate checkpoint');rows[step.checkpoint]=app.observe(captured.raw);}
  }
  captures.push({scenario:descriptor.scenario,captures:records});
 }
 return {rows,samples,captures};
}
export function complete(clock){return {status:'UNQUALIFIED_ALIGNED_CAPTURE_SOURCE_NO_CLOCK' ,schemas:{A:run('A',clock),B:run('B',clock)}};}
if(import.meta.url===pathToFileURL(process.argv[1]).href)console.log(JSON.stringify(complete()));
