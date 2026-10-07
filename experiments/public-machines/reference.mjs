import assert from 'node:assert/strict';
import {Descriptor as D, Schema, Fx} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';

export function run(schemaName='A') {
 const Cells=D.Component()('Cells'),Owned=D.Resource()('Owned');
 const G=Schema.bind(Schema.fragment({components:{Cells},resources:{Owned}}));
 const Flow=G.StateMachine('Flow',['Boot','Play','Pause']);
 const Level=G.StateMachine('Level',[0,1,2]);
 const rt=G.Runtime.make({services:G.Runtime.services(),resources:{Owned:[30,130]},machines:G.Runtime.machines(G.Runtime.machine(Level,0),G.Runtime.machine(Flow,'Boot')),debug:true});
 const output=[],attempts=[],deliveries=[],conditions=[],hooks=[];
 const marker=()=>G.Schedule.applyStateTransitions();
 function snapshot(label,result={ok:true}) {
  output.push({label,result:result.ok?{ok:true}:{ok:false,error:result.error},world:structuredClone(rt.debug.dump()),streams:structuredClone(rt.debug.streams()),attempts:[...attempts],deliveries:structuredClone(deliveries),conditions:[...conditions],hooks:[...hooks]});
 }
 const seed=G.System('seed',{},({commands})=>commands.spawn(G.Command.spawn([Cells,[10,99]]))&&undefined);
 assert.equal(rt.tick(G.Schedule(seed,G.Schedule.applyDeferred())).ok,true);
 snapshot('initial');
 const queue=(name,f)=>G.System(name,{machines:{flow:G.System.machine(Flow),level:G.System.machine(Level)},nextMachines:{flow:G.System.nextState(Flow),alias:G.System.nextState(Flow),level:G.System.nextState(Level)}},f);
 const writer=queue('overwrite',({machines,nextMachines,commands})=>{nextMachines.level.set(1);nextMachines.flow.set('Play');nextMachines.alias.set('Pause');attempts.push(['overwrite',machines.flow.get(),nextMachines.flow.getPending()]);commands.spawn(G.Command.spawn());});
 snapshot('queued',rt.tick(G.Schedule(writer)));
 snapshot('deferred-only',rt.tick(G.Schedule(G.Schedule.applyDeferred())));
 snapshot('committed',rt.tick(G.Schedule(marker())));
 const read=(name,fail=false)=>G.System(name,{transitionEvents:{flow:G.System.readTransitionEvent(Flow),level:G.System.readTransitionEvent(Level)}},({transitionEvents})=>{deliveries.push({name,flow:structuredClone(transitionEvents.flow.all()),level:structuredClone(transitionEvents.level.all()),lagged:[transitionEvents.flow.lagged(),transitionEvents.level.lagged()]});return fail?Fx.fail('reader-failed'):undefined;});
 let readerFails=true;
 const fast=read('fast'),slow=read('slow');
 const retry=G.System('retry-reader',{transitionEvents:{flow:G.System.readTransitionEvent(Flow),level:G.System.readTransitionEvent(Level)}},({transitionEvents})=>{deliveries.push({name:'retry-reader',flow:structuredClone(transitionEvents.flow.all()),level:structuredClone(transitionEvents.level.all()),lagged:[transitionEvents.flow.lagged(),transitionEvents.level.lagged()]});return readerFails?Fx.fail('reader-failed'):undefined;});
 snapshot('readers-register',rt.tick(G.Schedule(fast,slow)));
 const gate=(name,c)=>G.System(name,{when:[c]},()=>{conditions.push(name);});
 const gates=[gate('inPause',G.Condition.inState(Flow,'Pause')),gate('changed',G.Condition.stateChanged(Flow)),gate('notBoot',G.Condition.not(G.Condition.inState(Flow,'Boot'))),gate('and',G.Condition.and(G.Condition.inState(Flow,'Pause'),G.Condition.not(G.Condition.inState(Level,0)))),gate('or',G.Condition.or(G.Condition.inState(Flow,'Boot'),G.Condition.inState(Level,1))),gate('emptyAnd',G.Condition.and()),gate('emptyOr',G.Condition.or())];
 const same=queue('same-set',({nextMachines})=>nextMachines.flow.set('Pause'));
 snapshot('same-set-and-conditions',rt.tick(G.Schedule(same,marker(),...gates,fast)));
 const sameSkip=queue('same-skip',({nextMachines})=>nextMachines.flow.setIfChanged('Pause'));
 snapshot('same-skip-and-conditions',rt.tick(G.Schedule(sameSkip,marker(),...gates,fast)));
 const skipOverwrite=queue('skip-overwrite',({nextMachines})=>{nextMachines.flow.setIfChanged('Pause');nextMachines.flow.set('Pause');});
 snapshot('overwrite-skip-flag',rt.tick(G.Schedule(skipOverwrite,marker(),fast)));
 const reset=queue('reset',({nextMachines})=>{nextMachines.flow.set('Play');nextMachines.flow.reset();attempts.push(['reset',nextMachines.flow.getPending()??null]);});
 snapshot('reset',rt.tick(G.Schedule(reset,marker(),fast)));
 const beforeFailure=queue('old-pending',({nextMachines})=>nextMachines.flow.set('Boot'));
 snapshot('old-pending',rt.tick(G.Schedule(beforeFailure)));
 const writable=G.Query({selection:{cells:G.Query.write(Cells)}});
 const failed=G.System('failed-publisher',{queries:{all:writable},resources:{owned:G.System.writeResource(Owned)},nextMachines:{flow:G.System.nextState(Flow),level:G.System.nextState(Level)}},({queries,resources,nextMachines,commands})=>{for(const {data} of queries.all.each())data.cells.set([88,188]);resources.owned.set([77,177]);nextMachines.flow.set('Play');nextMachines.level.set(2);commands.spawn(G.Command.spawn());attempts.push(['failed-publisher']);return Fx.fail('publish-failed');});
 snapshot('publisher-failed',rt.tick(G.Schedule(failed,marker())));
 snapshot('failure-retry-marker',rt.tick(G.Schedule(marker(),fast)));
 snapshot('reader-failed',rt.tick(G.Schedule(retry)));
 snapshot('reader-failed-repeat',rt.tick(G.Schedule(retry)));
 snapshot('slow-backlog',rt.tick(G.Schedule(slow)));
 const skipped=G.Schedule.when([G.Condition.inState(Flow,'Play')],slow);
 const play=queue('play',({nextMachines})=>nextMachines.flow.set('Play'));
 snapshot('skip-reader',rt.tick(G.Schedule(queue('pause',({nextMachines})=>nextMachines.flow.set('Pause')),marker(),skipped)));
 snapshot('skip-reader-no-backlog',rt.tick(G.Schedule(play,marker(),slow)));
 const levelHook=queue('level-hook',({nextMachines})=>{hooks.push('Level');nextMachines.flow.set('Boot');});
 const flowHook=queue('flow-hook',({nextMachines})=>{hooks.push('Flow');nextMachines.flow.set('Boot');nextMachines.level.set(2);});
 const bundle=G.Schedule.transitions(G.Schedule.onEnter(Flow,'Pause',[flowHook]),G.Schedule.onEnter(Level,1,[levelHook]));
 const both=queue('definition-order',({nextMachines})=>{nextMachines.level.set(1);nextMachines.flow.set('Pause');});
 snapshot('marker-generated-and-definition-order',rt.tick(G.Schedule(both,G.Schedule.applyStateTransitions(bundle))));
 snapshot('next-marker',rt.tick(G.Schedule(marker(),fast,slow)));
 snapshot('empty-frame',rt.tick(G.Schedule()));
 snapshot('empty-frame-2',rt.tick(G.Schedule()));
 snapshot('retained-failed-reader',rt.tick(G.Schedule(retry)));
 readerFails=false;snapshot('failed-reader-retry-success',rt.tick(G.Schedule(retry)));
 snapshot('reader-repeat-empty',rt.tick(G.Schedule(retry)));
 return {schema:schemaName,observations:output};
}

