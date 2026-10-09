"""Metadata-only prepare; no child launched."""
import hashlib,importlib.util,json,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=Path('/workspace/formal-proofs/bendvy')
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def main(out):
    original=json.loads(Path('/tmp/bendvy-inspect54-garden-native02/plan.json').read_text())
    out=Path(out).resolve();out.mkdir(parents=True,exist_ok=False)
    pins=dict(original['pins'])
    for p in HERE.rglob('*'):
        if p.is_file() and '__pycache__' not in str(p):pins[str(p.resolve())]=sha(p)
    config=ROOT/'experiments/public-simulation/delivery-v1/installed-config.py'
    sp=importlib.util.spec_from_file_location('config',config);m=importlib.util.module_from_spec(sp);sp.loader.exec_module(m)
    node=Path('/home/node/.local/share/mise/installs/node/24.20.0/bin/node').resolve(strict=True)
    taskset=Path('/usr/bin/taskset').resolve(strict=True)
    for p in [node,taskset,config,ROOT/'scripts/task_runner.py',ROOT/'scripts/evidence_boundary.py',Path('/tmp/bendvy-inspect54-garden-native02/plan.json')]:pins[str(p)]=sha(p)
    if {p:sha(p)for p in pins}!=pins:raise ValueError('source binding drift')
    target=out/'reference.c'
    plan={'scope':'Garden exact-source copied-reference compiler progress diagnostic only; no installed ELF binding, Native/performance or complete54 qualification','pins':pins,'entry':original['entrypoint'],'sourceInventory':original['sourceInventory'],'oracleSHA256':original['oracleSHA256'],'wholeOracleSHA256':original['wholeOracleSHA256'],'environment':m.environment(),'output':str(target),'argv':[str(taskset),'-c','5',str(node),str(HERE/'emit.mts'),original['entrypoint'],str(target)],'capSeconds':30,'progressLimit':2048}
    path=out/'plan.json';path.write_text(json.dumps(plan,indent=2)+'\n');print(sha(path))
if __name__=='__main__':main(sys.argv[1])
