"""Complete foreign-instance/cleanup supplement; not TS same-operation parity.

Committed state, Array payloads and independent deliveries use observed TS
values. Namespace transport/refusal, eager registries, raw cursor/clock layout
and explicit existing-contract cleanup are source-derived Bend supplements.
"""
import copy,gzip,json,importlib.util,pathlib,re
HERE=pathlib.Path(__file__).resolve().parent
s=importlib.util.spec_from_file_location('skip_model',HERE/'skip-model.py');skip=importlib.util.module_from_spec(s);s.loader.exec_module(skip)
base=skip.base;listing=base.listing

def expected():
 golden=json.loads(gzip.decompress((HERE/'evidence/primary-ts-v1/expected.json.gz').read_bytes()));seed=skip.expected();result={}
 for root,first_ns in [('A',1),('B',3)]:
  worlds={};oracle=golden['independent-'+root]['applications'][0]['observations']
  for side,ns in [('A',first_ns),('B',first_ns+1)]:
   fields=copy.deepcopy(seed[root][1]['fields']);fields['ns']=str(ns)
   fields['owned']=listing(next(o['world']['resources']['Owned'] for o in oracle if o['label']==side+'-published'))
   fields['users']=listing([f'2:{ns}:4:publish:{listing(base.BODY_ACCESS)}:0',f'1:{ns}:3:seed:{listing(base.BODY_ACCESS)}:0'])
   fields['hookOwners']=f'{ns}:1:flow-hook:[machine.Flow.next, machine.Level.next]:0|{ns}:2:level-hook:[machine.Flow.next]:0'
   initial=copy.deepcopy(fields);from_seed=seed[root][0]['fields']
   for key in ['flow','flowStream','levelStream','frame','tick','registrations','nextSystem','active']:initial[key]=from_seed[key]
   initial['users']=listing([f'1:{ns}:3:seed:{listing(base.BODY_ACCESS)}:0'])
   rows=[{'label':'seeded','status':'ok','fields':initial},{'label':'published','status':'ok','fields':copy.deepcopy(fields)}]
   # Explicitly provisioned reader Registry5 stays outside the gameplay catalog.
   registrations=[(1,'flow-hook',['machine.Flow.next','machine.Level.next']),(2,'level-hook',['machine.Flow.next']),(3,'seed',base.BODY_ACCESS),(4,'publish',base.BODY_ACCESS),(5,'shared-definition',base.READ_ACCESS)]
   fields['registrations']=listing(f'{ident}:{name}:{listing(access)}' for ident,name,access in reversed(registrations));fields['nextSystem']='6'
   worlds[side]={'ns':ns,'fields':fields,'rows':rows,'registrations':registrations}
  def record(label,status):
   for side in ['A','B']:worlds[side]['rows'].append({'label':label,'status':status,'fields':copy.deepcopy(worlds[side]['fields'])})
  record('two-independent-instances','ok');record('foreign-A-on-B','reader-registration-rejected')
  def completed(side):
   f=worlds[side]['fields'];f['tick']='6'
   f['flowStream']='batches=[5:[Boot>Play]],positions=[5:6:5],dropped=0,frameStart=2'
   f['levelStream']='batches=[],positions=[5:6:5],dropped=0,frameStart=2'
  completed('A');record('A-legitimate-retry','ok');completed('B');record('B-independent-instance','ok')
  for side in ['A','B']:
   w=worlds[side];f=w['fields'];f['flowStream']='batches=[5:[Boot>Play]],positions=[],dropped=0,frameStart=2';f['levelStream']='batches=[],positions=[],dropped=0,frameStart=2'
   f['registrations']=listing(f'{ident}:{name}:{listing(access)}' for ident,name,access in reversed(w['registrations'][:-1]))
   w['rows'].append({'label':side+'-owned-cleanup','status':'cleaned','fields':copy.deepcopy(f)})
  token=lambda ns:f'99:{ns}:5:shared-definition:{listing(base.READ_ACCESS)}:0:flow={ns}:5:level={ns}:5'
  caps=lambda label:label+'|A='+token(first_ns)+'|B='+token(first_ns+1)
  actual_delivery='[actual:flow=[Boot>Play]:level=[]:lagged=false,false]'
  # Check complete actual public arrays for independent-runtime observations.
  ds=next(o for o in oracle if o['label']=='B-reader')['deliveries']
  assert len(ds)==2 and all(d=={'flow':[{'from':0,'to':1}],'lagged':False} for d in ds)
  result[root]={'worlds':{side:w['rows'] for side,w in worlds.items()},'instances':[caps('two-independent-instances'),'foreign-delivery=none',caps('foreign-A-on-B'),'A-delivery='+actual_delivery,caps('A-legitimate-retry'),'B-delivery='+actual_delivery,caps('B-independent-instance'),'A-owned-cleanup|A=disposed','B-owned-cleanup|B=disposed']}
 return result

def structure(raw):
 out={};root=None;side=None;instances=False;wanted=expected()
 for line in raw.decode().splitlines():
  if line.startswith('SCHEMA='):root=line[7:];assert root not in out;out[root]={'worlds':{},'instances':[]};side=None;instances=False;continue
  if line.startswith('WORLD='):side=line[6:];assert root and side not in out[root]['worlds'];out[root]['worlds'][side]=[];instances=False;continue
  if line=='INSTANCES':assert root;instances=True;continue
  assert root and line
  if instances:out[root]['instances'].append(line);continue
  assert side;label,status,body=line.split('|',2);pairs=[v.split('=',1) for v in body.split(';')];assert len(pairs)==len({k for k,v in pairs});out[root]['worlds'][side].append({'label':label,'status':status,'fields':dict(pairs)})
 assert list(out)==list(wanted)
 for root,want in wanted.items():
  got=out[root];assert list(got['worlds'])==['A','B'];assert len(got['instances'])==len(want['instances'])==9
  for side,rows in want['worlds'].items():
   assert len(got['worlds'][side])==len(rows)==7
   for observed,expected_row in zip(got['worlds'][side],rows):
    assert observed['label']==expected_row['label'] and observed['status'] in ['ok','cleaned','reader-registration-rejected','ReaderNamespaceRejected']
    f=observed['fields'];assert f.keys()==expected_row['fields'].keys() and all(f.values())
    for key in ['ns','next','high','capacity','depth','frame','tick','queue','nextSystem','componentClock','busEvents']:assert f[key].isdigit()
    live=json.loads(f['live']);assert len(live)==int(f['capacity']) and all(type(v) is bool for v in live)
    for value in [f['owned'],f['cells'].split(':stamps=')[0].replace('none','null')]:assert isinstance(json.loads(value),list)
    assert re.fullmatch(r'\[(?:\d+:\d+:\d+(?:, \d+:\d+:\d+)*)?\]',f['cells'].split(':stamps=')[1])
    assert not any(x in v for v in f.values() for x in ['REJECTED','REFUSED','UNSUPPORTED'])
 return out

def validate(raw):
 out=structure(raw);wanted=expected()
 for root,want in wanted.items():
  assert out[root]['instances']==want['instances'],(root,'actual instance/delivery inventory')
  for side,rows in want['worlds'].items():
   for got,row in zip(out[root]['worlds'][side],rows):
    assert got['status']==row['status'],(root,side,got['label'],'status')
    for key,value in row['fields'].items():assert got['fields'][key]==value,(root,side,got['label'],key,got['fields'][key],value)
 return out
