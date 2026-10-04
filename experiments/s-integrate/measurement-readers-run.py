#!/usr/bin/env python3
"""Complete actual Host reader observations before any timing."""
import hashlib,importlib.util,json,pathlib,os,shutil,sys,tempfile
HERE=pathlib.Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parent/'t05'));from run import build,execute,command
spec=importlib.util.spec_from_file_location('life',HERE/'measurement-lifecycle-run.py');L=importlib.util.module_from_spec(spec);spec.loader.exec_module(L)
B=L.B;ENTRY='measurement-readers.bend';files={};B.closure(HERE/ENTRY,files)
def validate(text,schema,n,ref):
 lines=[json.loads(x) for x in text.splitlines()];assert len(lines)==234,len(lines)
 reads=[x for x in lines if x.get('kind')=='Read'];done=[x for x in lines if x.get('kind')=='ReadDone'];reserved=[x for x in lines if x.get('kind')=='Reserved'];assert len(reads)==len(done)==84 and len(reserved)==64
 initial=[{'handle':{'namespace':1,'id':j+1},'main':B.payload(schema,j,0),'aux':B.auxiliary(schema) if j%3==0 else None,'flag':{'group':8} if j%3==1 else None} for j in range(n)]
 seen={'Fast':0,'Slow':0};prior={'Fast':0,'Slow':0};fields=0
 for x,d,a,diag in zip(reads,done,ref['audit'],ref['diagnostics']):
  i=a['iteration'];rows=initial+([{'handle':{'namespace':1,'id':n+i+1},'main':B.payload(schema,i,1),'aux':None,'flag':None}] if a['phase']=='read' else [])
  who=a['who'];seen[who]+=1;tick=diag['tick']-1
  want={'kind':'Read','step':'','system':who,'count':seen[who],'boundary':{'since':prior[who],'streamSince':prior[who],'thisRun':tick},'query':rows,'added':[r for r in rows if r['handle']['id'] in a['added']],'changed':[r for r in rows if r['handle']['id'] in a['changed']],'removed':[{'namespace':1,'id':v} for v in a['removed']],'despawned':[{'namespace':1,'id':v} for v in a['despawned']],'messages':a['messages'],'messageLag':False,'removedLag':False,'despawnedLag':False}
  assert x==want,(who,i,'full Read mismatch',[(k,x[k],v) for k,v in want.items() if x.get(k)!=v][:1])
  expected_done={'kind':'ReadDone','step':'','system':who,'frame':diag['frame'],'tick':tick,'outcome':{'kind':'Success'},'messageLag':False,'removedLag':False,'despawnedLag':False};assert d==expected_done,(who,i,'ReadDone mismatch')
  normalized=L.norm([{'id':r['handle']['id'],**{k:v for k,v in r.items() if k!='handle'}} for r in rows],schema);assert L.digest(normalized)==a['rowsSha256'],(who,i,'TS full-row digest')
  prior[who]=tick;fields+=len(rows)+len(want['added'])+len(want['changed'])
 for i,x in enumerate(reserved):assert x=={'kind':'Reserved','step':'','worldName':schema.lower(),'label':'pending','handle':{'namespace':1,'id':n+i+1},'components':{'main':B.payload(schema,i,0),'aux':None,'flag':None}},('reservation',i)
 rows=[{'id':r['handle']['id'],**{k:v for k,v in r.items() if k!='handle'},'added':1,'changed':1} for r in initial]
 want={'phase':'final','observation':{'iteration':64,'pending':{'namespace':1,'id':n+64},'target':{'namespace':1,'id':n+64},'foreign':{'namespace':2,'id':1},'lookups':L.four(0,0,0,0),'world':{'namespace':1,'next':n+65,'rows':rows,'pending':[],'ledger':{'totals':L.four(0,101,102,103),'epoch':4},'mode':schema+'On'}}};want['observation']['query']=initial;assert lines[-2]==want,'final full world'
 assert L.digest(B.normalized(want['observation'],schema))==ref['finalSha256'],'final TS digest'
 summary={'counts':[{'system':s,'value':L.four(v,0,0,0)} for s,v in [('Slow',18),('Fast',66),('Update',64),('Dispose',64),('Reserve',64)]],'tick':469,'frames':195};assert lines[-1]==summary,lines[-1]
 return {'status':'PASS','fullReadObservations':84,'actualReaderDiagnostics':84,'fullRowsCompared':fields,'actualReservations':64,'clockNormalization':'Bend tick = TS tick - 1; seed performed before dispatcher; every callback checked','finalSha256':ref['finalSha256'],'summary':summary}
