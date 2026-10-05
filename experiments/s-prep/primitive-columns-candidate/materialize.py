#!/usr/bin/env python3
"""Freeze the actual primitive-column candidate for correctness checks, no timing."""
import argparse, hashlib, json, shutil
from pathlib import Path
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
GATES = HERE.parent / 'fivehour-connected-gates'
def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()
def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--role', required=True, choices=['JS', 'Native'])
    parser.add_argument('--output', required=True, type=Path)
    args = parser.parse_args()
    source = ROOT / 'experiments/fivehour-candidate' / args.role / 'experiments/s-integrate'
    destination = args.output.resolve()
    destination.mkdir(parents=True, exist_ok=False)
    core = destination / 'experiments/s-integrate'
    shutil.copytree(source, core)
    pins = {str(p.relative_to(destination)): sha(p) for p in sorted(core.glob('*.bend'))}
    expected = set('''audited-invoker.bend cache.bend cached-payload.bend capture.bend commands.bend dispatcher.bend held-adapter.bend held.bend host-observations.bend host-render.bend host.bend identity.bend measurement-bend.bend observations.bend payload.bend query.bend raw-boundaries.bend reader-host.bend readers.bend schedule.bend storage.bend streams.bend structural-invoker.bend systems.bend transaction-dispatch-adapters.bend transaction.bend types.bend uncached-payload.bend prototype-static-client.bend'''.split())
    assert {p.name for p in core.glob('*.bend')} == expected, 'Unexpected source membership'
    digest = hashlib.sha256(json.dumps(pins, sort_keys=True, separators=(',', ':')).encode()).hexdigest()
    cache = {'scope': 'Current affine primitive metadata candidate; direct correctness only',
             'runtimeClosure': pins, 'runtimeClosureSHA256': digest,
             'specializedClosure': pins, 'currentRuntimeModules': len(pins),
             'productionAcceptance': False, 'measurementAcceptance': False}
    manifest = {'sources': pins, 'cacheSpecialization': cache,
                'baseline': 'a976667',
                'overrides': {name: 'current-candidate/' + args.role + '/' + name for name in pins},
                'primitiveColumns': {'role': args.role, 'recipeSHA256': sha(Path(__file__)),
                                     'scope': 'Actual candidate source, no historical gate reuse or measured allowance'}}
    (destination / 'overlay.json').write_text(json.dumps(manifest, indent=2) + '\n')
    (destination / 'cache-specialization.json').write_text(json.dumps(cache, indent=2) + '\n')
    import sys
    sys.path.insert(0, str(GATES))
    import provider_controls
    assert provider_controls.runtime_sources(destination) == pins
    print(json.dumps({'role': args.role, 'runtimeClosureSHA256': digest, 'modules': len(pins)}))
if __name__ == '__main__':
    main()
