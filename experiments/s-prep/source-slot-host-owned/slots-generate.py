#!/usr/bin/env python3
"""Author finite balanced full-cell Slot traces with literal independent expectations."""
import pathlib,json,hashlib
H=pathlib.Path(__file__).resolve().parent
template=H.parents[0]/'source-packed-cache-slot-controls/slot.bend'
assert hashlib.sha256(template.read_bytes()).hexdigest()=='cab3728de6a0c10d3a73581b1ce990238460e11b19b25ae0e48a65728248bdf5'
base=template.read_text()
# Existing authored Motion fixture kept; extend finite balanced payload depth by one.
line='    run(16,'
arr='[100:U32^4n]'
for i in range(1,16):arr=f'Array.set(U32,{arr},{i},{100+i})'
base=base.replace('    return Unit{}','    run(16,'+arr+')\n    return Unit{}')
(H/'motion-slot.bend').write_text(base)
health=base.replace('PositionView','VitalsView').replace('PrototypeMotionMainSlot','PrototypeHealthMainSlot').replace('position','vitals')
health=health.replace('CP.PrototypeHealthMainSlot{array,frame,a,b,c,d,cf}','CP.PrototypeHealthMainSlot{array,reserve,class,a,b,c,d,cr,cc}')
health=health.replace('U32.show(frame)','U32.show(reserve)').replace('T.VitalsView{T.Four{a,b,c,d},cf}','T.VitalsView{T.Four{a,b,c,d},cr,cc}')
health=health.replace('CP.PrototypeHealthMainSlot{array,4,999,200,300,400,77}','CP.PrototypeHealthMainSlot{array,4,5,999,200,300,400,77,88}')
health=health.replace('rawFrame','rawReserve').replace(' ++ ",\\\"cached\\\":"',' ++ ",\\\"rawClass\\\":" ++ U32.show(class) ++ ",\\\"cached\\\":"')
(H/'health-slot.bend').write_text(health)
for schema in ['motion','health']:
 lines=[]
 for length in [1,2,4,8,16]:
  fields={'a':700,'b':200,'c':300,'d':400};prior={'a':999,'b':200,'c':300,'d':400}
  if schema=='motion':view={'coordinates':fields,'frame':77};retained={'coordinates':prior,'frame':77};metadata={'rawFrame':4}
  else:view={'levels':fields,'reserve':77,'class':88};retained={'levels':prior,'reserve':77,'class':88};metadata={'rawReserve':4,'rawClass':5}
  lines.append(json.dumps({'length':length,'array':[700]+list(range(101,100+length)),**metadata,'cached':view,'retained':retained,'old':[100,500]},separators=(',',':')))
 (H/(schema+'-slot-expected.txt')).write_text('\n'.join(lines)+'\n')
