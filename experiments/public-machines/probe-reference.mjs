import assert from 'node:assert/strict';
import {Descriptor as D,Schema,Fx} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';

// Additional nine-operation development cohort. This does not replace the
// frozen complete 24-checkpoint oracle and does not qualify feature performance.
export function run(schema='A') {
 const Cells=D.Component()('Cells'),Owned=D.Resource()('Owned');
 const G=Schema.bind(Schema.fragment({components:{Cells},resources:{Owned}}));
 const Flow=G.StateMachine('Flow',['Boot','Play','Pause']),Level=G.StateMachine('Level',[0,1,2]);
 const rt=G.Runtime.make({services:G.Runtime.services(),resources:{Owned:[30,130]},machines:G.Runtime.machines(G.Runtime.machine(Level,0),G.Runtime.machine(Flow,'Boot')),debug:true});
 const observations=[],hooks=[];
 const snapshot=(label,result)=>observations.push({label,result,world:structuredClone(rt.debug.dump()),streams:structuredClone(rt.debug.streams()),hooks:[...hooks]});
 const queue=(name,body)=>G.System(name,{machines:{flow:G.System.machine(Flow)},nextMachines:{flow:G.System.nextState(Flow),alias:G.System.nextState(Flow),level:G.System.nextState(Level)}},body);
 const seed=G.System('seed',{},({commands})=>{commands.spawn(G.Command.spawn([Cells,[10,99]]));});
 snapshot('initial',rt.tick(G.Schedule(seed,G.Schedule.applyDeferred())));
 const writer=queue('machine-work',({machines,nextMachines,commands})=>{
  nextMachines.level.set(1);nextMachines.flow.set('Play');nextMachines.alias.set('Pause');
  assert.equal(machines.flow.get(),'Boot');assert.equal(nextMachines.alias.getPending(),'Pause');
  commands.spawn(G.Command.spawn());
 });
 snapshot('queued',rt.tick(G.Schedule(writer)));
 snapshot('deferred-only',rt.tick(G.Schedule(G.Schedule.applyDeferred())));
 snapshot('committed',rt.tick(G.Schedule(G.Schedule.applyStateTransitions())));
 snapshot('old-pending',rt.tick(G.Schedule(queue('old-pending',({nextMachines})=>nextMachines.flow.set('Boot')))));
 const query=G.Query({selection:{cells:G.Query.write(Cells)}});
 const failing=G.System('failed-publisher',{queries:{cells:query},resources:{owned:G.System.writeResource(Owned)},nextMachines:{flow:G.System.nextState(Flow),level:G.System.nextState(Level)}},({queries,resources,nextMachines,commands})=>{
  for(const {data} of queries.cells.each())data.cells.set([88,188]);
  resources.owned.set([77,177]);nextMachines.flow.set('Play');nextMachines.level.set(2);commands.spawn(G.Command.spawn());return Fx.fail('Boom');
 });
 snapshot('publisher-failed',rt.tick(G.Schedule(failing)));
 snapshot('marker-queued',rt.tick(G.Schedule(queue('definition-order',({nextMachines})=>{nextMachines.level.set(1);nextMachines.flow.set('Pause');}))));
 const flowHook=queue('flow-hook',({nextMachines})=>{hooks.push('Flow');nextMachines.flow.set('Boot');nextMachines.level.set(2);});
 const levelHook=queue('level-hook',({nextMachines})=>{hooks.push('Level');nextMachines.flow.set('Boot');});
 const bundle=G.Schedule.transitions(G.Schedule.onEnter(Flow,'Pause',[flowHook]),G.Schedule.onEnter(Level,1,[levelHook]));
 snapshot('marker-exception',rt.tick(G.Schedule(G.Schedule.applyStateTransitions(bundle))));
 snapshot('next-marker',rt.tick(G.Schedule(G.Schedule.applyStateTransitions())));
 return {schema,observations};
}
if(import.meta.url===new URL(process.argv[1],'file://').href)console.log(JSON.stringify({applications:[run('A'),run('B')]}));
