"""Source applicability and full historical-oracle equality, without backend input."""
import gzip
import hashlib
import json
from pathlib import Path
import model

HERE = Path(__file__).resolve().parent


def main():
    for path, digest in json.loads((HERE / 'source-pins.json').read_text()).items():
        assert hashlib.sha256(Path(path).read_bytes()).hexdigest() == digest, path
    freeze = json.loads((HERE / 'source-freeze.json').read_text())
    root = Path(freeze['snapshot'])
    entry = root / freeze['entrypoint']
    systems = (entry.parent / 'systems.bend').read_text()
    application = (entry.parent / 'application.bend').read_text()
    phases = (root / 'src/ecs/machine-handler-phases.bend').read_text()
    for token in ['Component.tx_set(', 'Component.Family{"Cells"}',
                  'Tx.Failure{"transition-first-attempt"}', 'tentativeCells=',
                  'first_local(~S,touch(~S,world,id),id)']:
        assert token in systems, token
    assert 'Operation.run(' in application
    assert 'Lens.queue_first(' in application and 'M.Initial{' not in application
    assert 'M.queue(' in (entry.parent / 'lenses.bend').read_text()
    assert 'H.prepare(' in phases and 'M.snapshot(' in phases
    labels = ['before', 'queued', 'first-failure', 'first-reader-before-retry',
              'first-retry', 'second-marker', 'first-reader', 'second-reader',
              'later-first-marker', 'later-second-marker']
    rows = model.observations()
    assert len(rows) == 11 and all(row.startswith(label + ':') for row, label in zip(rows, labels))
    # Full source-derived failure observation proves payload/stamp rollback while
    # World clock and callback Local prefix remain advanced.
    assert 'tentativeCells=Column{values=leaf:some(node(leaf:12,leaf:32));stamps=[1:0:2]}|clock=2' in rows[2]
    assert 'first=Column{values=leaf:some(node(leaf:11,leaf:32));stamps=[1:0:1]}' in rows[2]
    assert 'clock=2}' in rows[2] and 'firstStream={batches=[]' in rows[2]
    assert 'first=Column{values=leaf:some(node(leaf:23,leaf:32));stamps=[1:0:8]}' in rows[-2]
    assert '|pending=0|' in rows[-2] and '|applied=8}' in rows[-2]
    raw = model.expected()
    old = gzip.decompress(Path(freeze['historicalOracle']).read_bytes())
    assert raw == old == (HERE / 'expected.stdout').read_bytes()
    assert gzip.decompress((HERE / 'expected.stdout.gz').read_bytes()) == raw
    assert len(raw) == 24422
    print('PASS', len(raw), hashlib.sha256(raw).hexdigest())


if __name__ == '__main__':
    main()
