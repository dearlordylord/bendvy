"""Independent complete Family bridge oracle, authored before backend outputs."""
import copy,json,hashlib
from pathlib import Path
HERE=Path(__file__).resolve().parent
PRIOR=HERE.parents[2]/'retained-codec-v1/independent-oracle-v2.json'
def tree(a,b):return {'ANode':[{'ALeaf':None if a is None else {'Some':a}},{'ALeaf':None if b is None else {'Some':b}}]}
def observation(namespace,changed=False,removed=False):
    raw=PRIOR.read_bytes();assert hashlib.sha256(raw).hexdigest()=='9682fe82bd7aa2cc54c9b6feb731616497231a6e8a8065fc7a40f1c68d4d9bcf'
    owner=copy.deepcopy(json.loads(raw)['Workshop']['before']);owner['namespace']=namespace
    for h in owner['handles']:h['namespace']=namespace
    first=[11,13] if changed else [7,9]
    owner['store']['saved']['rows'][0]['components']['Payload']=first
    if changed:owner['store']['codec']={'ArrayValue':{'FiniteNumber':{}}}
    if removed:
        owner['store']['saved']['rows'][1]['components']={};owner['clock']=1
    return {'owner':owner,'physical':{'saved':{'values':tree(first,None if removed else [17,19]),'stamps':[{'id':2,'added':0,'changed':0}] if removed else []},'transient':{'values':tree([107,109],[117,119]),'stamps':[]}}}
def schema():
    return {'beforeA':observation(1,True),'beforeB':observation(2),'trace':{'steps':[{'Found':[11,13]},[17,19],'ComponentAbsent','MissingEntity',{'Found':[7,9]}],'afterA':observation(1,True,True),'afterB':observation(2)}}
def expected():
    return {'inventory':[{'kind':kind,'key':name,'name':name} for kind,name in [('Component','Payload'),('Component','Scratch'),('Resource','Settings'),('Resource','ScratchSettings')]],'Workshop':schema(),'Garden':schema()}
if __name__=='__main__':print(json.dumps(expected(),indent=2))
