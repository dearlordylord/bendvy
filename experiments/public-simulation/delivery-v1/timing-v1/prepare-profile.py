"""Conditional before diagnostic preparation; no profiler execution."""
import hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def prepare():
    source=Path('/tmp/bendvy63-timing-application-plan-v2.json');plan=json.loads(source.read_bytes())
    if sha(source)!='d0bfccde74693866af1e74e7cfce3ce9dd743a1407c71aa6de2db0eca024baea':raise ValueError('qualified application source required')
    out=Path('/tmp/bendvy63-simulation-js-before-profile-v1');original=Path('/tmp/bendvy63-ordinary-delivery-v6/simulation.js')
    if out.exists()or out.is_symlink():raise ValueError('fresh profile outputs required')
    tools=plan['toolConfiguration']['tools'];commands=[]
    for role,flag,name in [('CPU','--cpu-prof','simulation.cpuprofile'),('allocation','--heap-prof','simulation.heapprofile')]:
        commands.append(dict(label='before-'+role,argv=[tools['taskset'],'-c','5',tools['node'],flag,flag+'-dir='+str(out),flag+'-name='+name,str(original)],capSeconds=5,control=role,emits=name))
    files=[HERE.parent/'run-delivery.py',HERE/'prepare-profile.py',HERE/'validate-profile.py',HERE/'SAMPLING-READINESS.md',HERE/'test-profile.py',source,Path('/tmp/bendvy63-ordinary-delivery-v6/receipt.json'),original]
    pins=dict(plan['pins'])
    for file in files:pins[str(file.resolve())]=sha(file)
    plan.update(pins=pins,smallInputPaths=sorted(set(plan['smallInputPaths'])|{str(p.resolve())for p in files}),outputRoot=str(out),commands=commands,qualificationValidator=str(HERE/'validate-profile.py'),maximumProbeCommands=48,scope='Conditional before whole-process CPU/sampled-allocation diagnostic on exact unchanged JS simulation; includes startup/printer/JIT and is not timed-region memory or RSS measurement',timing='Prepare only; execute after confirmed comparative signal and separate admission; no repeated observations/aftercandidate yet')
    return plan
if __name__=='__main__':print(json.dumps(prepare(),indent=2))
