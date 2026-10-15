"""Finite source-only public reader authority/disposal model; no runtime inputs."""
import copy
import gzip
import hashlib
import json
from pathlib import Path
from state import State
from render import world

HERE = Path(__file__).resolve().parent
ACCESS = ['machine.machine.state.transition.read']


def scenario(namespace):
    local, foreign = State(), State()
    local.initialize()
    foreign.initialize()
    registrations = [(1, 'first', ACCESS), (2, 'survivor', ACCESS)]
    owners = [dict(identity=1, name='first', cursor=0),
              dict(identity=2, name='survivor', cursor=0)]
    trace, timeline = [], []

    def physical(state, ns, metadata):
        # W.nextSystemId is monotonic and is never decremented by disposal.
        text = world(state, metadata, ns)
        actual_next = 3 if state is local else 1
        return text.replace(';nextSystemId=' + str(len(metadata) + 1) + ';',
                            ';nextSystemId=' + str(actual_next) + ';')

    def owner(value):
        if value is None:
            return 'disposed'
        return (f'sys={namespace}:{value["identity"]}:{value["name"]}:'
                f'[machine.machine.state.transition.read]:cursor={value["cursor"]};'
                f'stream={namespace}:{value["identity"]}')

    def observe(label):
        trace.append(label + ';local{' + physical(local, namespace, registrations)
                     + '};foreign{' + physical(foreign, namespace + 1, [])
                     + '};fast{' + owner(owners[0]) + '};slow{' + owner(owners[1]) + '}')
        timeline.append(dict(label=label, local=local.snapshot(), foreign=foreign.snapshot(),
                             registrations=copy.deepcopy(registrations), owners=copy.deepcopy(owners)))

    def read(label, failed=False):
        first = owners[0]
        values, lagged = local.open_reader(first['identity'])
        reading = 'values=[' + ', '.join(values) + '];lagged=' + str(lagged).lower()
        if failed:
            line = 'callback=failure:transition-reader-failed;attempt{' + reading + '}'
        else:
            local.complete_reader(first['identity'])
            first['cursor'] = local.clock
            line = 'callback=success;' + reading
        observe(label + ';' + line)

    def dispose():
        identity = owners[0]['identity']
        registrations[:] = [r for r in registrations if r[0] != identity]
        local.positions[:] = [p for p in local.positions if p[0] != identity]
        owners[0] = None
        observe('local-dispose;accepted')

    observe('registered')
    read('failed-reader', True)
    observe('foreign-read;reader-refused-before-callback')
    observe('foreign-dispose;refused')
    read('retry')
    dispose()
    owners[:] = [owners[1], owners[0]]
    read('survivor-read')
    read('survivor-repeat')
    dispose()
    assert len(trace) == 9
    assert timeline[1]['local'] == timeline[2]['local'] == timeline[3]['local']
    assert timeline[1]['owners'] == timeline[2]['owners'] == timeline[3]['owners']
    assert timeline[1]['local']['positions'] == [[1, 0, 1]]
    assert timeline[4]['local']['positions'] == [[1, 1, 1]]
    assert timeline[5]['local']['positions'] == []
    assert timeline[6]['local']['positions'] == [[2, 1, 1]]
    assert timeline[6]['owners'] == timeline[7]['owners']
    assert local.positions == [] and registrations == [] and owners == [None, None]
    assert foreign.positions == [] and foreign.clock == local.clock == 1
    return ''.join(trace) + 'final-local{' + physical(local, namespace, registrations) + '};final-foreign{' + physical(foreign, namespace + 1, []) + '}\n', timeline


def selftest():
    for path, digest in json.loads((HERE / 'source-pins.json').read_text()).items():
        assert hashlib.sha256(Path(path).read_bytes()).hexdigest() == digest, path
    freeze = json.loads((HERE / 'source-freeze.json').read_text())
    source = (Path(freeze['snapshot']) / freeze['entrypoint']).read_text()
    for fragment in ['read_fast(~S,"failed-reader",True{},observe(~S,"registered",state))',
                     'foreign_read(~S,', 'dispose_fast(~S,True{},',
                     'read_fast(~S,"retry",False{},', 'read_fast(~S,"survivor-repeat",False{},',
                     'App.reader_create(~S,"first",Fixture.initialize(~S,world))',
                     'App.reader_create(~S,"survivor",world)',
                     'a ++ b']:
        assert fragment in source, fragment
    a, at = scenario(1)
    b, bt = scenario(3)
    # Sequential IO World creation uses the shared host allocator, then IO.print
    # appends one LF to the argument whose two scenarios each already end in LF.
    return (a + b + '\n').encode(), dict(A=at, B=bt)


if __name__ == '__main__':
    raw, timeline = selftest()
    (HERE / 'expected.stdout').write_bytes(raw)
    (HERE / 'expected.stdout.gz').write_bytes(gzip.compress(raw, mtime=0))
    (HERE / 'timeline.json').write_text(json.dumps(timeline, indent=2) + '\n')
    (HERE / 'expected.sha256').write_text(hashlib.sha256(raw).hexdigest() + '  expected.stdout\n')
    print(len(raw), hashlib.sha256(raw).hexdigest())
