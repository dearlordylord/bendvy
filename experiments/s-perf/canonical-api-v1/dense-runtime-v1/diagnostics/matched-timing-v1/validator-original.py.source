#!/usr/bin/env python3
"""Actual D.tick/Host/opaque callbacks/one Tx Dense+Sparse; bounded diagnostics."""
import hashlib,json,pathlib,re,shutil,sys,tempfile,os
HERE=pathlib.Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parent/'t05'))
from run import build,execute,command,CHECK
ENTRY='measurement-bend.bend'
def digest(b):return hashlib.sha256(b).hexdigest()
def closure(p,seen):
 if p.name in seen:return
 seen[p.name]=p
 for relative in re.findall(r'^import (\./\S+\.bend)',p.read_text(),re.M):closure((p.parent/relative).resolve(),seen)
files={};closure(HERE/ENTRY,files)
def four(xs):return dict(zip('abcd',xs))
def payload(schema,j,delta):return {'coordinates':four([j+delta,j+1,j+2,j+3]),'frame':7} if schema=='Motion' else {'levels':four([j+delta,j+1,j+2,j+3]),'reserve':9,'class':2}
def auxiliary(schema):return {'rates':four([1,2,3,4]),'moving':True} if schema=='Motion' else {'layers':four([1,2,3,4]),'grade':3}
def expected(schema,sparse,n):
 rows=[];selected=[j for j in range(n) if not sparse or j%8==0]
 for j in range(n):
  yes=j in selected
  rows.append({'id':j+1,'main':payload(schema,j,64) if yes else None,'aux':auxiliary(schema) if j%3==0 else None,'flag':{'group':8} if j%3==1 else None,'added':1 if yes else 0,'changed':65 if yes else 0})
 total=sum(4*j+6+i for i in range(64) for j in selected)
 if sparse:
  for i in range(64):
   for weight,group in zip([1,3,5],(selected,[j for j in selected if j%3==0],[j for j in selected if j%3!=0])):
    total+=weight*(len(group)+1)
    for rank,j in enumerate(group,1):
     value=1+j+1+(4*j+6+i+1)+(7 if schema=='Motion' else 11)
     if j%3==0:value+=12 if schema=='Motion' else 14
     if j%3==1:value+=9
     total+=weight*rank*value
 return {'readsum':total%2**32,'calls':64,'tick':65,'frames':65,'world':{'namespace':1,'next':n+1,'rows':rows,'pending':[],'ledger':{'totals':four([len(selected)*64,101,102,103]),'epoch':4},'mode':schema+'On'}}
def normalized(data,schema):
 def convert(x):
  if isinstance(x,dict):
   if list(x)==list('abcd'):return list(x.values())
   return {k:convert(v) for k,v in x.items()}
  if isinstance(x,list):return [convert(v) for v in x]
  return x
 return {'rows':[{'rawId':r['id'],'main':convert(r['main']),'aux':convert(r['aux']),'flag':r['flag']} for r in data['world']['rows'] if r['main'] is not None],'ledger':convert(data['world']['ledger'])}
def copied(folder):
 folder.mkdir()
 for name,p in files.items():(folder/name).write_bytes(p.read_bytes())
def validate(value,schema,sparse,n,ref):
 actual=json.loads(value);ms=actual.pop('milliseconds');assert actual==expected(schema,sparse,n),(schema,sparse,n,'full world/checksum/dispatch difference')
 normal=normalized(actual,schema);h=digest(json.dumps(normal,separators=(',',':')).encode());assert h==ref['finalSha256'],(h,ref['finalSha256'])
 return {'status':'PASS','milliseconds':ms,'fullRowsCompared':n,'selectedRowsCompared':len(normal['rows']),'normalizedFinalSha256':h,'worksum':actual['readsum'],'captures':actual['calls'],'tick':actual['tick'],'frames':actual['frames']}
