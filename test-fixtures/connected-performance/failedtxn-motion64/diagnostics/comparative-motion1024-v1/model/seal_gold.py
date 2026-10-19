"""Reproduce accepted full streams first, then derive the public supplement."""
import argparse
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import sys

PRIOR = Path(__file__).resolve().parents[2] / 'comparative-v1/model'
CONTROL256 = Path(__file__).resolve().parents[2] / 'comparative-motion256-v1/model'
sys.path.insert(0, str(PRIOR))
import public_model as P
from ts_model import full as original_ts_full

sha = lambda raw: hashlib.sha256(raw).hexdigest()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    target = args.output.resolve()
    assert not target.exists(), 'Fresh output required'
    source_basis = json.loads((Path(__file__).parent / 'SOURCE-BASIS.json').read_text())
    root = Path(__file__).resolve().parents[6]
    for name, expected in source_basis['sourcePins'].items():
        assert sha((root / name).read_bytes()) == expected, name
    reuse = source_basis['prerequisiteReuse']
    semantic = Path(reuse['semantic1024']['directory'])
    comparative = Path(reuse['comparative256']['directory'])
    def verified_basis(item):
        path = Path(item['directory']) / 'PILOT-ORACLE-BASIS.json'
        assert sha(path.read_bytes()) == item['basisSHA256']
        result = json.loads(path.read_text())
        assert result['status'] == 'PASS'
        for role, expected in result['oracles'].items():
            digest = hashlib.sha256(); size = 0
            with gzip.open(Path(item['directory']) / f'{role}-expected.stdout.gz', 'rb') as stream:
                while data := stream.read(1024 * 1024):
                    digest.update(data); size += len(data)
            assert (size, digest.hexdigest()) == (expected['bytes'], expected['sha256'])
        return result
    semantic_basis = verified_basis(reuse['semantic1024'])
    prior64_basis = verified_basis(reuse['comparative64'])
    for role, expected in json.loads((PRIOR / 'EXPECTED.json').read_text())['oracles'].items():
        assert prior64_basis['oracles'][role] == expected
    for name, expected in prior64_basis['sourcePins'].items():
        assert sha((PRIOR / name).read_bytes()) == expected
    comparative_basis = verified_basis(reuse['comparative256'])
    assert (semantic_basis['count'], semantic_basis['iterations']) == (1024, 64)
    assert sha((P.SOURCE / 'SOURCE-BASIS.json').read_bytes()) == semantic_basis['sourceBasisSHA256']
    for name, expected in semantic_basis['sourcePins'].items():
        assert sha((P.SOURCE / name).read_bytes()) == expected
    assert sha((CONTROL256 / 'seal_gold.py').read_bytes()) == comparative_basis['sourcePins']['seal_gold.py']
    for role, expected in json.loads((CONTROL256 / 'EXPECTED.json').read_text())['oracles'].items():
        assert comparative_basis['oracles'][role] == expected
    digest = hashlib.sha256(); size = 0
    for namespace in [1, 2]:
        with gzip.open(semantic / f'canonical-ns{namespace}.stdout.gz', 'rb') as stream:
            while data := stream.read(1024 * 1024):
                digest.update(data); size += len(data)
    assert (size, digest.hexdigest()) == (semantic_basis['canonicalBytes'], semantic_basis['canonicalSHA256'])
    C, M = P.C, P.C.M
    fixtures = json.loads(gzip.decompress((semantic / 'observer-fixtures.json.gz').read_bytes()))
    target.mkdir(parents=True)
    outputs = {}
    chunks = {'bend': [], 'ts': []}
    world_results = []
    for index, namespace in enumerate([1, 2]):
        # setup_output also performs original prime callbacks/publication/schedule.
        import io
        original = M.Model
        M.Model = P.Observer
        try:
            model, spool = M.setup_output(M.World(namespace), 1024, 64, io.StringIO())
            for iteration in range(64):
                M.do_iteration(model, iteration)
            records = model.completed()
            spool.unlink()
        finally:
            M.Model = original
        fixture = fixtures[index]
        assert records == fixture['records']
        assert model.raw_map() == fixture['rawActorMap']
        assert C.tuple_records(records) == fixture['tuple']
        publics = {'bend': model.bend_public(), 'ts': P.ts_public(records)}
        assert (len(publics['bend']['boundaries']), len(publics['bend']['schedules']),
                len(publics['bend']['calls'])) == (256, 385, 64)
        result = {'namespace': namespace, 'tupleValues': len(fixture['tuple']),
                  'fold': fixture['fold'], 'records': len(records), 'public': {}}
        for role, public in publics.items():
            cells = C.tuple_records([public])
            fold = 0
            for value in cells:
                fold = (fold * 33 + value) % 2**32
            show = json.dumps if role == 'bend' else C.compact
            actors = (model.raw_map() if role == 'bend' else
                      original_ts_full(fixture)['method']['rawActorMap'])
            raw = (f"{['WARMUP', 'SAMPLE'][index]}\nFORCE:{fixture['fold']}\n"
                   f"PUBLIC-FORCE:{fold}\nTUPLE:{show(fixture['tuple'])}\n"
                   f"PUBLIC-TUPLE:{show(cells)}\nACTORS:{C.compact(actors)}\n").encode()
            chunks[role].append(raw)
            result['public'][role] = {'cells': len(cells), 'fold': fold,
                                      'publicTupleValues': len(cells), 'publicFold': fold,
                                      'recordSHA256': sha(C.compact(public).encode())}
            (target / f'{role}-public-ns{namespace}.json.gz').write_bytes(
                gzip.compress(C.compact({'record': public, 'tuple': cells, 'fold': fold}).encode(), mtime=0))
        world_results.append(result)
    for role, parts in chunks.items():
        raw = b''.join(parts)
        packed = gzip.compress(raw, mtime=0)
        (target / f'{role}-expected.stdout.gz').write_bytes(packed)
        outputs[role] = {'bytes': len(raw), 'sha256': sha(raw), 'gzipSHA256': sha(packed)}
    receipt = {'status': 'PASS', 'count': 1024, 'iterations': 64, 'worlds': world_results, 'oracles': outputs,
               'sourcePins': {p.name: sha(p.read_bytes()) for p in Path(__file__).parent.glob('*.py')},
               'preservation256': comparative_basis,
               'preservation': semantic_basis,
               'scope': 'Independent source model only; role-specific public strategies stay distinct.'}
    (target / 'PILOT-ORACLE-BASIS.json').write_text(json.dumps(receipt, indent=2) + '\n')
    print(json.dumps(receipt))


if __name__ == '__main__':
    main()
