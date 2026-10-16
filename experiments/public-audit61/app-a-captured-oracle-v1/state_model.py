"""Provisional operation model; serialization awaits the checked source freeze.
No backend output is an input. Each affine array is retained as a tree.
"""
from dataclasses import dataclass
@dataclass
class CapturedState:
    scalar: int = 11
    scalar_added: int = 2
    scalar_changed: int = 2
    clock: int = 2
    query_calls: int = 0
    query_values: tuple = (30, 40)
    query_cursor: int = 0
    resource_capture: tuple = (100, 200)
    counter: tuple = (10, 11)
    def schedule(self, allow_query):
        self.counter = (21, 22)
        if allow_query:
            old = self.scalar
            self.query_calls += 1
            self.query_values = tuple(x + old for x in self.query_values)
            self.scalar += 4
            self.clock += 1
            self.scalar_changed = self.clock
            self.query_cursor = self.clock
        amount = 1 + sum(self.counter)
        self.resource_capture = tuple(x + amount for x in self.resource_capture)

def selftest():
    s = CapturedState()
    s.schedule(True)
    assert (s.scalar,s.clock,s.query_calls,s.query_values,s.query_cursor,s.resource_capture)==(15,3,1,(41,51),3,(144,244))
    s.schedule(False)
    assert (s.scalar,s.clock,s.query_calls,s.query_values,s.query_cursor,s.resource_capture)==(15,3,1,(41,51),3,(188,288))
    s.schedule(True)
    assert (s.scalar,s.clock,s.query_calls,s.query_values,s.query_cursor,s.resource_capture)==(19,4,2,(56,66),4,(232,332))
if __name__ == '__main__':
    selftest()
