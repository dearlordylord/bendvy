"""Source-only finite logical repeated-unregister authority model."""
from pathlib import Path
from copy import deepcopy
import argparse
import gzip
import hashlib
import json
import base_model as base

HERE = Path(__file__).resolve().parent
MUTANT = False


def derive(namespace):
    world = base.World(namespace, 10)
    owner = base.Capture.fresh(namespace, world.register('repeated'), 'repeated', 1)
    rows = [('registered', deepcopy(world), deepcopy(owner))]
    metadata = (owner.namespace, owner.identity, owner.name)
    assert metadata == (namespace, 1, 'repeated')
    # First real disposal succeeds; only Data metadata is copied. The actual
    # returned four-cell pack becomes the reconstructed stale wrapper's owner.
    if not MUTANT:
        world.registrations.remove((owner.identity, owner.name))
    rows.append(('first-disposed', deepcopy(world), deepcopy(owner)))
    allowed = metadata[0] == world.namespace and (metadata[1], metadata[2]) in world.registrations
    rows.append(('second-disposed' if allowed else 'second-refused', deepcopy(world), deepcopy(owner)))
    return rows


def render(namespace):
    return ''.join(label + '|' + base.show_world(world) + '|' + base.show_capture(owner) + '\n'
                   for label, world, owner in derive(namespace))


def expected():
    # One actual create per nominal schema; allocator order is namespaces1,2.
    return ('Workshop\n' + render(1) + 'Garden\n' + render(2) + '\n').encode()


def selftest():
    for namespace in [1, 2]:
        rows = derive(namespace)
        assert len(rows) == 3
        assert [r[0] for r in rows] == ['registered', 'first-disposed', 'second-disposed' if MUTANT else 'second-refused']
        assert rows[0][1].registrations == [(1, 'repeated')]
        assert rows[1][1].registrations == ([(1, 'repeated')] if MUTANT else [])
        assert rows[1][1:] == rows[2][1:]
        assert all(owner.cells == [1, 2, 3, 4] for _, _, owner in rows)
        assert all(owner.identity == 1 and owner.namespace == namespace for _, _, owner in rows)
        assert all(world.counter == 10 and world.next_system == 2 for _, world, _ in rows)
    raw = expected()
    assert raw.count(b'\n') == 9 and raw.endswith(b'\n\n') and not raw.endswith(b'\n\n\n')
    base.source_bindings()
    pin = json.loads((HERE / 'model-basis.json').read_text())
    assert hashlib.sha256((HERE / 'base_model.py').read_bytes()).hexdigest() == pin['baseModelSHA256']


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--write', action='store_true')
    args = parser.parse_args()
    selftest()
    raw = expected()
    if args.write:
        (HERE / 'normal.stdout').write_bytes(raw)
        (HERE / 'normal.stdout.gz').write_bytes(gzip.compress(raw, mtime=0))
    assert (HERE / 'normal.stdout').read_bytes() == raw
    assert gzip.decompress((HERE / 'normal.stdout.gz').read_bytes()) == raw
    print(json.dumps({'status': 'PASS', 'bytes': len(raw), 'sha256': base.digest(raw), 'rows': 6, 'mutant': MUTANT}))


if __name__ == '__main__':
    main()
