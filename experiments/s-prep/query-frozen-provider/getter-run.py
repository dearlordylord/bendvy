#!/usr/bin/env python3
"""Finite actual query/command lifecycle; never a benchmark or full Host gate."""
import argparse,atexit,hashlib,json,os,pathlib,signal,subprocess,tempfile
HERE=pathlib.Path(__file__).resolve().parent
ROOT=HERE.parents[2]
p=argparse.ArgumentParser();p.add_argument('--candidate-root',type=pathlib.Path,default=ROOT/'experiments/fivehour-candidate');p.add_argument('--output',type=pathlib.Path,default=HERE/'getter-evidence.json');a=p.parse_args()
CPU=os.environ.get('BENDVY_CPU','11')
receipt={'status':'INCOMPLETE','scope':'Finite actual Q.each/Q.lookup and public C queue/apply lifecycle; not full22 gates, authority proof or performance acceptance','commands':[],'subjects':{},'sourceSHA256':{}}
atexit.register(lambda:a.output.write_text(json.dumps(receipt,indent=2)+'\n'))
def run(args,limit=5):
 if "--check-only" in list(map(str,args)):
  limit=int(os.environ.get("BENDVY_CHECKER_SECONDS","5"));assert limit in (5,15)
 receipt['commands'].append({'argv':list(map(str,args)),'limitSeconds':limit})
 child=subprocess.Popen(list(map(str,args)),stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True,start_new_session=True)
 try:out,err=child.communicate(timeout=limit)
 except subprocess.TimeoutExpired:
  os.killpg(child.pid,signal.SIGKILL);child.communicate();receipt['failure']={'argv':list(map(str,args)),'limitSeconds':limit,'status':'TIMEOUT'};raise
 if child.returncode:
  receipt['failure']={'argv':list(map(str,args)),'exit':child.returncode,'out':out,'err':err};raise RuntimeError(receipt['failure'])
 return out+err
assert 'bend 2.0.35' in run(['bend','version']);run(['bend','guide'])
fixture=(HERE/'getter-control.bend').read_text();literal=(HERE/'getter-expected.txt').read_text()
with tempfile.TemporaryDirectory(prefix='primitive-query-') as directory:
 tmp=pathlib.Path(directory)
 for backend in ['JS','Native']:
  frozen={f.name:f.read_bytes() for f in (a.candidate_root/backend/'experiments/s-integrate').glob('*.bend')}
  receipt['sourceSHA256'][backend]={n:hashlib.sha256(v).hexdigest() for n,v in frozen.items()}
  for schema in ['one','two']:
   stage=tmp/(backend+'-'+schema);stage.mkdir()
   for n,v in frozen.items():(stage/n).write_bytes(v)
   owners=(ROOT/'experiments/s-prep/primitive-storage-integration/owners.bend').read_text()
   owners='import Base\n\n'+owners[owners.index('type Motion is Type:'):owners.index('def snap_leaf(')]
   (stage/'owners.bend').write_text(owners)
   receipt['fixtureOwnersSHA256']=hashlib.sha256(owners.encode()).hexdigest()
   source=fixture;expected=literal
   if schema=='two':
    source=source.replace('QuerySchemaOne','QuerySchemaTwo').replace('A.Motion','A.TEMP').replace('A.Health','A.Motion').replace('A.TEMP','A.Health')
    source=source.replace('motion_','TEMP_').replace('health_','motion_').replace('TEMP_','health_')
    source=source.replace('make_motion','make_TEMP').replace('make_health','make_motion').replace('make_TEMP','make_health')
    source=source.replace('S.World{7,','S.World{9,').replace('S.Handle{7,','S.Handle{9,').replace('S.Handle{8,','S.Handle{10,')
    expected=expected.replace('7:','9:')
   subject=backend+'-'+schema;(stage/'getter-control.bend').write_text(source)
   receipt['subjects'][subject]={'status':'INCOMPLETE','fixtureSHA256':hashlib.sha256(source.encode()).hexdigest(),'expectedSHA256':hashlib.sha256(expected.encode()).hexdigest()}
   def command(args,limit=5):return run(['taskset','-c',CPU,*args],limit)
   def build(label):
    f=stage/'getter-control.bend';assert 'ALL PROOFS CHECK' in command(['bend',f,'--check-only'])
    if backend=='JS':
     js=stage/(label+'.js');command(['bend',f,'-o',js],30);return command(['node',js])
    c=stage/(label+'.c');binary=stage/label
    command(['bend',f,'-o',c],30);command(['clang','-O3',c,'-o',binary,'-lm','-pthread'],120);return command([binary,'--threads','1','--gpu','off'])
   original=build('original');assert original==expected,(subject,original,expected)
   query=(stage/'query.bend').read_text()
   needle='List.reverse(&2,O,values)';assert query.count(needle)==2
   mutations={'query-order':query.replace(needle,'values'), 'flag-membership':query.replace('case Present{} None{}: False{}','case Present{} None{}: True{}')}
   assert query.count('case Present{} None{}: False{}')==1
   witnesses={}
   for name,changed in mutations.items():
    (stage/'query.bend').write_text(changed)
    observed=build(name);assert observed!=expected,(subject,name,'mutant survived literal oracle')
    actual_lines=observed.splitlines();expected_lines=expected.splitlines()
    assert len(actual_lines)==len(expected_lines)==40,'Mutation dropped checkpoints'
    assert [x.split(':',1)[0] for x in actual_lines]==[x.split(':',1)[0] for x in expected_lines],'Mutation reordered checkpoint labels'
    label='initial-required' if name=='query-order' else 'initial-present'
    at=next(i for i,x in enumerate(expected_lines) if x.startswith(label+':'))
    namespace='7' if schema=='one' else '9'
    if name=='query-order':assert actual_lines[at].startswith(label+':'+namespace+':3|'),actual_lines[at]
    else:assert namespace+':3|30:30,31,32,33|none|absent;' in actual_lines[at],actual_lines[at]
    witnesses[name]={'checkpoint':label,'expected':expected_lines[at],'actual':actual_lines[at],'outputSHA256':hashlib.sha256(observed.encode()).hexdigest()}
   (stage/'query.bend').write_text(query)
   receipt['subjects'][subject].update({'status':'PASS','literalObservations':len(expected.splitlines()),'originalSHA256':hashlib.sha256(original.encode()).hexdigest(),'mutants':['query-order','flag-membership'],'witnesses':witnesses})
receipt['status']='FINITE_QUERY_COMMAND_LIFECYCLE_AND_TWO_COMPILING_MUTANTS_PASS'
print(receipt['status'])
