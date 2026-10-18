"""Independent greenhouse state machine, frozen before either backend runs."""
from pathlib import Path
import gzip
plants=[10,20]
entered=total=clock=cursor=0
clock=2 # two initial component insertions, no ticks for reserve/activate
lines=[]
for watering in (True,True,False,True):
    water=[]
    for i,height in enumerate(plants):
        plants[i]=height+int(watering)
        clock+=int(watering)
        water.append(plants[i])
    original=plants.copy()
    growth=[]
    status=1
    if watering: # Changed since the preceding successful growth query
        for i,height in enumerate(plants):
            entered+=1
            total+=height
            plants[i]=height+10
            clock+=1
            if entered==2:
                plants=original
                growth=[]
                status=2
                break
            growth.append(plants[i])
    if status==1:
        cursor=clock
    numbers=lambda xs: ''.join(f'{x},' for x in xs)
    lines.append('|'.join([numbers([status,cursor,entered,total]),numbers(plants),numbers(water),numbers(growth)]))
expected=('\n'.join(lines)+'\nsealed=77\n').encode()
root=Path(__file__).resolve().parent
(root/'expected.stdout').write_bytes(expected)
(root/'expected.stdout.gz').write_bytes(gzip.compress(expected,mtime=0))
print(expected.decode(),end='')
