"""Independent source-derived paused generational cleanup trace."""
from pathlib import Path
import hashlib
import json

HERE = Path(__file__).resolve().parent


def listing(items):
    return '[' + ', '.join(items) + ']'


def pair(value):
    return f'node(leaf:{value},leaf:{value + 1})'


class State:
    def __init__(self):
        self.generation = 0
        self.phase = 'Pending'
        self.order = [(1, 0)]
        self.free = []
        self.owner = None
        self.stamp = None
        self.returned = []
        self.trace = []
        self.events = []
        # Batch.spawn stages activation followed by actual owner delivery.
        self.pending = [('activate', 0), ('deliver', 100)]
        self.clock = 0
        self.frames = []
        self.replacement = None
        self.log = []

    def valid(self, generation):
        return generation == self.generation and self.phase == 'Live'

    def world(self):
        allocator = (f'next=2;high=1;capacity=2;depth=1;slots=node(leaf:0:Consumed,leaf:{self.generation}:{self.phase});free='
                     + listing(map(str, self.free)) + ';order='
                     + listing(f'{index}:{generation}' for index, generation in self.order))
        values = 'leaf:none' if self.owner is None else 'leaf:some(' + pair(self.owner) + ')'
        stamps = [] if self.stamp is None else [f'1:{self.stamp[0]}:{self.stamp[1]}']
        column = 'Column{values=' + values + ';stamps=' + listing(stamps) + '}'
        returned = ''.join(pair(owner) + ';' for owner in self.returned) + '[]'
        components = 'column=' + column + ';returned=' + returned + ';trace=' + listing(self.trace)
        return ('ns=1;allocator={' + allocator + '};components={' + components
                + '};graph=[]/[];resource=node(leaf:61,leaf:62);events=' + listing(self.events)
                + f';pending={len(self.pending)};registrations=[];nextSystem=1;clock={self.clock}')

    def checkpoint(self, label):
        replacement = 'none' if self.replacement is None else f'1/1:{self.replacement}'
        self.log.append(label + ':{world={' + self.world()
                        + '};namespace=1;old=1/1:0;replacement=' + replacement
                        + ';frames=' + listing(self.frames) + '}\n')

    def barrier(self):
        queue, self.pending = self.pending, []
        for operation, value in queue:
            if operation == 'activate':
                assert self.phase == 'Pending' and self.generation == value
                self.phase = 'Live'
            elif operation == 'deliver':
                assert self.valid(self.generation)
                previous = self.owner
                self.owner = value
                self.clock += 1
                self.stamp = (self.clock, self.clock) if previous is None else (self.stamp[0], self.clock)
                if previous is not None:
                    self.returned.append(previous)
                self.trace.append(f'populate:1/1:{self.generation}')
            else:
                assert operation == 'despawn' and self.valid(value)
                self.phase = 'DeadRetained'
                if self.owner is not None:
                    self.returned.append(self.owner)
                self.owner = None
                self.stamp = None
                self.trace.append(f'clear:1/1:{value}')
                self.events.extend([f'Original(Removed(1/1:{value}))', f'Original(Cleared(1/1:{value}))'])
                self.generation += 1
                self.phase = 'Free'
                self.free.insert(0, 1)
                self.order.remove((1, value))

    def pause(self):
        # drive(2): Enter -> Descriptors(empty) -> Finish, then fuel exhausted.
        assert self.valid(0)
        self.frames = ['Finish:1:0']
        self.log.append('cleanup:Incomplete\n')

    def reuse(self):
        assert self.free.pop(0) == 1 and self.phase == 'Free'
        self.phase = 'Pending'
        self.order.append((1, self.generation))
        self.replacement = self.generation
        self.pending.extend([('activate', self.generation), ('deliver', 200)])

    def resume(self):
        assert self.frames == ['Finish:1:0']
        before = self.world()
        # units(1) reaches Finish. W.valid rejects old generation before clear.
        assert not self.valid(0) and self.valid(1)
        self.frames = []
        assert self.world() == before
        self.log.append('cleanup:Complete\n')


def render():
    state = State()
    state.barrier()
    state.checkpoint('original-live')
    state.pause()
    state.checkpoint('paused-actual-finish')
    assert state.valid(0)
    state.pending.append(('despawn', 0))
    state.log.append('separate-despawn:Accepted\n')
    state.checkpoint('separate-cleanup-queued')
    state.barrier()
    state.checkpoint('old-cleared-and-released')
    state.reuse()
    state.checkpoint('new-generation-pending')
    state.barrier()
    state.checkpoint('new-generation-live-before-resume')
    state.resume()
    state.checkpoint('retained-stale-finish-resumed')
    assert state.valid(state.replacement) and state.owner == 200
    # Component.get restores the same owner and does not alter the stamp/clock.
    state.log.append('replacement-read:200\n')
    state.checkpoint('new-generation-read-preserved')
    assert state.returned == [100] and state.stamp == (2, 2)
    assert state.trace == ['populate:1/1:0', 'clear:1/1:0', 'populate:1/1:1']
    # The accumulated log already ends LF; one IO.print appends another LF.
    return (''.join(state.log) + '\n').encode()


def selftest():
    raw = render()
    assert raw.count(b':{world={') == 8
    assert raw.count(b'cleanup:Incomplete\n') == raw.count(b'cleanup:Complete\n') == 1
    assert b'new-generation-pending:' in raw and b';pending=2;' in raw
    assert b'Column{values=leaf:some(node(leaf:200,leaf:201));stamps=[1:2:2]}' in raw
    assert b';returned=node(leaf:100,leaf:101);[];' in raw
    assert raw.endswith(b';frames=[]}\n\n')


def verify_basis():
    basis = json.loads((HERE / 'SOURCE-BASIS.json').read_text())
    for path, digest in basis['sourcePins'].items():
        assert hashlib.sha256(Path(path).read_bytes()).hexdigest() == digest, path
    freeze = basis['freeze']
    assert hashlib.sha256(Path(freeze['path']).read_bytes()).hexdigest() == freeze['sha256']


if __name__ == '__main__':
    import sys
    verify_basis()
    selftest()
    if '--selftest' not in sys.argv:
        sys.stdout.buffer.write(render())
