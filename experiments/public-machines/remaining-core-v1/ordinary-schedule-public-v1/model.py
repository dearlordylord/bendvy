"""Complete ordinary Sch.run trace; source-derived, no backend input."""
import json
from pathlib import Path

def listing(items): return '['+', '.join(items)+']'
def slot(current,pending,previous,changed):
    return current+'/'+pending+'/previous='+previous+'/changed='+str(changed)
def checkpoint(label,flow,level,events,pending,clock,cursor,cohort,variant):
    return label+':'+('ns=1/next=1/high=0/capacity=1/depth=0/live=L(False)'
      '/components=N(L(N(L(13),L(29))),L(L(47)))/resource=N(L(31),L(37))'
      '/slot='+flow+'/level='+level+'/events='+listing(events)+f'/pending={pending}'
      '/registrations=[1:phases:[Flow.next, Level.next]]/nextSystem=2'+f'/clock={clock}'
      '/registry=1:1:phases:[Flow.next, Level.next]'+f':cursor={cursor}'
      '/cohort='+cohort+'/owners=N(L(43),L(59))/status=ok')+schedule_text(label,variant)+'\n'
def schedule_text(label,variant):
    groups=[('exit',2),('apply',1),('transition',3),('enter',4)] if variant=='order' else [('apply',1),('exit',2),('transition',3),('enter',4)]
    steps=['barrier']
    for name,i in groups: steps+=['phase:'+name,'system:'+str(i)+':condition=0']
    observations=[]
    status='ready'
    if label!='initial':
        status='rejected' if variant=='rejected' else 'failed:finite-phase-error' if variant=='failure' else 'finished'
        if variant!='rejected':
            observations=['applied']
            for name,i in groups:
                observations+=['entered:'+name,'ran:'+str(i)]
                if variant=='failure' and i==3: break
    return '/schedule='+('9' if variant=='rejected' else '1')+':ordinary-machine-marker:'+listing(steps)+'/observations='+listing(observations)+'/scheduleStatus='+status

def render(variant):
    events=['seed'];flow,level='Boot:10','Boot:90';fp,lp='Play:20','Pause:30';fprev,lprev='Pause:90','Play:70';fc=lc=False;cohort='none,none';clock,pending,cursor=17,1,0
    def checkpoint_now(label):
        return checkpoint(label,slot(flow,fp+':skip=False' if fp else 'none',fprev,fc),slot(level,lp+':skip=False' if lp else 'none',lprev,lc),events,pending,clock,cursor,cohort,variant)
    text=checkpoint_now('initial')
    def hooks(names):
        nonlocal fp,cursor
        for name in names:
            events.append(name+':Flow='+flow+',Level='+level);cursor=clock
            if name=='transitionFlow':fp='Pause:50'
    for label in ('marker1','marker2'):
        if variant!='rejected':
            clock,pending=18,0
            if variant=='order':hooks(('exitFlow','exitLevel'))
            cf,cl=fp,lp;fp=lp=None
            cohort=(cf+':skip=False' if cf else 'none')+','+(cl+':skip=False' if cl else 'none')
            if cf:
                old=flow;flow=cf;fprev=old;fc=True;events.append('applyFlow:'+old+'->'+flow)
            events.append('applyQueueLevel:Flow='+flow+',Level='+level);cursor=clock;lp='Boot:40'
            if cl:
                old=level;level=cl;lprev=old;lc=True;events.append('applyLevel:'+old+'->'+level)
            if variant!='order':hooks(('exitFlow','exitLevel'))
            if variant=='failure':events.append('finite-phase-failure')
            else:hooks(('transitionFlow','transitionLevel','enterFlow','enterLevel'))
        text+=checkpoint_now(label)
    return (json.dumps(text)+'\n').encode()
if __name__=='__main__':
    import sys
    sys.stdout.buffer.write(render(sys.argv[1]))
