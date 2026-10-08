import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {Descriptor, Schema, Fx} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';

const input=JSON.parse(readFileSync(new URL('./inputs.json',import.meta.url)));
function run(root) {
  const Position=Descriptor.Component()('Simulation/Position');
  const Velocity=Descriptor.Component()('Simulation/Velocity');
  const Health=Descriptor.Component()('Simulation/Health');
  const Step=Descriptor.Resource()('Simulation/Step');
  const Hit=Descriptor.Event()('Simulation/Hit');
  const Death=Descriptor.Event()('Simulation/Death');
  const Game=Schema.bind(Schema.fragment({components:{Position,Velocity,Health},resources:{Step},events:{Hit,Death}}));
  const runtime=Game.Runtime.make({resources:{Step:0},debug:true});
  const moving=Game.Query({selection:{position:Game.Query.write(Position),velocity:Game.Query.read(Velocity)}});
  const vulnerable=Game.Query({selection:{position:Game.Query.read(Position),health:Game.Query.write(Health)}});
  const Spawn=Game.System('Simulation/Spawn',{},({commands})=>{
    for (let index=0;index<input.health.length;index++)
      commands.spawn(Game.Command.spawn([Position,0],[Velocity,1+((input.seed+index)%2)],[Health,input.health[index]]));
  });
  const Move=Game.System('Simulation/Move',{queries:{moving},resources:{step:Game.System.writeResource(Step)}},({queries,resources})=>{
    resources.step.update(value=>value+1);
    for(const {data} of queries.moving.each()) data.position.update(value=>value+data.velocity.get()*input.fixedStep);
  });
  const Damage=Game.System('Simulation/Damage',{queries:{vulnerable},events:{hit:Game.System.writeEvent(Hit),death:Game.System.writeEvent(Death)}},({queries,events,commands})=>{
    for(const {entity,data} of queries.vulnerable.each()) {
      if(data.position.get()<input.goal) continue;
      const health=data.health.get()-input.damage;
      data.health.set(health);
      events.hit.emit({entity:entity.id.value,damage:input.damage});
      if(health===0) {events.death.emit({entity:entity.id.value});commands.despawn(entity.id);}
    }
  });
  const readers={a:[],b:[]};
  let failNextB=false;
  const reader=key=>Game.System('Simulation/Reader'+key.toUpperCase(),{events:{hit:Game.System.readEvent(Hit),death:Game.System.readEvent(Death)}},({events})=>{
    readers[key].push({hits:events.hit.all(),deaths:events.death.all()});
    if(key==='b'&&failNextB) {failNextB=false;return Fx.fail('RetryReaderB');}
  });
  const A=reader('a'),B=reader('b');
  const phases=[];
  function checkpoint(label,schedule) {
    const result=runtime.tick(schedule);
    phases.push({label,result,dump:runtime.debug.dump(),readers:structuredClone(readers)});
  }
  checkpoint('register-readers',Game.Schedule(A,B));
  checkpoint('queue-spawn',Game.Schedule(Spawn));
  checkpoint('spawn-barrier',Game.Schedule(Game.Schedule.applyDeferred()));
  checkpoint('step-1-damage',Game.Schedule(Move,Damage));
  checkpoint('step-1-readers',Game.Schedule(A,B));
  checkpoint('step-1-barrier',Game.Schedule(Game.Schedule.applyDeferred()));
  checkpoint('step-2-damage',Game.Schedule(Move,Damage));
  failNextB=true;
  checkpoint('step-2-reader-failure',Game.Schedule(A,B));
  checkpoint('step-2-reader-retry',Game.Schedule(B));
  checkpoint('step-2-barrier',Game.Schedule(Game.Schedule.applyDeferred()));
  checkpoint('step-3-damage',Game.Schedule(Move,Damage));
  checkpoint('step-3-readers',Game.Schedule(A,B));
  checkpoint('step-3-barrier',Game.Schedule(Game.Schedule.applyDeferred()));
  checkpoint('empty-readers',Game.Schedule(A,B));
  return {root,phases};
}
const output=['Workshop','Garden'].map(run);
console.log(JSON.stringify(output));
assert.deepEqual(JSON.parse(JSON.stringify(output)),JSON.parse(readFileSync(new URL('./expected.json',import.meta.url))));
