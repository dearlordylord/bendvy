#!/usr/bin/env python3
"""Diagnostic: same lifecycle calls, full-field checksum encoding instead of JSON rows.
Passing this control never substitutes for the full-field trace gate.
"""
import hashlib,importlib.util,json,os,pathlib,sys,tempfile,time
HERE=pathlib.Path(__file__).resolve().parent
s=importlib.util.spec_from_file_location('life',HERE/'measurement-lifecycle-run.py');L=importlib.util.module_from_spec(s);s.loader.exec_module(L)
B=L.B;build=L.build;execute=L.execute;command=L.command
files={};B.closure(HERE/'measurement-lifecycle.bend',files);B.closure(HERE/'measurement-compact.bend',files);frozen={n:p.read_bytes() for n,p in files.items()}
def mix(a,b):return (a*65599+b)%2**32
def fold(values,seed=1):
 for x in values:seed=mix(seed,x)
 return seed
def xs(v):return list(v.values())
def mainhash(v):
 if v is None:return 0
 return fold(xs(v['coordinates'])+[v['frame']]) if 'coordinates' in v else fold(xs(v['levels'])+[v['reserve'],v['class']])
def maybemain(v):return 0 if v is None else mix(1,mainhash(v))
def auxhash(v):return 0 if v is None else fold(xs(v['rates'])+[int(v['moving'])]) if 'rates' in v else fold(xs(v['layers'])+[v['grade']])
def flaghash(v):return 0 if v is None else mix(1,v['group'])
def queryhash(rows):return mix(fold([fold([r['handle']['namespace'],r['handle']['id'],mainhash(r['main']),auxhash(r['aux']),flaghash(r['flag'])]) for r in rows]),0)
def worldhash(w):
 rows=mix(fold([fold([r['id'],maybemain(r['main']),auxhash(r['aux']),flaghash(r['flag']),r['added'],r['changed']]) for r in w['rows']]),0)
 pending=[]
 for p in w['pending']:
  assert p['kind']=='SpawnView';b=p['bundle'];pending.append(fold([p['id'],fold([maybemain(b['main']),auxhash(b['aux']),flaghash(b['flag'])])]))
 resource=0 if w['ledger'] is None else fold(xs(w['ledger']['totals'])+[w['ledger']['epoch']])
 return fold([w['namespace'],w['next'],rows,mix(fold(pending),0),resource,1])
