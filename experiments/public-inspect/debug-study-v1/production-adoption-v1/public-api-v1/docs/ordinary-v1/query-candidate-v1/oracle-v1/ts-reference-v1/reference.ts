import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {Descriptor,Schema,Decode,Fx} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const copy=(x:any)=>JSON.parse(JSON.stringify(x));
function scene(category:string) {
 const descriptor=(name:string)=>category==='plain'?Descriptor.Component<number[]>()(name):category==='transient'?Descriptor.TransientComponent<number[]>()(name):Descriptor.ConstructedComponent(Decode.array(Decode.integer))(name);
 const Position=descriptor('Position'),Velocity=descriptor('Velocity'),Health=descriptor('Health');
 const G=Schema.bind(Schema.fragment({components:{Position,Velocity,Health},resources:{},events:{},relations:{}}));
 const runtime=G.Runtime.make({debug:true,services:G.Runtime.services()});
 let fail=false;let attempts:any[]=[];
 const selection={position:G.Query.read(Position),velocity:G.Query.write(Velocity),health:G.Query.optional(Health)};
 const queries=[G.Query({selection}),G.Query({selection,filters:[G.Query.added(Position)]}),G.Query({selection,filters:[G.Query.changed(Position)]}),G.Query({selection,without:[Health]}),G.Query({selection,with:[Health]})];
 const names=['main','added','changed','withoutHealth','withHealth'];
 const systems=queries.map((query,i)=>G.System(names[i],{queries:{entities:query}},({queries})=>{
  for(const {entity,data} of queries.entities.each()) {
   const position=[...data.position.get()],velocityBefore=[...data.velocity.get()];
   attempts.push({entity:entity.id.value,position,velocityBefore,health:data.health.present?{present:true,value:[...data.health.get()]}:{present:false}});
   data.velocity.set([velocityBefore[0]+position[0],...velocityBefore.slice(1)]);
   if(fail)return Fx.fail('Failure');
  }
 }));
 const update=G.Schedule(...systems,G.Schedule.applyDeferred());
 const phases:any[]=[];
 function observe(label:string,operation:any,descriptions:any[]=[]) {
  phases.push(copy({label,operation,descriptions,dump:runtime.debug.dump(),population:runtime.debug.population(),streams:runtime.debug.streams(),frame:runtime.debug.frame()}));
 }
 const seed=G.System('seed',{},({commands})=>{
  commands.spawn(G.Command.spawn([Position,[1,101]],[Velocity,[10,201]],[Health,[100,301]]));
  commands.spawn(G.Command.spawn([Position,[2,102]],[Velocity,[20,202]]));
  commands.spawn(G.Command.spawn([Position,[3,103]],[Health,[300,303]]));
 });
 observe('seed',{result:runtime.tick(G.Schedule(seed,G.Schedule.applyDeferred())),attempts:[]});
 runtime.debug.nameSchedules({Update:update});
 observe('register',{result:runtime.tick(G.Schedule()),attempts:[]});
 function run(label:string,i:number,failure=false) {fail=failure;attempts=[];const result=runtime.tick(G.Schedule(systems[i]));observe(label,{result,attempts});}
 run('main-fail',0,true);run('main-retry',0);run('main-second',0);run('added-first',1);run('added-empty',1);
 const replace=G.System('replacePosition',{queries:{entities:G.Query({selection:{position:G.Query.write(Position)}})}},({queries})=>{for(const {entity,data} of queries.entities.each())if(entity.id.value===2)data.position.set([5,102]);});
 observe('position-e2-replace',{result:runtime.tick(G.Schedule(replace)),attempts:[]});
 run('changed-first',2);run('changed-empty',2);run('without-health',3);run('with-health',4);
 const before=copy(runtime.debug.dump());
 observe('app-enabled-descriptions',{kind:'describe'},[runtime.debug.describe(),runtime.debug.describe()]);
 assert.deepEqual(runtime.debug.dump(),before);
 const disabled=G.Runtime.make({debug:false,services:G.Runtime.services()});
 observe('app-disabled-description',{kind:'disabledRuntime',hasDebug:'debug' in disabled},[]);
 observe('foreign-registration-refusal',{kind:'notExpressible',reason:'No public nominal World/System registration refusal API'},[]);
 return {category,phases};
}
const report=['plain','transient','constructed'].map(scene);
console.log(JSON.stringify(report));
assert.deepEqual(report,JSON.parse(readFileSync(new URL('./expected.json',import.meta.url),'utf8')));
