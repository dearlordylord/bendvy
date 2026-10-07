"""Independent complete finite model for the full registered #49 application.

The model consumes no emitted Bend output. TS-equivalence is independently
checked against retained actual reference records before a backend is executed.
"""
import copy,json
NAMES=['exit0','exit1','transition0','transition1','enter0','enter1','level0','fast','slow','flaky','seed','queue']
HOOK_ACCESS=['component.Cells.write','resource.Owned.write','event.Ping.read','event.Ping.emit','machine.Flow.read','machine.Level.read','machine.Flow.next','transition.Flow.read','transition.Level.read']
READ_ACCESS=['event.Ping.read','transition.Flow.read','transition.Level.read']
ACCESS=[HOOK_ACCESS]*7+[READ_ACCESS]*3+[['command.spawn'],['machine.Flow.next','machine.Level.next','command.spawn']]
def show(xs):return '['+', '.join(map(str,xs))+']'
def boolean(x):return str(x).lower()
def fresh():
 return dict(next=1,high=0,capacity=1,depth=0,live=[False],cells=[None],stamps=[],owned=[3,13],clock=0,tick=0,frame=0,windowBoundary=0,flow=dict(current='Boot',pending=None,previous=None,flag=False),level=dict(current='0',pending=None,previous=None,flag=False),locals=[0]*7,cursors=[0]*12,streams={k:dict(batches=[],positions=[],dropped=0,frameStart=0) for k in ['Ping','Flow','Level']},attempts=[],deliveries=[],logical_attempts=[],logical_deliveries=[],pendingCommands=[],events=[])
def slot(value):return f"{value['current']}(pending={value['pending']+':false' if value['pending'] else 'none'},previous={value['previous'] or 'none'},changed={boolean(value['flag'])})"
def event_text(k,event):return f"{event['handler']}:{event['attempt']}" if k=='Ping' else f"{event['from']}>{event['to']}"
def stream_text(k,stream):
 batches=show([f'{t}:{show([event_text(k,x) for x in vals])}' for t,vals in stream['batches']])
 positions=show([f'{i}:{cursor}:{registered}' for i,cursor,registered in stream['positions']])
 return f"batches={batches},positions={positions},dropped={stream['dropped']},frameStart={stream['frameStart']}"
def world_text(s):
 cells=show(['none' if a is None else show(a) for a in s['cells']]);stamps=show([f'{i}:{a}:{c}' for i,a,c in s['stamps']]);regs=show([f'{i+1}:{NAMES[i]}:{show(ACCESS[i])}' for i in reversed(range(12))]);local=show([f'1:{i+1}:[{count}]' for i,count in enumerate(s['locals'])]);owned='none' if s['owned'] is None else show(s['owned']);level='missing' if s['level'] is None else slot(s['level'])
 return f"ns=1;next={s['next']};high={s['high']};capacity={s['capacity']};depth={s['depth']};live={show(map(boolean,s['live']))};cells={cells}:stamps={stamps};owned={owned};flow={slot(s['flow'])};level={level};flowStream={stream_text('Flow',s['streams']['Flow'])};levelStream={stream_text('Level',s['streams']['Level'])};frame={s['frame']};tick={s['tick']};hooks=[];locals={local};pingStream={stream_text('Ping',s['streams']['Ping'])};selector=0:0:false;attempts={show(s['attempts'])};deliveries={show(s['deliveries'])};queue={len(s['pendingCommands'])};registrations={regs};nextSystem=13;componentClock={s['clock']};busEvents={show([event_text('Ping',e) for e in s['events']])}"
def registry(s,i):return f'1:{i+1}:{NAMES[i]}:{show(ACCESS[i])}:{s["cursors"][i]}'
def owners(s,k):
 items=[]
 for name,start in [('exit',0),('transition',2),('enter',4)]:
  rows=[f'{i-start}:{registry(s,i)}' for i in range(start,start+2)] if k=='Flow' else ([f'2:{registry(s,6)}'] if name=='enter' else [])
  items.append(name+'='+show(rows))
 return ';'.join(items)
