"""Independent operation algebra for frozen d7b308a89 resource-field consumer.

This models ownership-bearing values, not physical allocation identity. No Bend,
compiler output, backend artifact or recorded expected output is an input.
"""
from dataclasses import dataclass


def pair(seed):
    return (seed, seed + 1)


def matrix(seed):
    return (pair(seed), pair(seed + 2))


@dataclass(frozen=True)
class Args:
    first: tuple
    element: tuple
    second: tuple
    rejected: tuple
    fail: bool


def seeded_args(seed, fail):
    return Args(matrix(seed), pair(seed + 10), matrix(seed + 20),
                pair(seed + 30), fail)


@dataclass(frozen=True)
class Record:
    kind: str
    value: tuple
    index: int | None = None


@dataclass
class State:
    namespace: int
    target: tuple = matrix(10)
    same_sibling: tuple = matrix(800)
    other_sibling: tuple = pair(900)
    capture: tuple = pair(700)
    clock: int = 0
    cursor: int = 0
    registered: bool = False

    def run(self, args):
        assert self.registered
        original = self.target
        # Journal records the old owners newest-first. Invalid slot 99 returns
        # its incoming element immediately and adds no inverse action.
        first_with_swap = (args.first[0], args.element)
        self.target = args.second
        if args.fail:
            records = (Record('Replaced', args.first),
                       Record('Swapped', args.element, 1),
                       Record('Replaced', args.second))
            self.target = original
        else:
            records = (Record('Replaced', original),
                       Record('Swapped', args.first[1], 1),
                       Record('Replaced', first_with_swap))
            self.cursor = self.clock
        return (args.rejected,), records


def retry_args(elements, records, fail):
    """Rebuild input from actual failure-return shapes; no replacement values."""
    first, element, second = records
    assert second.kind == first.kind == 'Replaced'
    assert element.kind == 'Swapped' and element.index == 1
    assert len(elements) == 1
    return Args(first.value, element.value, second.value, elements[0], fail)


def selftest():
    state = State(1, registered=True)
    original = state.target
    elements, records = state.run(seeded_args(100, False))
    committed = matrix(120)
    assert state.target == committed
    assert records == (Record('Replaced', original),
                       Record('Swapped', pair(102), 1),
                       Record('Replaced', (pair(100), pair(110))))
    args = seeded_args(200, True)
    elements, records = state.run(args)
    assert state.target == committed
    assert records == (Record('Replaced', matrix(200)),
                       Record('Swapped', pair(210), 1),
                       Record('Replaced', matrix(220)))
    again = retry_args(elements, records, True)
    assert again == args
    elements, records = state.run(again)
    final = retry_args(elements, records, False)
    assert final == seeded_args(200, False)
    state.run(final)
    assert state.target == matrix(220)
    assert state.capture == pair(700)
    assert state.same_sibling == matrix(800) and state.other_sibling == pair(900)
    assert state.clock == state.cursor == 0


if __name__ == '__main__':
    selftest()
    print('independent source-operation model checks passed')
