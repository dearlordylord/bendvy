#!/usr/bin/env python3
import hashlib,importlib.util,json,pathlib,os,shutil,re,sys,tempfile
HERE=pathlib.Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parent/'t05'));from run import build,execute,command
spec=importlib.util.spec_from_file_location('base_measurement',HERE/'measurement-bend-run.py');B=importlib.util.module_from_spec(spec);spec.loader.exec_module(B)
ENTRY='measurement-lifecycle.bend'
files={};B.closure(HERE/ENTRY,files)
def four(a,b,c,d):return dict(zip('abcd',[a,b,c,d]))
def norm(rows,schema):return B.normalized({'world':{'rows':rows,'ledger':{'totals':four(0,101,102,103),'epoch':4}}},schema)['rows']
def digest(v):return hashlib.sha256(json.dumps(v,separators=(',',':')).encode()).hexdigest()
def validate(text,schema,n,reference):
 lines=[json.loads(x) for x in text.splitlines()];assert len(lines)==193,len(lines)
 expected={j+1:{'id':j+1,'main':B.payload(schema,j,0),'aux':B.auxiliary(schema) if j%3==0 else None,'flag':{'group':8} if j%3==1 else None,'added':1,'changed':1} for j in range(n)}
 for i in range(64):
  keys=sorted(expected);target=keys[0 if i%3==0 else len(keys)//2 if i%3==1 else -1];new=n+i+1
  for offset,phase in enumerate(['pending','live','disposed']):
   if phase=='live':expected[new]={'id':new,'main':B.payload(schema,i,0),'aux':None,'flag':None,'added':3+4*i,'changed':3+4*i}
   if phase=='disposed':del expected[target]
   rows=[expected[k] for k in sorted(expected)]
   want={'phase':phase,'observation':{'iteration':i,'pending':{'namespace':1,'id':new},'target':{'namespace':1,'id':target},'foreign':{'namespace':2,'id':1},'lookups':four(0 if phase=='pending' else 2,0 if phase=='disposed' else 2,0,0),
    'world':{'namespace':1,'next':new+1,'rows':rows,'pending':[{'kind':'SpawnView','id':new,'bundle':{'main':B.payload(schema,i,0),'aux':None,'flag':None}}] if phase=='pending' else [],'ledger':{'totals':four(0,101,102,103),'epoch':4},'mode':schema+'On'}}}
   want['observation']['query']=[{'handle':{'namespace':1,'id':r['id']},'main':r['main'],'aux':r['aux'],'flag':r['flag']} for r in rows]
   assert lines[3*i+offset]==want,(i,phase,'complete checkpoint mismatch')
   normalized=norm(rows,schema);assert digest(normalized)==reference['audit'][3*i+offset]['sha256'],(i,phase,'fresh TS field digest')
 assert lines[-1]=={'counts':[{'system':'Dispose','value':four(64,0,0,0)},{'system':'Reserve','value':four(64,0,0,0)}],'tick':257,'frames':193},lines[-1]
 return {'status':'PASS','completeBoundaries':192,'allFieldComparisons':sum(len(x['observation']['world']['rows']) for x in lines[:-1]),'finalNormalizedSha256':digest(norm(rows,schema)),'summary':lines[-1]}
frozen={n:p.read_bytes() for n,p in files.items()}
def copy(folder):
 folder.mkdir()
 for n,value in frozen.items():(folder/n).write_bytes(value)
def main():
 os.sched_setaffinity(0,{10})
 evidence={'scope':'actual dispatched lifecycle workload, full streamed correctness observations; no comparative timing','limits':{'checker':5,'runtime':5,'codegen':30,'clang':120},'sources':{n:hashlib.sha256(value).hexdigest() for n,value in frozen.items()},'runnerSha256':hashlib.sha256(pathlib.Path(__file__).read_bytes()).hexdigest(),'cpuAffinity':sorted(os.sched_getaffinity(0)),'compiler':command(['bend','version']).strip(),'node':command(['node','--version']).strip(),'compilerSha256':hashlib.sha256(pathlib.Path(shutil.which('bend')).resolve().read_bytes()).hexdigest(),'baseSha256':hashlib.sha256((pathlib.Path.home()/'.bend/bend2/base.bend').read_bytes()).hexdigest(),'referenceAdapterSha256':hashlib.sha256((HERE/'measurement-reference.mjs').read_bytes()).hexdigest(),'measurementContractSha256':hashlib.sha256((HERE.parent.parent/'docs/design/s-integrate-measurement.md').read_bytes()).hexdigest(),'cases':[],'mutants':[]}
 if '--mutants-only' in sys.argv:
  prior_path=HERE/'measurement-lifecycle-query-first-evidence.json';prior=json.loads(prior_path.read_text());assert prior['sources']==evidence['sources'],'resume source mismatch'
  evidence['cases']=prior['cases'];evidence['caseEvidence']={'file':prior_path.name,'sha256':hashlib.sha256(prior_path.read_bytes()).hexdigest(),'runnerSha256':prior['runnerSha256'],'note':'unchanged source cases retained; only mutation gates replayed without overlapping CPU10 work'}
 with tempfile.TemporaryDirectory(prefix='measurement-life-') as tmp:
  root=pathlib.Path(tmp);original=root/'original';copy(original);programs=[] if '--mutants-only' in sys.argv else build(original/ENTRY,original)
  for schema,num in ([] if '--mutants-only' in sys.argv else [('Motion',0),('Health',1)]):
   for n in [64,256,1024]:
    ref=json.loads(command(['node',HERE/'measurement-reference.mjs',schema,'lifecycle',str(n)]));case={'schema':schema,'count':n,'freshReference':ref['status'],'backends':{}}
    for program in programs:
     backend='JS' if program.suffix=='.js' else 'Native'
     try:case['backends'][backend]=validate(execute(program,[str(num),str(n)]),schema,n,ref)
     except (RuntimeError,AssertionError,json.JSONDecodeError) as e:case['backends'][backend]={'status':'FAILED','error':str(e)}
    evidence['cases'].append(case);(HERE/'measurement-lifecycle-evidence.json').write_text(json.dumps(evidence,indent=2)+'\n');print(schema,n,{k:v['status'] for k,v in case['backends'].items()},flush=True)
  source=(original/ENTRY).read_text()
  for name,old,new in [('head-only-target','case 1: U32.div(count,2)','case 1: 0'),('omit-disposal','motion_dispose_host(host,target)','host')]:
   try:
    folder=root/name;copy(folder);assert source.count(old)==1;entry=folder/ENTRY;entry.write_text(source.replace(old,new));bins=build(entry,folder);ref=json.loads(command(['node',HERE/'measurement-reference.mjs','Motion','lifecycle','64']))
    for program in bins:
     text=execute(program,['0','64']);rejected=False
     try:validate(text,'Motion',64,ref)
     except AssertionError:rejected=True
     assert rejected,name
    evidence['mutants'].append({'name':name,'compiledNativeJs':True,'detectedBoth':True})
   except (RuntimeError,AssertionError,json.JSONDecodeError) as e:evidence['mutants'].append({'name':name,'status':'FAILED','error':str(e)})
   (HERE/'measurement-lifecycle-evidence.json').write_text(json.dumps(evidence,indent=2)+'\n')
 evidence['status']='PASS' if all(v['status']=='PASS' for c in evidence['cases'] for v in c['backends'].values()) and all(m.get('detectedBoth',False) for m in evidence['mutants']) else 'REGRESSION'
 (HERE/'measurement-lifecycle-evidence.json').write_text(json.dumps(evidence,indent=2)+'\n');print(evidence['status']);return int(evidence['status']!='PASS')
if __name__=='__main__':sys.exit(main())