def all_owner_text(s):return owners(s,'Flow')+';level='+owners(s,'Level')+';'+ ';'.join(f'{NAMES[i]}={registry(s,i)}' for i in [7,8,9,10,11])
def physical(s):return world_text(s)+';'+all_owner_text(s)
def reserve(s):
 i=s['next'];s['next']+=1;s['high']=i
 if i>=s['capacity']:s['live']+=[False]*s['capacity'];s['capacity']*=2;s['depth']+=1
 return i
def stamp(s,i,a,c):s['stamps']=[(i,a,c)]+[row for row in s['stamps'] if row[0]!=i]
def replace_cell(s,i,values):
 s['clock']+=1
 while len(s['cells'])<i:s['cells']+=[None]*len(s['cells'])
 old=s['cells'][i-1];added=next((a for key,a,_ in s['stamps'] if key==i),s['clock']) if old is not None else s['clock'];s['cells'][i-1]=values;stamp(s,i,added,s['clock'])
def barrier(s):
 for i,values,_ in s['pendingCommands']:s['live'][i]=True;replace_cell(s,i,values)
 s['pendingCommands']=[];s['tick']+=1

def begin_frame(s):
 s['windowBoundary']=s['streams']['Ping']['frameStart']
 for k,stream in s['streams'].items():
  boundary=min([stream['frameStart']]+[p[1] for p in stream['positions']]);removed=[t for t,_ in stream['batches'] if t<=boundary];stream['batches']=[(t,vs) for t,vs in stream['batches'] if t>boundary]
  if removed:stream['dropped']=max(stream['dropped'],max(removed))
  stream['frameStart']=s['tick']
 s['events']=[e for _,xs in s['streams']['Ping']['batches'] for e in xs];s['frame']+=1

def activated(s,i):
 for stream in s['streams'].values():
  if not any(p[0]==i+1 for p in stream['positions']):stream['positions'].insert(0,(i+1,0,s['tick']-1))
def completed(s,i):
 for stream in s['streams'].values():stream['positions']=[(key,s['tick'] if key==i+1 else cursor,registered) for key,cursor,registered in stream['positions']]
def reading(s,i):
 view={};lag=[]
 for k,stream in s['streams'].items():
  _,cursor,registered=next(p for p in stream['positions'] if p[0]==i+1);view[k]=[e for tick,xs in stream['batches'] if tick>cursor for e in xs];lag.append(stream['dropped']>max(cursor,registered))
 return view,lag
def view_text(view,lag):return ';'.join(f'{field}={show([event_text(k,e) for e in view[k]])}' for field,k in [('ping','Ping'),('flow','Flow'),('level','Level')])+';lagged='+','.join(map(boolean,lag))
def publish(s,k,event):s['tick']+=1;s['streams'][k]['batches'].append((s['tick'],[event]));s['events']+=([event] if k=='Ping' else [])
def logical_view(name,view,lag):
 def event(k,e):
  if k=='Ping':return dict(handler=NAMES[e['handler']],attempt=e['attempt'])
  if k=='Level':return dict(from_=int(e['from']),to=int(e['to']))
  return copy.deepcopy(e)
 result=dict(name=name,ping=[event('Ping',e) for e in view['Ping']],flow=[event('Flow',e) for e in view['Flow']],level=[event('Level',e) for e in view['Level']],lagged=lag.copy())
 for e in result['level']:e['from']=e.pop('from_')
 return result
def reader(s,i,fail=False):
 s['tick']+=1;activated(s,i);view,lag=reading(s,i);s['deliveries'].append(NAMES[i]+'|'+view_text(view,lag));s['logical_deliveries'].append(logical_view(NAMES[i],view,lag))
 if not fail:completed(s,i);s['cursors'][i]=s['clock']
 return 'reader-failed' if fail else 'ok'
