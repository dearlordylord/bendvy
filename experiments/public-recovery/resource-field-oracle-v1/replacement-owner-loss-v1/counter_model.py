"""Source-derived commit-only omission in the new selected-field adapter.

The normal independently authored source model supplies transition algebra and
formatting. No backend output is read/transformed to construct this counter.
"""
from pathlib import Path
import sys

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))
import model as normal_model
from state_model import State as NormalState


class CounterState(NormalState):
    def run(self, args):
        elements, records = super().run(args)
        if not args.fail:
            # Both replace calls wrap their newest action. On commit each
            # wrapper leaves state/recovery unchanged instead of releasing its
            # old Array owner. Swap action and every failure action still run.
            records = tuple(record for record in records if record.kind != 'Replaced')
        return elements, records


def derive():
    previous = normal_model.State
    normal_model.State = CounterState
    try:
        return normal_model.derive()
    finally:
        normal_model.State = previous


def selftest():
    raw, traces = derive()
    normal, normal_traces = normal_model.derive()
    assert raw != normal
    assert raw.endswith(b'\n\n')
    changed = []
    for before, after in zip(normal.splitlines(), raw.splitlines(), strict=True):
        if before != after:
            changed.append(after)
            assert after.startswith((b'returned:commit|', b'returned:retry-success|'))
            assert b'replaced:' in before and b'replaced:' not in after
            assert before.split(b'|recovered=')[0] == after.split(b'|recovered=')[0]
    assert len(changed) == 4  # two successful calls in each nominal schema
    for normal_trace, counter_trace in zip(normal_traces, traces, strict=True):
        for before, after in zip(normal_trace, counter_trace, strict=True):
            assert {k:v for k,v in before.items() if k != 'recovery'} == {
                k:v for k,v in after.items() if k != 'recovery'}
            if before['input']['fail']:
                assert before['recovery'] == after['recovery']
                assert len(after['recovery']) == 3
            else:
                assert [r['kind'] for r in after['recovery']] == ['Swapped']
    return raw, traces


if __name__ == '__main__':
    import gzip,hashlib,json
    raw, traces = selftest()
    (HERE / 'expected.stdout').write_bytes(raw)
    (HERE / 'expected.stdout.gz').write_bytes(gzip.compress(raw,mtime=0))
    (HERE / 'state-trace.json').write_text(json.dumps(traces,indent=2)+'\n')
    print(json.dumps({'bytes':len(raw),'sha256':hashlib.sha256(raw).hexdigest(),
                     'gzipBytes':len(gzip.compress(raw,mtime=0)),
                     'gzipSHA256':hashlib.sha256(gzip.compress(raw,mtime=0)).hexdigest()}))
