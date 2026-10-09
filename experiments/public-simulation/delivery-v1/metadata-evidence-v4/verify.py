"""No-child full actual v4 metadata archive and progressive guard verifier."""
import gzip,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
sha=lambda raw:hashlib.sha256(raw).hexdigest()
def verified():
    manifest=json.loads((HERE/'MANIFEST.json').read_text());raws={}
    for row in manifest['members']:
        path=HERE/row['archive'];assert path.is_file()and not path.is_symlink()
        compressed=path.read_bytes();assert sha(compressed)==row['archiveSHA256']
        raw=gzip.decompress(compressed);assert len(raw)==row['bytes']and sha(raw)==row['sha256'];assert row['source']not in raws;raws[row['source']]=raw
    assert {str(p.relative_to(HERE))for p in(HERE/'archive').glob('*.gz')}=={x['archive']for x in manifest['members']}
    planpath='/tmp/bendvy63-loader-metadata-plan-v4.json';plan=json.loads(raws[planpath]);digest=sha(raws[planpath]);assert digest=='27830e5ea5d1b81fa6d02a65e1e0ce2f1c3d19241a9354714f9694d931c2824f'
    root=Path(plan['outputRoot']);receipt=json.loads(raws[str(root/'receipt.json')]);assert receipt['planSHA256']==digest and receipt['status']=='METADATA_CAPTURED_NOT_RESOLVER_ADMISSION'
    assert not receipt.get('error')and not receipt.get('guardFailures')and receipt['closedResolverQualified']is False
    assert len(receipt['commands'])==len(plan['commands'])==10 and len(receipt['guards'])==31
    expected=dict(plan['pins']);expected[planpath]=digest;guard_index=0
    def guard(label):
        nonlocal guard_index
        binding=receipt['guards'][guard_index];guard_index+=1;assert binding['path']==str(root/(label+'.guard.json'))
        raw=raws[binding['path']];assert sha(raw)==binding['sha256'];value=json.loads(raw)
        assert value['label']==label and value['unchanged']is True and value['actualPins']==expected and value['namespace']==plan['namespace']
    for planned,row in zip(plan['commands'],receipt['commands']):
        assert row['label']==planned['label']and row['argv']==planned['argv']and row['argv'][:3]==['/usr/bin/taskset','-c','5']
        assert row['exit']==0 and row['failure']is None and row['capSeconds']==planned['capSeconds']==5
        assert row['runnerSHA256']==plan['pins']['/workspace/formal-proofs/bendvy/scripts/task_runner.py']
        guard(row['label']+'-pre');guard(row['label']+'-acquired')
        for stream in ['stdout','stderr']:
            binding=row[stream];raw=raws[binding['path']]
            assert binding['path']==planned[stream]and binding['publication']=='PUBLISHED'
            assert sha(raw)==binding['sha256']==binding['returnedSHA256']and len(raw)==binding['bytes']==binding['returnedBytes']
            if stream=='stderr':assert raw==b''
            expected[binding['path']]=sha(raw)
        guard(row['label']+'-post')
    guard('final');assert guard_index==31
    for path,raw in raws.items():
        if path in plan['pins']:assert sha(raw)==plan['pins'][path]
    # Exact executed source is archived; current worker helper is not its authority.
    return plan,receipt,raws
if __name__=='__main__':
    plan,receipt,raws=verified();print(json.dumps({'members':len(raws),'commands':10,'guards':31,'metadata':'PASS','resolverAdmission':False,'newChildren':0}))
