"""Source-only bounded profiling wire; never consumes backend output."""
import gzip
import hashlib
import importlib.machinery
import importlib.util
import json
import sys
from pathlib import Path
HERE = Path(__file__).resolve().parent

def digest(data):
    return hashlib.sha256(data).hexdigest()

def derive():
    basis = json.loads((HERE / "SOURCE.json").read_text())
    for path, expected in basis["pins"].items():
        assert digest(Path(path).read_bytes()) == expected, path
    source = (HERE / "main.bend").read_text()
    assert 'Core.checkpoint(~S,"profile-after-publications",Core.loop(~S,count,Core.read(~S,Core.publish(~S,runtime,Core.Seed{}),True{})))' in source
    assert source.count('scenario(~P.SchemaA,1024n)') == 1
    assert source.count('scenario(~P.SchemaB,1024n)') == 1
    assert 'IO.args' not in source and 'Core.execute' not in source
    loader = importlib.machinery.SourceFileLoader('bounded_capacity_model', str(HERE / 'capacity-model.py.source'))
    spec = importlib.util.spec_from_loader(loader.name, loader)
    model = importlib.util.module_from_spec(spec)
    sys.modules[loader.name] = model
    loader.exec_module(model)
    rows = []
    timelines = []
    for namespace in (1, 2):
        runtime = model.Runtime()
        runtime.seed()
        runtime.read(True)
        for _ in range(1024):
            runtime.publish()
        runtime.queue.invariant()
        assert runtime.queue.read(0) == tuple((i, i + 1) for i in range(1024))
        assert runtime.queue.size == runtime.queue.batch_count == 1024
        assert runtime.queue.dropped == 0
        assert runtime.position == (2, 0, 2)
        assert runtime.deliveries == [((), False)]
        assert runtime.tick == 3075 and runtime.frames == 1026
        rows.append(model.row(namespace, 'profile-after-publications', runtime))
        timelines.append(dict(namespace=namespace, publications=1024, tick=runtime.tick, frames=runtime.frames, queueSize=runtime.queue.size, batchCount=runtime.queue.batch_count, position=list(runtime.position), dropped=runtime.queue.dropped))
    # Core.finish returns its sole checkpoint String. IO.print adds one LF.
    wire = ('SCHEMA=A\n' + rows[0] + '\nSCHEMA=B\n' + rows[1] + '\n').encode()
    return wire, timelines

if __name__ == '__main__':
    raw, timeline = derive()
    if sys.argv[1:] == ['--write']:
        (HERE / 'expected.stdout').write_bytes(raw)
        (HERE / 'expected.stdout.gz').write_bytes(gzip.compress(raw, mtime=0))
        (HERE / 'expected.sha256').write_text(digest(raw) + '  expected.stdout\n')
        (HERE / 'timeline.json').write_text(json.dumps(timeline, indent=2) + '\n')
    else:
        assert not sys.argv[1:]
        assert raw == (HERE / 'expected.stdout').read_bytes()
        assert raw == gzip.decompress((HERE / 'expected.stdout.gz').read_bytes())
        assert json.loads((HERE / 'timeline.json').read_text()) == timeline
    print(json.dumps(dict(status='SOURCE_ONLY_BOUNDED_PROFILE_ORACLE_PASS', bytes=len(raw), sha256=digest(raw), count=1024)))
