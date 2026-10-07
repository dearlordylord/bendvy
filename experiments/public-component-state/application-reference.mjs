import {Descriptor,Schema,Fx,Decode} from '../../.references/bevy-ts/packages/core/src/index.ts';
function scenario(){
 const Phase=Descriptor.State('State/Phase',['ready','windup','active'],{transitions:{ready:['windup'],windup:['active','ready'],active:['ready']}});
 const Mode=Descriptor.State('State/Mode',[0,1,2]);
 const Neighbor=Descriptor.ConstructedComponent(Decode.array(Decode.number))('State/Neighbor');
 const G=Schema.bind(Schema.fragment({components:{Phase,Mode,Neighbor}}));const r=G.Runtime.make({services:G.Runtime.services()});
 const phases=['ready','windup','active'];const lines=[];let action,writerLabel,watchLabel;
 const all=G.Inspector('state/all',{queries:{q:G.Query({selection:{phase:G.Query.optional(Phase),mode:G.Query.optional(Mode),neighbor:G.Query.read(Neighbor)}})}},({queries})=>queries.q.each().map(({data})=>[data.phase.present?phases.indexOf(data.phase.get()):null,data.mode.present?data.mode.get():null,data.neighbor.get()]));
 const record=label=>{const rows=r.inspect(all);lines.push(label+'|'+JSON.stringify(rows.length?rows:[[null,null,null],[null,null,null]]));};
 const Spawn=G.System('state/spawn',{},({commands})=>{commands.spawn(G.Command.spawn([Phase,'ready'],[Mode,0],[Neighbor,[11,22,33,44]]));commands.spawn(G.Command.spawn([Neighbor,[11,22,33,44]]));});
 const Watch=G.System('state/watch',{queries:{q:G.Query({selection:{phase:G.Query.read(Phase)},filters:[G.Query.changed(Phase)]}),m:G.Query({selection:{mode:G.Query.read(Mode)},filters:[G.Query.changed(Mode)]})}},({queries})=>{lines.push(watchLabel+'|phase='+queries.q.each().map(({data})=>phases.indexOf(data.phase.get())).join(',')+';mode='+queries.m.each().map(({data})=>data.mode.get()).join(','));});
 const Writer=G.System('state/write',{queries:{q:G.Query({selection:{phase:G.Query.write(Phase),mode:G.Query.write(Mode),neighbor:G.Query.read(Neighbor)}})}},({queries})=>{
  const results=[];for(const {data} of queries.q.each()){
   if(action.startsWith('raw-')){const result=action==='raw-phase-legal'?data.phase.setRaw('ready'):action==='raw-phase-invalid'?data.phase.setRaw('sleeping'):action==='raw-mode-legal'?data.mode.setRaw(1):data.mode.setRaw(9);const supplied=action==='raw-phase-invalid'?'sleeping':9;results.push(result.ok?'raw:true':'raw:false|raw='+supplied+'|path='+result.error.path+'|expected='+result.error.expected+'|actual='+result.error.actual);continue;}
   if(action==='same'){data.phase.set(data.phase.get());results.push('same');continue;}
   const pair=action==='finish'?['windup','active']:['ready','windup'];const moved=data.phase.transition(...pair);
   if(action==='fail'||action==='advance')data.mode.transition(0,2);
   results.push(moved.ok?'moved':'mismatch:'+phases.indexOf(moved.error.expected)+':'+phases.indexOf(moved.error.actual));
  }
  if(action==='fail')return Fx.fail('Rejected');lines.push(writerLabel+'|'+results.join(','));
 });
 const write=(a,label)=>{action=a;writerLabel=label;const result=r.tick(G.Schedule(Writer));if(!result.ok)lines.push(label+'|failed:'+result.error.error);};
 const watch=label=>{watchLabel=label;r.tick(G.Schedule(Watch));};
 record('empty');r.tick(G.Schedule(Spawn));record('pending');r.tick(G.Schedule(G.Schedule.applyDeferred()));record('seeded');watch('changed-initial');
 write('fail','fail');record('rollback');watch('changed-after-fail');
 write('advance','advance');record('advanced');watch('changed-after-advance');
 write('advance','stale');record('stale-retains');watch('changed-after-stale');
 write('finish','finish');record('active');watch('changed-after-finish');
 for(const [a,label,reader] of [['raw-phase-legal','raw-phase-value','changed-after-raw-phase'],['raw-phase-invalid','raw-phase-retains','changed-after-invalid-phase'],['raw-mode-legal','raw-mode-value','changed-after-raw-mode'],['raw-mode-invalid','raw-mode-retains','changed-after-invalid-mode']]){write(a,a);record(label);watch(reader);}
 write('same','same');record('same-retains');watch('changed-after-same');
 return lines;
}
for(const line of [...scenario(),...scenario()])console.log(line);
