#!/usr/bin/env python3
"""Fresh unchanged archived public eight contracts; separate from private Slot proof."""
from pathlib import Path
import sys,json,hashlib,subprocess,os,signal,importlib.util,argparse
H=Path(__file__).resolve().parent;ROOT=Path('/workspace/formal-proofs/bendvy');G=ROOT/'experiments/s-prep/fivehour-connected-gates';sys.path.insert(0,str(G));import provider_controls as PC;import static_provider_boundary as SPB
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{9});base=Path('/tmp/bendvy-slot-host-v1');sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();m=json.loads((base/'overlay.json').read_text());pins=m['sources'];digest=hashlib.sha256(json.dumps(pins,sort_keys=True,separators=(',',':')).encode()).hexdigest();assert digest=='4baad4960575cda216576e8b90593fbd7ed7dcd44cfa86836b8d87dd5af71f5c';assert all(sha(base/n)==h for n,h in pins.items());c=json.loads((base/'cache-specialization.json').read_text());assert c==m['cacheSpecialization'] and c['runtimeClosure']==c['specializedClosure']==pins and c['runtimeClosureSHA256']==c['specializedClosureSHA256']==digest
r={'status':'INCOMPLETE','scope':'Eight exact archived public rank2 provider contracts against current whole29; not private Slot provider proof','sourcePins':pins,'sourceClosure':digest,'runnerSHA256':sha(Path(__file__)),'protectedRunnerSHA256':sha(G/'static_provider_boundary.py'),'cases':[]}
original=PC.static_registration
try:original(base/'experiments/s-integrate')
except AssertionError as e:r['retainedRegistrationRefusal']=str(e)
# Same callback/body/kind/public-header guards; only identify the actual private registration.
s=(G/'provider_controls.py').read_text();old="assert measurement.count('HA.'+lane+'_row(~SC.'+lane+'_body,')==1,'Static measured callback absent/ambiguous'";new="assert measurement.count('HA.prototype_cursor_flatfold_'+lane+'(~SC.'+lane+'_body,handles,owner,total)')==1,'Actual private cursor registration absent/ambiguous'";assert s.count(old)==1;s=s.replace(old,new)
# exec globals must share its definitions.
namespace={'__file__':str(G/'provider_controls.py')};exec(compile(s,str(G/'provider_controls.py'),'exec'),namespace);PC.static_registration=namespace['static_registration'];assert PC.static_registration(base/'experiments/s-integrate');r['registrationAdapterSHA256']=hashlib.sha256(s.encode()).hexdigest();(a.output/'route-provider-controls.py').write_text(s)
def check(path):
 folder=a.output/path.stem;folder.mkdir();(folder/'subject.bend').write_bytes(path.read_bytes());x=subprocess.Popen(['bend',path,'--check-only'],stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True)
 try:o=x.communicate(timeout=15)[0]
 except subprocess.TimeoutExpired:os.killpg(x.pid,signal.SIGKILL);o=x.communicate()[0];(folder/'checker.txt').write_text(o);raise
 (folder/'checker.txt').write_text(o);return {'exit':x.returncode,'output':o,'limitSeconds':15}
try:
 r['boundary']=SPB.run(base/'experiments/s-integrate',check);assert len(r['boundary']['cases'])==8;r['status']='FRESH_RETAINED_PUBLIC_STATIC_EIGHT_CONTRACTS_PASS'
finally:(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
