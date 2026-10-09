"""Unchanged Held stock installed C emission-only preparation/execution."""
import gzip,hashlib,json,sys,types
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent
ROOT=Path('/workspace/formal-proofs/bendvy')
ARCHIVE=ROOT/'experiments/public-inspect/native-debug-call-boundary-v1/full-consumer-v1/held-continuation-v1/clang-cost-v1/evidence-v1/cost02'
OLD_SHA='c90a241e8c7ccd508c42707abff26a67306ab741dd951ae38fa4290f35313cd9'
def sha(path):
 p=Path(path)
 if not p.is_file() or p.is_symlink():raise ValueError('regular nonsymlink input required')
 return hashlib.sha256(p.read_bytes()).hexdigest()
def admitted(path,digest):
 if sha(path)!=digest:raise ValueError('supplied plan digest mismatch')
 p=json.loads(Path(path).read_text());actual=str(Path(sys.executable).resolve(strict=True))
 if actual!=p['tools']['python'] or sha(actual)!=p['pins'][actual]:raise ValueError('actual interpreter drift')
 return p

def prepare(destination):
 out=Path(destination).resolve();out.mkdir(exist_ok=False)
 original=HERE.parent/'clang-cost-v1/o1-preparation-v1/plan.json'
 p=json.loads(original.read_text())
 if sha(original)!='d5f73fa25834748be6cb6794cfb5e9b444e5af1870eedcbff50afef213d7c549':raise ValueError('original reviewed plan drift')
 if {k:sha(k)for k in p['pins']}!=p['pins']:raise ValueError('current historical input drift')
 stock=Path('/home/node/.bend/bin/bend-2.0.35');expected='f77417474ded314ad5d1a68fa3ebbe214c2124bf04d56a59b05bc17be6b0327a'
 if stock.is_symlink() or sha(stock)!=expected:raise ValueError('exact installed tool drift')
 p['tools']['bend']=str(stock);p['pins'][str(stock)]=expected
 cohort=p['cohorts'][0];artifact=out/'normal-stock.c'
 cohort['commands']=[{'label':'normal-stock-emit','stage':'emit','argv':[p['tools']['taskset'],'-c','5',str(stock),cohort['entrypoint'],'-o',str(artifact)],'capSeconds':30,'artifact':str(artifact)}]
 cohort['backend']='installed-C-emission-only'
 p['scope']='Unchanged full Held71 installed Bend2.0.35 C emission-only prerequisite; no Clang/runtime/omission/performance/task qualification'
 p['pins'].update({str(HERE/'prepare.py'):sha(HERE/'prepare.py'),str(original):sha(original)})
 p.pop('o1DiagnosticOnly',None);p['installedEmissionOnly']=True;p['clangCostDiagnosticOnly']=False;p['arityDiagnosticOnly']=True
 f=out/'plan.json';f.write_text(json.dumps(p,indent=2)+'\n');print(json.dumps({'plan':str(f),'sha256':sha(f),'status':'PREPARED_NO_CHILD'}))

def run(path,digest):
 p=admitted(path,digest)
 if p.get('installedEmissionOnly') is not True:raise ValueError('installed emission-only plan required')
 keys=[k for k in p['pins']if k.endswith('/full-consumer-v1/execution.py')]
 if len(keys)!=1:raise ValueError('unique reviewed execution source required')
 source=Path(keys[0]);raw=source.read_bytes()
 if hashlib.sha256(raw).hexdigest()!=p['pins'][str(source)]:raise ValueError('reviewed execution source drift')
 m=types.ModuleType('existing_full_runner');m.__file__=str(source);exec(compile(raw,str(source),'exec'),m.__dict__)
 m.run(path,digest)
if __name__=='__main__':
 if sys.argv[1]=='prepare':prepare(sys.argv[2])
 elif sys.argv[1]=='run':run(sys.argv[2],sys.argv[3])
 else:raise ValueError('prepare or run required')
