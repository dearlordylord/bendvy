"""Independent finite observations for the declared query application's operations."""

INPUTS = {1: (501, 3), 16: (503, 7), 17: (502, 5), 31: (504, 99)}
INITIAL_OUTPUTS = {1: (101, 10), 17: (202, 20), 18: (304, 40), 31: (303, 30)}


def shown(values):
    return "[" + ", ".join(values) + "]"


def column(values, changed):
    slots = []
    for index in range(32):
        if index in values:
            token, value = values[index]
            payload = f"{token}:{value}@{value}"
            stamps = f"0:0/0:{changed.get(index, 0)}"
        else:
            payload, stamps = "-", "-/-"
        slots.append(f"{index}={payload}@{stamps};")
    return "capacity=32[" + "".join(slots) + "]"


def allocator(live_count):
    capacity = 1
    depth = 0
    while capacity <= live_count:
        capacity *= 2
        depth += 1
    slots = ["0:live" if 1 <= index <= live_count else "0:consumed"
             for index in range(capacity)]
    order = [f"{index}:0" for index in range(1, live_count + 1)]
    return (f"next={live_count + 1},high={live_count},capacity={capacity},"
            f"depth={depth},slots={shown(slots)},free=[],order={shown(order)}")


def world(namespace, live_count, outputs, changed, registered, tick):
    registrations = "[1:query:[input, output]]" if registered else "[]"
    return (f"namespace={namespace};allocator={{{allocator(live_count)}}};"
            f"input={column(INPUTS, {})};output={column(outputs, changed)};"
            f"resource=800;events=0;pending=0;registrations={registrations};"
            f"nextSystem={2 if registered else 1};clock=0:{tick}:[]")


def scenario(runs=3):
    outputs = dict(INITIAL_OUTPUTS)
    changed = {}
    statuses = []
    live = set(range(1, 19))
    for tick in range(1, runs + 1):
        errors = []
        for index in sorted(live & INPUTS.keys() & outputs.keys()):
            token, value = outputs[index]
            step = INPUTS[index][1]
            outputs[index] = token + 1, value + step
            changed[index] = tick
            if value + step == 16:
                errors.append(f"{index}:after-write")
        statuses.append("error/query-body/" + shown(errors) if errors else "success/[]")
    system = ("namespace=1,id=1,name=query,access=[input, output],"
              f"cursor=0:{runs},local={900 + runs}:{runs}")
    original = world(1, 18, outputs, changed, True, runs)
    foreign = world(2, 0, INITIAL_OUTPUTS, {}, False, 0)
    return ("statuses=[" + ",".join(statuses) + "];admission=refused;"
            f"system={{{system}}};original={{{original}}};foreign={{{foreign}}}")


if __name__ == "__main__":
    for prefix in ("First/serial", "First/parallel", "Second/parallel"):
        print(prefix + "=" + scenario())

    print("First/error=" + scenario(2))
