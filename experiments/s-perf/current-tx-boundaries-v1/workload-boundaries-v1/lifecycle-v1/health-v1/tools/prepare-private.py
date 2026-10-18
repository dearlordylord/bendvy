from pathlib import Path
import hashlib,json,re,subprocess,os
ROOT=Path('/workspace/formal-proofs/bendvy');OUT=Path(__file__).resolve().parent.parent;BASE='d20550079';SUB=Path('experiments/s-perf/canonical-api-v1/dense-runtime-v1/diagnostics/tx-peaks-v1/subject');files={};pins={}
def read(p):return subprocess.check_output(['git','show',BASE+':'+str(p)],cwd=ROOT)
def visit(p):
 p=Path(os.path.normpath(p));key=str(p)
 if key in files:return
 raw=read(p);pins[key]=hashlib.sha256(raw).hexdigest()
 if key.startswith('src/ecs/') and key!='src/ecs/query-contract.bend':return
 files[key]=raw
 if p.suffix=='.bend':
  for name in re.findall(r'^import\s+(\S+)',raw.decode(),re.M):
   if name!='Base':visit(p.parent/name)
  for name in re.findall(r'^\s+import "([^"]+)"',raw.decode(),re.M):visit(p.parent/name)
visit(Path('experiments/s-perf/canonical-api-v1/lifecycle-runtime-v1/health-main.bend'))
def dest(p):
 p=Path(p)
 if str(p).startswith('src/ecs/') and str(p)!='src/ecs/query-contract.bend':return ROOT/'experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private'/p
 return OUT/'private'/p
for p,raw in files.items():
 target=dest(p);target.parent.mkdir(parents=True,exist_ok=True)
 if p.endswith('.bend'):
  text=raw.decode()
  def imp(m):
   name=m[1]
   if name=='Base':return m[0]
   resolved=Path(os.path.normpath(Path(p).parent/name));return 'import '+os.path.relpath(dest(resolved),target.parent)
  text=re.sub(r'^import\s+(\S+)',imp,text,flags=re.M)
  def ffi(m):return '  import "'+os.path.relpath(dest(Path(os.path.normpath(Path(p).parent/m[1]))),target.parent)+'"'
  text=re.sub(r'^  import "([^"]+)"',ffi,text,flags=re.M);target.write_text(text)
 else:target.write_bytes(raw)

(OUT/'COPY-BASIS.json').write_text(json.dumps({'baseline':BASE,'sourcePins':pins,'scope':'Original Health Lifecycle closure, private-rebased with immutable nominal World/Tx; generic meter adapters imported/copied separately.'},indent=2)+'\n')
print(len(files),'private consumer files')
