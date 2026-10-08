import {Descriptor as D,Schema,Fx} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
// Authored consumer: expectations are external and never produced here.
const observations=[];
for(const schema of ['Workshop','Garden']){
 const Cells=D.Component()(schema+'/Cells'),Owned=D.Resource()(schema+'/Owned');
 const G=Schema.bind(Schema.fragment({components:{Cells},resources:{Owned}}));
 const Flow=G.StateMachine(schema+'/Flow',[0,1,2]),Level=G.StateMachine(schema+'/Level',[10,11,12]);
 const runtime=G.Runtime.make({resources:{Owned:[3,13]},machines:G.Runtime.machines(G.Runtime.machine(Flow,0),G.Runtime.machine(Level,10))});
 let inspectorBodies=0,scheduledBodies=0,checkBodies=0;
 const selection=G.Query({selection:{cells:G.Query.read(Cells)}});
 const reads={machines:{flow:G.System.machine(Flow),level:G.System.machine(Level)},resources:{owned:G.System.readResource(Owned)},queries:{all:selection}};
 const project=({machines,resources,queries})=>({current:[machines.flow.get(),machines.level.get()],isTarget:[machines.flow.is(1),machines.level.is(11)],owned:[...resources.owned.get()],cells:[...queries.all.single().value.data.cells.get()]});
 const inspect=G.Inspector(schema+'/Current',reads,ctx=>{inspectorBodies++;return project(ctx);});
 const observer=G.Inspector(schema+'/OutsideObserver',reads,project);
 const point=(label,ordinary=true)=>{const value=runtime.inspect(ordinary?inspect:observer);observations.push({schema,label,...value,inspectorBodies,scheduledBodies});};
 const seed=G.System(schema+'/Seed',{},({commands})=>{commands.spawn(G.Command.spawn([Cells,[7,17]]));});
 runtime.tick(G.Schedule(seed,G.Schedule.applyDeferred()));point('initial');point('repeat');
 const queue=G.System(schema+'/Queue',{nextMachines:{flow:G.System.nextState(Flow),level:G.System.nextState(Level)}},({nextMachines})=>{nextMachines.flow.set(1);nextMachines.level.set(11);});
 runtime.tick(G.Schedule(queue));point('queued');runtime.tick(G.Schedule(G.Schedule.applyDeferred()));point('structural-barrier');
 runtime.tick(G.Schedule(G.Schedule.applyStateTransitions()));point('marker');
 const body=G.System(schema+'/Body',{},()=>{scheduledBodies++;});
 const checkFalse=G.Condition.check(schema+'/False',{machines:reads.machines},({machines})=>{checkBodies++;return machines.flow.is(0)&&machines.level.is(10);});
 const checkTrue=G.Condition.check(schema+'/True',{machines:reads.machines},({machines})=>{checkBodies++;return machines.flow.is(1)&&machines.level.is(11);});
 runtime.tick(G.Schedule(G.Schedule.when([checkFalse],body)));point('check-false',false);
 runtime.tick(G.Schedule(G.Schedule.when([checkTrue],body)));point('check-true',false);
 const failed=G.System(schema+'/Failed',{nextMachines:{flow:G.System.nextState(Flow),level:G.System.nextState(Level)}},({nextMachines})=>{nextMachines.flow.set(2);nextMachines.level.set(12);return Fx.fail('failed-next');});
 runtime.tick(G.Schedule(failed));runtime.tick(G.Schedule(G.Schedule.applyStateTransitions()));point('failed-next-rollback');
 const missing=G.Runtime.make({resources:{Owned:[3,13]},machines:G.Runtime.machines(G.Runtime.machine(Flow,0))});
 checkBodies=0;scheduledBodies=0;const result=missing.tryTick(G.Schedule(G.Schedule.when([checkTrue],body)));
 observations.push({schema,label:'missing-machine-check',result:result.ok?{ok:true}:{ok:false,kind:result.error.kind,requirements:result.error.requirements},checkBodies,scheduledBodies});
}
console.log(JSON.stringify({format:1,application:'InspectorCommittedMachines',observations}));