export function rawBoundaries() {
 const G=Schema.bind(Schema.fragment({}));const Flow=G.StateMachine('RawFlow',['Boot','Play']);
 const read=G.System('raw-read',{machines:{flow:G.System.machine(Flow)}},({machines})=>{seen.push(machines.flow.get());});
 const seen=[];const missing=G.Runtime.make({services:G.Runtime.services(),debug:true});
 const missingResult=missing.tryTick(G.Schedule(read));
 const invalid=G.Runtime.make({services:G.Runtime.services(),machines:G.Runtime.machines(G.Runtime.machine(Flow,'INVALID')),debug:true});
 const invalidResult=invalid.tick(G.Schedule(read));
 const invalidInitial=structuredClone(invalid.debug.dump());
 const invalidWriter=G.System('invalid-writer',{nextMachines:{flow:G.System.nextState(Flow)}},({nextMachines})=>nextMachines.flow.set('UNKNOWN'));
 const invalidWriteResult=invalid.tick(G.Schedule(invalidWriter,G.Schedule.applyStateTransitions()));
 const overwrite=G.Runtime.make({services:G.Runtime.services(),machines:G.Runtime.machines(G.Runtime.machine(Flow,'Boot'),G.Runtime.machine(Flow,'Play')),debug:true});
 let duplicate;try{G.StateMachine('RawFlow',['Boot']);}catch(error){duplicate=error.message;}
 return {missing:{result:missingResult,world:missing.debug.dump()},invalid:{result:invalidResult,world:invalidInitial,seen},invalidWrite:{result:invalidWriteResult,world:invalid.debug.dump()},duplicateInitial:overwrite.debug.dump(),duplicateDefinition:duplicate};
}

if(import.meta.url===new URL(process.argv[1],'file://').href)console.log(JSON.stringify({applications:[run('A'),run('B')],raw:rawBoundaries()}));
