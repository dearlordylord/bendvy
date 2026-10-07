import assert from 'node:assert/strict';
import {Descriptor as D,Schema} from '../../../.references/bevy-ts/packages/core/src/index.ts';

// Actual public operations; no numeric entity fabrication or held cell escape.
// The independent full oracle is authored separately from this adapter.
let output='';
for(const schema of ['Workshop','Garden']){
 const Stock=D.Component()(schema+'/Stock'),Score=D.Resource()(schema+'/Score');
 const G=Schema.bind(Schema.fragment({components:{Stock},resources:{Score}}));
 const runtime=G.Runtime.make({resources:{Score:{cells:[21,21,21,24]}}});
 const required=G.Query({selection:{stock:G.Query.read(Stock)}});
 const optional=G.Query({selection:{stock:G.Query.optional(Stock)}});
 const added=G.Query({selection:{stock:G.Query.read(Stock)},filters:[G.Query.added(Stock)]});
 const changed=G.Query({selection:{stock:G.Query.read(Stock)},filters:[G.Query.changed(Stock)]});
 let target;
 const cells=value=>JSON.stringify([...value]).replaceAll(',',', ');
 const row=match=>`${match.entity.id.value}:${'present' in match.data.stock&&!match.data.stock.present?'absent':cells(match.data.stock.get().cells)}`;
 const result=value=>!value.ok?(value.error._tag==='MultipleEntities'?`MultipleEntities:${value.error.count}`:value.error._tag==='NoEntities'?'NoEntities':`${value.error._tag}:${value.error.entityId}`):value.value===undefined?'None':`Found:${row(value.value)}`;
 const inspector=G.Inspector(schema+'/Cardinality',{queries:{required,optional,added,changed},resources:{score:G.System.readResource(Score)}},({queries,resources})=>Object.entries(queries).map(([name,q])=>`${name}|each=[${q.each().map(row).join(', ')}]|get=${result(q.get(target))}|single=${result(q.single())}|optional=${result(q.singleOptional())}`).join('\n')+`\nscore=${cells(resources.score.get().cells)}\n`);
 const inspect=phase=>{output+=phase+'\n'+runtime.inspect(inspector);};
 const tick=schedule=>assert.equal(runtime.tick(schedule).ok,true);
 const barrier=()=>tick(G.Schedule(G.Schedule.applyDeferred()));
 const reserve=G.System(schema+'/Reserve',{},({commands})=>{target=commands.spawn(G.Command.spawn());});
 output+=schema+'\n';tick(G.Schedule(reserve));inspect('reserved');barrier();inspect('absent');
 const insert=G.System(schema+'/Insert',{},({commands})=>{commands.insert(target,[Stock,{cells:[11,11,11,14]}]);});
 tick(G.Schedule(insert));barrier();inspect('one');inspect('one-repeat');
 const second=G.System(schema+'/Second',{},({commands})=>{commands.spawn(G.Command.spawn([Stock,{cells:[31,31,31,34]}]));});
 tick(G.Schedule(second));barrier();inspect('many');inspect('many-repeat');
}
console.log(JSON.stringify(output));
