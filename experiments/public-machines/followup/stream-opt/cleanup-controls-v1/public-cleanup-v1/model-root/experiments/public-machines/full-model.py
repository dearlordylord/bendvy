"""Prospective complete observer model, not observed Bend output.

Common values come from the frozen actual TS oracle. Physical storage, closed
registry metadata, publication clocks and affine catalog order are independently
source-derived supplements for this selected fixture. No raw callbacks are
serialized and no universal refinement is claimed.
"""
import json,re
from pathlib import Path

HERE=Path(__file__).resolve().parent
def listing(xs):return '['+', '.join(map(str,xs))+']'
def boolean(x):return str(x).lower()
BODY_ACCESS=['machine.Flow.read','machine.Flow.next','machine.Level.next','component.cells.write','resource.owned.write','commands.spawn']
READ_ACCESS=['transition.Flow.read','transition.Level.read']
GATES=[(30,'inPause','Flow=Pause'),(31,'changed','FlowChanged'),(32,'notBoot','not(Flow=Boot)'),(33,'and','and(Flow=Pause,not(Level=0))'),(34,'or','or(Flow=Boot,Level=1)'),(35,'emptyAnd','true'),(36,'emptyOr','false')]
def body(key,name,operation):return f'Body:{key}:{name}:{operation}'
def read(key,name,fails=False):return f'Read:{key}:{name}:{boolean(fails)}'
def marker(enabled=False):return 'Marker:'+boolean(enabled)
def plans():
 gates=[f'Gate:{k}:{n}:{c}' for k,n,c in GATES]
 return [
 [body(1,'seed','Seed'),'Deferred'],[body(2,'overwrite','Queue')],['Deferred'],[marker()],
 [read(10,'fast'),read(11,'slow')],
 [body(3,'same-set','SameSet'),marker(),*gates,read(10,'fast')],
 [body(4,'same-skip','SameSkip'),marker(),*gates,read(10,'fast')],
 [body(5,'skip-overwrite','OverwriteSkip'),marker(),read(10,'fast')],
 [body(6,'reset','Reset'),marker(),read(10,'fast')],[body(7,'old-pending','OldPending')],
 [body(8,'failed-publisher','FailingPublisher:publish-failed'),marker()],
 [marker(),read(10,'fast')],[read(12,'retry-reader',True)],[read(12,'retry-reader',True)],
 [read(11,'slow')],[body(9,'pause','PauseRequest'),marker(),'GatedRead:11:slow:Flow=Play'],
 [body(13,'play','PlayRequest'),marker(),read(11,'slow')],
 [body(14,'definition-order','MarkerQueues'),marker(True)],
 [marker(),read(10,'fast'),read(11,'slow')],[],[],[read(12,'retry-reader',True)],
 [read(12,'retry-reader')],[read(12,'retry-reader')]]

FLOW_EVENTS=[(6,'Boot','Pause'),(12,'Pause','Pause'),(30,'Pause','Pause'),(38,'Pause','Boot'),(45,'Boot','Pause'),(48,'Pause','Play'),(52,'Play','Pause'),(57,'Pause','Boot')]
LEVEL_EVENTS=[(7,0,1),(54,1,1)]
CHANGED={'Flow':{3,5,7,11,15,16,17,18},'Level':{3,17}}
FAST_CURSORS={4:8,5:19,6:27,7:31,8:34,11:39,18:58}
SLOW_CURSORS={4:9,14:42,15:45,16:49,18:59}
RETRY_CURSORS={22:61,23:62}

def slot(value,changed):
 pending='none' if 'pending' not in value else str(value['pending'])+':false'
 return f"{value['current']}(pending={pending},previous={value.get('previous','none')},changed={boolean(changed)})"
def delivery(value):
 trans=lambda values:listing(f"{v['from']}>{v['to']}" for v in values)
 return value['name']+':flow='+trans(value['flow'])+':level='+trans(value['level'])+':lagged='+','.join(map(boolean,value['lagged']))
def attempt(value):
 if value[0]=='overwrite':return ':'.join(value)
 if value[0]=='reset':return 'reset:none'
 assert value==['failed-publisher'];return value[0]

