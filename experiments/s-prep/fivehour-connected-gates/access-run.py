#!/usr/bin/env python3
"""Candidate-overlay actual-call-site controls; no universal confinement claim."""
import pathlib,re,json,hashlib,tempfile,subprocess,os,signal,time,shutil,argparse
HERE=pathlib.Path(__file__).resolve().parent
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('overlay',type=pathlib.Path,help='Materialized indexed overlay root')
parser.add_argument('--evidence',type=pathlib.Path,default=HERE/'access-evidence.json')
parser.add_argument('--cpu',type=int,default=9)
args=parser.parse_args()
OVERLAY=args.overlay.resolve()
SOURCE=OVERLAY/'experiments/s-integrate'
manifest_path=OVERLAY/'overlay.json'
manifest=json.loads(manifest_path.read_text())
required={'storage.bend','identity.bend','commands.bend','host.bend','dispatcher.bend','query.bend','observations.bend'}
assert required.issubset({pathlib.Path(n).name for n in manifest['overrides']}),'Not a complete indexed candidate overlay'
ENTRY='integrated-access-positive.bend'
def closure(p,seen):
 if p.name in seen:
  assert seen[p.name]==p,'Basename collision: '+str(p)
  return
 assert p.is_relative_to(OVERLAY),'Import escapes candidate overlay: '+str(p)
 seen[p.name]=p
 for relative in re.findall(r'^import (\./\S+\.bend)',p.read_text(),re.M):closure((p.parent/relative).resolve(),seen)
files={};closure(SOURCE/ENTRY,files)
assert required.issubset(files),'Candidate modules absent from checked closure'
def check(path):
 start=time.monotonic();p=subprocess.Popen(['taskset','-c',str(args.cpu),'bend',str(path),'--check-only'],stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True)
 try:out,_=p.communicate(timeout=5)
 except subprocess.TimeoutExpired:
  os.killpg(p.pid,signal.SIGKILL);out,_=p.communicate();raise AssertionError('five-second checker limit: '+out)
 return {'exit':p.returncode,'seconds':time.monotonic()-start,'output':out}
def mutate(folder,label):
 file=folder/ENTRY;s=file.read_text();location='motion_read'
 if label in ['undeclared_token','cross_schema']:
  file=folder/'systems.bend';s=file.read_text();start=s.index('def motion_a(');end=s.index('\ndef ',start+1);old=s[start:end];token='T.VelocityToken{}' if label=='undeclared_token' else 'T.VitalsToken{}';assert 'T.PositionToken{},11' in old;s=s[:start]+old.replace('T.PositionToken{},11',token+',11')+s[end:];location='motion_a'
 elif label in ['audit_copy','audit_copy_text_historical']:
  file=folder/'audited-invoker.bend';s=file.read_text();assert 'D.audit_log(audit,text)' in s;
  if label=='audit_copy':
   assert 'owner:Wrapped<Tx>,text:String' in s;s=s.replace('owner:Wrapped<Tx>,text:String','owner:Wrapped<Tx>,+text:String')
  s=s.replace('D.audit_log(audit,text)','IO.bind(D.Audit,D.Audit,D.audit_log(audit,text), _ => D.audit_log(audit,text))');location='log'
 else:
  start=s.index('def motion_read(');end=s.index('\ndef motion_query',start);old=s[start:end];line=old.splitlines()[-1];prefix=old[:old.index(line)]
  if label=='write_through_read':body='  O.client(T.MotionSchema,T.PositionToken,T.PositionView,T.VelocityView,T.Selected,T.PositionToken{},Owner,Aux,get,aux_get,handle,flag,CP.position_swap(owner,30),aux)'
  elif label=='reconstruct_owner':body='  O.client(T.MotionSchema,T.PositionToken,T.PositionView,T.VelocityView,T.Selected,T.PositionToken{},Owner,Aux,get,aux_get,handle,flag,CP.position_new(T.Position{[30:U32^2n],7}),aux)'
  elif label=='invalid_owner_return':body='  O.client(T.MotionSchema,T.PositionToken,T.PositionView,T.VelocityView,T.Selected,T.PositionToken{},Owner,Aux,get,aux_get,handle,flag,aux,owner)'
  elif label=='irrecoverable_destructure':body='  match owner:\n    case T.Position{values,frame}: (T.Position{[30:U32^2n],frame},(aux,O.QueryRow{handle,T.PositionView{T.Four{30,30,30,30},frame},None{},flag}))'
  else:raise AssertionError(label)
  s=s[:start]+prefix+body+'\n'+s[end:]
 file.write_text(s);return location
