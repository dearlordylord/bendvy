"""Independent complete ordinary adoption oracle; no runtime output input."""
import copy,json,hashlib
from pathlib import Path
HERE=Path(__file__).resolve().parent
PRIOR=HERE.parent.parent/'retained-codec-v1/independent-oracle-v2.json'
def ordinary():
    recipe={'key':'Payload','codec':{'ArrayValue':{'LiteralValues':[7,9]}}}
    column={'values':{'ANode':[{'ALeaf':{'Some':[7,9]}},{'ALeaf':None}]},'stamps':[]}
    inventory=[{'kind':kind,'key':name,'name':name} for kind,name in [('Component','Payload'),('Component','Scratch'),('Resource','Settings'),('Resource','ScratchSettings')]]
    return {'inventory':inventory,'admission':{
        'accepted':{'recipe':copy.deepcopy(recipe),'checked':{'Accepted':[7,9]},'column':copy.deepcopy(column)},
        'rejected':{'recipe':copy.deepcopy(recipe),'checked':{'Rejected':{'Invalid':{'path':'$[0]','expected':'literal','actual':11}}},'before':copy.deepcopy(column),'after':copy.deepcopy(column),'incoming':[11,13]}}}
def expected():
    data=PRIOR.read_bytes();assert hashlib.sha256(data).hexdigest()=='9682fe82bd7aa2cc54c9b6feb731616497231a6e8a8065fc7a40f1c68d4d9bcf'
    return {'scenario':json.loads(data),'ordinary':ordinary()}
if __name__=='__main__':print(json.dumps(expected(),indent=2))