def hook(s,i,active,fail=False):
 s['locals'][i]+=1;s['tick']+=1;activated(s,i);view,lag=reading(s,i);s['attempts'].append(NAMES[i]+'|'+view_text(view,lag)+f';local={s["locals"][i]};current={slot(s["flow"])},{slot(s["level"])};active={active}')
 logical=logical_view(NAMES[i],view,lag);logical.update(local=s['locals'][i],current=[s['flow']['current'],int(s['level']['current'])],active=dict(from_=active.split('>')[0],to=active.split('>')[1]));logical['active']['from']=logical['active'].pop('from_')
 if i==6:logical['active']={k:int(v) for k,v in logical['active'].items()}
 s['logical_attempts'].append(logical)
 before=copy.deepcopy((s['cells'],s['stamps'],s['owned'],s['flow']))
 touched=[]
 for id in range(1,s['next']):
  if s['live'][id] and id<=len(s['cells']) and s['cells'][id-1] is not None:
   v=s['cells'][id-1].copy();v[2]+=1;replace_cell(s,id,v);touched.append(id)
 s['owned']=[s['owned'][0]+1,s['owned'][1]+10];reserved=reserve(s)
 if i==4:s['flow']['pending']='Pause'
 if fail:
  s['cells'],oldstamps,s['owned'],s['flow']=before
  s['stamps']=oldstamps
  for id in reversed(touched):
   _,a,c=next(row for row in oldstamps if row[0]==id);stamp(s,id,a,c)
  return 'hook-failed:'+NAMES[i]
 s['pendingCommands'].append((reserved,[100+i,1000+i,0,0],NAMES[i]));completed(s,i);publish(s,'Ping',dict(handler=i,attempt=s['locals'][i]));s['cursors'][i]=s['clock'];return 'ok'

def marker(s,phase,pos):
 barrier(s);snapshots={k:s[k.lower()]['pending'] for k in ['Flow','Level']};s['flow']['flag']=False;s['level']['flag']=False
 for k in ['Flow','Level']:
  slotState=s[k.lower()];target=snapshots[k]
  if target is None:continue
  old=slotState['current'];slotState.update(pending=None,previous=old,flag=False)
  if k=='Flow' and old=='Boot' and target=='Play':
   for i in range(4):
    fail=i==phase*2+pos and s['locals'][i]==0
    status=hook(s,i,old+'>'+target,fail)
    if status!='ok':s['flow']['pending']=target;return status
  slotState=s[k.lower()];slotState.update(current=target,previous=old,flag=True);publish(s,k,dict(from_=old,to=target))
  # Normalize reserved Python keyword to the actual message field.
  s['streams'][k]['batches'][-1][1][0]['from']=s['streams'][k]['batches'][-1][1][0].pop('from_')
  if k=='Flow' and target=='Play':
   for i in [4,5]:
    status=hook(s,i,old+'>'+target,i==phase*2+pos and s['locals'][i]==0)
    if status!='ok':return status
  if k=='Level' and target=='1':
   status=hook(s,6,old+'>'+target)
   if status!='ok':return status
 return 'ok'
def debug_projection(s):
 machines={}
 for k in ['Flow','Level']:
  q=s[k.lower()]
  if q is None:continue
  cv=lambda x:int(x) if k=='Level' else x
  machines[k]={'current':cv(q['current'])}
  for fld in ['pending','previous']:
   if q[fld] is not None:machines[k][fld]=cv(q[fld])
 return dict(version=1,frame=s['frame'],tick=s['tick'],entityCount=sum(s['live']),entities=[dict(id=i,components={'Cells':s['cells'][i-1][:3]},relations={}) for i in range(1,s['next']) if s['live'][i] and i<=len(s['cells'])],resources={} if s['owned'] is None else {'Owned':s['owned']},machines=machines,pendingCommands=[dict(tag='spawn',system=origin) for _,_,origin in s['pendingCommands']])
