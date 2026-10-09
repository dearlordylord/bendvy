"""Complete skip fixture model: primary common values plus source-derived owners."""
import gzip,json,importlib.util,pathlib
HERE=pathlib.Path(__file__).resolve().parent
s=importlib.util.spec_from_file_location('initial_model',HERE.parent/'full-model.py');base=importlib.util.module_from_spec(s);s.loader.exec_module(base)
listing=base.listing;boolean=base.boolean
NAMES={0:'Boot',1:'Play',2:'Pause'}
def expected():
 oracle=json.loads(gzip.decompress((HERE/'evidence/primary-ts-v1/expected.json.gz').read_bytes()));result={}
 plans=[[base.body(1,'seed','Seed'),'Deferred'],[base.body(2,'publish','PlayRequest'),base.marker()],['GatedRead:10:reader:Flow=Boot'],[base.body(3,'second','PauseRequest'),base.marker(),base.read(10,'reader')],[base.read(10,'reader')]]
 for ns,root in enumerate(['A','B'],1):
  app=oracle['skip-'+root]['applications'][0];regs=[(1,'flow-hook',['machine.Flow.next','machine.Level.next']),(2,'level-hook',['machine.Flow.next'])];users=[];rows=[];reader=False
  for i,(o,active) in enumerate(zip(app['observations'],plans)):
   w=o['world'];flow=w['machines']['Flow'];reader=i>=3
   if i in [0,1,3]:
    key,name=[(1,'seed'),(2,'publish'),(0,''),(3,'second')][i];ident=len(regs)+1;regs.append((ident,name,base.BODY_ACCESS));users.insert(0,(key,ident,name))
   if i==3:regs.append((len(regs)+1,'reader',base.READ_ACCESS))
   reg=lambda ident,name,access:f'{ns}:{ident}:{name}:{listing(access)}:0'
   fields={'ns':str(ns),'next':'2','high':'1','capacity':'2','depth':'1','live':'[false, true]','cells':base.physical_cells(w),'owned':listing(w['resources']['Owned']),
    'flow':f"{NAMES[flow['current']]}(pending=none,previous={NAMES[flow['previous']] if 'previous' in flow else 'none'},changed={boolean(i in [1,3])})",'level':'0(pending=none,previous=none,changed=false)',
    'frame':str(w['frame']),'tick':str(w['tick']),'hooks':'[]','queue':'0','registrations':listing(f'{ident}:{name}:{listing(access)}' for ident,name,access in reversed(regs)),'nextSystem':str(len(regs)+1),'componentClock':'1','busEvents':'0',
    'users':listing(f'{key}:'+reg(ident,name,base.BODY_ACCESS) for key,ident,name in users),'hookOwners':reg(1,'flow-hook',regs[0][2])+'|'+reg(2,'level-hook',regs[1][2]),'readerOwners':listing([f'10:'+reg(6,'reader',base.READ_ACCESS)+f':flow={ns}:6:level={ns}:6'] if reader else []),
    'attempts':'[]','deliveries':listing('reader:flow='+listing(f"{NAMES[e['from']]}>{NAMES[e['to']]}" for e in d['flow'])+':level=[]:lagged='+boolean(d['lagged'])+',false' for d in o['deliveries']),'conditions':'[]','active':listing(active)}
   positions=listing([f'6:{9 if i==3 else 10}:8'] if reader else [])
   start=[0,2,5,5,9][i];drop=5 if i>=3 else 0
   batches=[] if i==0 else ['5:[Boot>Play]'] if i<3 else ['8:[Play>Pause]']
   fields['flowStream']='batches='+listing(batches)+',positions='+positions+f',dropped={drop},frameStart={start}'
   fields['levelStream']='batches=[],positions='+positions+f',dropped=0,frameStart={start}'
   # Match all actual public rows, not only the number of publications.
   stream=next((s for s in o['streams'] if s['stream']=='Flow'),None)
   assert (0 if stream is None else stream['size'])==len(batches)
   assert (0 if stream is None else len(stream['readers']))==int(reader)
   if reader:assert stream['readers']==[{'system':'reader','unread':0,'lagged':False}]
   rows.append({'label':o['label'],'status':'ok','fields':fields})
  result[root]=rows
 return result

def structure(raw):
 out={};root=None;wanted=expected()
 for line in raw.decode().splitlines():
  if line.startswith('SCHEMA='):root=line[7:];assert root not in out;out[root]=[];continue
  assert root is not None and line;label,status,body=line.split('|',2);pairs=[v.split('=',1) for v in body.split(';')];assert len(pairs)==len({k for k,v in pairs});out[root].append({'label':label,'status':status,'fields':dict(pairs)})
 assert list(out)==list(wanted)
 for root,rows in wanted.items():
  assert len(out[root])==len(rows)==5
  for got,want in zip(out[root],rows):
   assert got['label']==want['label'] and got['status']=='ok'
   assert got['fields'].keys()==want['fields'].keys() and all(got['fields'].values())
   for key in ['ns','next','high','capacity','depth','frame','tick','queue','nextSystem','componentClock','busEvents']:assert got['fields'][key].isdigit()
   assert not any(v in value for value in got['fields'].values() for v in ['REFUSED','REJECTED','UNSUPPORTED'])
   assert len(json.loads(got['fields']['live']))==int(got['fields']['capacity'])
   cells,stamps=got['fields']['cells'].split(':stamps=');assert isinstance(json.loads(cells.replace('none','null')),list) and stamps
   assert isinstance(json.loads(got['fields']['owned']),list)
 return out

def validate(raw):
 out=structure(raw);wanted=expected()
 for root,rows in wanted.items():
  for got,want in zip(out[root],rows):
   for key,value in want['fields'].items():assert got['fields'][key]==value,(root,got['label'],key,got['fields'][key],value)
 return out
