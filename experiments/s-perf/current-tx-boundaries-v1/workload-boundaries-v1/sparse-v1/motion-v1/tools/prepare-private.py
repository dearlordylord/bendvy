from pathlib import Path
import hashlib,json,os,re,subprocess
ROOT=Path(__file__).resolve().parents[7]
OUT=Path(__file__).resolve().parent.parent
SUB=ROOT/'experiments/s-perf/canonical-api-v1/sparse-runtime-v1/diagnostics/tx-peaks-v1/motion-subject'
DENSE=ROOT/'experiments/s-perf/current-tx-boundaries-v1'
files={};pins={}
def actual(p):
 p=Path(os.path.normpath(p))
 if p.is_relative_to(ROOT/'src'):return DENSE/'private'/p.relative_to(ROOT)
 return p
def dest(p):
 p=actual(p)
 if p.is_relative_to(SUB):return OUT/'subject'/p.relative_to(SUB)
 if p.is_relative_to(DENSE/'private'):return OUT/'private'/p.relative_to(DENSE/'private')
 if p==DENSE/'meter.bend':return OUT/'meter.bend'
 return OUT/'private'/p.relative_to(ROOT)
def visit(p):
 p=actual(p)
 if p in files:return
 raw=p.read_bytes() if p.exists() else subprocess.check_output(["git","show","41409a5ee:"+str(p.relative_to(ROOT))],cwd=ROOT);files[p]=raw;pins[str(p.relative_to(ROOT))]=hashlib.sha256(raw).hexdigest()
 if p.suffix=='.bend':
  for name in re.findall(r'^import\s+(\S+)',raw.decode(),re.M):
   if name!='Base':visit(p.parent/name)
  for name in re.findall(r'^\s+import "([^"]+)"',raw.decode(),re.M):visit(p.parent/name)
visit(SUB/'motion-main.bend');visit(DENSE/'subject/tx-metrics.bend')
for p,raw in files.items():
 target=dest(p)
 if p==DENSE/'subject/tx-metrics.bend':target=OUT/'subject/tx-metrics.bend'
 target.parent.mkdir(parents=True,exist_ok=True)
 if p.suffix=='.bend':
  text=raw.decode()
  def imp(m):
   name=m[1]
   return m[0] if name=='Base' else 'import '+os.path.relpath(dest(p.parent/name),target.parent)
  text=re.sub(r'^import\s+(\S+)',imp,text,flags=re.M)
  text=re.sub(r'^  import "([^"]+)"',lambda m:'  import "'+os.path.relpath(dest(p.parent/m[1]),target.parent)+'"',text,flags=re.M)
  target.write_text(text)
 else:target.write_bytes(raw)
p=OUT/'subject/motion.bend';t=p.read_text()
t=t.replace('ProfileOutput{values,sample}', 'ProfileOutput{values,Metrics.finished(sample,True{})}').replace('ProfileFailure{error,sample}','ProfileFailure{error,Metrics.finished(sample,False{})}')
t=t.replace('Seeded{world,reservations,outcome,sample}','Seeded{world,reservations,outcome,Metrics.finished(sample,Tx.committed(~Unit,outcome))}')
t=t.replace('Metrics.observe(~World(),~Nat,','Metrics.observe_world(~T.MotionSchema,~Store(),~Resources(),~Nat,').replace('Tx.begin(~World(),~Nat,world)','Metrics.begin(~T.MotionSchema,~Store(),~Resources(),~Nat,world)');t=t.replace('case Tx.Returned{world,outcome}:','case Tx.Returned{world,+outcome}:');p.write_text(t)
p=OUT/'subject/motion-driver.bend';t=p.read_text().replace('[sample]','[Metrics.at_iteration(sample,List.length(&2,Status,statuses))]').replace('case Shared{audit,statuses,prior,samples},Sys.Completed','case Shared{audit,+statuses,prior,samples},Sys.Completed');p.write_text(t)
p=OUT/'subject/motion-main.bend';t=p.read_text().replace('def write(metricsPath:String,','def write(count:U32,iterations:U32,metricsPath:String,').replace('Metrics.report(samples)','Metrics.report(count,iterations,samples)').replace('write(metricsPath,created(count,iterations,result))','write(count,iterations,metricsPath,created(count,iterations,result))');p.write_text(t)
(OUT/'COPY-BASIS.json').write_text(json.dumps({'base':'41409a5ee','sourcePins':pins,'scope':'Sparse terminal observer and ordinary App; accepted Dense private core and Meter. Original three postcommit scans unchanged. Actual afterappend and beforefinish reports; no readonly scan Tx invented.'},indent=2)+'\n')
print(len(files))
