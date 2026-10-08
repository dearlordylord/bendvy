"""Portable audit of historical development cohorts; executes no backend."""
import hashlib,io,json,tarfile
from pathlib import Path
HERE=Path(__file__).resolve().parent
sha=lambda b:hashlib.sha256(b).hexdigest()
def same(a,b):
    assert type(a) is type(b)
    if isinstance(a,dict):
        assert a.keys()==b.keys()
        for key in a:same(a[key],b[key])
    elif isinstance(a,list):
        assert len(a)==len(b)
        for x,y in zip(a,b):same(x,y)
    else:assert a==b

def main():
    selected=json.loads((HERE/'FILES.json').read_bytes())
    for name,digest in selected['files'].items():assert sha((HERE/name).read_bytes())==digest,name
    data={}
    with tarfile.open(fileobj=io.BytesIO((HERE/'evidence.tar.gz').read_bytes()),mode='r:gz') as archive:
        for member in archive:
            assert member.isfile() and not member.name.startswith('/') and '..' not in Path(member.name).parts
            assert member.name not in data
            assert Path(member.name).name not in ('consumer.js','consumer.c','consumer.native')
            data[member.name]=archive.extractfile(member).read()
    assert {name:sha(b) for name,b in data.items()}==json.loads((HERE/'index.json').read_bytes())['members']
    def raw(path):return data[path.split('/public-adoption-v1/',1)[1]]
    def cohort(name,labels,caps,status):
        prefix='development/'+name+'/'
        receipt=json.loads(data[prefix+'receipt.json'])
        assert receipt['status']==status and not receipt.get('guardFailures')
        assert [r['label'] for r in receipt['commands']]==labels
        assert [r['capSeconds'] for r in receipt['commands']]==caps
        assert receipt['environment']['BEND_NO_TELEMETRY']=='1'
        for row in receipt['commands']:
            assert row['exit']==0 and row['failure'] is None and row['argv'][1:3]==['-c','5']
            for stream in ['stdout','stderr']:
                b=raw(row[stream]['path']);assert len(b)==row[stream]['bytes'] and sha(b)==row[stream]['sha256']
            assert raw(row['stderr']['path'])==b''
        frozen=receipt['sourceStage']
        assert len(frozen['sources'])==41
        actual={Path(row['copy']).name:sha(raw(row['copy'])) for row in frozen['sources']}
        assert actual==frozen['inventory']
        for row in frozen['sources']:assert sha(raw(row['copy']))==row['copySHA256']
        mutation=receipt.get('mutation')
        for join in frozen['importJoins']:
            observed=sha(raw(join['copyTarget']))
            if mutation and join['copyTarget']==mutation['copy']:
                assert join['copyTargetSHA256']==mutation['originalSHA256']
                assert observed==mutation['mutantSHA256']
            else:assert observed==join['copyTargetSHA256']
        result=raw(receipt['commands'][-1]['stdout']['path'])
        return receipt,result
    js,jsraw=cohort('js-direct-v1',['emit','consumer'],[30,5],'DEVELOPMENT_PASS')
    native,nativeraw=cohort('native-direct-v1',['emit','build','consumer'],[30,120,5],'DEVELOPMENT_PASS')
    mutant,mutantraw=cohort('js-product-mutant-v1',['source','emit','consumer'],[5,30,5],'REACHED_PRODUCT_MUTANT_DETECTED')
    assert jsraw==nativeraw and len(jsraw)==9605
    assert sha(jsraw)=='c381bdeab1e75d6ecbe893baabc2e901ee162499c2e59d838f7cdaa0a9a201dc'
    assert native['commands'][-1]['argv'][-4:]==['--threads','1','--gpu','off']
    assert '-O3' in native['commands'][1]['argv']
    assert js['sourceStage']['inventory']==native['sourceStage']['inventory']
    expected=(HERE.parent/'oracle-review-v1/expected.json').read_bytes()
    counter=(HERE.parent/'oracle-review-v1/expected-product-mutant.json').read_bytes()
    assert sha(expected)=='a73fafb487385764fa1aeb44ee72b55ce41e88c610ad76e45e5e797240ebd216'
    assert sha(counter)=='ea171b9285f89e468f9ca6cf8e4474de7249fc2f429bb1e674639f19c568a02b'
    same(json.loads(jsraw),json.loads(expected));same(json.loads(mutantraw),json.loads(counter))
    assert mutant['positiveOracleRejected'] and json.loads(mutantraw)!=json.loads(expected)
    positive={r['source']:r for r in js['sourceStage']['sources']}
    changed={r['source']:r for r in mutant['sourceStage']['sources']}
    assert positive.keys()==changed.keys()
    delta=json.loads(data['development/cosmetic-eof-delta.json'])
    for source,p in positive.items():
        m=changed[source];before=raw(p['copy']);after=raw(m['copy'])
        if source.endswith('/public-adoption-v1/schema-product.bend'):
            assert before.decode().count('List.append(&2,D.Field,fields,more)')==1
            assert before.replace(b'List.append(&2,D.Field,fields,more)',b'more')==after
        elif source.endswith('/public-adoption-v1/schema.bend'):
            assert before.rstrip()+b'\n'==after
            assert p['sourceSHA256']==delta['executedOriginalSHA256'] and m['sourceSHA256']==delta['integrationSHA256']
        else:assert before==after and p['sourceSHA256']==m['sourceSHA256']
    diffs=json.loads(data['development/js-product-mutant-v1/complete-diff.json'])
    assert len(diffs['completeTypeSensitiveDiffs'])==30 and diffs['exactIndependentWholeCounterfactualMatches']
    controls=json.loads(data['development/source-controls-v1/receipt.json'])
    assert controls['status']=='SOURCE_CONTROLS_PASS' and not controls.get('guardFailures')
    assert len(controls['commands'])==4
    for name,closure in controls['sourceClosures'].items():
        for path,digest in closure['pins'].items():assert sha(data['development/source-controls-v1/inputs/'+digest+'.bend'])==digest
    for row in controls['commands']:
        assert row['exit']==1 and row['failure'] is None and row['capSeconds']==5
        assert raw(row['stdout']['path'])==b''
        stderr=raw(row['stderr']['path']);assert stderr.count(b'Error:')==1
        for stream in ['stdout','stderr']:
            b=raw(row[stream]['path']);assert sha(b)==row[stream]['sha256'] and len(b)==row[stream]['bytes']
    print('PASS: complete development JS/Native oracle, reached product mutant, exact source controls; no delivery/performance/tool qualification')
if __name__=='__main__':main()
