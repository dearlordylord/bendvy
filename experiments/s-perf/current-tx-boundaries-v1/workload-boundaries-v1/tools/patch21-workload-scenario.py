from pathlib import Path
import re
D=Path('/tmp/bendvy-workload-tx-boundaries/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1');F=D/'private/experiments/s-perf/canonical-api-v1/failedtxn-runtime-v1';p=F/'motion-systems.bend';s=p.read_text().replace('1n+List.length(&2,Meter.Sample,metrics)','List.length(&2,Meter.Sample,metrics)');s+='''
def metric_snapshot(world:F.World(),runtime:Runtime(),_:Unit) -> F.World() & (Runtime() & List<&2,Meter.Sample>):
  match runtime:
    case (owners,Shared{meta,tick,+frame}):(world,((owners,Shared{meta,tick,frame}),frame_metrics(frame)))
def frame_metrics(frame:Frame) -> List<&2,Meter.Sample>:
  match frame:
    case Frame{_,_,_,_,_,_,_,_,metrics}:metrics
'''
# Bend declaration order.
a=s.index('def metric_snapshot');b=s.index('def frame_metrics',a);s=s[:a]+s[b:]+s[a:b];p.write_text(s)
p=F/'motion-program.bend';s=p.read_text();s='import ../../../../../meter.bend as Meter\n'+s;s+='''
def metrics_observed(namespace:U32,boundaries:List<&2,Boundary.Boundary>,schedules:List<&2,String>,status:Status,result:EntryApp.Slot() & List<&2,Meter.Sample>) -> State & List<&2,Meter.Sample>:
  (app,metrics)=result
  (State{app,namespace,boundaries,schedules,status},metrics)
def metrics(state:State) -> State & List<&2,Meter.Sample>:
  match state:
    case State{app,namespace,boundaries,schedules,status}:metrics_observed(namespace,boundaries,schedules,status,EntryApp.project(~Unit,~List<&2,Meter.Sample>,~S.metric_snapshot,app,Unit{}))
''';p.write_text(s)
p=F/'motion-stream.bend';s='import ../../../../../meter.bend as Meter\n'+p.read_text();s+='''
def final_profiled(prefix:Doc.Doc,result:P.State & List<&2,Meter.Sample>) -> Doc.Doc & List<&2,Meter.Sample>:
  (owner,metrics)=result
  (final(prefix,owner),metrics)
def final_profile(prefix:Doc.Doc,owner:P.State) -> Doc.Doc & List<&2,Meter.Sample>:final_profiled(prefix,P.metrics(owner))
''';p.write_text(s)
p=F/'motion-scenario.bend';s='import ../../../../../meter.bend as Meter\n'+p.read_text();names=['primed','registered','named','dispose_registered','setup','targets','seed_applied','seed_pending','seeded','created','program'];lines=s.splitlines()
for i,line in enumerate(lines):
 if any(line.startswith('def '+n+'(') for n in names):lines[i]=line.replace('-> Doc.Doc:','-> Doc.Doc & List<&2,Meter.Sample>:')
s='\n'.join(lines)+'\n';s=s.replace('Stream.final(Doc.concat','Stream.final_profile(Doc.concat')
# Thread seed report as detached Data through original setup call sequence.
ns={};tool=(D/'tools/prepare-private.py').read_text();exec(tool[tool.index('def split(s):'):tool.index('# Functions accepting')],ns);end=ns['end'];targets=['named','dispose_registered','setup','targets','seed_applied','seed_pending'];edits=[]
for m in re.finditer(r'(?<![\w.])('+'|'.join(targets)+r')\(',s):
 a=m.end()-1;e=end(s,a);defining=bool(re.search(r'def\s+$',s[max(0,m.start()-5):m.start()]));edits.append((a+1,a+1,'seed:Meter.Sample,' if defining else 'seed,'))
for a,e,r in reversed(edits):s=s[:a]+r+s[e:]
s=s.replace('S.Frame{first,second,0,0,None{},None{},[],[],[]}','S.Frame{first,second,0,0,None{},None{},[],[],[seed]}')
s=s.replace('case F.Seeded{world,+reservations,outcome}:seed_pending(seed,','case F.Seeded{world,+reservations,+outcome,report}:seed_pending(Meter.Sample{"seed",None{},None{},0n,Tx.committed(~Unit,outcome),report},')
# Exceptional setup branches preserve original canonical text; no observed Tx report fabricated.
lines=s.splitlines()
for i,line in enumerate(lines):
 if re.match(r'\s+case .*:Doc.concat\(',line):
  prefix,expr=line.split(':Doc.concat(',1);lines[i]=prefix+':(Doc.concat('+expr+',[])'
s='\n'.join(lines)+'\n';p.write_text(s)
