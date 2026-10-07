import { Descriptor as D, Schema, Inspector } from '../../../../.references/bevy-ts/packages/core/src/index.ts';
// System is a public package subpath (exports './*'), not a root namespace.
import * as System from '../../../../.references/bevy-ts/packages/core/src/System.ts';

// Actual constructors and requirement fields only. Projection callbacks are
// deliberately never evaluated; availability checking is not this API.
const observations=[];
for(const schema of ['Workshop','Garden']){
 const Stock=D.Component()(schema+'/Stock');
 const Score=D.Resource()(schema+'/Score'),Bonus=D.Resource()(schema+'/Bonus');
 const SharedLeft=D.Resource()(schema+'/Shared'),SharedRight=D.Resource()(schema+'/Shared');
 const keyIds=new Map();
 for(const [key,id] of [[Score.key,1],[Bonus.key,2],[SharedLeft.key,3],[SharedRight.key,4]])if(!keyIds.has(key))keyIds.set(key,id);
 const G=Schema.bind(Schema.fragment({components:{Stock},resources:{Score,Bonus}}));
 const required=G.Query({selection:{stock:G.Query.read(Stock)}});
 const optional=G.Query({selection:{stock:G.Query.optional(Stock)}});
 for(const label of ['empty','query-only','resource-absent','resource-present','aliases','same-name-interned-aliases']){
  let calls=0;
  const read=()=>{calls++;return 'not-evaluated';};
  const name=schema+'/Metadata/'+label;
  let definition;
  if(label==='same-name-interned-aliases'){
   // No schema registration, validation or runtime operation for these two
   // descriptors: kind/name interning makes both the SAME key/token3.
   definition=Inspector.make(name,{schema:G.schema,resources:{left:System.readResource(SharedLeft),right:System.readResource(SharedRight)}},read);
  }else{
   const access=label==='query-only'?{queries:{required,optional}}:
    label==='resource-absent'||label==='resource-present'?{resources:{score:G.System.readResource(Score)}}:
    label==='aliases'?{resources:{bonus:G.System.readResource(Bonus),bonusAlias:G.System.readResource(Bonus),score:G.System.readResource(Score)}}:{};
   definition=G.Inspector(name,access,read);
  }
  let runtime;
  if(label==='resource-absent')runtime=G.Runtime.make({resources:{}});
  if(label==='resource-present')runtime=G.Runtime.make({resources:{Score:{cells:[21,22,23,24]}}});
  for(const pass of ['first','repeat']){
   observations.push({schema,case:label,read:pass,kind:definition.kind,name:definition.name,systemName:definition.system.name,
    requirements:definition.requirements.map(req=>({kind:req.kind,id:keyIds.get(req.key),name:req.name})),
    readCallbackIsSupplied:definition.read===read,requirementsAreSystemRequirements:definition.requirements===definition.system.requirements,
    callbackCalls:calls,runtimeSetup:runtime===undefined?'not-created':label==='resource-absent'?'absent':'present',factory:label==='same-name-interned-aliases'?'low-level-metadata-only':'bound'});
  }
 }
}
console.log(JSON.stringify({format:1,application:'InspectorDefinitionMetadata',observations}));
