from pathlib import Path
import re
D=Path('/tmp/bendvy-workload-tx-boundaries/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1');F=D/'private/experiments/s-perf/canonical-api-v1/failedtxn-runtime-v1';ns={};s=(D/'tools/prepare-private.py').read_text();exec(s[s.index('def split(s):'):s.index('# Functions accepting')],ns);split,end=ns['split'],ns['end']
# Reconstruct original Frame with detached Data metadata, without changing original eight fields.
for p in F.glob('*.bend'):
 s=p.read_text();edits=[]
 for m in re.finditer(r'\bFrame\{',s):
  a=m.end()-1;e=end(s,a);fields=split(s[a+1:e]);
  if len(fields)!=8:continue
  line=s[s.rfind('\n',0,m.start())+1:m.start()];pattern='case ' in line and ':' not in line[line.index('case '):]
  if any(':W.Handle' in x for x in fields):extra='metrics:List<&2,Meter.Sample>'
  elif pattern:extra='metrics'
  elif p.name=='motion-scenario.bend':extra='[]'
  else:extra='metrics'
  fields.append(extra);edits.append((a+1,e,','.join(fields)))
 for a,e,r in reversed(edits):s=s[:a]+r+s[e:]
 if edits and p.name=='motion-systems.bend':s='import ../../../../../meter.bend as Meter\n'+s
 p.write_text(s)
p=F/'motion-systems.bend';s=p.read_text();a=s.index('def local_logged(')
helpers='''def measured_report(kind:String,committed:Bool,report:Meter.Report,frame:Frame) -> Frame:
  match frame:
    case Frame{first,second,+iteration,+phase,pending,retry,failed,calls,+metrics}:Frame{first,second,iteration,phase,pending,retry,failed,calls,List.append(&2,Meter.Sample,metrics,[Meter.sample(kind,iteration,phase,1n+List.length(&2,Meter.Sample,metrics),committed,report)])}
def measured_reports(kind:String,+committed:Bool,reports:List<&2,Meter.Report>,frame:Frame) -> Frame:
  match reports:
    case []:frame
    case report <> rest:measured_reports(kind,committed,rest,measured_report(kind,committed,report,frame))
def local_kind(value:Bool) -> String:
  match value:
    case True{}:"A"
    case False{}:"B"
def local_measured(a:Bool,frame:Frame,reports:List<&2,Meter.Report>,meta:L.Meta(),tick:Nat,world:F.World(),before:String,after:L.Instance() & String,+result:Bool & (L.Call & Maybe<&2,W.Handle<T.MotionSchema>>)) -> LocalResult():
  match result:
    case (ok,value):local_logged(a,measured_reports(local_kind(a),ok,reports,frame),meta,tick,world,before,after,(ok,value))
'''
# no forward references: local_measured must follow local_logged.
b=s.index('def local_returned(',a);s=s[:a]+helpers[:helpers.index('def local_measured')]+s[a:b]+helpers[helpers.index('def local_measured'):]+s[b:]
s=s.replace('Done{L.Returned{meta,tick,call}}}:local_logged(a,frame,meta,tick,world,before,Render.instance(instance),called(status(call)))','Done{L.Returned{meta,tick,call,reports}}}:local_measured(a,frame,reports,meta,tick,world,before,Render.instance(instance),called(status(call)))')
s=s.replace('Ordinary.RunCompleted{context,provider,output}:pub_context(frame,','Ordinary.RunCompleted{context,provider,output,report}:pub_context(measured_report("Publications",True{},report,frame),').replace('Ordinary.RunFailed{context,provider,_,output}:pub_context(frame,','Ordinary.RunFailed{context,provider,_,output,report}:pub_context(measured_report("Publications",False{},report,frame),')
s=s.replace('Dispose.Output{statuses,facts,_}}}:(registry,(Shared{meta,tick,frame_call(frame,','Dispose.Output{statuses,facts,+outcome,report}}}:(registry,(Shared{meta,tick,frame_call(measured_report("Dispose",Tx.committed(~Unit,outcome),report,frame),')
# result contains affine Call: never mark whole result duplicable.
s=s.replace('+result:Bool & (L.Call','result:Bool & (L.Call').replace('case (ok,value):local_logged','case (+ok,value):local_logged')
p.write_text(s)
