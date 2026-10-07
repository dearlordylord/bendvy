"""Source-bound finite bundle integration; reviewed donor supervisor/raw log policy."""
from pathlib import Path
import argparse,hashlib,json,os,re,runpy,shutil,sys,tempfile,time
ROOT=Path(__file__).resolve().parents[4];LOCAL=Path('experiments/public-bundles/production-candidate/transactions');HERE=ROOT/LOCAL
args=argparse.ArgumentParser();args.add_argument('--native',action='store_true');args.add_argument('--preflight-only',action='store_true');args.add_argument('--diagnostic-freeze',action='store_true');args=args.parse_args()
os.sched_setaffinity(0,{5})
OUT=ROOT/'.artifacts'/('bundles41-transactions-'+str(time.time_ns()));OUT.mkdir()
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def inventory(p):return {str(f.relative_to(p)):sha(f) for f in sorted(p.rglob('*')) if f.is_file()}
def closure(p,seen):
 p=p.resolve()
 if p in seen:return
 seen.add(p)
 for name in re.findall(r'^\s*import\s+(\S+)',p.read_text(),re.M):
  if name!='Base':closure(p.parent/name.strip('"'),seen)
SUP=Path('experiments/public-identity/production-candidate/promotion')
plans=json.loads((HERE/'VARIANTS.json').read_text())['variants'];diagnostics={} if args.diagnostic_freeze else json.loads((HERE/'diagnostics.json').read_text());oldDiagnostics=json.loads((HERE.parent/'diagnostics.json').read_text());files=set()
closure(HERE/'main.bend',files)
for name in oldDiagnostics:closure(ROOT/'experiments/public-bundles/public-client'/('negative-'+name+'.bend'),files)
for name in ['owner','schema','read-write']:closure(HERE/('negative-'+name+'.bend'),files)
closure(HERE/'positive.bend',files)
files.add(HERE.parent/'diagnostics.json')
files.add(HERE.parent/'expected-reference.stdout');files.add(HERE.parent/'expected-combined-reference.stdout')
files.update(p for p in HERE.iterdir() if p.is_file())
files.update(ROOT/p for p in [SUP/'supervisor.py',SUP/'supervisor-provenance.json',SUP/'supervisor-control.py',Path('experiments/s-prep/fivehour-connected-gates/supervisor.py'),Path('scripts/receipt-logs.py'),Path('scripts/task_runner.py'),LOCAL/'tool-pins.py',Path('experiments/public-bundles/reference.mjs'),Path('experiments/public-bundles/combined-reference.mjs')])
for v in plans:
 for e in v['edits']:
  f=ROOT/e['path'];assert sha(f)==e['originalSHA256'];assert f.read_text().count(e['anchor'])==e['count'];assert hashlib.sha256(f.read_text().replace(e['anchor'],e['replacement']).encode()).hexdigest()==e['intendedSHA256'];files.add(f)
sources={str(p.relative_to(ROOT)):sha(p) for p in files}
configNames=['bend.json','bend.config.json','bunfig.toml','package.json','.clang','clang.cfg']
def config_inventory(roots):return {str(root/name):(sha(root/name) if (root/name).is_file() else None) for root in roots for name in configNames}
rootConfigs=config_inventory({ROOT,Path.cwd(),HERE})
external={str(p):inventory(p) for p in [ROOT/'.references/bevy-ts/packages/core/src',Path('/home/node/.bend/bend2')]}
fixed={str(p):sha(p) for p in [Path(shutil.which('bend')).resolve(),Path(shutil.which('node')).resolve(),Path(sys.executable).resolve(),Path('/home/node/.bend/check.json'),ROOT/'.references/sources.json',ROOT/'.references/bevy-ts/package.json',ROOT/'.references/bevy-ts/packages/core/package.json',Path('/tmp/bendvy-clang19-diagnostic/clang19'),Path('/tmp/bendvy-clang19-diagnostic/root/usr/lib/llvm-19/bin/clang')]}
tool=runpy.run_path(str(HERE/'tool-pins.py'));toolSnapshot=tool['snapshot']()
backends=['JS','Native'] if args.native else ['JS']
labels=['supervisor-raw','supervisor-escape','proof-boundary','positive-batch']+['negative-'+n for n in oldDiagnostics]+['batch-negative-'+n for n in ['owner','schema','read-write']]+['reference-'+n for n in ['bevy-ts','bevy','bend2','TS-api','TS-combined','TS-fifo']]
for name in ['normal']+[p['name'] for p in plans]:
 labels.append(name+'-live-check')
 for backend in backends:
  labels.append(name+'-'+backend+'-emit')
  if backend=='Native':labels.append(name+'-'+backend+'-clang')
  labels.append(name+'-'+backend+'-run')