def physical_cells(world):
 # Selected constructor paths: P.empty_store starts with one ALeaf; seed
 # reserves id1 and populates it, and P.cells_set_world writes only id1.
 # Column.ensure grows iff target > size (column.bend137-151), and ordinary
 # swap uses id-1 (column.bend275-281). Empty spawns touch World.live only.
 # Thus BOTH nominal roots retain one physical Column cell throughout these
 # 24 frames, including complete inverse restoration after the failed write.
 # Payload contents remain grounded in the complete TS public entity record.
 touched_ids=[1];capacity=1
 while capacity<max(touched_ids):capacity*=2
 owners={e['id']:e['components']['Cells'] for e in world['entities'] if 'Cells' in e['components']}
 assert set(owners)=={1},'selected fixture component-owner inventory changed'
 cells=['none']*capacity
 for entity_id,payload in owners.items():cells[entity_id-1]=listing(payload)
 return listing(cells)+':stamps=[1:1:1]'

def expected():
 oracle=json.loads((HERE/'expected.json').read_text())
 result={}
 for ns,app in enumerate(oracle['applications'],1):
  assert len(app['observations'])==24
  registrations=[(1,'flow-hook',['machine.Flow.next','machine.Level.next']),(2,'level-hook',['machine.Flow.next'])]
  users=[];readers=[];ids={};positions={};rows=[]
  def activate(key,name,access,kind):
   if name not in ids:
    ids[name]=len(registrations)+1;registrations.append((ids[name],name,access))
   entries=users if kind=='user' else readers
   entries[:]=[(k,n) for k,n in entries if k!=key]
   entries.insert(0,(key,name))
  previous_tick=0;dropped={'Flow':0,'Level':0}
  for i,(o,actions) in enumerate(zip(app['observations'],plans())):
   world=o['world'];tick=world['tick']
   for action in actions:
    pieces=action.split(':');kind=pieces[0]
    if kind=='Body':activate(int(pieces[1]),pieces[2],BODY_ACCESS,'user')
    elif kind=='Gate':
     # Only these actual conditions match in this selected Pause/Level1 frame.
     name=pieces[2]
     if name!='emptyOr' and (name!='changed' or i==5):activate(int(pieces[1]),name,BODY_ACCESS,'user')
    elif kind=='Read':activate(int(pieces[1]),pieces[2],READ_ACCESS,'reader')
    elif kind=='GatedRead':
     assert i==15
     readers[:]=[(k,n) for k,n in readers if k!=11];readers.insert(0,(11,'slow'))
    if i==10 and kind=='Body':break # Actual failing body prevents marker dispatch.
   if i==4:positions={'slow':[ids['slow'],9,8],'fast':[ids['fast'],8,7]}
   if i==12:positions={'retry-reader':[ids['retry-reader'],0,39],**positions}
   for name,changes in [('fast',FAST_CURSORS),('slow',SLOW_CURSORS),('retry-reader',RETRY_CURSORS)]:
    if i in changes:positions[name][1]=changes[i]
   registry=lambda name:f"{ns}:{ids[name]}:{name}:{listing(READ_ACCESS if name in ('fast','slow','retry-reader') else BODY_ACCESS)}:0"
   user_rows=[f'{key}:'+registry(name) for key,name in users]
   reader_rows=[f'{key}:'+registry(name)+f':flow={ns}:{ids[name]}:level={ns}:{ids[name]}' for key,name in readers]
   hook_rows=f'{ns}:1:flow-hook:{listing(registrations[0][2])}:0|{ns}:2:level-hook:{listing(registrations[1][2])}:0'
   queue=len(world['pendingCommands'])
   fields={'ns':str(ns),'next':str(2 if i==0 else 3 if i<10 else 4),'high':str(1 if i==0 else 2 if i<10 else 3),'capacity':str(2 if i==0 else 4),'depth':str(1 if i==0 else 2),'live':listing(['false','true'] if i==0 else ['false','true','false','false'] if i==1 else ['false','true','true','false']),
    'cells':physical_cells(world),'owned':listing(world['resources']['Owned']),
    'flow':slot(world['machines']['Flow'],i in CHANGED['Flow']),'level':slot(world['machines']['Level'],i in CHANGED['Level']),
    'frame':str(world['frame']),'tick':str(tick),'hooks':listing(o['hooks']),
    'queue':str(queue),'registrations':listing(f'{ident}:{name}:{listing(access)}' for ident,name,access in reversed(registrations)),
    'nextSystem':str(len(registrations)+1),'componentClock':str(1 if i<10 else 2),'busEvents':'0',
    'users':listing(user_rows),'hookOwners':hook_rows,'readerOwners':listing(reader_rows),
    'attempts':listing(map(attempt,o['attempts'])),'deliveries':listing(map(delivery,o['deliveries'])),'conditions':listing(o['conditions']),'active':listing(actions)}
   for name,events in [('Flow',FLOW_EVENTS),('Level',LEVEL_EVENTS)]:
    published=[e for e in events if e[0]<=tick]
    info=next((s for s in o['streams'] if s['stream']==name),None)
    size=0 if info is None else info['size']
    kept=published[-size:] if size else []
    removed=published[:len(published)-size]
    if removed:dropped[name]=removed[-1][0]
    fields[name.lower()+'Stream']='batches='+listing(f'{t}:[{a}>{b}]' for t,a,b in kept)+',positions='+listing(':'.join(map(str,p)) for p in positions.values())+f',dropped={dropped[name]},frameStart={previous_tick}'
    # Independently cross-check the source-derived raw cursor model against ALL
    # observed public unread/lagged rows, rather than accepting snapshot size alone.
    if info:
     for reader in info['readers']:
      cursor=positions[reader['system']][1]
      assert reader['unread']==sum(t>cursor for t,_,_ in kept),(o['label'],name,reader)
      assert reader['lagged']==(max(cursor,positions[reader['system']][2])<dropped[name]),(o['label'],name,reader)
   status='ok' if o['result']['ok'] else 'failed:'+o['result']['error']['error']
   rows.append({'label':o['label'],'status':status,'fields':fields})
   previous_tick=tick
  result[app['schema']]=rows
 return result

