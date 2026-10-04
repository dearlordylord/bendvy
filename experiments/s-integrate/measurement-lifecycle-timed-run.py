#!/usr/bin/env python3
"""Exact public lifecycle: full traces first, then seven comparable timing samples."""
import hashlib,importlib.util,json,os,pathlib,statistics,sys,tempfile,shutil
HERE=pathlib.Path(__file__).resolve().parent
def module(name,file):
 s=importlib.util.spec_from_file_location(name,HERE/file);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
L=module('life','measurement-lifecycle-run.py');F=module('fields','measurement-fields-run.py');C=module('compact','measurement-compact-run.py');R=module('timing','measurement-samples-run.py');B=L.B
files={};B.closure(HERE/'measurement-lifecycle-timed.bend',files);frozen={n:p.read_bytes() for n,p in files.items()}
def expected(schema,n,backend):
 live={j+1:{'id':j+1,'main':B.payload(schema,j,0),'aux':B.auxiliary(schema) if j%3==0 else None,'flag':{'group':8} if j%3==1 else None,'added':1,'changed':1} for j in range(n)};stale=[];observations=[];digest=1
 for i in range(64):
  keys=sorted(live);target=keys[0 if i%3==0 else n//2 if i%3==1 else -1];fresh=n+i+1
  for phase in range(3):
   if phase==1:live[fresh]={'id':fresh,'main':B.payload(schema,i,0),'aux':None,'flag':None,'added':5+8*i,'changed':5+8*i}
   if phase==2:del live[target];stale.append(target)
   rows=[live[k] for k in sorted(live)];query=[{'handle':{'namespace':1,'id':r['id']},'main':r['main'],'aux':r['aux'],'flag':r['flag']} for r in rows]
   ledger={'totals':L.four(0,101,102,103),'epoch':4};lookups=L.four(0 if phase==0 else 2,0 if phase==2 else 2,2 if backend=='TS' and 1 in live else 0,0)
   seen=[[{'namespace':1,'id':j},0] for j in stale];value={'iteration':i,'phase':phase,'query':query,'ledger':ledger,'lookups':lookups,'stale':seen};observations.append(value)
   sh=C.mix(C.fold([C.fold([1,j,0]) for j in stale]),0)
   oh=C.fold([i,phase,C.queryhash(query),C.fold([0,101,102,103,4]),C.fold(list(lookups.values())),sh]);digest=C.mix(digest,oh)
 return observations,digest,rows,target

def decode_observation(x,schema):
 assert set(x)=={'iteration','phase','query','ledger','lookups','stale'}
 out=dict(x);q=[]
 for r in x['query']:
  assert len(r)==4 and len(r[0])==2
  q.append({'handle':dict(zip(['namespace','id'],r[0])),'main':F.decode_main(r[1],schema),'aux':F.decode_aux(r[2],schema),'flag':F.decode_flag(r[3])})
 out['query']=q
 # All literal enum/schema field names are protocol keys; payloads remain actual.
 F.strict_json(out);return out

def validate_one(lines,schema,n,backend,full,legacy):
 observations,digest,rows,target=expected(schema,n,backend)
 count=258 if backend=='TS' else 259
 assert len(lines)==(count if full else count-192),(len(lines),backend,full)
 if full:
  for i,(value,want) in enumerate(zip(lines[:192],observations)):
   assert decode_observation(value,schema)==want,(i,'full public observation')
   rs=[{'id':r['handle']['id'],'main':r['main'],'aux':r['aux'],'flag':r['flag']} for r in want['query']]
   assert L.digest(L.norm(rs,schema))==legacy['audit'][i]['sha256'],(i,'original frozen TS row digest')
  lines=lines[192:]
 header=lines[0];assert set(header)=={'milliseconds','digest','staleCount'} and header['digest']==digest and header['staleCount']==64,header
 assert type(header['milliseconds']) in [int,float] and header['milliseconds']>=0
 for i,x in enumerate(lines[1:65]):
  assert x=={'kind':'Reserved','step':'','worldName':schema.lower(),'label':'pending','handle':{'namespace':1,'id':n+i+1},'components':{'main':B.payload(schema,i,0),'aux':None,'flag':None}},('raw reservation',i)
 norm=L.norm(rows,schema);assert L.digest(norm)==legacy['finalSha256']
 if backend=='TS':
  x=lines[-1];assert x['finalRows']==norm and x['ledger']=={'totals':[0,101,102,103],'epoch':4} and x['captures']=={'Select':64,'Reserve':64,'Dispose':64,'Observe':192} and x['finalSha256']==legacy['finalSha256']
 else:
  want={'phase':'final','observation':{'iteration':64,'pending':{'namespace':1,'id':n+64},'target':{'namespace':1,'id':target},'foreign':{'namespace':2,'id':1},'lookups':L.four(2,0,0,0),'query':observations[-1]['query'],'world':{'namespace':1,'next':n+65,'rows':rows,'pending':[],'ledger':{'totals':L.four(0,101,102,103),'epoch':4},'mode':schema+'On'}}}
  assert lines[-2]==want,'full final owner/query'
  assert lines[-1]=={'counts':[{'system':s,'value':L.four(c,0,0,0)} for s,c in [('Observe',192),('Select',64),('Dispose',64),('Reserve',64)]],'tick':513,'frames':385},'actual capture/clock'
 return {'milliseconds':header['milliseconds'],'digest':digest,'staleLookups':sum(len(x['stale']) for x in observations),'fullBoundaryCount':192 if full else 0,'rawReservations':64,'finalSha256':legacy['finalSha256']}

def validate(text,schema,n,backend,full,legacy):
 lines=[json.loads(x) for x in text.splitlines()]
 if full:return validate_one(lines,schema,n,backend,True,legacy)
 width=66 if backend=='TS' else 67;assert len(lines)==2*width
 warmup=validate_one(lines[:width],schema,n,backend,False,legacy);sample=validate_one(lines[width:],schema,n,backend,False,legacy)
 assert sample['milliseconds']>0,'below timing resolution'
 return {**sample,'warmupMilliseconds':warmup['milliseconds']}

def copied(folder):
 folder.mkdir()
 for name,value in frozen.items():(folder/name).write_bytes(value)
 return folder/'measurement-lifecycle-timed.bend'
def child(args,folder):
 rss=folder/'rss.json'
 rss.unlink(missing_ok=True)
 meta,text=R.child([folder/'rss-launcher',rss,*args],folder)
 meta.pop('peakRssKiB',None)
 meta['backendCommand']=[str(x) for x in args]
 if meta['status']=='PASS':
  data=json.loads(rss.read_text());assert data['exitCode']==0
  meta['peakRssKiB']=data['childPeakRssKiB']
  meta['launcherPeakRssKiB']=data['launcherPeakRssKiB']
 return meta,text

def main():
 os.sched_setaffinity(0,{10})
 e={'scope':'exact public lifecycle work; full historical stale lookup coverage and complete fields before timing; intentional foreign TS collision/Bend Missing retained','cpuAffinity':sorted(os.sched_getaffinity(0)),'limits':{'checker':5,'runtime':5,'codegen':30,'clang':120},'iterations':64,'repetitions':7,'warmup':'one fresh identical world then one fresh measured world, same child','rss':'clean C exec launcher forks actual backend; launcher wait4 childPeakRssKiB; whole backend including warmup/setup/final output; outer Python peak excluded','timed':'Select+Reserve,Observe,Deferred,Observe,Dispose+Deferred,Observe; query/Ledger/three lookups/all historical stales; full-field ordered checksum; no JSON or O.world','compiler':L.command(['bend','version']).strip(),'node':L.command(['node','--version']).strip(),'sourceHashes':{n:hashlib.sha256(v).hexdigest() for n,v in frozen.items()},'runnerSha256':R.digest(pathlib.Path(__file__)),'referenceSha256':R.digest(HERE/'measurement-lifecycle-timing-reference.mjs'),'originalReferenceSha256':R.digest(HERE/'measurement-reference.mjs'),'contractSha256':R.digest(HERE/'measurement-lifecycle-timing-plan.md'),'compilerSha256':R.digest(pathlib.Path(shutil.which('bend')).resolve()),'baseSha256':R.digest(pathlib.Path.home()/'.bend/bend2/base.bend'),'clang':L.command(['clang','--version']).splitlines()[0],'buildHelperSha256':R.digest(pathlib.Path(L.B.__file__)),'launcherSha256':R.digest(HERE/'measurement-lifecycle-rss-launcher.c'),'priorWithdrawnEvidenceSha256':R.digest(HERE/'measurement-lifecycle-timed-first-evidence.json'),'cases':[],'mutants':[]}
 def save():(HERE/'measurement-lifecycle-timed-evidence.json').write_text(json.dumps(e,indent=2)+'\n')
 with tempfile.TemporaryDirectory(prefix='measurement-life-timed-') as tmp:
  root=pathlib.Path(tmp);L.command(['clang','-O2',HERE/'measurement-lifecycle-rss-launcher.c','-o',root/'rss-launcher'],timeout=120);entry=copied(root/'original');bins=L.build(entry,entry.parent)
  for schema,num in [('Motion',0),('Health',1)]:
   for n in [64,256,1024]:
    legacy=json.loads(L.command(['node',HERE/'measurement-reference.mjs',schema,'lifecycle',str(n)]));c={'schema':schema,'count':n,'full':{},'samples':{b:[] for b in ['Native','TS','JS']},'summary':{}};e['cases'].append(c)
    def args(backend,full):
     if backend=='TS':return ['node',HERE/'measurement-lifecycle-timing-reference.mjs',schema,str(n),str(int(full))]
     if backend=='JS':return ['node',bins[1],str(num),str(n),str(int(full))]
     return [bins[0],str(num),str(n),str(int(full)),'--threads','1','--gpu','off']
    for backend in ['Native','TS','JS']:
     meta,text=child(args(backend,True),root)
     if text is not None:
      try:meta.update(validate(text,schema,n,backend,True,legacy))
      except (AssertionError,TypeError,json.JSONDecodeError) as error:meta={'status':'FAILED','error':str(error),**{k:v for k,v in meta.items() if k!='status'}}
     c['full'][backend]=meta;save()
    if not all(x['status']=='PASS' for x in c['full'].values()):c['status']='UNVERIFIED';save();print(schema,n,'UNVERIFIED',flush=True);continue
    for repetition in range(7):
     order=['Native','TS','JS'];offset=repetition%3;order=order[offset:]+order[:offset]
     for backend in order:
      meta,text=child(args(backend,False),root);meta['repetition']=repetition+1;meta['order']=order
      if text is not None:
       try:meta.update(validate(text,schema,n,backend,False,legacy))
       except (AssertionError,TypeError,json.JSONDecodeError) as error:meta={'status':'FAILED','error':str(error),**{k:v for k,v in meta.items() if k!='status'}}
      c['samples'][backend].append(meta);save()
    complete=all(len(xs)==7 and all(v['status']=='PASS' for v in xs) for xs in c['samples'].values());c['status']='MEASURED' if complete else 'REGRESSION'
    for backend,xs in c['samples'].items():
     if all(v['status']=='PASS' for v in xs):c['summary'][backend]={'milliseconds':R.stats([v['milliseconds'] for v in xs]),'peakRssKiB':R.stats([v['peakRssKiB'] for v in xs])}
    if complete:c['ratios']={b+'/TS':c['summary'][b]['milliseconds']['median']/c['summary']['TS']['milliseconds']['median'] for b in ['Native','JS']}
    save();print(schema,n,c['status'],c.get('ratios'),flush=True)
  for name,old,new in [('head-only-target','case 1: U32.div(count,2)','case 1: 0'),('omit-disposal','motion_dispose_host(host,target)','host')]:
   entry=copied(root/name);p=entry.parent/'measurement-lifecycle.bend';s=p.read_text();assert s.count(old)==1;p.write_text(s.replace(old,new))
   try:
    mb=L.build(entry,entry.parent);legacy=json.loads(L.command(['node',HERE/'measurement-reference.mjs','Motion','lifecycle','64']))
    for i,backend in enumerate(['Native','JS']):
     text=L.execute(mb[i],['0','64','1']);rejected=False
     try:validate(text,'Motion',64,backend,True,legacy)
     except AssertionError:rejected=True
     assert rejected,name
    e['mutants'].append({'name':name,'compiledNativeJs':True,'detectedBoth':True})
   except (RuntimeError,AssertionError,json.JSONDecodeError) as error:e['mutants'].append({'name':name,'status':'FAILED','error':str(error)})
   save()
 e['status']='MEASURED' if all(c['status']=='MEASURED' for c in e['cases']) and all(m.get('detectedBoth') for m in e['mutants']) else 'REGRESSION';save();return int(e['status']!='MEASURED')
if __name__=='__main__':sys.exit(main())
