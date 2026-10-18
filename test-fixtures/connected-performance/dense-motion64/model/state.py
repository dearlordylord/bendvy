"""Independent parameterized Dense operation state; wire entry awaits source freeze."""
import argparse
import copy
import json
from dataclasses import dataclass, field


def listing(values):
    return "[" + ", ".join(map(str, values)) + "]"


def tree(values):
    assert values and len(values) & (len(values) - 1) == 0
    if len(values) == 1:
        return "leaf:" + str(values[0])
    half = len(values) // 2
    return "node(" + tree(values[:half]) + "," + tree(values[half:]) + ")"


@dataclass
class Column:
    values: list = field(default_factory=lambda: [None])
    stamps: dict = field(default_factory=dict)
    order: list = field(default_factory=list)

    def write(self, entity, value, tick):
        while len(self.values) < entity:
            self.values += [None] * len(self.values)
        added = self.stamps.get(entity, (tick, tick))[0]
        self.values[entity - 1] = value
        self.stamps[entity] = (added, tick)
        self.order = [entity] + [key for key in self.order if key != entity]

    def show(self, render):
        values = ["none" if value is None else "some(" + render(value) + ")"
                  for value in self.values]
        stamps = [f"{key}:{self.stamps[key][0]}:{self.stamps[key][1]}" for key in self.order]
        return "Column{values=" + tree(values) + ";stamps=" + listing(stamps) + "}"


@dataclass
class IndexedMetadata:
    """Factory-produced scalar trees, independent of payload-array capacity."""
    added: list = field(default_factory=lambda: [0])
    changed: list = field(default_factory=lambda: [0])
    capacity: int = 1
    depth: int = 0
    exceptional: list = field(default_factory=list)

    @staticmethod
    def normal(entity):
        return 0 < entity <= 131072

    def get(self, entity):
        if not self.normal(entity):
            return next((stamp for key, stamp in self.exceptional if key == entity), (0, 0))
        if entity > self.capacity:
            return (0, 0)
        return (self.added[entity - 1], self.changed[entity - 1])

    def set(self, entity, stamp):
        if not self.normal(entity):
            self.exceptional = [(entity, stamp)] + [(key, old) for key, old in self.exceptional if key != entity]
            return
        while entity > self.capacity:
            self.added += [0] * self.capacity
            self.changed += [0] * self.capacity
            self.capacity *= 2
            self.depth += 1
        self.added[entity - 1], self.changed[entity - 1] = stamp

    def clear(self, entity):
        if not self.normal(entity):
            self.exceptional = [(key, old) for key, old in self.exceptional if key != entity]
        elif entity <= self.capacity:
            self.set(entity, (0, 0))

    def show(self):
        entries = [f"{key}:{stamp[0]}:{stamp[1]}" for key, stamp in self.exceptional]
        return ("added=" + tree(self.added) + ";changed=" + tree(self.changed)
                + f";capacity={self.capacity};depth={self.depth};exceptional=" + listing(entries))


@dataclass
class IndexedColumn(Column):
    metadata: IndexedMetadata = field(default_factory=IndexedMetadata)

    def write(self, entity, value, tick):
        was_present = entity <= len(self.values) and self.values[entity - 1] is not None
        previous = self.metadata.get(entity)
        super().write(entity, value, tick)
        # lifecycle.written: retained added stamp depends on actual presence.
        stamp = (previous[0], tick) if was_present else (tick, tick)
        self.metadata.set(entity, stamp)
        self.stamps[entity] = stamp

    def show(self, render):
        values = ["none" if value is None else "some(" + render(value) + ")"
                  for value in self.values]
        return "Indexed{owned(values=" + tree(values) + ";metadata={" + self.metadata.show() + "})}"


