import {Schema,Descriptor,Decode} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const clone=value=>JSON.parse(JSON.stringify(value,(_key,value)=>value===undefined?{undefined:true}:value));
const result=r=>r.ok?{ok:true}:{ok:false,error:clone(r.error)};
function run(root){
 const Name=Descriptor.ConstructedComponent(Decode.string)('Name');
 const Scratch=Descriptor.TransientComponent()('Scratch');
 const Score=Descriptor.ConstructedResource(Decode.integer)('Score');
 const Spare=Descriptor.ConstructedResource(Decode.integer)('Spare');
 const Cache=Descriptor.TransientResource()('Cache');
 const Ping=Descriptor.Event()('Ping');
 const G=Schema.bind(Schema.fragment({components:{Name,Scratch},resources:{Score,Spare,Cache},events:{Ping}}),Schema.defineRoot(root));
 const made=G.Runtime.make({resources:{Score:5,Spare:7,Cache:9},debug:true});
 if(!made.ok)throw Error('fixture construction failed');
 const runtime=made.value,watch=[],slow=[],ids=[];
 const names=G.Query({selection:{name:G.Query.read(Name)}});
 const added=G.Query({selection:{name:G.Query.read(Name)},filters:[G.Query.added(Name)]});
 const Watch=G.System('watch',{queries:{added},despawned:{gone:G.System.readDespawned()},events:{ping:G.System.readEvent(Ping)}},({queries,despawned,events})=>{
  watch.push({added:queries.added.each().map(row=>[row.entity.id.value,row.data.name.get()]),despawned:despawned.gone.all().map(id=>id.value),events:events.ping.all()});
 });
 const Slow=G.System('slow',{events:{ping:G.System.readEvent(Ping)}},({events})=>{slow.push(events.ping.all());});
 const tick=(...steps)=>{const r=runtime.tick(G.Schedule(...steps));if(!r.ok)throw Error('fixture tick failed');};
 const state=()=>clone({snapshot:runtime.snapshot(),dump:runtime.debug.dump(),streams:runtime.debug.streams(),watch,slow});
 tick(Watch,Slow);
 tick(G.System('seed',{},({commands})=>{ids.push(commands.spawn(G.Command.spawn([Name,'a'],[Scratch,101])));ids.push(commands.spawn(G.Command.spawn([Name,'b'])));}),G.Schedule.applyDeferred());
 tick(G.System('queue',{events:{ping:G.System.writeEvent(Ping)},resources:{score:G.System.writeResource(Score)}},({commands,events,resources})=>{
  for(let n=0;n<4;n++)ids.push(commands.spawn(G.Command.spawn([Name,'pending'+n])));
  events.ping.emit(17);resources.score.set(11);
 }));
 const initial=state();
 const good={version:1,nextEntity:2,entities:[{id:1,components:{Name:'restored'}}],relations:{},resources:{Score:42},machines:{}};
 const tests=[
  ['null',null],['missing-version',{}],['version-before-next',{...good,version:2,nextEntity:0}],
  ['next-before-name',{...good,nextEntity:0,entities:[{id:1,components:{Missing:1}}]}],
  ['entities-shape',{...good,entities:{}}],['entity-id',{...good,entities:[{id:0,components:{}}]}],
  ['components-shape',{...good,entities:[{id:1,components:null}]}],
  ['relations-required',{...good,relations:undefined}],['relation-path',{...good,relations:{R:[[0,[1]]]}}],
  ['resources-shape',{...good,resources:null}],['machines-required',{...good,machines:undefined}],
  ['machine-path',{...good,machines:{M:null}}],
  ['duplicate-before-second-name',{...good,entities:[{id:1,components:{Name:'x'}},{id:1,components:{Missing:1}}]}],
  ['first-name-before-later-duplicate',{...good,entities:[{id:1,components:{Missing:1}},{id:1,components:{}}]}],
  ['name-before-value',{...good,entities:[{id:1,components:{Missing:1,Name:12}}]}],
  ['value-before-later-name',{...good,entities:[{id:1,components:{Name:12,Missing:1}}]}],
  ['transient-component',{...good,entities:[{id:1,components:{Scratch:1}}]}],
  ['unknown-resource',{...good,resources:{Missing:1}}],['transient-resource',{...good,resources:{Cache:1}}],
  ['late-invalid-resource',{...good,resources:{Score:'bad'}}],
 ];
 const failures=tests.map(([label,input])=>({label,result:result(runtime.restore(input)),state:state()}));
 tick(Watch); // rejection left its cursor and unread event intact; slow stays behind.
 const afterFailureRead=state();
 const restored=result(runtime.restore(good)),afterRestore=state();
 const handles=ids.map(id=>G.Entity.handle(id,Name));let stale=[];
 tick(Watch,Slow,G.System('lookup',{queries:{names}},({lookup})=>{
  stale=handles.map(handle=>{const r=lookup.getHandle(handle,names);return r.ok?{ok:true,id:handle.value,name:r.value.data.name.get()}:{ok:false,error:clone(r.error)};});
 }));
 const afterReaders=state();let allocated;
 tick(G.System('later',{},({commands})=>{allocated=commands.spawn(G.Command.spawn([Name,'later'])).value;}),G.Schedule.applyDeferred());
 const afterAllocate=state();
 return {root,initial,failures,afterFailureRead,restored,afterRestore,stale,afterReaders,allocated,afterAllocate};
}
process.stdout.write(JSON.stringify(['Workshop','Garden'].map(run))+'\n');
