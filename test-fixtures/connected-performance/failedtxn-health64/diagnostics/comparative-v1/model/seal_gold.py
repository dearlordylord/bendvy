"""Reproduce accepted full streams first, then derive the public supplement."""
import argparse
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import sys

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
    # This independent control reconstructs the old canonical, every common cell,
    # and both old full role streams from the unchanged original operation model.
    subprocess.run([sys.executable, str(P.SOURCE / 'seal_gold.py'),
                    '--output', str(target / 'preservation')], check=True)
    C, M = P.C, P.C.M
    fixtures = json.loads(gzip.decompress((target / 'preservation/observer-fixtures.json.gz').read_bytes()))
    outputs = {}
    chunks = {'bend': [], 'ts': []}
    world_results = []
    for index, namespace in enumerate([1, 2]):
        # setup_output also performs original prime callbacks/publication/schedule.
        import io
        original = M.Model
        M.Model = P.Observer
        try:
            model, spool = M.setup_output(64, 64, namespace, io.StringIO())
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
    receipt = {'status': 'PASS', 'worlds': world_results, 'oracles': outputs,
               'sourcePins': {p.name: sha(p.read_bytes()) for p in Path(__file__).parent.glob('*.py')},
               'preservation': json.loads((target / 'preservation/PILOT-ORACLE-BASIS.json').read_text()),
               'scope': 'Independent source model only; role-specific public strategies stay distinct.'}
    (target / 'PILOT-ORACLE-BASIS.json').write_text(json.dumps(receipt, indent=2) + '\n')
    print(json.dumps(receipt))


if __name__ == '__main__':
    main()