tool_paths={'compiler':pathlib.Path(shutil.which('bend')).resolve(),'Base':pathlib.Path.home()/'.bend/bend2/base.bend'}
toolchain={n:{'path':str(p),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()} for n,p in tool_paths.items()}
r={'scope':'indexed candidate actual audited closed A/B + Host.query rank-2 providers; static controls only', 'overlay':str(OVERLAY),'overlay_manifest_sha256':hashlib.sha256(manifest_path.read_bytes()).hexdigest(),'overlay_baseline':manifest['baseline'],'candidate_overrides':{n:hashlib.sha256((OVERLAY/n).read_bytes()).hexdigest() for n in manifest['overrides']},'checker_limit_seconds':5,'cpu_affinity':[args.cpu],'source_revision':subprocess.check_output(['git','rev-parse','HEAD'],cwd=HERE,text=True).strip(),'compiler':subprocess.check_output(['bend','version'],text=True).strip(),'toolchain':toolchain,'runner_sha256':hashlib.sha256(pathlib.Path(__file__).read_bytes()).hexdigest(),'hashes':{n:hashlib.sha256(p.read_bytes()).hexdigest() for n,p in files.items()},'cases':{}}
with tempfile.TemporaryDirectory(prefix='integrated-access-') as d:
 for label in ['positive','undeclared_token','cross_schema','write_through_read','reconstruct_owner','invalid_owner_return','audit_copy_text_historical','audit_copy','irrecoverable_destructure']:
  folder=pathlib.Path(d)/label;folder.mkdir()
  for n,p in files.items():(folder/n).write_bytes(p.read_bytes())
  location=None if label=='positive' else mutate(folder,label)
  result=check(folder/ENTRY)
  if label=='positive':assert result['exit']==0 and 'ALL PROOFS CHECK' in result['output'],result
  else:
   assert result['exit']==1 and 'SOME PROOFS FAIL' in result['output'],result
   assert 'Location: '+location in result['output'],result
   # Pin intended actual boundary; no parser/import/TODO/timeouts accepted.
   patterns={'undeclared_token':['expected : T.PositionToken','T.VelocityToken{}'],'cross_schema':['expected : T.PositionToken','T.VitalsToken{}'],'write_through_read':['expected : CC.Cache<T.Position, T.PositionView>','observed : Owner'],'reconstruct_owner':['expected : Owner','observed : CC.Cache<T.Position, T.PositionView>','CP.position_new(T.Position{'],'invalid_owner_return':['expected : Owner','observed : Aux'],'audit_copy_text_historical':['expected : text','observed : text (consumed more than once)'],'audit_copy':['expected : audit','observed : audit (consumed more than once)'],'irrecoverable_destructure':['expected : a datatype','observed : Owner','T.Position{']}
   for pattern in patterns[label]:assert pattern in result['output'],result
   result['intended_diagnostics']=patterns[label]
   result['mutation_file']=('systems.bend' if label in ['undeclared_token','cross_schema'] else 'audited-invoker.bend' if label in ['audit_copy','audit_copy_text_historical'] else ENTRY)
   result['mutated_source_sha256']=hashlib.sha256((folder/result['mutation_file']).read_bytes()).hexdigest()
  result['classification']='historical non-owner String duplication witness' if label=='audit_copy_text_historical' else 'intended actual affine Audit owner duplication' if label=='audit_copy' else 'original actual provider boundary control'
  r['cases'][label]=result
args.evidence.write_text(json.dumps(r,indent=2)+'\n')
print('INDEXED ACCESS STATIC CONTROLS PASS')
