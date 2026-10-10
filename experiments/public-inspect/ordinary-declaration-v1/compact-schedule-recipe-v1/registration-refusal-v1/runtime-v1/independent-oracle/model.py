"""Independent complete source-only missing model, no runtime stdout."""
from pathlib import Path
import types,json,hashlib
HERE=Path(__file__).resolve().parent
owner=types.ModuleType("owner");owner.__file__=str(HERE/"owner-model.py.source")
exec(compile((HERE/"owner-model.py.source").read_bytes(),owner.__file__,"exec"),owner.__dict__)
base=owner.base
KIND="refusal"
def world(seeded,value,removed=False):
    s=base.state(seeded,value,True)
    if removed:s=s.replace("registrations=[2:CounterUpdate:[Counter], 1:PositionRead:[Position, Position]]","registrations=[1:PositionRead:[Position, Position]]")
    return s
def snapshot(seeded,value,enabled=True,removed=False):
    s=base.snapshot(seeded,value,True,False,False,enabled)
    label,_=s.split("|world{",1)
    return label+"|"+owner.owners(seeded)+"|"+world(seeded,value,removed)
def scenario(seeded):
    missing=KIND=="missing";value=10 if missing else 11
    first="FirstRun:MissingProvision:[Resource:7]" if missing else "FirstRun:args=Some:ResourceArgs:Unit:Rejected"
    second="SecondRun:MissingProvision:[Resource:7]" if missing else "SecondRun:args=None:Rejected"
    lines=[snapshot(seeded,10),snapshot(seeded,10,False),snapshot(seeded,10),first+"|"+owner.owners(seeded)+"|"+world(seeded,value,not missing),snapshot(seeded,value,removed=not missing),second+"|"+owner.owners(seeded)+"|"+world(seeded,value,not missing),snapshot(seeded,value,removed=not missing),snapshot(seeded,value,False,not missing),snapshot(seeded,value,removed=not missing)]
    return ''.join(s+'\n' for s in lines)
def report():return ('consumer.Report{'+json.dumps(scenario(False))+', '+json.dumps(scenario(True))+'}\n').encode()
if __name__=="__main__":
    raw=report();print(len(raw),hashlib.sha256(raw).hexdigest())