def structure(raw):
 lines=raw.decode('utf-8').splitlines();observed={};schema=None
 for line in lines:
  if line.startswith('SCHEMA='):
   schema=line[7:];assert schema not in observed;observed[schema]=[];continue
  assert schema is not None and line,'unexpected output'
  label,status,body=line.split('|',2);pairs=[p.split('=',1) for p in body.split(';')]
  assert len({k for k,v in pairs})==len(pairs),'duplicate observer field'
  observed[schema].append({'label':label,'status':status,'fields':dict(pairs)})
 wanted=expected()
 assert list(observed)==list(wanted),'schema inventory/order'
 for schema,rows in wanted.items():
  assert len(observed[schema])==len(rows)==24,'checkpoint inventory'
  for got,want in zip(observed[schema],rows):
   assert got['label']==want['label'],(schema,got['label'],'checkpoint label')
   assert got['status'] in {'ok','failed:publish-failed','failed:reader-failed','failed:AliasObservationMismatch','failed:ResetObservationMismatch'},(schema,got['label'],'unexpected status',got['status'])
   assert got['fields'].keys()==want['fields'].keys(),(schema,got['label'],'field inventory')
   assert all(value for value in got['fields'].values()),(schema,got['label'],'empty field')
   assert not any(marker in value for value in got['fields'].values() for marker in ['UNSUPPORTED_COLUMN_ROUTE','HOOK_PROVISION_REJECTED','WORLD_CREATE_REFUSED','POPULATE_REJECTED','HOOK_FAILED']), 'unsupported/refused route is not a complete observation'
   fields=got['fields']
   for key in ['ns','next','high','capacity','depth','frame','tick','queue','nextSystem','componentClock','busEvents']:assert fields[key].isdigit(),(schema,got['label'],'malformed numeric',key)
   live=json.loads(fields['live']);assert len(live)==int(fields['capacity']) and all(type(v) is bool for v in live),'complete physical live Array'
   owned=json.loads(fields['owned']);assert isinstance(owned,list) and all(type(v) is int and 0<=v<=4294967295 for v in owned),'malformed actual resource Array'
   cells,stamps=fields['cells'].split(':stamps=',1);cells=json.loads(cells.replace('none','null'))
   assert isinstance(cells,list) and all(v is None or isinstance(v,list) and all(type(n) is int and 0<=n<=4294967295 for n in v) for v in cells),'malformed actual component Array'
   assert re.fullmatch(r'\[(?:\d+:\d+:\d+(?:, \d+:\d+:\d+)*)?\]',stamps),'malformed stamp owner'
   for key,values in [('flow','Boot|Play|Pause'),('level','0|1|2')]:
    assert re.fullmatch(rf'(?:{values})\(pending=(?:none|(?:{values}):(?:true|false)),previous=(?:none|{values}),changed=(?:true|false)\)',fields[key]),'malformed actual machine slot'
 return observed

def validate(raw):
 observed=structure(raw);wanted=expected()
 for schema,rows in wanted.items():
  for got,want in zip(observed[schema],rows):
   assert got['status']==want['status'],(schema,got['label'],got['status'],want['status'])
   for key,value in want['fields'].items():assert got['fields'][key]==value,(schema,got['label'],key,got['fields'][key],value)
 return observed
