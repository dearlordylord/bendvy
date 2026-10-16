"""Exact historical mode-model reuse plus independently derived physical framing."""
import ast
import gzip
import hashlib
import json
from pathlib import Path


HERE = Path(__file__).resolve().parent
ORDER = ['required_out', 'optional_out', 'present_out', 'absent_out',
         'required_in', 'optional_in', 'present_in', 'absent_in']


def listing(values):
    return '[' + ', '.join(values) + ']'


def physical():
    # Actual current constructor and cursor-free callpath preserve these fields.
    batches = [(2, [(4, 7)]), (3, [(7, 8), (8, 7)])]
    front = []
    for tick, values in batches:
        items = listing([str(source) + '>' + str(target) for source, target in values])
        front.append(f'Batch{{{tick};count={len(values)};items={items}}}')
    size = sum(len(values) for tick, values in batches)
    flow = ('Queue{front=' + listing(front) + f';back=[];size={size};dropped=0;batchCount={len(batches)}}}'
            + ';positions=[5:1:1];frameStart=2')
    level = 'Queue{front=[];back=[];size=0;dropped=0;batchCount=0};positions=[];frameStart=0'
    return 'Flow{' + flow + '};Level{' + level + '}'


def historical(mode):
    namespace = {}
    model_path = HERE / 'historical' / (mode + '.model.py.source')
    exec(compile(model_path.read_bytes(), str(model_path), 'exec'), namespace)
    raw = namespace['expected']() if mode == 'required_out' else namespace['expected'](mode)
    retained = gzip.decompress((HERE / 'historical' / (mode + '.stdout.gz')).read_bytes())
    assert raw == retained, mode
    values = ast.literal_eval(raw.decode())
    assert isinstance(values, tuple) and len(values) == 2 and all(isinstance(value, str) for value in values)
    # Exact inverse of the old pure main's complete tuple/String rendering.
    assert raw == ('(' + ', '.join(json.dumps(value, ensure_ascii=False) for value in values) + ')\n').encode()
    return raw, values


def render():
    chunks = []
    for mode in ORDER:
        raw, (workshop, garden) = historical(mode)
        chunks.append(mode + '\n')
        for schema, logical in [('Workshop', workshop), ('Garden', garden)]:
            chunks.append(schema + '\nPhysicalInitial=' + physical() + '\n'
                          + logical + 'PhysicalTerminal=' + physical() + '\n')
    return (''.join(chunks) + '\n').encode()


def selftest():
    sizes = {}
    for mode in ORDER:
        raw, values = historical(mode)
        sizes[mode] = len(raw)
        for logical in values:
            assert logical.count('CheckFirst=True\nCheckSecond=True\n') == 2
            assert 'FirstCursor=Active:14:13' in logical
            assert 'SecondCursor=Active:17:13' in logical
            assert logical.endswith('clock=17)\n')
            assert logical.count('pending=1') == 8
            assert logical.count('stream([2:[4>7], 3:[7>8, 8>7]],[5:1:1],0,2)') == 8
    assert sizes['required_out'] == 14025
    assert sizes['required_in'] == 13701
    raw = render()
    assert raw.count(b'PhysicalInitial=') == raw.count(b'PhysicalTerminal=') == 16
    assert raw.count(b'CheckFirst=True\nCheckSecond=True\n') == 32
    assert raw.count(b'Flow{Queue{front=[Batch{2;count=1;items=[4>7]}, Batch{3;count=2;items=[7>8, 8>7]}]') == 32
    assert raw.endswith(b'\n\n')


if __name__ == '__main__':
    import sys
    selftest()
    if '--selftest' not in sys.argv:
        sys.stdout.buffer.write(render())
