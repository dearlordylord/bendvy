"""Independent pinned-source public TS oracle; never reads backend output."""
import copy,json
from pathlib import Path
names=['main','added','changed','withoutHealth','withHealth']
def description(category):
 systems=[]
 for i,name in enumerate(names):
  q=dict(slot='entities',reads=['Position'],writes=['Velocity'],optional=['Health'],with_=['Health'] if i==4 else [],without=['Health'] if i==3 else [],added=['Position'] if i==1 else [],changed=['Position'] if i==2 else [],relations=[])
  q['with']=q.pop('with_')
  systems.append(dict(name=name,placements=[f'Update#{i}'],queries=[q],resources=dict(reads=[],writes=[]),events=dict(reads=[],writes=[]),machines=dict(reads=[],next=[],transitions=[],transitionEvents=[]),removed=[],despawned=False,relationFailures=[],services=[],when=[]))
 return dict(version=1,components=[dict(name=n,storage=category) for n in ['Position','Velocity','Health']],resources=[],events=[],relations=[],machines=[],services=[],schedules=[dict(name='Update',steps=[dict(kind='system',system=n) for n in names]+[dict(kind='applyDeferred')])],systems=systems,access=dict(components=[dict(name=n,readers=names,writers=names if n=='Velocity' else []) for n in ['Position','Velocity','Health']],resources=[],events=[]),lints=[dict(severity='info',code='component-never-read',subject='Velocity',message='Velocity is written by main, added, changed, withoutHealth, withHealth but read by no other described system')])
def scene(category):
 positions=[[1,101],[2,102],[3,103]];velocities=[[10,201],[20,202],None];health=[[100,301],None,[300,303]]
 phases=[];frame=1;tick=2
 def observe(label,operation,descriptions=[]):
  entities=[]
  for i in range(3):
   components={'Position':positions[i]}
   if velocities[i] is not None:components['Velocity']=velocities[i]
   if health[i] is not None:components['Health']=health[i]
   entities.append(dict(id=i+1,components=components,relations={}))
  phases.append(copy.deepcopy(dict(label=label,operation=operation,descriptions=descriptions,dump=dict(version=1,frame=frame,tick=tick,entityCount=3,entities=entities,resources={},machines={},pendingCommands=[]),population=dict(entities=3,components=dict(Position=3,Velocity=2,Health=2)),streams=[],frame=frame)))
 success={'ok':True}
 observe('seed',dict(result=success,attempts=[]));frame+=1
 observe('register',dict(result=success,attempts=[]))
 def run(label,ids,failure=False):
  nonlocal frame,tick
  frame+=1;tick+=1;attempts=[]
  for i in ids:
   attempts.append(dict(entity=i+1,position=positions[i].copy(),velocityBefore=velocities[i].copy(),health=dict(present=True,value=health[i].copy()) if health[i] is not None else dict(present=False)))
   if failure:break
   velocities[i]=[velocities[i][0]+positions[i][0],*velocities[i][1:]]
  result=dict(ok=False,error=dict(kind='SystemFailure',system='main',error='Failure')) if failure else success
  observe(label,dict(result=result,attempts=attempts))
 run('main-fail',[0,1],True);run('main-retry',[0,1]);run('main-second',[0,1]);run('added-first',[0,1]);run('added-empty',[])
 frame+=1;tick+=1;positions[1]=[5,102];observe('position-e2-replace',dict(result=success,attempts=[]))
 run('changed-first',[0,1]);run('changed-empty',[]);run('without-health',[1]);run('with-health',[0])
 observe('app-enabled-descriptions',dict(kind='describe'),[description(category),description(category)])
 observe('app-disabled-description',dict(kind='disabledRuntime',hasDebug=False))
 observe('foreign-registration-refusal',dict(kind='notExpressible',reason='No public nominal World/System registration refusal API'))
 return dict(category=category,phases=phases)
if __name__=='__main__':
 Path(__file__).with_name('expected.json').write_text(json.dumps([scene(c) for c in ['plain','transient','constructed']],indent=2)+'\n')
