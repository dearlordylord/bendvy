import {Descriptor,Schema} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
import {describe as staticDescribe} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/internal/debug.ts';
import {readFileSync} from 'node:fs';
import {isDeepStrictEqual} from 'node:util';
const oracle=JSON.parse(readFileSync(new URL('./ORACLE.json',import.meta.url),'utf8')).cases;
const emit=(name:string,runtime:any,override?:()=>unknown)=>{
 const before=runtime.debug.describe();const observed:any=override?.()??before;const after=runtime.debug.describe();
 const scoped={name,indexes:observed.access,lints:observed.lints};
 console.log(JSON.stringify({name,scope:override?'actual-pinned-static-describe edge fixture':'actual-public-runtime-debug-describe',scoped,before,observed,after}));
 const expected=oracle.find((x:any)=>x.name===name);if(!isDeepStrictEqual(scoped,expected))throw new Error(name+': full independent indexes/lints oracle');
 if(!isDeepStrictEqual(before,after))throw new Error(name+': description noninterference');
};
const setup=(cs:string[],rs:string[]=[],es:string[]=[])=>{
 const components=Object.fromEntries(cs.map(n=>[n,Descriptor.Component<number>()(n)]));
 const resources=Object.fromEntries(rs.map(n=>[n,Descriptor.Resource<number>()(n)]));
 const events=Object.fromEntries(es.map(n=>[n,Descriptor.Event<number>()(n)]));
 const G=Schema.bind(Schema.fragment({components,resources,events}));return {G,components,resources,events,runtime:G.Runtime.make({debug:true,services:G.Runtime.services()})};
};
{
 const {runtime}=setup(['A'],['R'],['E']);emit('emptySchedules',runtime);
}
{
 const {G,components:c,resources:r,events:e,runtime}=setup(['read','write','optional','with','without','added','changed','removed','unused'],['RR','RW'],['ER','EW']);
 const query=G.Query({selection:{read:G.Query.read(c.read),write:G.Query.write(c.write),optional:G.Query.optional(c.optional)},with:[c.with],without:[c.without],filters:[G.Query.added(c.added),G.Query.changed(c.changed)]});
 const all=G.System('All',{queries:{q:query},resources:{rr:G.System.readResource(r.RR),rw:G.System.writeResource(r.RW)},events:{er:G.System.readEvent(e.ER),ew:G.System.writeEvent(e.EW)},removed:{r:G.System.readRemoved(c.removed)}},()=>{});
 runtime.debug.nameSchedules({main:G.Schedule(all)});emit('indexCategories',runtime);
}
for(const marker of [false,true]){
 const {G,components:c,resources:r,events:e,runtime}=setup(['A','B','Unused'],['R'],['Emit','Read','Flow']);const play=G.StateMachine('Play',['Idle','Running']);
 const reader=G.System('Reader',{queries:{q:G.Query({selection:{a:G.Query.read(c.A)}})},resources:{r:G.System.readResource(r.R)},events:{read:G.System.readEvent(e.Read),flow:G.System.readEvent(e.Flow)}},()=>{});
 const writer=G.System('Writer',{queries:{q:G.Query({selection:{a:G.Query.write(c.A),b:G.Query.write(c.B)}})},resources:{r:G.System.writeResource(r.R)},events:{emit:G.System.writeEvent(e.Emit),flow:G.System.writeEvent(e.Flow)},nextMachines:{play:G.System.nextState(play)}},()=>{});
 runtime.debug.nameSchedules(marker?{main:G.Schedule(reader,G.Schedule.applyDeferred(),writer),other:G.Schedule(G.Schedule.applyStateTransitions())}:{main:G.Schedule(reader,G.Schedule.applyDeferred(),writer)});
 emit(marker?'markerAnywhere':'allFiveLintFamilies',runtime);
}
{
 const {G,components:c,runtime}=setup(['A','Absent']);const reader=G.System('Reader',{queries:{q:G.Query({selection:{},with:[c.A],without:[c.Absent]})}},()=>{});const writer=G.System('Writer',{queries:{q:G.Query({selection:{a:G.Query.write(c.A)}})}},()=>{});
 runtime.debug.nameSchedules({main:G.Schedule(reader,writer)});emit('presenceIsIndexedNotReadBeforeWrite',runtime);
}
{
 const {G,components:c,runtime}=setup(['A']);const both=G.System('Both',{queries:{q:G.Query({selection:{a:G.Query.read(c.A),aw:G.Query.write(c.A)}})}},()=>{});const writer=G.System('Writer',{queries:{q:G.Query({selection:{a:G.Query.write(c.A)}})}},()=>{});
 runtime.debug.nameSchedules({main:G.Schedule(both,writer)});emit('earlierReadWriteExcluded',runtime);
}
{
 const {G,components:c,runtime}=setup(['A']);const query=G.Query({selection:{a:G.Query.read(c.A)}});const r1=G.System('Reader1',{queries:{q:query}},()=>{});const r2=G.System('Reader2',{queries:{q:query}},()=>{});const writer=G.System('Writer',{queries:{q:G.Query({selection:{a:G.Query.write(c.A)}})}},()=>{});
 runtime.debug.nameSchedules({main:G.Schedule(r1,r2,writer),again:G.Schedule(r1)});emit('readerDedupAndPlural',runtime);
}
{
 const {G,components:c,runtime}=setup(['A','Unknown']);const all=G.System('All',{queries:{q:G.Query({selection:{u:G.Query.read(c.Unknown)}})}},()=>{});const schedule=G.Schedule(all);
 // Internal static edge input deliberately repeats descriptor A and omits
 // Unknown from declaration order. This is not a public foreign-query grant.
 const observed=()=>staticDescribe({schema:{components:{a:c.A,aAgain:c.A},resources:{},events:{},relations:{}},machines:[],currentMachine:()=>undefined,providedServices:[],hasResource:()=>false,schedules:[['main',schedule]]} as any);
 emit('initialNameDedupAndUnknownAppend',runtime,observed);
}

{
 const {G,runtime}=setup([]);const play=G.StateMachine('Play',['Idle','Running']);const writer=G.System('Writer',{nextMachines:{one:G.System.nextState(play),two:G.System.nextState(play)}},()=>{});
 runtime.debug.nameSchedules({main:G.Schedule(writer)});emit('duplicateNextSlotRetained',runtime);
}
