"""Reuse qualified semantic streams; freshly derive every comparative carrier."""
import argparse,gzip,hashlib,json
from pathlib import Path
import public_model as P
C = P.C
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[5]
sha = lambda raw: hashlib.sha256(raw).hexdigest()

def stream_hash(path):
    digest = hashlib.sha256(); size = 0
    with gzip.open(path, 'rb') as source:
        while data := source.read(1024*1024):
            digest.update(data); size += len(data)
    return dict(bytes=size, sha256=digest.hexdigest())

def main():
    parser = argparse.ArgumentParser(); parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args(); target = args.output.resolve()
    assert not target.exists(), 'Fresh output required'
    basis = json.loads((HERE/'SOURCE-BASIS.json').read_text())
    for name, expected in basis['sourcePins'].items():
        assert sha((ROOT/name).read_bytes()) == expected, name
    old = Path(basis['acceptedSemanticDirectory'])
    assert sha((old/'PILOT-ORACLE-BASIS.json').read_bytes()) == basis['acceptedBasisSHA256']
    accepted = json.loads((old/'PILOT-ORACLE-BASIS.json').read_text())
    assert accepted['status']=='PASS' and (accepted['count'],accepted['iterations'])==(256,64)
    assert sha((P.SOURCE/'SOURCE-BASIS.json').read_bytes())==accepted['sourceBasisSHA256']
    for name, expected in accepted['modelPins'].items():
        assert sha((P.SOURCE/name).read_bytes())==expected
    for role, expected in accepted['oracles'].items():
        assert stream_hash(old/f'{role}-expected.stdout.gz') == {k:expected[k] for k in ['bytes','sha256']}
    for summary in accepted['worlds']:
        ns, foreign = summary['primaryNamespace'], summary['foreignNamespace']
        assert stream_hash(old/f'canonical-ns{ns}-{foreign}.stdout.gz')==summary['canonical']
    fixtures=json.loads(gzip.decompress((old/'observer-fixtures.json.gz').read_bytes()))
    target.mkdir(parents=True); outputs={}; chunks={'bend':[],'ts':[]}; worlds=[]
    for fixture in fixtures:
        ns, foreign=fixture['namespace'],fixture['foreignNamespace']
        f=C.derive(ns,foreign,256,64)
        assert f['common']==fixture['common'] and f['foreign']==fixture['foreign'] and f['actors']==fixture['actors']
        common=C.cells(f['common']); assert common==fixture['tuple']
        assert C.fold(common)==fixture['fold']
        publics={'bend':P.bend_public(f),'ts':P.ts_public(f)}
        summary=dict(label=fixture['label'],primaryNamespace=ns,foreignNamespace=foreign,
                     records=len(f['common']),tupleValues=len(common),fold=C.fold(common),foreign={},public={})
        for role in ['bend','ts']:
            own_foreign=C.cells(f['foreign'][role]); assert own_foreign==fixture['foreignTuples'][role]
            assert C.fold(own_foreign)==fixture['foreignFolds'][role]
            public=C.cells([publics[role]]); public_fold=C.fold(public)
            show=json.dumps if role=='bend' else C.compact
            actors=f['actors'] if role=='bend' else P.original_ts_full(f)['method']['rawActorMap']
            raw=(f"{fixture['label']}\nFORCE:{C.fold(common)}\nFOREIGN-FORCE:{C.fold(own_foreign)}\n"
                 f"PUBLIC-FORCE:{public_fold}\nTUPLE:{show(common)}\nFOREIGN-TUPLE:{show(own_foreign)}\n"
                 f"PUBLIC-TUPLE:{show(public)}\nACTORS:{C.compact(actors)}\n").encode()
            chunks[role].append(raw)
            summary['foreign'][role]=dict(records=len(f['foreign'][role]),tupleValues=len(own_foreign),fold=C.fold(own_foreign))
            summary['public'][role]=dict(publicTupleValues=len(public),publicFold=public_fold,
                                         recordSHA256=sha(C.compact(publics[role]).encode()))
            (target/f'{role}-public-ns{ns}.json.gz').write_bytes(gzip.compress(C.compact(dict(record=publics[role],tuple=public,fold=public_fold)).encode(),mtime=0))
        worlds.append(summary)
    for role, pieces in chunks.items():
        raw=b''.join(pieces); packed=gzip.compress(raw,mtime=0)
        (target/f'{role}-expected.stdout.gz').write_bytes(packed)
        outputs[role]=dict(bytes=len(raw),sha256=sha(raw),gzipSHA256=sha(packed))
    result=dict(status='PASS',count=256,iterations=64,worlds=worlds,oracles=outputs,
                acceptedSemanticBasisSHA256=basis['acceptedBasisSHA256'],
                sourceBasisSHA256=sha((HERE/'SOURCE-BASIS.json').read_bytes()),
                modelPins={p.name:sha(p.read_bytes())for p in HERE.glob('*.py')},
                scope='Qualified original semantic streams/source verified and reused; fresh original operation/common/foreign/maps exactly equal before new own-role public carriers. No subject or comparative performance claim.')
    (target/'PILOT-ORACLE-BASIS.json').write_text(json.dumps(result,indent=2)+'\n'); print(json.dumps(result))
if __name__=='__main__':main()
