"""Independent finite apply-retention model; no backend output inputs."""
import json
from pathlib import Path

def listing(items): return '['+', '.join(items)+']'
def slot(current,pending,previous,changed):
    return current+'/'+pending+'/previous='+previous+'/changed='+str(changed)
def checkpoint(label,flow,level,events,pending,clock,cursor,cohort):
    return label+':'+('ns=1/next=1/high=0/capacity=1/depth=0/live=L(False)'
      '/components=N(L(N(L(13),L(29))),L(L(47)))/resource=N(L(31),L(37))'
      '/slot='+flow+'/level='+level+'/events='+listing(events)+f'/pending={pending}'
      '/registrations=[1:phases:[Flow.next, Level.next]]/nextSystem=2'+f'/clock={clock}'
      '/registry=1:1:phases:[Flow.next, Level.next]'+f':cursor={cursor}'
      '/cohort='+cohort+'/owners=N(L(43),L(59))/status=ok')+'\n'
def render(drop=False):
    events=['seed']
    flow,level='Boot:10','Boot:90'
    fp,lp='Play:20','Pause:30'
    fprev,lprev='Pause:90','Play:70'
    text=checkpoint('initial',slot(flow,fp+':skip=False',fprev,False),slot(level,lp+':skip=False',lprev,False),events,1,17,0,'none,none')
    for label in ('marker1','marker2'):
        # Structural barrier drains seed once. Whole cohort resets pending
        # before applyFlow; applyQueueLevel then queues the next Level request.
        cf,cl=fp,lp
        fp=lp=None
        cohort=cf+':skip=False,'+(cl+':skip=False' if cl else 'none')
        old=flow; flow=cf; fprev=old
        events.append('applyFlow:'+old+'->'+flow)
        events.append('applyQueueLevel:Flow='+flow+',Level='+level)
        lp='Boot:40'
        if cl is not None:
            old=level; level=cl; lprev=old
            events.append('applyLevel:'+old+'->'+level)
            if drop: lp=None
        # Unscheduled Level returns the slot unchanged, including Boot40.
        for hook in ('exitFlow','exitLevel','transitionFlow','transitionLevel','enterFlow','enterLevel'):
            events.append(hook+':Flow='+flow+',Level='+level)
            if hook=='transitionFlow': fp='Pause:50'
        text+=checkpoint(label,slot(flow,fp+':skip=False',fprev,True),slot(level,lp+':skip=False' if lp else 'none',lprev,True),events,0,18,18,cohort)
    return (json.dumps(text)+'\n').encode()
if __name__=='__main__':
    import sys
    sys.stdout.buffer.write(render('--drop' in sys.argv))
