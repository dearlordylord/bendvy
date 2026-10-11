import {Descriptor as D, Schema} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';

function scenario(label) {
  const Position=D.Component()('Position');
  const FirstResource=D.Resource()('FirstResource');
  const SecondResource=D.Resource()('SecondResource');
  const G=Schema.bind(Schema.fragment({components:{Position},resources:{FirstResource,SecondResource}}));
  const position=[42], firstResource=[17], secondResource=[18];
  const rt=G.Runtime.make({services:G.Runtime.services(),resources:{FirstResource:firstResource,SecondResource:secondResource},debug:true});
  const query=G.Query({selection:{position:G.Query.read(Position)}});
  const inspector=G.Inspector('PresentResourceRead',{queries:{position:query},resources:{first:G.System.readResource(FirstResource),second:G.System.readResource(SecondResource)}},context=>{
    const first=context.resources.first.get(),second=context.resources.second.get();
    const rows=[...context.queries.position.each()].map(({entity,data})=>{const value=data.position.get();return {entity:entity.id.value,value,samePosition:value===position};});
    return {rows,first,second,sameFirst:first===firstResource,sameSecond:second===secondResource,distinctResources:first!==second};
  });
  const setup=G.System('Setup',{},({commands})=>{commands.spawn(G.Command.spawn([Position,position]));});
  const setupSchedule=G.Schedule(setup,G.Schedule.applyDeferred());
  rt.debug.nameSchedules({Setup:setupSchedule});
  const setupStatus=rt.tick(setupSchedule);
  const observations=[];
  for(const name of ['before1','before2','after1','after2']) {
    const projection=rt.inspect(inspector);
    observations.push({label:name,projection,dump:rt.debug.dump(),population:rt.debug.population(),description:rt.debug.describe(),streams:rt.debug.streams()});
  }
  return {schema:label,setupStatus,observations,position,firstResource,secondResource};
}
console.log(JSON.stringify([scenario('A'),scenario('Other')]));
