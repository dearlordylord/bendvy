"""Finite eager-RHS mutation countermodel; no backend observations.

The isolated source mutation always evaluates the RHS after a Value result,
including when the original combinator would short-circuit. Supported Changed.run always succeeds; missing slots
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
    if first.kind != 'Value':
        return first
    return right()


def and_then(left, right):
    return combine(left, right, True)


def or_else(left, right):
    return combine(left, right, False)


def selftest():
    level, flow = Changed(), Changed()
    assert and_then(lambda: Result('Value', True), lambda: level.run(1, True, 2)).value
    assert or_else(lambda: Result('Value', True), lambda: flow.run(1, True, 2)).value
    assert flow.revision == 1, 'eager shortcut consumes formerly skipped Flow revision'
    assert and_then(lambda: Result('Value', False), lambda: level.run(2, True, 4)).value
    assert level.revision == 2, 'eager AND shortcut now invokes RHS'
    assert not and_then(lambda: Result('Value', True), lambda: level.run(2, True, 5)).value
