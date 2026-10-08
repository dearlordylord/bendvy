import assert from 'node:assert/strict';
import { Descriptor, Schema, Fx } from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
import { readFileSync } from 'node:fs';
const Counter = Descriptor.Resource()('Trace/Counter');
const Tag = Descriptor.Component()('Trace/Tag');
const Game = Schema.bind(Schema.fragment({resources:{Counter}, components:{Tag}}));
const runtime = Game.Runtime.make({resources:{Counter:9}, debug:true});
const Spawn = Game.System('Trace/Spawn', {}, ({commands}) => {commands.spawn(Game.Command.spawn([Tag,true]));});
const Increment = Game.System('Trace/Increment', {resources:{counter:Game.System.writeResource(Counter)}}, ({resources}) => {resources.counter.update(x=>x+1);});
const Fail = Game.System('Trace/Fail', {resources:{counter:Game.System.writeResource(Counter)}}, ({resources,commands}) => {
 resources.counter.set(99); commands.spawn(Game.Command.spawn([Tag,false])); return Fx.fail('ExpectedFailure');
});
const never = Game.Condition.check('never', {}, () => false);
const Skipped = Game.System('Trace/Skipped', {when:[never]}, () => {throw 'SkippedBodyMustNotRun';});
const Defect = Game.System('Trace/Defect', {resources:{counter:Game.System.writeResource(Counter)}}, ({resources,commands}) => {resources.counter.set(77);commands.spawn(Game.Command.spawn([Tag,false]));throw 'ExpectedDefect';});
const skipped = Game.Schedule(Skipped);
const defect = Game.Schedule(Defect);
const success = Game.Schedule(Spawn, Increment, Game.Schedule.applyDeferred());
const failure = Game.Schedule(Fail);
runtime.debug.nameSchedules({success,failure,skipped,defect});
const events=[];
const stop=runtime.debug.observe(event=>{
 const value=structuredClone(event);
 if ('ms' in value) {assert.equal(typeof value.ms,'number');assert.ok(Number.isFinite(value.ms)&&value.ms>=0);value.ms=0;}
 events.push(value);
});
const phases=[];
for (const [label,schedule] of [['success',success],['failure',failure],['skipped',skipped],['defect',defect],['recovery',success]]) {
 let result;
 try {result=runtime.tick(schedule);} catch (error) {result={thrown:error};}
 phases.push({label,result,events:structuredClone(events),dump:runtime.debug.dump()});
}
stop();
console.log(JSON.stringify(phases));
assert.deepEqual(JSON.parse(JSON.stringify(phases)),JSON.parse(readFileSync(new URL('./expected.json',import.meta.url))));
