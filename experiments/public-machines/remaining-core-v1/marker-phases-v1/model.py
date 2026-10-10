"""Three complete marker-phase checkpoints, independently source-derived."""
import json

def listing(items):return '['+', '.join(items)+']'
def slot(current,pending,previous,changed):
    return current+'/'+pending+'/previous='+previous+'/changed='+str(changed)
def checkpoint(label,flow,level,events,pending,clock,cursor,cohort):
    text=('ns=1/next=1/high=0/capacity=1/depth=0/live=L(False)'
          '/components=N(L(N(L(13),L(29))),L(L(47)))/resource=N(L(31),L(37))'
          '/slot='+flow+'/level='+level+'/events='+listing(events)+f'/pending={pending}'
          '/registrations=[1:phases:[Flow.next, Level.next]]/nextSystem=2'+f'/clock={clock}'
          '/registry=1:1:phases:[Flow.next, Level.next]'+f':cursor={cursor}'
          '/cohort='+cohort+'/owners=N(L(43),L(59))/status=ok')
    return label+':'+text+'\n'
def render():
    events=['seed']
    text=checkpoint('initial',slot('Boot:10','Play:20:skip=False','Pause:90','False'),slot('Boot:90','Pause:30:skip=False','Play:70','False'),events,1,17,0,'none,none')
    # Global structural flush runs the one existing clock increment. Capture
    # resets both initial pending slots before any apply/exit/transition/enter.
    for label,oldflow,oldlevel,currentflow,currentlevel,cohort in [
       ('marker1','Boot:10','Boot:90','Play:20','Pause:30','Play:20:skip=False,Pause:30:skip=False'),
       ('marker2','Play:20','Pause:30','Pause:50','Play:60','Pause:50:skip=False,Play:60:skip=False')]:
        events += ['applyFlow:'+oldflow+'->'+currentflow,'applyLevel:'+oldlevel+'->'+currentlevel]
        # Every real tracked hook reads both current values before queuing. No
        # hook applies a pending queue or advances the clock. Enter overwrites
        # the exit-queued Level Boot40 with Play60; Flow Pause50 persists.
        events += [name+':Flow='+currentflow+',Level='+currentlevel for name in
                   ['exitFlow','exitLevel','transitionFlow','transitionLevel','enterFlow','enterLevel']]
        text += checkpoint(label,slot(currentflow,'Pause:50:skip=False',oldflow,'True'),slot(currentlevel,'Play:60:skip=False',oldlevel,'True'),events,0,18,18,cohort)
    # Entry returns String; installed show_val uses JSON quoting, including the
    # trailing checkpoint newline inside the String plus output newline.
    return (json.dumps(text)+'\n').encode()
if __name__=='__main__':
    import sys
    sys.stdout.buffer.write(render())
