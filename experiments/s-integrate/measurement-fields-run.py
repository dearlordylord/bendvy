#!/usr/bin/env python3
"""Lossless compact tuples, decoded into the unchanged full lifecycle validator."""
import hashlib,importlib.util,json,os,pathlib,sys,tempfile,time
HERE=pathlib.Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('life',HERE/'measurement-lifecycle-run.py');L=importlib.util.module_from_spec(spec);spec.loader.exec_module(L)
B=L.B;files={};B.closure(HERE/'measurement-lifecycle.bend',files);B.closure(HERE/'measurement-fields.bend',files);frozen={n:p.read_bytes() for n,p in files.items()}
def u(value):
 assert type(value) is int and 0<=value<=4294967295,'U32 scalar type/range'
 return value
def strict_json(value,key=None):
 if value is None:return
 if isinstance(value,dict):
  for k,v in value.items():strict_json(v,k)
 elif isinstance(value,list):
  for v in value:strict_json(v,key)
 elif key=='moving':assert type(value) is bool,'moving Bool'
 elif isinstance(value,str):assert key in ['phase','mode','kind','system'],'unexpected string scalar'
 else:u(value)
def decode_main(v,schema):
 if v is None:return None
 assert len(v)==(2 if schema=='Motion' else 3) and len(v[0])==4
 return {'coordinates':dict(zip('abcd',v[0])),'frame':v[1]} if schema=='Motion' else {'levels':dict(zip('abcd',v[0])),'reserve':v[1],'class':v[2]}
def decode_aux(v,schema):
 if v is None:return None
 assert len(v)==2 and len(v[0])==4
 return {'rates':dict(zip('abcd',v[0])),'moving':v[1]} if schema=='Motion' else {'layers':dict(zip('abcd',v[0])),'grade':v[1]}
def decode_flag(v):return None if v is None else {'group':v}
def decode(text,schema):
 lines=[json.loads(x) for x in text.splitlines()]
 for x in lines[:-1]:
  o=x['observation'];rows=[];query=[]
  for r in o['world']['rows']:
   assert len(r)==6
   rows.append({'id':r[0],'main':decode_main(r[1],schema),'aux':decode_aux(r[2],schema),'flag':decode_flag(r[3]),'added':r[4],'changed':r[5]})
  for q in o['query']:
   assert len(q)==4 and len(q[0])==2
   query.append({'handle':dict(zip(['namespace','id'],q[0])),'main':decode_main(q[1],schema),'aux':decode_aux(q[2],schema),'flag':decode_flag(q[3])})
  o['world']['rows']=rows;o['query']=query
 for x in lines:strict_json(x)
 return '\n'.join(json.dumps(x,separators=(',',':')) for x in lines)
def rewritten(folder):
 folder.mkdir()
 for n,b in frozen.items():(folder/n).write_bytes(b)
 p=folder/'measurement-lifecycle.bend';s='import ./measurement-fields.bend as Fields\n'+p.read_text()
 for sc,ma,ax,fl,mode,rv,ra,rf in [('Motion','PositionView','VelocityView','Selected','MotionMode','position','velocity','selected'),('Health','VitalsView','ArmorView','Tracked','HealthMode','vitals','armor','tracked')]:
  old=f'J.render_list(O.QueryRow<T.{sc}Schema,T.{ma},T.{ax},T.{fl}>,J.render_query(T.{sc}Schema,T.{ma},T.{ax},T.{fl},J.render_{rv},J.render_{ra},J.render_{rf}),query)';assert s.count(old)==1;s=s.replace(old,f'Fields.{sc.lower()}_query(query)')
  old=f'J.render_world(T.{ma},T.{ax},T.{fl},J.render_{rv},J.render_{ra},J.render_{rf},T.LedgerView,T.{mode},J.render_ledger,J.render_{sc.lower()}_mode,view)';assert s.count(old)==1;s=s.replace(old,f'Fields.{sc.lower()}_world(view)')
 p.write_text(s);return p