def validate(text,schema,n,ref):
 lines=[json.loads(v) for v in text.splitlines()];assert len(lines)==193
 expected={j+1:{'id':j+1,'main':B.payload(schema,j,0),'aux':B.auxiliary(schema) if j%3==0 else None,'flag':{'group':8} if j%3==1 else None,'added':1,'changed':1} for j in range(n)}
 for i in range(64):
  keys=sorted(expected);target=keys[0 if i%3==0 else len(keys)//2 if i%3==1 else -1];new=n+i+1
  for k,phase in enumerate(['pending','live','disposed']):
   if phase=='live':expected[new]={'id':new,'main':B.payload(schema,i,0),'aux':None,'flag':None,'added':3+4*i,'changed':3+4*i}
   if phase=='disposed':del expected[target]
   rows=[expected[j] for j in sorted(expected)];q=[{'handle':{'namespace':1,'id':r['id']},'main':r['main'],'aux':r['aux'],'flag':r['flag']} for r in rows]
   w={'namespace':1,'next':new+1,'rows':rows,'pending':[{'kind':'SpawnView','id':new,'bundle':{'main':B.payload(schema,i,0),'aux':None,'flag':None}}] if phase=='pending' else [],'ledger':{'totals':L.four(0,101,102,103),'epoch':4},'mode':schema+'On'}
   want={'phase':phase,'observation':{'iteration':i,'pending':{'namespace':1,'id':new},'target':{'namespace':1,'id':target},'foreign':{'namespace':2,'id':1},'lookups':L.four(0 if phase=='pending' else 2,0 if phase=='disposed' else 2,0,0),'query':queryhash(q),'world':worldhash(w)}}
   assert lines[3*i+k]==want,(i,phase,'compact mismatch');assert L.digest(L.norm(rows,schema))==ref['audit'][3*i+k]['sha256']
 assert lines[-1]=={'counts':[{'system':'Dispose','value':L.four(64,0,0,0)},{'system':'Reserve','value':L.four(64,0,0,0)}],'tick':257,'frames':193}
 return {'status':'PASS','compactBoundaries':192,'outputBytes':len(text.encode()),'claim':'supplementary finite full-field checksum only; no full-trace or performance acceptance'}
def main():
 os.sched_setaffinity(0,{10})
 e={'scope':'encoding-cost diagnostic; same lifecycle dispatcher/query/lookup/O.world operations; checksums collide and cannot replace full-field validation','cpuAffinity':sorted(os.sched_getaffinity(0)),'runtimeLimit':5,'sourceHashes':{n:hashlib.sha256(b).hexdigest() for n,b in frozen.items()},'runnerSha256':hashlib.sha256(pathlib.Path(__file__).read_bytes()).hexdigest(),'cases':[]}
 with tempfile.TemporaryDirectory(prefix='measurement-compact-') as tmp:
  root=pathlib.Path(tmp)
  for n,b in frozen.items():(root/n).write_bytes(b)
  p=root/'measurement-lifecycle.bend';text=p.read_text();text='import ./measurement-compact.bend as Compact\n'+text
  for sc,ma,ax,fl,mode,rv,ra,rf in [('Motion','PositionView','VelocityView','Selected','MotionMode','position','velocity','selected'),('Health','VitalsView','ArmorView','Tracked','HealthMode','vitals','armor','tracked')]:
   old=f'J.render_list(O.QueryRow<T.{sc}Schema,T.{ma},T.{ax},T.{fl}>,J.render_query(T.{sc}Schema,T.{ma},T.{ax},T.{fl},J.render_{rv},J.render_{ra},J.render_{rf}),query)';assert text.count(old)==1;text=text.replace(old,f'U32.show(Compact.{sc.lower()}_query(query,1))')
   old=f'J.render_world(T.{ma},T.{ax},T.{fl},J.render_{rv},J.render_{ra},J.render_{rf},T.LedgerView,T.{mode},J.render_ledger,J.render_{sc.lower()}_mode,view)';assert text.count(old)==1;text=text.replace(old,f'U32.show(Compact.{sc.lower()}_world(view))')
  p.write_text(text);e['diagnosticEntrySha256']=hashlib.sha256(p.read_bytes()).hexdigest();programs=build(p,root)
  for schema,num in [('Motion',0),('Health',1)]:
   for n in [64,256,1024]:
    ref=json.loads(command(['node',HERE/'measurement-reference.mjs',schema,'lifecycle',str(n)]));c={'schema':schema,'count':n,'backends':{}}
    for program in programs:
     backend='JS' if program.suffix=='.js' else 'Native'
     try:
      started=time.perf_counter();output=execute(program,[str(num),str(n)]);elapsed=time.perf_counter()-started
      c['backends'][backend]={**validate(output,schema,n,ref),'wholeProcessSeconds':elapsed}
     except (RuntimeError,AssertionError,json.JSONDecodeError) as ex:c['backends'][backend]={'status':'FAILED','error':str(ex)}
    e['cases'].append(c);print(schema,n,{k:v['status'] for k,v in c['backends'].items()},flush=True)
    (HERE/'measurement-compact-evidence.json').write_text(json.dumps(e,indent=2)+'\n')
 e['status']='PASS' if all(v['status']=='PASS' for c in e['cases'] for v in c['backends'].values()) else 'REGRESSION';(HERE/'measurement-compact-evidence.json').write_text(json.dumps(e,indent=2)+'\n');return int(e['status']!='PASS')
if __name__=='__main__':sys.exit(main())
