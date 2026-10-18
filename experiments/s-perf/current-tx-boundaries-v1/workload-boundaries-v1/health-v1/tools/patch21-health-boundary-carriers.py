from pathlib import Path
import re,os
D=Path('/tmp/bendvy-workload-health-boundaries/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/health-v1');F=D/'private/experiments/s-perf/canonical-api-v1/failedtxn-runtime-v1';A=Path('/workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1');M=A/'private/experiments/s-perf/canonical-api-v1/failedtxn-runtime-v1';meter='import '+os.path.relpath(A/'meter.bend',F)+' as Meter\n'
# Exact same report-only Local/Dispose adaptations as accepted Motion, applied to original Health sources.
script=Path('/tmp/patch21-workload-carriers.py').read_text().replace("D=Path('/tmp/bendvy-workload-tx-boundaries/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1')",'D=Path('+repr(str(D))+')').replace('motion-','health-').replace('T.MotionSchema','T.HealthSchema').replace("'import ../../../../../meter.bend as Meter\\n'",repr(meter));exec(script)
p=F/'health.bend';s=meter+p.read_text();s=s.replace('outcome:Tx.Outcome<Unit>}','outcome:Tx.Outcome<Unit>,report:Meter.Report}').replace('Tx.Returned{world,outcome}:Seeded{world,reservations,outcome}','Tx.Returned{world,outcome,report}:Seeded{world,reservations,outcome,report}').replace('Tx.begin(~World(),~E.event_type(),world)','Cmd.tx_begin(~T.HealthSchema,~Store(),~Resources(),~E.event_type(),world)');p.write_text(s)
# The copied Health Frame keeps its original eight fields, including String call construction.
ns={};tool=(D/'tools/prepare-private.py').read_text();exec(tool[tool.index('def split(s):'):tool.index('# Functions accepting')],ns);split,end=ns['split'],ns['end']
for p in F.glob('*.bend'):
 s=p.read_text();edits=[]
 for m in re.finditer(r'\bFrame\{',s):
  a=m.end()-1;e=end(s,a);fields=split(s[a+1:e])
  if len(fields)!=8:continue
  line=s[s.rfind('\n',0,m.start())+1:m.start()];pattern='case ' in line and ':' not in line[line.index('case '):]
  extra='metrics:List<&2,Meter.Sample>' if any(':W.Handle' in x for x in fields) else ('metrics' if pattern or p.name!='health-scenario.bend' else '[]');fields.append(extra);edits.append((a+1,e,','.join(fields)))
 for a,e,r in reversed(edits):s=s[:a]+r+s[e:]
 if edits and p.name=='health-systems.bend':s=meter+s
 p.write_text(s)
# Extract only generic detached metadata helpers; no Motion business or Doc formatting is copied.
def definition(text,name):return re.search(r'^def '+name+r'\(.*?(?=^def |\Z)',text,re.M|re.S)[0]
def converted(text):return text.replace('T.MotionSchema','T.HealthSchema')
p=F/'health-systems.bend';s=p.read_text();accepted=(M/'motion-systems.bend').read_text();a=s.index('def local_logged(');s=s[:a]+''.join(converted(definition(accepted,n)) for n in ['measured_report','measured_reports','local_kind'])+s[a:];a=s.index('def local_returned(');s=s[:a]+converted(definition(accepted,'local_measured'))+s[a:]
s=s.replace('Done{L.Returned{meta,tick,call}}}:local_logged(a,frame,meta,tick,world,before,Render.instance(instance),called(status(call)))','Done{L.Returned{meta,tick,call,reports}}}:local_measured(a,frame,reports,meta,tick,world,before,Render.instance(instance),called(status(call)))')
s=s.replace('Ordinary.RunCompleted{context,provider,output}:pub_context(frame,','Ordinary.RunCompleted{context,provider,output,report}:pub_context(measured_report("Publications",True{},report,frame),').replace('Ordinary.RunFailed{context,provider,_,output}:pub_context(frame,','Ordinary.RunFailed{context,provider,_,output,report}:pub_context(measured_report("Publications",False{},report,frame),')
s=s.replace('Dispose.Output{statuses,facts,_}}}:(registry,(Shared{meta,tick,frame_call(frame,','Dispose.Output{statuses,facts,+outcome,report}}}:(registry,(Shared{meta,tick,frame_call(measured_report("Dispose",Tx.committed(~Unit,outcome),report,frame),')
s+='\n'+''.join(converted(definition(accepted,n)) for n in ['frame_metrics','metric_snapshot']);p.write_text(s)
p=F/'health-program.bend';s=meter+p.read_text();accepted=(M/'motion-program.bend').read_text();s+='\n'+''.join(converted(definition(accepted,n)) for n in ['metrics_observed','metrics']);p.write_text(s)
p=F/'health-stream.bend';s=meter+p.read_text();accepted=(M/'motion-stream.bend').read_text();s+='\n'+''.join(converted(definition(accepted,n)).replace('Doc.Doc','List<&2,String>').replace('prefix:List<&2,String>','prefix:String') for n in ['final_profiled','final_profile']);p.write_text(s)