logs=runpy.run_path(str(ROOT/'scripts/receipt-logs.py'))['CommandLogs'](OUT,labels)
r={'status':'INCOMPLETE','sources':sources,'externalInventories':external,'fixedInputs':fixed,'toolSnapshot':toolSnapshot,'plannedLabels':labels,'plannedVariants':plans,'rootConfigurations':rootConfigs,'commands':[],'generated':{},'immutableLogs':{},'cases':{},'scope':'Finite actual public declared constructor/heterogeneous owner/deferred/canonical foreign integration; no policy/proof/performance adoption','affinity':[5],'caps':{'check':5,'emit':30,'clang':120,'runtime':5}}
env=dict(os.environ,BEND_NO_TELEMETRY='1',BENDVY_CLANG19_ROOT='/tmp/bendvy-clang19-diagnostic/root')
try:
 with tempfile.TemporaryDirectory(prefix='bundles41-transactions-') as tmp:
  stage=Path(tmp)
  for n in sources:
   p=stage/n;p.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/n,p)
  staged=dict(sources);stageConfigs=config_inventory({stage,stage/LOCAL});r['stageConfigurations']=stageConfigs;supervisor=runpy.run_path(str(stage/SUP/'supervisor.py'));provenance=json.loads((stage/SUP/'supervisor-provenance.json').read_text());original=(stage/provenance['origin']).read_bytes();assert hashlib.sha256(original).hexdigest()==provenance['originSHA256'];assert (stage/SUP/'supervisor.py').read_bytes()[:provenance['unchangedPrefixBytes']]==original;r['supervisorProvenance']=provenance
  def guard():
   tool['verify'](toolSnapshot);logs.guard()
   assert config_inventory({ROOT,Path.cwd(),HERE})==rootConfigs,'root/cwd configuration drift'
   assert config_inventory({stage,stage/LOCAL})==stageConfigs,'stage configuration drift'
   assert all(sha(ROOT/n)==h for n,h in sources.items()),'live source drift'
   assert inventory(stage)==staged,'stage drift'
   assert all(inventory(Path(n))==h for n,h in external.items()),'external inventory drift'
   assert all(sha(Path(n))==h for n,h in fixed.items()),'fixed input drift'
   assert all(sha(OUT/n)==h for n,h in r['generated'].items()),'generated drift'
  def run(label,argv,cap,exit=0,emits=None):
   guard();assert label in labels
   if emits:assert not (OUT/emits).exists()
   argv=['taskset','-c','5']+list(map(str,argv))
   try:code,out,err=supervisor['execute_split'](argv,cap,env=env)
   except (TimeoutError,RuntimeError) as error:
    r['immutableLogs']=logs.record(label,getattr(error,'stdout',b''),getattr(error,'stderr',b''));r['commands'].append({'label':label,'argv':argv,'cap':cap,'supervisionFailure':str(error)});raise
   r['immutableLogs']=logs.record(label,out,err);r['commands'].append({'label':label,'argv':argv,'cap':cap,'exit':code,'stdoutSHA256':sha(OUT/(label+'.stdout')),'stderrSHA256':sha(OUT/(label+'.stderr'))});assert code==exit,(label,err.decode())
   if emits:r['generated'][emits]=sha(OUT/emits)
   guard();return out.decode(),err.decode()
  out,err=run('supervisor-raw',[sys.executable,stage/SUP/'supervisor-control.py','raw'],5);assert out=='raw-out\n' and err=='raw-err\n'
  guard()
  try:supervisor['execute_split'](['taskset','-c','5',sys.executable,str(stage/SUP/'supervisor-control.py'),'escape'],0.5,env=env)
  except TimeoutError as error:
   out=error.stdout;err=error.stderr;assert out.startswith(b'escaped:') and not err;pid=int(out.decode().strip().split(':')[1]);assert not Path('/proc',str(pid)).exists() and not supervisor['child_pids'](os.getpid());r['immutableLogs']=logs.record('supervisor-escape',out,err);r['commands'].append({'label':'supervisor-escape','expectedTimeoutControl':True,'escapedPID':pid,'reaped':True})
  else:raise AssertionError('escaping child deadline absent')
  guard()
  fixture=stage/LOCAL/'main.bend';out,err=run('proof-boundary',['bend',fixture,'--check-only'],5,1);assert not out and 'rely on unsafe or foreign code' in err
  for n,expected in oldDiagnostics.items():
   out,err=run('negative-'+n,['bend',stage/'experiments/public-bundles/public-client'/('negative-'+n+'.bend'),'--check-only'],5,1);assert not out and err==expected,(n,'complete intended diagnostic mismatch',err)
  out,err=run('positive-batch',['bend',stage/LOCAL/'positive.bend','--check-only'],5);assert out=='ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n' and not err
  observedDiagnostics={}
  intent={
   'owner':['- expected : batch','- observed : batch (consumed more than once)','batch:BT.Batch<Schema,Array<U32>,Array<U32>,U32,B.Pack<Array<U32>,B.Pack<Array<U32>,Unit>>>','6>| def bad'],
   'schema':['- expected : W.Handle<Schema>','- observed : W.Handle<Other>','9>|   BT.insert','batch,target,payload'],
   'read-write':['- expected : Cap.Request<H, Array<U32>, Unit>','- observed : Cap.Read<H, Unit>','5>|   Public.apply','Unit,cap,payload,ctx']}
  spans={'owner':(6,'batch',0),'schema':(9,'target',0),'read-write':(5,'cap',0)}
  authoredSpans={}
  for n,(line,token,_) in spans.items():
   source=(stage/LOCAL/('negative-'+n+'.bend')).read_text().splitlines()[line-1]
   column=source.index(token) if n=='owner' else source.rindex(token)
   authoredSpans[n]=' '*(len(str(line))+1)+'| '+' '*column+'^'*len(token)+'\n'
  r['authoredDiagnosticSpans']=authoredSpans
  for n in ['owner','schema','read-write']:
   out,err=run('batch-negative-'+n,['bend',stage/LOCAL/('negative-'+n+'.bend'),'--check-only'],5,1);assert not out and all(needle in err for needle in intent[n]) and authoredSpans[n] in err and 'Location: bad\n' in err,(n,'unintended diagnostic/type/span',err)
   if not args.diagnostic_freeze:assert err==diagnostics[n],(n,'complete intended diagnostic mismatch',err)
   observedDiagnostics[n]=err
  if args.diagnostic_freeze:
   guard();(OUT/'diagnostics.json').write_text(json.dumps(observedDiagnostics,indent=2)+'\n');r['generated']['diagnostics.json']=sha(OUT/'diagnostics.json');guard();r['status']='DIAGNOSTIC_FREEZE_CHECKED_ONLY'
  else:
   manifest=json.loads((ROOT/'.references/sources.json').read_text())
   for n,e in manifest['sources'].items():out,err=run('reference-'+n,['git','-C',ROOT/'.references'/n,'rev-parse','HEAD'],5);assert not err and out.strip()==e['commit']
   for name,file,expected in [('TS-api','reference.mjs','expected-reference.stdout'),('TS-combined','combined-reference.mjs','expected-combined-reference.stdout')]:
    out,err=run('reference-'+name,['node',stage/'experiments/public-bundles'/file],5);assert not err and out==(stage/LOCAL.parent/expected).read_text()
   out,err=run('reference-TS-fifo',['node',stage/LOCAL/'fifo-reference.mjs'],5);assert not err and out==(stage/LOCAL/'expected-fifo-reference.stdout').read_text()
   expected=(stage/LOCAL/'expected.stdout').read_text()
   def execute(name,variant=None):
    out,err=run(name+'-live-check',['bend',fixture],5);assert not err
    if variant is None:assert out==expected,(name,'literal normal mismatch',out)
    else:
     row=next(x for x in out.splitlines() if x.startswith(variant['witness']+'='));assert row!=variant['baselineLiteralRow'] and variant['contains'] in row,(name,'named witness absent',row)
    for backend in backends:
     suffix='js' if backend=='JS' else 'c';label=name+'-'+backend;run(label+'-emit',['bend',fixture,'-o',OUT/(label+'.'+suffix)],30,emits=label+'.'+suffix)
     if backend=='Native':run(label+'-clang',['/tmp/bendvy-clang19-diagnostic/clang19','-O3',OUT/(label+'.c'),'-pthread','-lm','-o',OUT/(label+'.native')],120,emits=label+'.native')
     seen,err=run(label+'-run',['node',OUT/(label+'.js')] if backend=='JS' else [OUT/(label+'.native'),'--threads','1','--gpu','off'],5);assert not err and seen==out;r['cases'][label]={'fullLiveOutputMatch':True,'normalLiteralMatch':variant is None,'namedWitness':variant['witness'] if variant else None,'stdoutSHA256':hashlib.sha256(seen.encode()).hexdigest()}
   if args.preflight_only:
    out,err=run('normal-live-check',['bend',fixture],5);assert not err and out==expected;r['status']='JS_LIVE_PREFLIGHT_PASS'
   else:
    execute('normal')
    for variant in plans:
     originals={e['path']:(stage/e['path']).read_text() for e in variant['edits']};guard()
     for e in variant['edits']:(stage/e['path']).write_text(originals[e['path']].replace(e['anchor'],e['replacement']));staged[e['path']]=sha(stage/e['path']);assert staged[e['path']]==e['intendedSHA256']
     guard();execute(variant['name'],variant)
     for n,text in originals.items():(stage/n).write_text(text);staged[n]=sha(stage/n)
     guard()
    r['status']='FINITE_PUBLIC_BUNDLE_TX_PASS';r['nativeExecuted']=args.native
   guard()
finally:
 (OUT/'receipt.json').write_text(json.dumps(r,indent=2)+'\n');print(OUT)