def main():
 os.sched_setaffinity(0,{10})
 e={'scope':'lossless per-field tuple serialization of unchanged actual lifecycle; full canonical-object equality after independent decoding; no timing acceptance','limits':{'checker':5,'runtime':5,'codegen':30,'clang':120},'cpuAffinity':sorted(os.sched_getaffinity(0)),'compiler':L.command(['bend','version']).strip(),'node':L.command(['node','--version']).strip(),'sourceHashes':{n:hashlib.sha256(b).hexdigest() for n,b in frozen.items()},'runnerSha256':hashlib.sha256(pathlib.Path(__file__).read_bytes()).hexdigest(),'fullValidatorSha256':hashlib.sha256((HERE/'measurement-lifecycle-run.py').read_bytes()).hexdigest(),'referenceAdapterSha256':hashlib.sha256((HERE/'measurement-reference.mjs').read_bytes()).hexdigest(),'cases':[],'decoderControls':[],'mutants':[]}
 with tempfile.TemporaryDirectory(prefix='measurement-fields-') as tmp:
  root=pathlib.Path(tmp);entry=rewritten(root/'original');e['instantiatedEntrySha256']=hashlib.sha256(entry.read_bytes()).hexdigest();bins=L.build(entry,entry.parent)
  for schema,num in [('Motion',0),('Health',1)]:
   for n in [64,256,1024]:
    ref=json.loads(L.command(['node',HERE/'measurement-reference.mjs',schema,'lifecycle',str(n)]));case={'schema':schema,'count':n,'backends':{}}
    for program in bins:
     backend='JS' if program.suffix=='.js' else 'Native'
     try:
      start=time.perf_counter();text=L.execute(program,[str(num),str(n)]);elapsed=time.perf_counter()-start
      case['backends'][backend]={**L.validate(decode(text,schema),schema,n,ref),'outputBytes':len(text.encode()),'wholeProcessSeconds':elapsed}
     except (RuntimeError,AssertionError,json.JSONDecodeError) as error:case['backends'][backend]={'status':'FAILED','error':str(error)}
    if schema=='Motion' and n==64:
     # Use an actual native/JS execution's output, never an invented passing fixture.
     baseline=L.execute(bins[0],['0','64']);L.validate(decode(baseline,schema),schema,n,ref)
     for name in ['missing-cell','string-in-U32','reordered-query']:
      bad=[json.loads(x) for x in baseline.splitlines()]
      if name=='missing-cell':bad[0]['observation']['query'][0][1][0].pop()
      if name=='string-in-U32':bad[0]['observation']['world']['rows'][0][0]='1'
      if name=='reordered-query':bad[0]['observation']['query'][:2]=bad[0]['observation']['query'][1::-1]
      rejected=False
      try:L.validate(decode('\n'.join(json.dumps(x) for x in bad),schema),schema,n,ref)
      except (AssertionError,TypeError):rejected=True
      assert rejected,name
      e['decoderControls'].append({'name':name,'detected':True})
    e['cases'].append(case);(HERE/'measurement-fields-evidence.json').write_text(json.dumps(e,indent=2)+'\n');print(schema,n,{k:v['status'] for k,v in case['backends'].items()},flush=True)
  entry=rewritten(root/'omit-fourth-cell');p=entry.parent/'measurement-fields.bend';s=p.read_text();assert s.count('[a,b,c,d]')==1;p.write_text(s.replace('T.Four{a,b,c,d}','T.Four{a,b,+c,d}').replace('[a,b,c,d]','[a,b,c,c]'))
  try:
   bins=L.build(entry,entry.parent);ref=json.loads(L.command(['node',HERE/'measurement-reference.mjs','Motion','lifecycle','64']))
   for b in bins:
    text=L.execute(b,['0','64']);rejected=False
    try:L.validate(decode(text,'Motion'),'Motion',64,ref)
    except AssertionError:rejected=True
    assert rejected,'fourth field loss undetected'
   e['mutants'].append({'name':'omit-fourth-cell','compiledNativeJs':True,'detectedBoth':True})
  except (RuntimeError,AssertionError,json.JSONDecodeError) as error:e['mutants'].append({'name':'omit-fourth-cell','status':'FAILED','error':str(error)})
 e['status']='PASS' if all(v['status']=='PASS' for c in e['cases'] for v in c['backends'].values()) and all(m.get('detectedBoth') for m in e['mutants']) else 'REGRESSION';(HERE/'measurement-fields-evidence.json').write_text(json.dumps(e,indent=2)+'\n');print(e['status']);return int(e['status']!='PASS')
if __name__=='__main__':sys.exit(main())
