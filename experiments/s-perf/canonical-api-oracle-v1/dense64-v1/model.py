"""Independent finite canonical Dense64 operation model and complete wire formatter."""
import argparse
import copy
import json
from dataclasses import dataclass, field
from shared import derive


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
class World:
    schema: str
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

    def reserve_all(self):
        for entity in range(1, 65):
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
        return ("next=65;high=64;capacity=128;depth=7;slots="
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
        return ("namespace=1|allocator={" + self.allocator() + "}|store={" + stored
                + "}|resource={" + resource + "}|events=[]|pending=" + str(len(self.pending))
                + ":" + "Raw;" * len(self.pending) + "end|registrations=" + registrations
                + "|nextSystem=" + str(2 if self.registered else 1) + "|clock=" + str(self.clock))

    def owner(self):
        names = self.names()
        return ("ns=1;id=1;name=BenchUpdate;access=" + listing([names[0], names[3]])
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
            rows.append(f"handle=1:{entity}:0;main=Found("
                        + json.dumps(main, separators=(",", ":")) + ");aux=" + aux_text
                        + ";flag=" + flag_text)
        return listing(rows)


def report(schema):
    world = World(schema)
    world.reserve_all()
    reservations = listing(f"Reserved(1:{entity}:0)" for entity in world.order)
    text = f"Dense64 {schema}\nseedOutcome=Success|reservations={reservations}\n"
    text += "seedPending=" + world.world() + "\n"
    world.populate()
    text += "seedApplied=" + world.world() + "\n"
    world.registered = True
    text += "registered=" + world.state() + "\n"
    for _ in range(64):
        world.update()
    text += "final=" + world.state() + "\n"
    before = copy.deepcopy(world)
    text += "logicalRows=" + world.logical_rows() + "\n"
    assert before == world
    text += "afterLogicalRead=" + world.world() + "\n"
    return (text + "\n").encode(), world


def selftest():
    for schema in ("Motion", "Health"):
        raw, world = report(schema)
        final, audit = derive(schema)
        assert world.clock == world.cursor == 4203
        assert world.ledger == final["ledger"]["totals"]
        assert len(world.phases) == 128 and world.phases.count("Live") == 64
        assert all(world.columns[0].values[j] == list(final["rows"][j]["main"].values())[0]
                   for j in range(64))
        assert [sum(values) for values in world.audit] == [row["readSum"] for row in audit]
        assert all(len(values) == 64 for values in world.audit)
        assert raw.endswith(b"\n\n") and b"UNSUPPORTED" not in raw
        assert len(world.columns[1].stamps) == 22 and len(world.columns[2].stamps) == 21
    return True


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("schema", nargs="?", choices=["Motion", "Health"], default="Motion")
    parser.add_argument("--self-test", "--selftest", action="store_true")
    args = parser.parse_args()
    if args.self_test:
        assert selftest()
        print("PASS")
    else:
        import sys
        sys.stdout.buffer.write(report(args.schema)[0])