@dataclass
class World:
    schema: str
    count: int = 64
    namespace: int = 1
    phases: list = field(default_factory=lambda: ["Consumed"])
    order: list = field(default_factory=list)
    columns: list = field(default_factory=lambda: [Column(), Column(), Column()])
    ledger: list = field(default_factory=lambda: [0, 101, 102, 103])
    pending: list = field(default_factory=list)
    registered: bool = False
    clock: int = 0
    cursor: int = 0
    audit: list = field(default_factory=list)
    statuses: list = field(default_factory=list)

    indexed: bool = False

    def __post_init__(self):
        if self.indexed:
            self.columns = [IndexedColumn(), IndexedColumn(), IndexedColumn()]

    def reserve_all(self):
        for entity in range(1, self.count + 1):
            if entity == len(self.phases):
                self.phases += ["Consumed"] * len(self.phases)
            self.phases[entity] = "Pending"
            self.order.append(entity)
            self.pending.insert(0, entity)

    def populate(self):
        for entity in reversed(self.pending):
            j = entity - 1
            self.phases[entity] = "Live"
            values = [[j, j + 1, j + 2, j + 3], [1, 2, 3, 4], 8]
            for index, present in enumerate([True, j % 3 == 0, j % 3 == 1]):
                if present:
                    self.clock += 1
                    self.columns[index].write(entity, values[index], self.clock)
        self.pending = []

    def update(self):
        values = []
        for entity in self.order:
            old = self.columns[0].values[entity - 1]
            values.append(sum(old))
            replacement = old.copy()
            replacement[0] += 1
            self.clock += 1
            self.columns[0].write(entity, replacement, self.clock)
            # This is deliberately a per-row full resource read/write.
            self.ledger = [self.ledger[0] + 1, *self.ledger[1:]]
        self.audit.append(values)
        self.statuses.append("Succeeded")
        self.cursor = self.clock

    def names(self):
        return (("Position", "Velocity", "Selected", "MotionLedger") if self.schema == "Motion"
                else ("Vitals", "Armor", "Tracked", "HealthLedger"))

    def main(self, values):
        return self.names()[0] + "{" + tree(values) + (";7}" if self.schema == "Motion" else ";9,2}")

    def aux(self, values):
        return self.names()[1] + "{" + tree(values) + (";True}" if self.schema == "Motion" else ";3}")

    def flag(self, value):
        return self.names()[2] + "{" + str(value) + "}"

    def allocator(self):
        return (f"next={self.count + 1};high={self.count};capacity={len(self.phases)};depth={len(self.phases).bit_length() - 1};slots="
                + tree(["0:" + phase for phase in self.phases]) + ";free=[];order="
                + listing(f"{entity}:0" for entity in self.order))

    def world(self):
        names = self.names()
        access = listing([names[0], names[3]])
        stored = ";".join(name + "={" + column.show(render) + "}"
                          for name, column, render in zip(("main", "aux", "flag"), self.columns,
                                                          (self.main, self.aux, self.flag)))
        resource = names[3] + "{" + tree(self.ledger) + ";4};sibling=Unit"
        registrations = listing(["1:BenchUpdate:" + access]) if self.registered else "[]"
        return (f"namespace={self.namespace}|allocator={{" + self.allocator() + "}|store={" + stored
                + "}|resource={" + resource + "}|events=[]|pending=" + str(len(self.pending))
                + ":" + "Raw;" * len(self.pending) + "end|registrations=" + registrations
                + "|nextSystem=" + str(2 if self.registered else 1) + "|clock=" + str(self.clock))

    def owner(self):
        names = self.names()
        return (f"ns={self.namespace};id=1;name=BenchUpdate;access=" + listing([names[0], names[3]])
                + ";cursor=" + str(self.cursor) + ";slot=dense64;clauses="
                + listing([names[0] + ":Write", names[3] + ":Write"]))

    def state(self):
        audits = ["values=" + listing(values) + ";readsum=" + str(sum(values)) + ";updated="
                  + str(len(values)) for values in self.audit]
        return ("world={" + self.world() + "}|owner={" + self.owner() + "}|audit="
                + listing(audits) + "|statuses=" + listing(self.statuses))

    def logical_rows(self):
        rows = []
        for entity in self.order:
            j = entity - 1
            values = self.columns[0].values[j]
            four = dict(zip("abcd", values))
            main = ({"coordinates": four, "frame": 7} if self.schema == "Motion"
                    else {"levels": four, "reserve": 9, "class": 2})
            aux = self.columns[1].values[j]
            if aux is None:
                aux_text = "ComponentAbsent"
            else:
                four_aux = dict(zip("abcd", aux))
                aux_value = ({"rates": four_aux, "moving": True} if self.schema == "Motion"
                             else {"layers": four_aux, "grade": 3})
                aux_text = "Found(" + json.dumps(aux_value, separators=(",", ":")) + ")"
            flag = self.columns[2].values[j]
            flag_text = "ComponentAbsent" if flag is None else 'Found({"group":8})'
            rows.append(f"handle={self.namespace}:{entity}:0;main=Found("
                        + json.dumps(main, separators=(",", ":")) + ");aux=" + aux_text
                        + ";flag=" + flag_text)
        return listing(rows)



def derived_shared(schema, count, iterations=64):
    assert schema in ("Motion", "Health") and count in (64, 256, 1024)
    rows = []
    for j in range(count):
        values = [j + iterations, j + 1, j + 2, j + 3]
        main = ({"coordinates": values, "frame": 7} if schema == "Motion"
                else {"levels": values, "reserve": 9, "class": 2})
        aux = None
        if j % 3 == 0:
            aux = ({"rates": [1, 2, 3, 4], "moving": True} if schema == "Motion"
                   else {"layers": [1, 2, 3, 4], "grade": 3})
        rows.append({"rawId": j + 1, "main": main, "aux": aux,
                     "flag": {"group": 8} if j % 3 == 1 else None})
    return ({"rows": rows, "ledger": {"totals": [count * iterations, 101, 102, 103], "epoch": 4}},
            [{"readSum": 2 * count * (count - 1) + (6 + i) * count,
              "updated": count, "selections": {}} for i in range(iterations)])


def expected_seed_writes(count):
    return count + (count + 2) // 3 + (count + 1) // 3


def operation_selftest(count=64):
    for schema in ("Motion", "Health"):
        world = World(schema, count)
        world.reserve_all()
        assert len(world.pending) == count
        assert world.phases.count("Pending") == count
        assert len(world.phases) == 2 * count
        world.populate()
        assert world.clock == expected_seed_writes(count)
        world.registered = True
        for _ in range(64):
            world.update()
        final, audit = derived_shared(schema, count)
        assert world.clock == world.cursor == expected_seed_writes(count) + count * 64
        assert world.ledger == final["ledger"]["totals"]
        assert [sum(values) for values in world.audit] == [row["readSum"] for row in audit]
        assert all(len(values) == count for values in world.audit)
        assert all(world.columns[0].values[j] == list(final["rows"][j]["main"].values())[0]
                   for j in range(count))
    return True
