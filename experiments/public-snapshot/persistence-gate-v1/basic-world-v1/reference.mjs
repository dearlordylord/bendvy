import {Schema,Descriptor,Decode,Result} from "/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts";
// Actual constructed descriptor provider. Validation uses pinned Decode;
// retaining the supplied array is an explicit trusted constructor choice.
const codec=Decode.array(Decode.integer);
const provider={result(raw){const r=codec.decode(raw);return r.ok?Result.success(raw):r;},decode:codec.decode};
const basic=s=>({version:s.version,nextEntity:s.nextEntity,entities:s.entities,resources:s.resources});
const detached=s=>JSON.parse(JSON.stringify(basic(s)));
const output={};
for(const name of ["Workshop","Garden"]){
 const Payload=Descriptor.ConstructedComponent(provider)("Payload");
 const Scratch=Descriptor.TransientComponent()("Scratch");
 const Settings=Descriptor.ConstructedResource(provider)("Settings");
 const Cache=Descriptor.TransientResource()("Cache");
 const G=Schema.bind(Schema.fragment({components:{Payload,Scratch},resources:{Settings,Cache}}),Schema.defineRoot(name));
 const made=G.Runtime.make({resources:{Settings:[27,29],Cache:[127,129]}});
 if(!made.ok)throw Error(JSON.stringify(made));
 const runtime=made.value;
 const tick=(...steps)=>{const r=runtime.tick(G.Schedule(...steps));if(!r.ok)throw Error(JSON.stringify(r));};
 const ids=[];
 tick(G.System("seed",{},({commands})=>{ids.push(commands.spawn(G.Command.spawn([Payload,[7,9]],[Scratch,[107,109]])));ids.push(commands.spawn(G.Command.spawn([Payload,[17,19]],[Scratch,[117,119]])));ids.push(commands.spawn(G.Command.spawn()));}),G.Schedule.applyDeferred());
 tick(G.System("remove-third",{},({commands})=>{commands.despawn(ids[2]);}),G.Schedule.applyDeferred());
 const first=runtime.snapshot(),firstAtSave=detached(first);
 const second=runtime.snapshot(),secondAtSave=detached(second);
 const query=G.Query({selection:{payload:G.Query.write(Payload)}});
 tick(G.System("mutate",{queries:{query},resources:{settings:G.System.writeResource(Settings)}},({queries,resources})=>{for(const row of queries.query.each()){if(row.entity.id.value===1){const values=row.data.payload.get();values[0]=11;values[1]=13;}}const values=resources.settings.get();values[0]=31;values[1]=33;}));
 const after=runtime.snapshot();
 output[name]={firstAtSave,secondAtSave,after:detached(after),retainedAliasFirst:detached(first),retainedAliasSecond:detached(second)};
}
process.stdout.write(JSON.stringify(output)+"\n");
