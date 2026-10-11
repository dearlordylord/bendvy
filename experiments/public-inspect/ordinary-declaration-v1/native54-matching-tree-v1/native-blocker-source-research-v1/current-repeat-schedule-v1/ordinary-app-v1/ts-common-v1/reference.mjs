import {Descriptor as D, Schema} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';

function scenario(label) {
  const Position=D.Component()('Position');
  const Unqueried=D.Component()('Unqueried');
  const Counter=D.Resource()('Counter');
  const G=Schema.bind(Schema.fragment({components:{Position,Unqueried},resources:{Counter}}));
  const position=[42], counter=[10];
  const rt=G.Runtime.make({resources:{Counter:counter},debug:true});
  const query=G.Query({selection:{first:G.Query.read(Position),second:G.Query.read(Position)}});
  const reads=context=>[...context.queries.position.each()].map(({entity,data})=>{const first=data.first.get(),second=data.second.get();return {entity:entity.id.value,first,second,samePosition:first===position && second===position};});
  const operational=[];
  const component=G.System('SharedSystem',{queries:{position:query}},context=>{
    operational.push(reads(context));
  });
  const resourceNotRun=G.System('SharedSystem',{resources:{counter:G.System.writeResource(Counter)}},()=>{});
  const inspect=G.Inspector('HostRead',{queries:{position:query},resources:{counter:G.System.readResource(Counter)}},context=>{const counterValue=context.resources.counter.get();return {rows:reads(context),counter:counterValue,sameCounter:counterValue===counter};});
  const schedule=G.Schedule(component);
  rt.debug.nameSchedules({InspectApp:schedule,ResourceNotRun:G.Schedule(resourceNotRun)});
  const setup=G.System('Setup',{},({commands})=>{
    commands.spawn(G.Command.spawn([Position,position]));
    commands.spawn(G.Command.spawn());
  });
  const setupStatus=rt.tick(G.Schedule(setup,G.Schedule.applyDeferred()));
  const observations=[];
  const snapshot=name=>{
    const projection=rt.inspect(inspect);
    observations.push({label:name,projection,dump:rt.debug.dump(),population:rt.debug.population(),description:rt.debug.describe(),streams:rt.debug.streams()});
  };
  snapshot('before1');snapshot('before2');
  const first=rt.tick(schedule);
  snapshot('afterFirst');snapshot('between');
  const second=rt.tick(schedule);
  snapshot('afterSecond1');snapshot('afterSecond2');
  return {schema:label,setupStatus,first,second,operational,observations,position,counter};
}
console.log(JSON.stringify([scenario('A'),scenario('Other')]));
