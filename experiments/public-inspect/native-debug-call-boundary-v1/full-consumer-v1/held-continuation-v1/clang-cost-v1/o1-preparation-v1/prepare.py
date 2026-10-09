"""Changed exact-C O1 preparation/execution; no emission or installed Bend claim."""
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

def prepare(out):
 out=Path(out).resolve();out.mkdir(exist_ok=False)
 oldraw=gzip.decompress((ARCHIVE/'plan.json.gz').read_bytes())
 if hashlib.sha256(oldraw).hexdigest()!=OLD_SHA:raise ValueError('original O0 plan drift')
 p=json.loads(oldraw)
 if len(p['cohorts'])!=1:raise ValueError('complete normal cohort required')
 cohort=p['cohorts'][0];c=cohort['commands'][1]['argv'][6]
 if p['pins'][c]!='b12ec5dc8a2f316e34a8e9b73304946afeb0480933ebf2ed35c4ec889d9a8552':raise ValueError('exact retained C differs')
 if {k:sha(k)for k in p['pins']}!=p['pins']:raise ValueError('source-current O0 input drift')
 receipt=json.loads(gzip.decompress((ARCHIVE/'receipt.json.gz').read_bytes()))
 if receipt['status']!='CLANG_COST_DIAGNOSTIC_COMPLETED' or receipt['planSHA256']!=OLD_SHA:raise ValueError('retained O0 terminal binding differs')
 tools=p['tools'];binary=out/'normal-O1.native';prefix=[tools['taskset'],'-c','5']
 cohort['commands']=[{'label':'normal-O1-build','stage':'build','argv':prefix+[tools['clangWrapper'],'-O1','-ftime-report',c,'-o',str(binary),'-pthread','-lm'],'capSeconds':120,'artifact':str(binary)}, {'label':'normal-O1-runtime','stage':'runtime','argv':prefix+[str(binary),'--threads','1','--gpu','off'],'capSeconds':5}]
 cohort['backend']='native-O1-diagnostic'
 p['scope']=__doc__+'; unchanged full normal71 oracle; no O3/mutation/performance/task qualification'
 p['pins'].update({str(HERE/'prepare.py'):sha(HERE/'prepare.py'),str(ARCHIVE/'plan.json.gz'):sha(ARCHIVE/'plan.json.gz'),str(ARCHIVE/'receipt.json.gz'):sha(ARCHIVE/'receipt.json.gz')})
 p['o1DiagnosticOnly']=True
 f=out/'plan.json';f.write_text(json.dumps(p,indent=2)+'\n');print(json.dumps({'plan':str(f),'sha256':sha(f),'status':'PREPARED_NO_CHILD'}))

def run(path,digest):
 p=admitted(path,digest)
 if p.get('o1DiagnosticOnly') is not True:raise ValueError('O1 diagnostic plan required')
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
