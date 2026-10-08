"""No-child packaging of three already-qualified complete Native controls."""
from pathlib import Path
import hashlib,json,tarfile,io
H=Path(__file__).resolve().parent;J=H.parent;R=J.parents[3]
sha=lambda b:hashlib.sha256(b).hexdigest()
CASES={'outgoing-filter-negated':'1791447085549449964','incoming-order-reversed':'1791447653436036094','world-valid-omitted':'1791448592957414675'}
files={};excluded={};actual={}
def name(p):
 p=str(p);prefix=str(R)+'/'
 return 'worktree/'+p[len(prefix):] if p.startswith(prefix) else 'external/'+p.lstrip('/')
def add(p):
 p=Path(p);n=name(p);b=p.read_bytes()
 assert n not in files or files[n]==b
 files[n]=b
for case,stamp in CASES.items():
 a=R/'.artifacts'/('inspector-relation55-native-mutant-'+case+'-'+stamp);p=json.loads((a/'plan.json').read_text());r=json.loads((a/'receipt.json').read_text());q=json.loads((a/'prepare-receipt.json').read_text())
 assert r['status']=='DEVELOPMENT_MUTANT_TWO_SCHEMA_NATIVE192_REACHED_NOT_FULL55' and r['full192JoinMatched'] is True and r['reachedWitnessCount']==dict(zip(CASES,(322,360,576)))[case]
 actual[case]=name(a)
 for x in (a/'plan.json',a/'receipt.json',a/'prepare-receipt.json'):add(x)
 for x,h in p['pins'].items():
  path=Path(x);b=path.read_bytes();assert sha(b)==h
  if 'private-environment' in path.name:excluded[x]={'SHA256':h,'reason':'private environment metadata only'}
  elif path.suffix in ('.py','.bend','.json','.mjs','.md','.bytes','.stdout','.stderr','.c') or path.name=='base.bend' or path.name=='bend-check':add(x)
  else:excluded[x]={'SHA256':h,'reason':'installed executable/library/resource or historical ELF identity only'}
 for rec in (r,q):
  for x,h in rec['probePins'].items():assert sha(Path(x).read_bytes())==h;add(x)
 for x,h in r['logs'].items():assert sha((a/x).read_bytes())==h;add(a/x)
 for x,h in r['generated'].items():
  assert sha(Path(x).read_bytes())==h
  if x.endswith('.c'):add(x)
  else:excluded[x]={'SHA256':h,'reason':'actual ELF identity only'}
 for x,h in p['inventory'].items():assert sha((Path(p['stage'])/x).read_bytes())==h;add(Path(p['stage'])/x)
for x in (J/'mutant-schema-native.py',J/'mutant-schema-native-proposal.json',J/'next-qualification/schema-native-mutants/proposal.json',J/'next-qualification/schema-native-mutants/source-checks.json'):
 add(x)
index={'scope':'FINITE_THREE_REACHED_NATIVE192_CONTROLS_NOT_FULL55','actual':actual,'fixture':name(J),'normalNativeArchiveSHA256':sha((J/'schema-native-evidence-v1/evidence.tar.gz').read_bytes()),'controlsArchiveSHA256':sha((J/'controls-evidence-v1/evidence.tar.gz').read_bytes()),'excluded':excluded,'records':[{'name':n,'SHA256':sha(b),'bytes':len(b)} for n,b in sorted(files.items())]}
b=(json.dumps(index,indent=2)+'\n').encode();(H/'index.json').write_bytes(b)
with tarfile.open(H/'evidence.tar.gz','w:gz') as t:
 for n,b in sorted({'index.json':b,**{'objects/'+sha(b):b for b in files.values()}}.items()):
  m=tarfile.TarInfo(n);m.size=len(b);m.mode=0o644;m.mtime=0;t.addfile(m,io.BytesIO(b))
print('packaged',len(files),'records')
