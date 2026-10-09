"""Prepare repeated equal full-lifecycle observations; no execution."""
import argparse,hashlib,json,runpy
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=Path('/workspace/formal-proofs/bendvy');sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def prepare(context, scales):
    old=Path('/tmp/bendvy63-timing-application-plan-v2.json')
    if sha(old)!='d0bfccde74693866af1e74e7cfce3ce9dd743a1407c71aa6de2db0eca024baea':raise ValueError('qualified application plan required')
    plan=json.loads(old.read_bytes());actual=Path('/tmp/bendvy63-timing-application-qualification-v1');receipt=json.loads((actual/'receipt.json').read_bytes())
    if receipt['planSHA256']!=sha(old) or len(receipt['cases'])!=3 or any(not c['reachedControlMatch']for c in receipt['cases'].values()):raise ValueError('complete actual qualification required')
    binary=actual/'simulation.native'
    if sha(binary)!=receipt['generated']['simulation.native']:raise ValueError('qualified binary drift')
    contract=ROOT/'benchmarks/contract.json';rows=runpy.run_path(str(HERE/'sampling.py'))['schedule'](json.loads(contract.read_bytes()),scales)
    tools=plan['toolConfiguration']['tools'];inputs=Path('/tmp/bendvy63-timing-application-input-v1');out=Path('/tmp/bendvy63-timing-paired-scale'+''.join(map(str,scales))+'-v1')
    if out.exists()or out.is_symlink():raise ValueError('fresh sampling outputs required')
    roles={'TS':[tools['node'],str(inputs/'reference.mjs')],'JS':[tools['node'],str(inputs/'simulation.js')],'Native':[str(binary),'--threads','1','--gpu','off']}
    commands=[dict(label=r['label'],argv=[tools['taskset'],'-c','5',*roles[r['role']]],capSeconds=5,control=r['role'])for r in rows]
    files=[HERE.parent/'run-delivery.py',HERE/'sampling.py',HERE/'test-sampling.py',HERE/'prepare-sampling.py',HERE/'SAMPLING-READINESS.md',Path('/tmp/bendvy63-cpu5-quiet-context-v1.json'),contract,old,actual/'receipt.json',binary,HERE/'evidence-application-v2/MANIFEST.json',HERE/'evidence-application-v2/verify.py']
    pins=dict(plan['pins'])
    for file in files:pins[str(file.resolve())]=sha(file)
    toolconfig=dict(plan['toolConfiguration']);toolconfig['tools']=dict(tools,qualifiedSimulationNative=str(binary))
    plan.update(pins=pins,smallInputPaths=sorted(set(plan['smallInputPaths'])|{str(p.resolve())for p in files if p!=binary}),toolConfiguration=toolconfig,outputRoot=str(out),commands=commands,samplingRows=rows,samplingHelper=str(HERE/'sampling.py'),quietWindowContext=context,maximumProbeCommands=9*(2*len(commands)+2),scope=str(len(commands))+' fresh process full14phase/twoschema applications;20balancedpairs/2warmups for lifecycle groups'+str(scales)+'; fullgroups1/2/4 contract remains visible, no same-process largerworld/statistical verdict/#28 baseline change',timing='Requires integrator quiet-window context and exact independent plan admission; process startup/build excluded; transport retained separately')
    return plan
if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--quiet-window',required=True);parser.add_argument('--scales',nargs='+',type=int,default=[1]);args=parser.parse_args();print(json.dumps(prepare(args.quiet_window,args.scales),indent=2))
