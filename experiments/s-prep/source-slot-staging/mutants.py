#!/usr/bin/env python3
"""Compile actual ingress/staging defects; require unchanged finite oracle disagreement."""
import argparse,hashlib,json,os,pathlib,shutil,signal,subprocess
from fixtures import expected
P=pathlib.Path;p=argparse.ArgumentParser();p.add_argument('--baseline',type=P,required=True);p.add_argument('--output',type=P,required=True);p.add_argument('--cpu',type=int,default=6);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=False)
def sha(b):return hashlib.sha256(b).hexdigest()
r={'status':'INCOMPLETE','baselineEvidenceSHA256':sha((a.baseline/'evidence.json').read_bytes()),'scope':'Four compiling reached source defects against complete finite Slot staging oracle; no universal mutation claim','commands':[],'subjects':{}}
b=json.loads((a.baseline/'evidence.json').read_text());assert b['status']=='PASS_BOUNDED_SLOT_STAGING';r['sourceManifest']=b['sourceManifest'];r['closureSHA256']=b['closureSHA256']
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def run(argv,limit,label):
 out=a.output/(label+'.txt');entry={'argv':list(map(str,argv)),'limitSeconds':limit,'log':out.name};r['commands'].append(entry);save();env=os.environ.copy();env['BENDVY_CLANG19_ROOT']='/tmp/bendvy-clang19-diagnostic/root'
 with out.open('w') as f:
  proc=subprocess.Popen(['taskset','-c',str(a.cpu),*map(str,argv)],stdout=f,stderr=subprocess.STDOUT,start_new_session=True,env=env)
  try:entry['exit']=proc.wait(timeout=limit)
  except subprocess.TimeoutExpired:os.killpg(proc.pid,signal.SIGKILL);proc.wait();entry['timeout']=True;save();raise
 assert entry['exit']==0,entry;entry['sha256']=sha(out.read_bytes());save();return out.read_text()
try:
 for defect in ['foreign-accepted','local-rejected','foreign-clears-pending','tx-drops-command']:
  stage=a.output/defect;stage.mkdir()
  for k,v in b['sourceManifest'].items():
   f=a.baseline/'core'/P(k).name;assert sha(f.read_bytes())==v;shutil.copyfile(f,stage/f.name)
  if defect=='tx-drops-command':
   file=stage/'transaction.bend';s=file.read_text();old='Tx{world,selected,undo,command <> commands,pings,marks}';new='Tx{world,selected,undo,commands,pings,marks}'
  else:
   file=stage/'commands.bend';s=file.read_text()
   if defect in ['foreign-accepted','local-rejected']:old='U32.is_eq(namespace,foreign)';new='True{}' if defect=='foreign-accepted' else 'False{}'
   else:
    anchor='def queue_checked(';assert s.count(anchor)==1
    helper='''def staging_mutant_drop_pending(-Schema: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,world: S.World<Schema,M,A,F,L,Mode>) -> S.World<Schema,M,A,F,L,Mode>:
  match world:
    case S.World{namespace,next,rows,pending,ledger,mode}: S.World{namespace,next,rows,[],ledger,mode}
'''
    s=s.replace(anchor,helper+anchor);old='T.CommandMissing{world,payload}';new='T.CommandMissing{staging_mutant_drop_pending(Schema,M,A,F,L,Mode,world),payload}'
  assert s.count(old)==1,(defect,s.count(old));file.write_text(s.replace(old,new));r['subjects'][defect]={'mutationFile':file.name,'mutationSHA256':sha(file.read_bytes()),'old':old,'new':new,'roles':{}};save()
  for schema in ['Motion','Health']:
   source=stage/(schema.lower()+'-runtime.bend');source.write_bytes((a.baseline/'core'/source.name).read_bytes());text=run(['bend',source,'--check-only'],15,defect+schema+'-check');assert 'ALL PROOFS CHECK' in text
   for backend in ['JS','Native']:
    dest=stage/(schema.lower()+('.js' if backend=='JS' else '.c'));run(['bend',source,'-o',dest],30,defect+schema+backend+'-emit')
    if backend=='Native':run(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',dest,'-o',stage/(schema.lower()+'-native'),'-lm','-pthread'],120,defect+schema+'-clang')
    argv=['node',dest] if backend=='JS' else [stage/(schema.lower()+'-native'),'--threads','1','--gpu','off'];text=run(argv,5,defect+schema+backend+'-run');assert text!=expected(schema),(defect,schema,backend,'defect undetected')
    if defect=='foreign-accepted':assert 'BAD_QUEUED' in text
    elif defect=='local-rejected':assert 'BAD_SEED_MISSING' in text
    elif defect=='foreign-clears-pending':assert 'False|' in text
    elif defect=='tx-drops-command':assert 'tx:|pings:81,82,' in text
    r['subjects'][defect]['roles'][schema+backend]={'status':'COMPILES_AND_DETECTED','fixtureSHA256':sha(source.read_bytes()),'expectedSHA256':sha(expected(schema).encode()),'outputSHA256':sha(text.encode())};save()
 r['status']='FOUR_REACHED_COMPILING_SLOT_DEFECTS_ALL_FOUR_ROLES_DETECTED';save()
except BaseException as e:r['error']=repr(e);save();raise
