"""Independent complete four-case raw traversal/finish oracle."""
import argparse
import copy
import sys
from state import World, listing


class Session(World):
    def __init__(self, namespace):
        super().__init__("Motion", 3)
        self.namespace = namespace
        self.undo = []

    def world(self):
        stored = ";".join(name + "={" + column.show(render) + "}"
                          for name, column, render in zip(("main", "aux", "flag"), self.columns,
                                                          (self.main, self.aux, self.flag)))
        resource = "MotionLedger{" + self.resource_tree() + ";4};sibling=Unit"
        return (f"namespace={self.namespace}|allocator={{" + self.allocator() + "}|store={" + stored
                + "}|resource={" + resource + "}|events=[]|pending=0:end|registrations=[]"
                + "|nextSystem=1|clock=" + str(self.clock))

    def resource_tree(self):
        from state import tree
        return tree(self.ledger)

    def row(self, entity):
        main = self.columns[0]
        old = main.values[entity - 1].copy()
        stamp = main.stamps[entity]
        value = sum(old)
        replacement = old.copy()
        replacement[0] += 1
        self.clock += 1
        main.write(entity, replacement, self.clock)
        self.undo.insert(0, ("component", entity, old, stamp))
        previous_ledger = self.ledger.copy()
        self.ledger = [self.ledger[0] + 1, *self.ledger[1:]]
        self.undo.insert(0, ("resource", previous_ledger))
        return value

    def rollback(self):
        # Core inverse closures preserve current World clock and use L.set
        # to restore each old stamp, which can change stamp-list order.
        for inverse in self.undo:
            if inverse[0] == "resource":
                self.ledger = inverse[1]
            else:
                _, entity, previous, stamp = inverse
                main = self.columns[0]
                main.values[entity - 1] = previous
                main.stamps[entity] = stamp
                main.order = [entity] + [key for key in main.order if key != entity]
        self.undo = []


def run_case(namespace, name, skip=False, empty=False, fail=False):
    session = Session(namespace)
    session.reserve_all()
    session.populate()
    selected = [] if empty else session.order
    values = []
    failed = False
    for entity in selected:
        if skip and entity == 2:
            continue
        value = session.row(entity)
        if fail and value == 10:
            failed = True
            break
        values.append(value)
    raw_values = values.copy()
    raw_outcome = "UserFailure" if failed else "Success"
    prefix = (name + "\nrawOutcome=" + raw_outcome + ";values=" + listing(values)
              + ";undo=" + str(len(session.undo))
              + ";commands=0;events=[];traceEnabled=False;world=" + session.world() + "\n")
    before = copy.deepcopy(session)
    if failed:
        session.rollback()
        values = []
    else:
        session.undo = []
    text = (prefix + "finishedOutcome=" + raw_outcome + ";values=" + listing(values)
            + ";world=" + session.world() + "\n\n")
    return text, before, session, raw_values, values


def report():
    cases = [(1, "success", False, False, False), (2, "skip-middle", True, False, False),
             (3, "empty", False, True, False), (4, "fail-second", False, False, True)]
    return "".join(run_case(*case)[0] for case in cases).encode()


def selftest():
    success = run_case(1, "success")
    skipped = run_case(2, "skip-middle", skip=True)
    empty = run_case(3, "empty", empty=True)
    failed = run_case(4, "fail-second", fail=True)
    assert [case[3] for case in (success, skipped, empty, failed)] == [[6, 10, 14], [6, 14], [], [6]]
    assert [case[1].clock for case in (success, skipped, empty, failed)] == [8, 7, 5, 7]
    assert [len(case[1].undo) for case in (success, skipped, empty, failed)] == [6, 4, 0, 4]
    assert failed[4] == [] and failed[2].clock == 7
    assert failed[1].columns[0].values[:3] == [[1, 1, 2, 3], [2, 2, 3, 4], [2, 3, 4, 5]]
    assert failed[2].columns[0].values[:3] == [[0, 1, 2, 3], [1, 2, 3, 4], [2, 3, 4, 5]]
    assert failed[1].columns[0].order == [2, 1, 3]
    assert failed[2].columns[0].order == [1, 2, 3]
    assert failed[2].columns[0].stamps == {1: (1, 1), 2: (3, 3), 3: (5, 5)}
    assert failed[2].ledger == [0, 101, 102, 103]
    assert report().endswith(b"\n\n") and report().count(b"traceEnabled=False") == 4
    return True


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--self-test", "--selftest", action="store_true")
    args = parser.parse_args()
    if args.self_test:
        assert selftest()
        print("PASS")
    else:
        sys.stdout.buffer.write(report())
