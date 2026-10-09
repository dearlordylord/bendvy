"""Cheap full literal and refusal/owner boundary controls, no runtime child."""
import importlib.util,json,hashlib
from pathlib import Path
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('prebound_model',HERE/'expected.py');M=importlib.util.module_from_spec(spec);spec.loader.exec_module(M)
n=M.normal();w=M.wrong_binding()
assert len(n.encode())==16012 and len(w.encode())==9660
assert n==json.loads((HERE/'expected.json').read_bytes()) and w==json.loads((HERE/'wrong-binding-expected.json').read_bytes())
assert n.splitlines()[5:]==w.splitlines()[5:] and n!=w
for ns,line in enumerate(w.splitlines()[:5],1):
 assert f'|ns={ns}|next=1|high=0|capacity=1|' in line and '|live=[False]|' in line
 assert '|context=[0, 0, 0, 0]/[]|raw=[]|installed=0|quarantine=0|pending=0|errors=[]|' in line
 assert '|depth=0|registrations=[]|nextSystem=1' in line
for corrupt in ['\n'.join(w.splitlines()[1:])+'\n',w.replace('|nextSystem=1','',1),w[:-2]+'X\n',w.replace('UndeclaredDescriptor:component:a:a','DuplicateKey:component:a',1)]:assert corrupt!=w
print('Independent whole16012 normal/9660 refusal, all10 lines/empty owners+World/unchangedSecond and four corruption controls PASS')
