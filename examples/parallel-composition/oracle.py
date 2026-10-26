#!/usr/bin/env python3
"""Finite transition model. Never reads generated code or implementation output."""
from dataclasses import dataclass, field


def show(values):
    return "[" + ", ".join(map(str, values)) + "]"


@dataclass
class Model:
    tick: int = 0
    x: int = 10
    count: int = 0
    labels: int = 0
    calls: int = 0
    present: bool = False
    refused: bool = False
    runs: list = field(default_factory=lambda: [0, 0, 0, 0])
    checks: list = field(default_factory=lambda: [0, 0])
    cursors: list = field(default_factory=lambda: [None] * 6)
    errors: list = field(default_factory=list)
    position_stamp: int = 0
    label_stamp: int = 0

    def enter(self, system):
        self.tick += 1
        self.cursors[system - 1] = self.tick

    def run(self):
        events = []
        # Declared nested edges: 1>2, 3>4, 1>3, 3>2.
        for system in [1, 3, 2, 4]:
            if system in [3, 4]:
                guard = system + 2
                self.enter(guard)
                self.checks[system - 3] += 1
                if not self.present:
                    self.errors.append("missing-service:host")
                    events.append(f"{system}:condition-error:missing-service:host")
                    continue
            self.enter(system)
            self.runs[system - 1] += 1
            if system in [1, 2]:
                self.x += 1
                self.count += 1
                self.position_stamp = self.tick
                events.append(f"{system}:ran:101:{self.x}")
            else:
                self.labels += 1
                self.calls += 1
                self.label_stamp = self.tick
                result = f"HOST-901:{self.calls}"
                if self.runs[system - 1] == 2:
                    self.errors.append("after-host-call")
                    events.append(f"{system}:body-error:after-host-call:{result}")
                else:
                    events.append(f"{system}:ran:{result}")
        return "finished:" + show(events)

    def observe(self, invalid=False, optional=True):
        def column(index, value, changed):
            return "capacity=8[" + "".join(
                f"{i}={value}@0:0/0:{changed};" if i == index else f"{i}=absent@never/never;"
                for i in range(8)
            ) + "]"

        names = ["motion-first", "motion-second", "labels-first", "labels-second", "host-first", "host-second"]
        access = [["position", "counter"], ["position", "counter"], ["label", "host"], ["label", "host"], ["host", "optional"], ["host", "optional"]]
        registrations = show(f"{i + 1}:{names[i]}:{show(access[i])}" for i in reversed(range(6)))
        position = f"101:{self.x}/cache=101:{self.x}"
        label = "LABEL-202" + "!" * self.labels + ":seed"
        host = f"HOST-901:{self.calls}" if self.present else "missing"
        allocator = "next=3,high=2,capacity=4,depth=2,slots=[0:consumed, 0:live, 0:live, 0:consumed],free=[],order=[1:0, 2:0]"
        optional_text = "some:OPTIONAL-303" if optional else "none"
        world = f"namespace=1;allocator={{{allocator}}};positions={column(1, position, self.position_stamp)};labels={column(2, label + '/cache=' + label, self.label_stamp)};counter=301:{self.count}/optional=some:302/cache=301:{self.count};host={host}/cache={host};optional={optional_text}/cache={optional_text};events=0;pending=0;registrations={registrations};next=7;clock=0:{self.tick}:[]"

        def meta(index, local):
            cursor = "never" if self.cursors[index] is None else f"0:{self.cursors[index]}"
            return f"ns=1,id={index + 1},name={names[index]},access={show(access[index])},cursor={cursor},local={local}"

        locals_ = [f"501:{self.runs[0]}:1:1:0", f"502:{self.runs[1]}:1:1:0", f"LOCAL-503:{self.runs[2]}:1:2:0", f"LOCAL-504:{self.runs[3]}:1:2:0"]
        owners = "[" + ";".join(meta(i, locals_[i]) for i in range(4)) + "];cached-ids=[1]/[3]/[1, 2]"
        guards = "[" + ";".join(meta(i + 4, f"{701 + i}:{self.checks[i]}") for i in range(2)) + "];cached-ids=[5]"
        pending = "none" if self.present else "HOST-901:0"
        refused = "[HOST-902:0]" if self.refused else "[]"
        entries = "[component:position:position:plain, component:label:label:constructed, resource:counter:counter, resource:host:host:transient, resource:optional:optional]"
        requirements = {1: "[component/position, resource/counter]", 2: "[component/position, resource/counter]", 3: "[component/label, resource/host]", 4: "[component/label, resource/host]"}
        order = [1, 2, 3, 4] if invalid else [1, 3, 2, 4]
        edges = "[1>3]" if invalid else "[1>2, 3>4, 1>3, 3>2]"
        schedule = show(f"{i}:{requirements[i]}" for i in order) + ":" + edges
        error = "invalid-nesting:[0]:unknown:3" if invalid else "none"
        return f"world={{{world}}};systems={{{owners}}};guards={{{guards}}};handler=801:{show(self.errors)};provisions=601:PROVISION-602;pending-host={pending};refused-host={refused};schema={entries};plan={schedule};bindings=[3>5, 4>6];original-bindings=[3>5, 4>6];invalid={error}"


def expected():
    lines = []
    for name, count in [("missing", 1), ("provided", 2), ("repeated", 3)]:
        model = Model()
        reports = [model.run()]
        if count > 1:
            model.present = True
            model.refused = True
            reports.extend(model.run() for _ in range(count - 1))
        lines.append(name + "=" + "|".join(reports) + "|" + model.observe())
    model = Model()
    lines.append("invalid-nesting=refused:invalid-nesting:[0]:unknown:3|" + model.observe(invalid=True))
    model = Model()
    lines.append("optional-none=" + model.run() + "|" + model.observe(optional=False))
    lines.append("validation=valid=accepted:text:seed/owner=VALID-906:seed;invalid=rejected:$:literal:text:bad/owner=REJECT-907:bad;optional-none=none;optional-some=some:OPTIONAL-905")
    returned = "counter=301:0/optional=some:302/cache=STALE;host=REFUSAL-HOST-904:9/cache=STALE;optional=some:OPTIONAL-303/cache=STALE"
    lines.append("schema-collision=duplicate-key:component:duplicate;factory=1;" + returned)
    lines.append("namespace-refusal=namespace-refused;factory=4294967295;" + returned)
    return "\n".join(lines) + "\n"


if __name__ == "__main__":
    print(expected(), end="")
