"""Full 65,537-publication model; all physical owners and 65,536 payloads.

Common machine/owner/frame/tick/delivery fields come from observed public TS.
Bend namespace, Registry ownership and raw stream cursor/batch metadata are
separate source-derived supplements. No snapshots, checksums or small capacity.
"""
import gzip,json,importlib.util,pathlib,re
HERE=pathlib.Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('initial_model',HERE.parent/'full-model.py');base=importlib.util.module_from_spec(spec);spec.loader.exec_module(base)
listing=base.listing;boolean=base.boolean
PUBLISH_ACCESS=['machine.Flow.read','machine.Flow.next','component.cells.write','commands.spawn']
READ_ACCESS=['transition.Flow.read']
FIELD_NAMES=['ns','next','high','capacity','depth','live','cells','owned','flow','flowStream','frame','tick','error','queue','registrations','nextSystem','componentClock','busEvents','publisherOwner','readerOwner','readerCap','deliveries']

def expected():
 golden=json.loads(gzip.decompress((HERE/'evidence/primary-ts-v1/expected.json.gz').read_bytes()));out={}
 for ns,root in enumerate(['A','B'],1):
  observations=golden['overflow-'+root]['applications'][0]['observations'];assert len(observations)==7
  rows=[]
  for i,o in enumerate(observations):
   w=o['world'];machine=w['machines']['Flow'];stream=next((v for v in o['streams'] if v['stream']=='Flow'),None)
   deliveries=o['deliveries']
   if i>=4:
    assert deliveries[1]['flow']==[{'from':v,'to':v+1} for v in range(1,65537)] and deliveries[1]['lagged'] is True
   if i>=5:assert deliveries[2]==deliveries[1]
   if i==6:assert deliveries[3]=={'flow':[],'lagged':False}
   values=range(65537) if i==2 else range(1,65537) if i in [3,4,5] else []
   batches=listing(f'{6+v*3}:[{v}>{v+1}]' for v in values)
   cursor=196616 if i==5 else 196617 if i==6 else 0
   positions=listing([f'2:{cursor}:2'] if i>=1 else [])
   dropped=6 if i in [3,4,5] else 196614 if i==6 else 0
   start=[0,2,196611,196614,196614,196615,196616][i]
   if stream:
    assert stream['size']==len(values)
    unread=len(values) if i<5 else 0
    assert stream['readers']==[{'system':'reader','unread':unread,'lagged':i in [3,4]}]
   owner=lambda ident,name,access:f'{ns}:{ident}:{name}:{listing(access)}:0'
   fields={'ns':str(ns),'next':'2','high':'1','capacity':'2','depth':'1','live':'[false, true]','cells':base.physical_cells(w),'owned':listing(w['resources']['Owned']),
    'flow':str(machine['current'])+'(pending=none,previous='+str(machine.get('previous','none'))+',changed='+boolean(i==2)+')',
    'flowStream':'batches='+batches+',positions='+positions+f',dropped={dropped},frameStart={start}',
    'frame':str(w['frame']),'tick':str(w['tick']),'error':'none','queue':'0',
    'registrations':listing(['2:reader:'+listing(READ_ACCESS),'1:publisher:'+listing(PUBLISH_ACCESS)]),'nextSystem':'3','componentClock':'1','busEvents':'0',
    'publisherOwner':owner(1,'publisher',PUBLISH_ACCESS),'readerOwner':owner(2,'reader',READ_ACCESS),'readerCap':f'{ns}:2',
    'deliveries':listing('values='+listing(f"{e['from']}>{e['to']}" for e in d['flow'])+',lagged='+boolean(d['lagged']) for d in deliveries)}
   assert list(fields)==FIELD_NAMES
   status='failed:reader-failed' if i in [1,4] else 'ok'
   rows.append({'label':o['label'],'status':status,'fields':fields})
  out[root]=rows
 return out

def structure(raw):
 out={};root=None;wanted=expected()
 for line in raw.decode('utf-8',errors='strict').splitlines():
  if line.startswith('SCHEMA='):root=line[7:];assert root not in out;out[root]=[];continue
  assert root is not None and line;label,status,body=line.split('|',2)
  pairs=[part.split('=',1) for part in body.split(';')];assert len(pairs)==len({key for key,value in pairs})
  out[root].append({'label':label,'status':status,'fields':dict(pairs)})
 assert list(out)==['A','B']
 for root,rows in wanted.items():
  assert len(out[root])==len(rows)==7
  for got,want in zip(out[root],rows):
   assert got['label']==want['label'] and got['status']==want['status']
   fields=got['fields'];assert list(fields)==FIELD_NAMES and all(fields.values())
   for key in ['ns','next','high','capacity','depth','frame','tick','queue','nextSystem','componentClock','busEvents']:assert fields[key].isdigit()
   live=json.loads(fields['live']);assert len(live)==int(fields['capacity']) and all(type(v) is bool for v in live)
   assert isinstance(json.loads(fields['owned']),list)
   cells,stamps=fields['cells'].split(':stamps=');assert isinstance(json.loads(cells.replace('none','null')),list)
   assert re.fullmatch(r'\[(?:\d+:\d+:\d+(?:, \d+:\d+:\d+)*)?\]',stamps)
   assert not any(v in fields[key] for key in fields for v in ['REFUSED','REJECTED','UNSUPPORTED'])
 return out

def validate(raw):
 out=structure(raw);wanted=expected()
 for root,rows in wanted.items():
  for got,want in zip(out[root],rows):
   assert got==want,(root,got['label'],next((k for k in FIELD_NAMES if got['fields'][k]!=want['fields'][k]),'row'))
 return out
