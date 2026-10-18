"""Independent state transitions approved before execution, without reading Bend.

Each fresh application registers L then R, so IDs are 1/2 and next is 3.
L changes its Local counter by one and returns the affine token increased by two.
R changes only that returned token by three. Failure after L suppresses R.
The source routing mutation selects the wrong leaf for L's ID; the unchanged
single-registration guard refuses it before either callback. Wrong-ID refusal
and foreign-world admission likewise leave Local/token/world unchanged. Both
foreign worlds come from independent IO creation; same registration order gives
colliding IDs, while host namespace allocation makes their namespaces distinct.
No transition in this fixture mutates World or advances the registry cursor.
"""
from pathlib import Path
import gzip


def expected(mutant=False):
    lines = []
    for label, fail in [('normal', False), ('failure', True)]:
        local, token = 10, 100
        if not mutant:
            local += 1
            token += 2
            if not fail:
                token += 3
        status = 'Failed' if mutant or fail else 'Finished'
        lines.append(f'{label}={status} local={local} token={token} clock=0 ids=1,2 next=3 cursor=0')
    lines.append('wrong=Failed local=10 token=100 clock=0 ids=1,2 next=3 cursor=0')
    lines.append('foreign distinct=True colliding=True attach=Invalid local=10 token=100 clock=0 ids=1,2 next=3 cursor=0')
    return ('\n'.join(lines) + '\n').encode()


if __name__ == '__main__':
    root = Path(__file__).parent
    for kind in ['normal', 'mutant']:
        raw = expected(kind == 'mutant')
        (root / f'expected-{kind}.stdout').write_bytes(raw)
        (root / f'expected-{kind}.stdout.gz').write_bytes(gzip.compress(raw, mtime=0))