def debug_streams(s):
 result=[]
 for k,stream in s['streams'].items():
  readers=[]
  for id,cursor,registered in reversed(stream['positions']):
   unread=sum(len(xs) for tick,xs in stream['batches'] if tick>cursor)
   readers.append(dict(system=NAMES[id-1],unread=unread,lagged=stream['dropped']>max(cursor,registered)))
  entry=dict(kind='event' if k=='Ping' else 'transitionEvent',stream=k,size=sum(len(xs) for _,xs in stream['batches']),capacity=65536,readers=readers)
  if stream['batches'] and readers:
   oldest=stream['batches'][0][0];holder=min(reversed(stream['positions']),key=lambda p:p[1])
   if oldest<=s['windowBoundary'] and holder[1]<oldest:entry['heldBy']=NAMES[holder[0]-1]
  result.append(entry)
 return result
def system_result(status):
 if status=='ok':return {'ok':True}
 system='flaky' if status=='reader-failed' else status.split(':',1)[1]
 return dict(ok=False,error=dict(kind='SystemFailure',system=system,error=status))
def case(phase,pos):
 s=fresh();rows=[];logical=[]
 def point(label,status='ok'):
  rows.append(label+'|'+status+'|'+physical(s));logical.append(dict(label=label,result=system_result(status),world=copy.deepcopy(debug_projection(s)),streams=copy.deepcopy(debug_streams(s)),hostLocal={NAMES[i]:n for i,n in enumerate(s['locals']) if n},attempts=copy.deepcopy(s['logical_attempts']),deliveries=copy.deepcopy(s['logical_deliveries'])))
 begin_frame(s);s['tick']+=1;s['pendingCommands'].append((reserve(s),[1,10,0,0],'seed'));s['cursors'][10]=s['clock'];barrier(s);reader(s,7);reader(s,8);point('initial')
 begin_frame(s);s['tick']+=1;s['flow']['pending']='Play';s['level']['pending']='1';s['pendingCommands'].append((reserve(s),[90,900,0,0],'queue'));s['cursors'][11]=s['clock'];point('queued')
 begin_frame(s);point('handler-failure',marker(s,phase,pos))
 begin_frame(s);point('reader-failure',reader(s,9,True))
 begin_frame(s);point('handler-retry',marker(s,phase,pos))
 begin_frame(s);point('reader-retry',reader(s,9))
 begin_frame(s);marker(s,phase,pos);reader(s,7);reader(s,8);point('later-marker')
 begin_frame(s);reader(s,7);reader(s,8);point('repeat-readers')
 return rows,logical

def missing_case():
 s=fresh();s['owned']=None;s['level']=None;v=physical(s);return ['before|'+v,'after|'+v,'requirements|[stateMachine.Level, resource.Owned]','status|MissingRuntimeRequirements']
def expected():
 result={}
 for schema in ['A','B']:
  for i,phase in enumerate(['exit','transition','enter']):
   for pos in [0,1]:
    name=f'schema{schema}_{phase}{pos}';result[name]=case(i,pos)[0];result[name+'_missing']=missing_case()
 return result

def expected_reference():
 applications=[]
 for schema in ['HandlersAlpha','HandlersBeta']:
  for i,phase in enumerate(['exit','transition','enter']):
   for pos in [0,1]:
    missing=fresh();missing['owned']=None;missing['level']=None
    before=debug_projection(missing)
    applications.append(dict(schema=schema,phase=phase,position=pos,requirements=[dict(kind='resource',name='Owned'),dict(kind='stateMachine',name='Flow'),dict(kind='stateMachine',name='Level')],records=case(i,pos)[1],missingRequirements=dict(result=dict(ok=False,error=dict(kind='MissingRuntimeRequirements',requirements=[dict(kind='stateMachine',name='Level'),dict(kind='resource',name='Owned')])),before=copy.deepcopy(before),after=copy.deepcopy(before))))
 return dict(applications=applications)

if __name__=='__main__':print(json.dumps(dict(bend=expected(),reference=expected_reference()),ensure_ascii=False,separators=(',',':')))
