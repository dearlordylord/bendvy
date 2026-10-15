"""Source-derived machine-stream state for the finite scheduled reader fixture.

St.skip is identity under the pinned Bevy-first contract. Successful callback
completion is a separate Ev.update operation; the historical model used one
method for both and cannot be reused by changing that method alone.
"""
from dataclasses import dataclass, field


def listing(values):
    return '[' + ', '.join(values) + ']'


@dataclass
class Stream:
    batches: list = field(default_factory=list)
    positions: list = field(default_factory=list)
    dropped: int = 0
    frame_start: int = 0

    def frame(self, tick):
        boundary = min([self.frame_start] + [position[1] for position in self.positions])
        gone = [at for at, _ in self.batches if at <= boundary]
        if gone:
            self.dropped = max(self.dropped, max(gone))
        self.batches = [(at, value) for at, value in self.batches if at > boundary]
        self.frame_start = tick

    def skip(self, identity, tick):
        # Both the stream and existing affine reader owner return unchanged.
        pass

    def complete(self, identity, tick, success=True):
        if success:
            self.positions = [(actual, tick if actual == identity else cursor, registered)
                              for actual, cursor, registered in self.positions]

    def read(self, identity, tick):
        old = next((position for position in self.positions if position[0] == identity), None)
        cursor, registered = (old[1], old[2]) if old else (0, tick)
        values = [value for at, value in self.batches if at > cursor]
        lagged = max(cursor, registered) < self.dropped
        if old is None:
            self.positions.insert(0, (identity, 0, tick))
        return values, lagged

    def show(self):
        return ('batches=' + listing([str(tick) + ':' + listing([value]) for tick, value in self.batches])
                + ',positions=' + listing([f'{identity}:{cursor}:{registered}' for identity, cursor, registered in self.positions])
                + f',dropped={self.dropped},frameStart={self.frame_start}')


def selftest():
    stream = Stream([(1, 'initial:Boot')])
    assert stream.read(1, 1) == (['initial:Boot'], False)
    stream.complete(1, 2)
    stream.batches.append((3, 'Boot>Play'))
    stream.frame(3)
    assert stream.dropped == 0
    before = stream.positions[:]
    stream.skip(1, 3)
    assert stream.positions == before
    stream.frame(4)
    assert stream.batches == [(3, 'Boot>Play')]
    assert stream.dropped == 1
    assert stream.read(1, 4) == (['Boot>Play'], False)
    stream.complete(1, 4, False)
    assert stream.positions == before
    stream.complete(1, 5)
    assert stream.read(1, 5) == ([], False)


if __name__ == '__main__':
    selftest()
    print('Stream source invariants PASS; final consumer not bound')
