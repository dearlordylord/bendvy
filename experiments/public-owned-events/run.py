"""Frozen exact-source five-second TS consumer preflight, no new dependencies."""
import hashlib,json,os,sys
from pathlib import Path
R=Path(__file__).resolve().parents[2];W=Path(__file__).resolve().parent;sys.path.insert(0,str(R/'scripts'));import check_preflight as P
D=W/'reference-001';ENV=W/'environment-001.json';PLAN=W/'plan-001.json'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def expected():
 out=[]
 def payload(i,mutated=False):return {'id':i,'cells':[11,99] if mutated else [i*10+1,i*10+2],'nested':{'text':'publisher-mutated' if mutated else 'event-'+str(i)}}
 def read(reader,values=None):
  values=values or [];return {'reader':reader,'lagged':False,'values':values,'identity':[{'payload':True,'cells':True,'nested':True} for _ in values],'sameBatch':True,'readCanEmit':False}
 for root in ['OwnedAlpha','OwnedBeta']:
  cases=[('registered-empty',[read('fast'),read('slow')]),('fast-shared-payload',[read('fast',[payload(1,True)])]),('fast-repeat',[read('fast')]),('slow-independent',[read('slow',[payload(1,True)])]),('fast-failed',[read('fast',[payload(2)])]),('fast-retry',[read('fast',[payload(2)])]),('slow-condition-skipped',[]),('slow-resume-discards',[read('slow')]),('other-runtime-empty',[read('fast')]),('undeclared',[{'reader':'undeclared','hasPing':False}]),('unheld-initial',[{'values':[],'lagged':False}]),('default-window-trim',[{'values':[],'lagged':True}]),('public-disposal-api',[{'runtimeDispose':False,'runtimeUnregister':False,'streamClear':False}]),('erased-cross-schema',[read('foreign')])]
  out.extend({'root':root,'label':label,'calls':calls} for label,calls in cases)
 return {'developmentOnly':True,'acceptance':False,'completeIssue53':False,'observed':out}
def prepare():
 assert not PLAN.exists() and not ENV.exists();gold=W/'expected-001.stdout';gold.write_text(json.dumps(expected(),separators=(',',':'))+'\n');ENV.write_text(json.dumps(dict(os.environ),sort_keys=True));ENV.chmod(0o600)
 node='/home/node/.local/share/mise/installs/node/24.20.0/bin/node';checks=[{'label':'reference','argv':[node,str(W/'reference.mjs')],'seconds':5,'stdout':str(gold),'stderr':str(W/'expected.stderr')}];(W/'expected.stderr').write_bytes(b'')
 files=[str(p) for p in [W/'reference.mjs',W/'oracle.mjs',Path(__file__),gold,W/'expected.stderr',Path(node),R/'.references/sources.json',R/'docs/SPEC.md',R/'scripts/check_preflight.py',R/'scripts/task_runner.py']];dirs=[str(R/'.references/bevy-ts/packages/core/src')];env=json.loads(ENV.read_text());b=P.binding(R,files,dirs,checks,env);PLAN.write_text(json.dumps({'developmentOnly':True,'acceptance':False,'completeIssue53':False,'files':files,'directories':dirs,'checks':checks,'binding':b,'environmentSHA256':sha(ENV)},indent=2)+'\n');print(sha(PLAN))
def execute():
 plan=json.loads(PLAN.read_text());assert sha(ENV)==plan['environmentSHA256'];env=json.loads(ENV.read_text());assert P.binding(R,plan['files'],plan['directories'],plan['checks'],env)==plan['binding'];print(P.run(D,root=R,files=[*plan['files'],str(PLAN),str(ENV)],directories=plan['directories'],checks=plan['checks'],env=env))
if sys.argv[1:]==['--prepare-only']:prepare()
elif sys.argv[1:]==['--execute']:execute()
else:raise SystemExit('use --prepare-only or --execute')
