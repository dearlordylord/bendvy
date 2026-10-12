import assert from 'node:assert/strict';
import {Descriptor as D,Schema,Fx} from '/workspace/formal-proofs/bendvy/.references/bevy-ts/packages/core/src/index.ts';
const Counter=D.Resource()('Counter'), Event=D.Event()('Event');
const G=Schema.bind(Schema.fragment({resources:{Counter},events:{Event}}));
const lines=[];
function scenario(mode){
 const rt=G.Runtime.make({resources:{Counter:0},services:G.Runtime.services()});
 let trace='', published=[];
 const empty=G.Query({selection:{}});
 const observe=G.System('snapshot',{queries:{all:empty},resources:{counter:G.System.readResource(Counter)},events:{event:G.System.readEvent(Event)}},({queries,resources,events})=>{
   published.push(...events.event.all());
   lines.push(`${resources.counter.get()}:${published.map(x=>`${x},`).join('')}:${queries.all.each().map(({entity})=>`${entity.id.value},`).join('')}`);
 });
 const access={resources:{counter:G.System.writeResource(Counter)},events:{event:G.System.writeEvent(Event)},queries:{all:empty}};
 const A=G.System('A',access,({resources,events,commands})=>{trace+='run:1;';commands.spawn(G.Command.spawn());if(mode==='failure'){resources.counter.set(resources.counter.get()*10+2);events.event.emit(2);}});
 const B=G.System('B',access,({queries,resources,events,commands})=>{trace+='run:2;';if(mode==='failure'){resources.counter.set(777);events.event.emit(7);commands.spawn(G.Command.spawn());return Fx.fail('planned');}resources.counter.set(resources.counter.get()*10+2+queries.all.each().length);events.event.emit(2);});
 const phase=name=>G.System(`phase-${name}`,{},()=>{trace+=`phase:${name};`;});
 const barrier=()=>G.Schedule(G.Schedule.applyDeferred(),G.System('barrier-observed',{},()=>{trace+='barrier;';}));
 const no=G.Condition.check('false',{resources:{counter:G.System.readResource(Counter)}},({resources})=>{resources.counter.get();trace+='skip:2;';return false;});
 const yes=G.Condition.check('true',{resources:{counter:G.System.readResource(Counter)}},({resources})=>resources.counter.get()<1000000);
 let plan;
 if(mode==='plain')plan=G.Schedule(phase('before'),G.Schedule.when([yes],A),phase('after'),B);
 if(mode==='barrier')plan=G.Schedule(phase('before'),A,barrier(),phase('after'),B);
 if(mode==='skip')plan=G.Schedule(A,G.Schedule.when([no],B),barrier());
 if(mode==='duplicate'){assert.throws(()=>G.Schedule(A,G.Schedule.when([no],A)),/Duplicate system step/);lines.push('invalid');return;}
 if(mode==='unknown'){assert.throws(()=>G.Schedule(undefined),/Schedule entry/);lines.push('invalid');return;}
 if(mode==='failure')plan=G.Schedule(phase('failure'),A,B,barrier());
 for(let n=0;n<2;n++){
   trace='';const result=rt.tick(plan);
   if(mode==='failure'){assert.equal(result.ok,false);assert.equal(result.error.error,'planned');lines.push(`fail:planned:${trace}`);}else{assert.equal(result.ok,true);lines.push(`ok:${trace}`);}
   assert.equal(rt.tick(G.Schedule(observe)).ok,true);
 }
 assert.equal(rt.tick(G.Schedule(G.Schedule.applyDeferred(),observe)).ok,true);
 lines[lines.length-1]='flush:'+lines.at(-1);
}
for(const mode of ['plain','barrier','skip','duplicate','unknown','failure'])scenario(mode);
console.log(lines.join('\n')+'\n');
