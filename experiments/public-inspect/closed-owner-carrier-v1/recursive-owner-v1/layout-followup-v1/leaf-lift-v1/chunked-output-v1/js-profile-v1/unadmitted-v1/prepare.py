"""Prepare four matched artifact-only Node diagnostics; no child."""
from pathlib import Path
import gzip
import hashlib
import json

HERE=Path(__file__).resolve().parent
ROOT=Path('/workspace/formal-proofs/bendvy')
sha=lambda path:hashlib.sha256(Path(path).read_bytes()).hexdigest()
SUBJECTS={'before':Path('/tmp/bendvy-inspect54-leaf-lift-js02'),
          'after':Path('/tmp/bendvy-inspect54-chunk-backend02/normal-js')}

def main():
    subjects={name:json.loads((path/'plan.json').read_text())for name,path in SUBJECTS.items()}
    assert subjects['before']['environment']==subjects['after']['environment']
    assert subjects['before']['tools']['node']==subjects['after']['tools']['node']
    assert subjects['before']['resourceRoots']==subjects['after']['resourceRoots']
    entries=[];originals={}
    for name,original in SUBJECTS.items():
        old=subjects[name];receipt=json.loads((original/'receipt.json').read_text())
        artifact=Path(old['generated'])
        assert not artifact.is_symlink() and artifact.is_file()
        assert receipt['status']=='COMPLETE_CONSUMER_DEVELOPMENT_PASS'
        assert sha(artifact)==receipt['emitArtifactSHA256']
        assert len(old['sourceInventory'])==46
        assert {str(path.relative_to(old['stage'])):sha(path)for path in Path(old['stage']).rglob('*.bend')}==old['sourceInventory']
        assert old['oracleBytes']==5077477
        expected=gzip.decompress(Path(old['oracle']).read_bytes())
        assert len(expected)==5077477 and hashlib.sha256(expected).hexdigest()=='810259f78227f2b3d158c02644978b6c7ecf58b40a4b2fb398a816005b2867e2'
        assert all(command['exit']==0 and command['failure']is None for command in receipt['commands'])
        pins={str(Path(old['stage'])/path):digest for path,digest in old['sourceInventory'].items()}
        pins[str(artifact)]=sha(artifact)
        for path in original.iterdir():
            if path.is_file():pins[str(path)]=sha(path)
        for guard in receipt['guards']:
            assert sha(guard['path'])==guard['sha256']
        for tool in ('python','node','taskset'):
            path=old['tools'][tool];assert sha(path)==old['pins'][path];pins[path]=sha(path)
        pins[old['oracle']]=sha(old['oracle'])
        for path in (ROOT/'scripts/task_runner.py',ROOT/'scripts/evidence_boundary.py'):
            pins[str(path)]=sha(path)
        for path in HERE.iterdir():
            if path.is_file() and path.name not in ('INDEX.json','SUBJECTS.json'):
                pins[str(path)]=sha(path)
        originals[name]={'plan':str(original/'plan.json'),'planSHA256':sha(original/'plan.json'),
                         'receipt':str(original/'receipt.json'),'receiptSHA256':sha(original/'receipt.json'),
                         'artifact':str(artifact),'artifactSHA256':sha(artifact),'sourceInventory':old['sourceInventory'],
                         'originalScope':'Historical stock emit + exact whole Node output; emitter not executed by profile'}
        for kind,flag,extension,interval in [('CPU','--cpu-prof','cpuprofile',100),('allocation','--heap-prof','heapprofile',8192)]:
            output=Path('/tmp/bendvy-inspect54-chunk-js-profile01')/(name+'-'+kind)
            output.mkdir(parents=True)
            assert list(output.iterdir())==[]
            profile=output/('scenario.'+extension)
            plan=dict(old)
            plan.update(scope='Matched whole-process '+name+' '+kind+' diagnostic; full output required, no timing/performance/adoption claim',
                        pins=pins,cwd=str(HERE),generated=str(artifact),native=str(artifact),
                        profileKind=kind,profileArtifact=str(profile),priorSubject=originals[name],
                        commands=[{'label':'consumer','argv':[old['tools']['taskset'],'-c','5',old['tools']['node'],flag,
                                   flag+'-dir='+str(output),flag+'-name='+profile.name,flag+'-interval='+str(interval),str(artifact)],
                                   'capSeconds':5}],
                        postConsumer='Exact independent 5077477-byte stdout, empty stderr, complete declared profile; sampled retained allocations != total allocation/RSS')
            path=output/'plan.json';path.write_text(json.dumps(plan,indent=2)+'\n')
            entries.append({'subject':name,'kind':kind,'plan':str(path),'sha256':sha(path),
                            'launchArgv':[old['tools']['python'],str(HERE/'development.py'),str(path),sha(path)]})
    (HERE/'SUBJECTS.json').write_text(json.dumps(originals,indent=2)+'\n')
    (HERE/'INDEX.json').write_text(json.dumps({'status':'FROZEN_UNADMITTED_NO_PROFILE_CHILD','entries':entries,
                                            'matched':'same Node24.20/CPU5/environment/independent full5077477oracle/5s cap; profiler settings equal by mode',
                                            'RSS':'Linux reaped subprocess-subtree peakRSS KiB includes runner owner+Node; no Node-only/timed-region claim'},indent=2)+'\n')
    print(json.dumps(entries,indent=2))

if __name__=='__main__':main()
