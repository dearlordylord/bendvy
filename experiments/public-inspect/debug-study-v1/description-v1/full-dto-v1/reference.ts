import {Descriptor,Schema,Result} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
import {readFileSync} from 'node:fs';
import {isDeepStrictEqual} from 'node:util';
const oracle=JSON.parse(readFileSync(new URL('./ORACLE.json',import.meta.url),'utf8')).cases;
const state=(value:string|number)=>{
 if(typeof value==='string')return {kind:'Text',value};
 const bytes=new DataView(new ArrayBuffer(8));bytes.setFloat64(0,value,true);
 return {kind:'NumberBits',low:bytes.getUint32(0,true),high:bytes.getUint32(4,true),spelling:String(value)};
};
const normalized=(raw:any)=>({...raw,machines:raw.machines.map((m:any)=>({name:m.name,states:m.states.map(state),current:m.current===undefined?{kind:'None'}:{kind:'Some',value:state(m.current)}}))});
const emit=(name:string,runtime:any)=>{
 const before=runtime.debug.describe();const observed=runtime.debug.describe();const after=runtime.debug.describe();
 const dto=normalized(observed);const beforeDTO=normalized(before);const afterDTO=normalized(after);console.log(JSON.stringify({name,beforeDTO,afterDTO,scope:'actual public runtime full Description normalized typed binary64/Maybe observations',before,observed,after,dto}));
 if(!isDeepStrictEqual(dto,oracle.find((c:any)=>c.name===name).description))throw new Error(name+': independent full Description DTO');
 if(!isDeepStrictEqual(beforeDTO,afterDTO))throw new Error(name+': lossless normalized full description noninterference');
 if(!isDeepStrictEqual(before,after))throw new Error(name+': full description noninterference');
};
{
 const G=Schema.bind(Schema.fragment({components:{},resources:{},events:{},relations:{}}));
 emit('empty',G.Runtime.make({debug:true,services:G.Runtime.services()}));
}
{
 const ctor={result:(value:number)=>Result.success(value)};
 const Plain=Descriptor.Component<number>()('Plain');const Constructed=Descriptor.ConstructedComponent(ctor)('Constructed');const Transient=Descriptor.TransientComponent<number>()('Transient');const Absent=Descriptor.Component<number>()('Absent');
 const RPlain=Descriptor.Resource<number>()('RPlain');const RMissing=Descriptor.Resource<number>()('RMissing');const RConstructed=Descriptor.ConstructedResource(ctor)('RConstructed');const RTransient=Descriptor.TransientResource<number>()('RTransient');
 const E=Descriptor.Event<number>()('E');const H=Descriptor.Hierarchy('Parent','Children');const Rel=Descriptor.Relation('Follows','Followers');
 const Clock=Descriptor.Service<{now:()=>number}>()('Clock');const HostOnly=Descriptor.Service<{}>()('HostOnly');const Missing=Descriptor.Service<{}>()('Missing');
 const G=Schema.bind(Schema.fragment({components:{Plain,Constructed,Transient,Absent},resources:{RPlain,RMissing,RConstructed,RTransient},events:{E},relations:{Parent:H.relation,Follows:Rel.relation}}));
 const Text=G.StateMachine('Text',['Boot','Run']);const Numeric=G.StateMachine('Numeric',[0,-0,1.5,9007199254740992,Infinity,-Infinity]);
 const query=G.Query({selection:{p:G.Query.read(Plain),c:G.Query.write(Constructed),t:G.Query.optional(Transient)},with:[Plain],without:[Absent],filters:[G.Query.added(Transient),G.Query.changed(Constructed)]});
 const inspect=G.System('Inspect',{queries:{q:query},resources:{rp:G.System.readResource(RPlain),rm:G.System.writeResource(RMissing)},machines:{numeric:G.System.machine(Numeric)},nextMachines:{text:G.System.nextState(Text)},removed:{absent:G.System.readRemoved(Absent)},despawned:{all:G.System.readDespawned()},relationFailures:{f:G.System.readRelationFailures(Rel.relation)},services:{clock:G.System.service(Clock),missing:G.System.service(Missing)}},()=>{});
 const runtime=G.Runtime.make({debug:true,resources:{RPlain:7},machines:G.Runtime.machines(G.Runtime.machine(Numeric,1.5)),services:G.Runtime.services(G.Runtime.service(HostOnly,{}),G.Runtime.service(Clock,{now:()=>{throw new Error('debug must not invoke service')}}))});
 runtime.debug.nameSchedules({main:G.Schedule(G.Schedule.applyDeferred(),inspect,G.Schedule.applyStateTransitions())});
 emit('allCategories',runtime);
}
