import assert from 'node:assert/strict';
import {Descriptor as D,Schema} from '../../../.references/bevy-ts/packages/core/src/index.ts';

// This observes real per-system Condition evaluation and requirement refusal.
// Host recording counters are diagnostic captures, not an affine Bend contract.
const observations=[];
for(const schema of ['Workshop','Garden'])for(const present of [false,true]){
 const Stock=D.Component()(schema+'/CheckStock'),Score=D.Resource()(schema+'/CheckScore');
 const G=Schema.bind(Schema.fragment({components:{Stock},resources:{Score}}));
 const runtime=G.Runtime.make({resources:present?{Score:{cells:[21,21,21,24]}}:{}});
 const plain=G.Query({selection:{stock:G.Query.read(Stock)}});
 let callbacks=[],ran=0;
 const check=G.Condition.check(schema+'/PlainCheck',{queries:{plain},resources:{score:G.System.readResource(Score)}},({queries,resources})=>{
  callbacks.push({rows:queries.plain.each().map(({entity,data})=>({id:entity.id.value,cells:[...data.stock.get().cells]})),score:[...resources.score.get().cells]});
  return true;
 });
 const first=G.System(schema+'/First',{},()=>{ran++;}),second=G.System(schema+'/Second',{},()=>{ran++;});
 const observe=(label,prefix=[])=>{
  callbacks=[];
  const result=runtime.tryTick(G.Schedule(...prefix,G.Schedule.when([check],first,second)));
  observations.push({schema,present,label,result:result.ok?{ok:true}:{ok:false,error:{kind:result.error.kind,requirements:result.error.requirements}},callbacks,ran});
 };
 observe('empty');
 const seed=G.System(schema+'/Seed',{},({commands})=>{commands.spawn(G.Command.spawn([Stock,{cells:[11,11,11,14]}]));});
 assert.equal(runtime.tick(G.Schedule(seed,G.Schedule.applyDeferred())).ok,true);
 observe('one');
 const update=G.System(schema+'/Update',{resources:{score:G.System.writeResource(Score)}},({resources})=>{resources.score.set({cells:[31,31,31,34]});});
 observe('committed-before-check',[update]);
}
console.log(JSON.stringify({format:1,application:'InspectorPlainCheck',observations}));
