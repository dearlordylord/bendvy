"""Finite ordinary-condition-composition model; no backend observations.

Source c66a2760310fb5f7d59a7365f99680b2cf58148e uses owner-preserving
short-circuit on Value. Supported Changed.run always succeeds; missing slots
produce false. InvalidRegistration denotes stale/foreign authority refusal,
not an ordinary fallible Bevy condition. No generic fallible leaf is modeled.
"""
from dataclasses import dataclass


@dataclass
class Result:
    kind: str
    value: bool | None = None


@dataclass
class Changed:
    revision: int = 0
    cursor: int = 0

    def run(self, current_revision, present, clock, available=True, registered=True):
        if not registered:
            return Result('InvalidRegistration')
        assert available, 'NoValue is unreachable from the supported Changed constructor'
        value = present and self.revision < current_revision
        self.revision = current_revision
        self.cursor = clock
        return Result('Value', value)


def negate(result):
    return Result('Value', not result.value) if result.kind == 'Value' else result


def combine(left, right, continue_on):
    first = left()
    if first.kind != 'Value' or first.value != continue_on:
        return first
    return right()


def and_then(left, right):
    return combine(left, right, True)


def or_else(left, right):
    return combine(left, right, False)


def selftest():
    changed_level, changed_flow = Changed(), Changed()
    fast = and_then(lambda: Result('Value', True), lambda: changed_level.run(1, True, 2))
    slow = or_else(lambda: negate(Result('Value', False)), lambda: changed_flow.run(1, True, 2))
    assert fast.value and slow.value
    assert (changed_level.revision, changed_level.cursor) == (1, 2)
    assert (changed_flow.revision, changed_flow.cursor) == (0, 0), 'short-circuit must retain RHS owner'
    fast = and_then(lambda: Result('Value', False), lambda: changed_level.run(2, True, 4))
    slow = or_else(lambda: negate(Result('Value', True)), lambda: changed_flow.run(2, True, 4))
    assert not fast.value and slow.value
    assert (changed_level.revision, changed_level.cursor) == (1, 2)
    assert (changed_flow.revision, changed_flow.cursor) == (2, 4)
    fast = and_then(lambda: Result('Value', True), lambda: changed_level.run(2, True, 5))
    slow = or_else(lambda: negate(Result('Value', True)), lambda: changed_flow.run(3, True, 5))
    assert fast.value and slow.value
    assert changed_level.revision == 2 and changed_flow.revision == 3
    assert changed_level.run(3, False, 6).value is False
    assert changed_level.revision == 3
    prior = (changed_flow.revision, changed_flow.cursor)
    refusal = changed_flow.run(4, True, 7, registered=False)
    assert refusal.kind == 'InvalidRegistration'
    assert (changed_flow.revision, changed_flow.cursor) == prior


if __name__ == '__main__':
    selftest()
    print('Lazy condition owner invariants PASS; final consumer not bound')