def main():
 evidence={'scope':'Dense/Sparse actual dispatcher+Host+one SystemTx per iteration; finite correctness before single diagnostic timing; no performance acceptance',
  'limits':{'checker':5,'runtime':5,'codegen':30,'clang':120},'compiler':command(['bend','version']).strip(),'node':command(['node','--version']).strip(),
  'cpuAffinity':sorted(os.sched_getaffinity(0)),'nativeWorkers':1,'gpu':'off','iterations':64,'clock':'IO.now milliseconds; excludes setup/final dump',
  'compilerSha256':digest(pathlib.Path(shutil.which('bend')).resolve().read_bytes()),'baseSha256':digest((pathlib.Path.home()/'.bend/bend2/base.bend').read_bytes()),'buildHelperSha256':digest((HERE.parent/'t05/run.py').read_bytes()),'checkerWrapperSha256':digest(pathlib.Path(CHECK).read_bytes()),'sources':{n:digest(p.read_bytes()) for n,p in files.items()},'runnerSha256':digest(pathlib.Path(__file__).read_bytes()),
  'referenceAdapterSha256':digest((HERE/'measurement-reference.mjs').read_bytes()),'measurementContractSha256':digest((HERE.parent.parent/'docs/design/s-integrate-measurement.md').read_bytes()),'cases':[],'negatives':[],'mutants':[]}
 with tempfile.TemporaryDirectory(prefix='measurement-bend-') as temporary:
  root=pathlib.Path(temporary);folder=root/'original';copied(folder);programs=build(folder/ENTRY,folder)
  for schema,sn in [('Motion',0),('Health',1)]:
   for sparse in [False,True]:
    for n in [64,256,1024]:
     workload='sparse' if sparse else 'dense'
     ref=json.loads(command(['node',HERE/'measurement-reference.mjs',schema,workload,str(n)]))
     case={'schema':schema,'workload':workload,'count':n,'freshReference':ref['status'],'backends':{}}
     for binary in programs:
      backend='JS' if binary.suffix=='.js' else 'Native'
      try:
       correctness=validate(execute(binary,[str(sn),str(int(sparse)),str(n)]),schema,sparse,n,ref)
       # A fresh identical invocation is timed only after full correctness passes.
       diagnostic=validate(execute(binary,[str(sn),str(int(sparse)),str(n)]),schema,sparse,n,ref)
       case['backends'][backend]={**correctness,'diagnosticMilliseconds':diagnostic['milliseconds'],'timingSamples':1,'timingAcceptance':False}
      except (RuntimeError,AssertionError,json.JSONDecodeError) as error:case['backends'][backend]={'status':'FAILED','error':str(error)}
     evidence['cases'].append(case);print(schema,workload,n,{k:v['status'] for k,v in case['backends'].items()},flush=True)
  # Fresh affine provider boundary negatives; use the same checked concrete instantiation.
  text=(folder/ENTRY).read_text()
  negatives=[('wrong-token','get(owner,T.PositionToken{})','get(owner,T.VitalsToken{})',['expected : T.PositionToken','T.VitalsToken{}']),
   ('reconstruct-opaque-owner','get(owner,T.PositionToken{})','get(T.Position{[0:U32^2n],7},T.PositionToken{})',['expected : Owner','T.Position{'])]
  for name,old,new,patterns in negatives:
   dest=root/name;copied(dest);assert text.count(old)==1;source=dest/ENTRY;source.write_text(text.replace(old,new));out=command([CHECK,source,'--check-only'],expected=1)
   assert 'Location: motion_body' in out and all(p in out for p in patterns),out
   evidence['negatives'].append({'name':name,'status':'intended rejection','diagnostic':out})
  mutants=[('main-no-increment','U32.add(first(values),1)),T.MotionLedgerToken{}','first(values)),T.MotionLedgerToken{}'),
   ('ledger-no-increment','set(owner,T.MotionLedgerToken{},U32.add(first(values),1))','set(owner,T.MotionLedgerToken{},first(values))'),
   ('wrong-Aux-present-selection','case 1 O.QueryRow{_,_,aux,_}: motion_has_aux(aux)','case 1 O.QueryRow{_,_,aux,_}: Bool.not(motion_has_aux(aux))')]
  for name,old,new in mutants:
   dest=root/name;copied(dest);assert text.count(old)==1,(name,text.count(old));source=dest/ENTRY;source.write_text(text.replace(old,new));bins=build(source,dest)
   outcomes=[]
   for binary in bins:
    sparse=name=='wrong-Aux-present-selection'
    actual=json.loads(execute(binary,['0',str(int(sparse)),'64']));actual.pop('milliseconds');assert actual!=expected('Motion',sparse,64),name;outcomes.append('detected')
   evidence['mutants'].append({'name':name,'compiledNativeJs':True,'outcomes':outcomes})
 evidence['status']='PASS' if all(v['status']=='PASS' for c in evidence['cases'] for v in c['backends'].values()) else 'REGRESSION'
 (HERE/'measurement-bend-evidence.json').write_text(json.dumps(evidence,indent=2)+'\n')
 print(evidence['status']+'; not performance acceptance')
 return 0 if evidence['status']=='PASS' else 1
if __name__=='__main__':sys.exit(main())