frozen={n:p.read_bytes() for n,p in files.items()}
def copy(folder):
 folder.mkdir()
 for n,value in frozen.items():(folder/n).write_bytes(value)
def main():
 os.sched_setaffinity(0,{10})
 evidence={'scope':'actual dispatched Type update and Host retained Fast/Slow reads; correctness only, no timing acceptance','limits':{'checker':5,'runtime':5,'codegen':30,'clang':120},'sources':{n:hashlib.sha256(value).hexdigest() for n,value in frozen.items()},'runnerSha256':hashlib.sha256(pathlib.Path(__file__).read_bytes()).hexdigest(),'cpuAffinity':sorted(os.sched_getaffinity(0)),'compiler':command(['bend','version']).strip(),'node':command(['node','--version']).strip(),'compilerSha256':hashlib.sha256(pathlib.Path(shutil.which('bend')).resolve().read_bytes()).hexdigest(),'baseSha256':hashlib.sha256((pathlib.Path.home()/'.bend/bend2/base.bend').read_bytes()).hexdigest(),'referenceAdapterSha256':hashlib.sha256((HERE/'measurement-reference.mjs').read_bytes()).hexdigest(),'measurementContractSha256':hashlib.sha256((HERE.parent.parent/'docs/design/s-integrate-measurement.md').read_bytes()).hexdigest(),'cases':[],'mutants':[]}
 with tempfile.TemporaryDirectory(prefix='measurement-readers-') as tmp:
  root=pathlib.Path(tmp);original=root/'original';copy(original);programs=build(original/ENTRY,original)
  for schema,num in [('Motion',0),('Health',1)]:
   for n in [64,256,1024]:
    ref=json.loads(command(['node',HERE/'measurement-reference.mjs',schema,'readers',str(n)]));case={'schema':schema,'count':n,'freshReference':ref['status'],'backends':{}}
    for program in programs:
     backend='JS' if program.suffix=='.js' else 'Native'
     try:case['backends'][backend]=validate(execute(program,[str(num),str(n)]),schema,n,ref)
     except (RuntimeError,AssertionError,json.JSONDecodeError) as e:case['backends'][backend]={'status':'FAILED','error':str(e)}
    evidence['cases'].append(case);(HERE/'measurement-readers-evidence.json').write_text(json.dumps(evidence,indent=2)+'\n');print(schema,n,{k:v['status'] for k,v in case['backends'].items()},flush=True)
  source=(original/ENTRY).read_text()
  for name,old,new in [('no-main-change','U32.add(M.first(values),1)','M.first(values)'),('slow-every-iteration','U32.is_eq(U32.mod(i,4),3)','True{}')]:
   try:
    folder=root/name;copy(folder);assert source.count(old)==2;entry=folder/ENTRY;entry.write_text(source.replace(old,new));bins=build(entry,folder);ref=json.loads(command(['node',HERE/'measurement-reference.mjs','Motion','readers','64']))
    for program in bins:
     text=execute(program,['0','64']);rejected=False
     try:validate(text,'Motion',64,ref)
     except AssertionError:rejected=True
     assert rejected,name
    evidence['mutants'].append({'name':name,'compiledNativeJs':True,'detectedBoth':True})
   except (RuntimeError,AssertionError,json.JSONDecodeError) as e:evidence['mutants'].append({'name':name,'status':'FAILED','error':str(e)})
   (HERE/'measurement-readers-evidence.json').write_text(json.dumps(evidence,indent=2)+'\n')
 evidence['status']='PASS' if all(v['status']=='PASS' for c in evidence['cases'] for v in c['backends'].values()) and all(m.get('detectedBoth',False) for m in evidence['mutants']) else 'REGRESSION'
 (HERE/'measurement-readers-evidence.json').write_text(json.dumps(evidence,indent=2)+'\n');print(evidence['status']);return int(evidence['status']!='PASS')
if __name__=='__main__':sys.exit(main())
