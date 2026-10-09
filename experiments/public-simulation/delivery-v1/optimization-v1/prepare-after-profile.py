"""Conditional before diagnostic preparation; no profiler execution."""
import hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;TIMING=HERE.parent/"timing-v1";sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def prepare():
    source=Path('/tmp/bendvy63-named-loop-timing-qualification-plan-v3.json');plan=json.loads(source.read_bytes())
    if sha(source)!='58ce9622d0f755531bfec9c17c4b800265ef5d5f423ae7f8d1dc91770e90e2f0':raise ValueError('qualified application source required')
    out=Path('/tmp/bendvy63-named-loop-after-profile-v1');original=Path('/tmp/bendvy63-named-loop-qualification-v1/simulation.js')
    if out.exists()or out.is_symlink():raise ValueError('fresh profile outputs required')
    tools=plan['toolConfiguration']['tools'];commands=[]
    for role,flag,name in [('CPU','--cpu-prof','simulation.cpuprofile'),('allocation','--heap-prof','simulation.heapprofile')]:
        commands.append(dict(label='after-'+role,argv=[tools['taskset'],'-c','5',tools['node'],flag,flag+'-dir='+str(out),flag+'-name='+name,flag+'-interval='+('100' if role=='CPU' else '8192'),str(original)],capSeconds=5,control=role,emits=name))
    files=[HERE.parent/'run-delivery.py',HERE/'prepare-after-profile.py',HERE/'validate-after-profile.py',HERE/'TIMING-READINESS.md',TIMING/'test-profile.py',source,Path('/tmp/bendvy63-named-loop-qualification-v1/receipt.json'),original]
    pins=dict(plan['pins'])
    for file in files:pins[str(file.resolve())]=sha(file)
    plan.update(pins=pins,smallInputPaths=sorted(set(plan['smallInputPaths'])|{str(p.resolve())for p in files}),outputRoot=str(out),commands=commands,qualificationValidator=str(HERE/'validate-after-profile.py'),maximumProbeCommands=48,scope='After-candidate whole-process CPU/sampled-allocation diagnostic on exact unchanged JS simulation; includes startup/printer/JIT and is not timed-region memory or RSS measurement',timing='Prepare only; execute only after paired signal and exact admission; CPU interval100us and sampled heap8192bytes are diagnostic settings, not gates')
    return plan
if __name__=='__main__':print(json.dumps(prepare(),indent=2))
