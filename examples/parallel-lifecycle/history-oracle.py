"""Independent historical execution model; no observed output is used as input."""
from pathlib import Path
import runpy

query = runpy.run_path(str(Path(__file__).resolve().parents[1] / "parallel-query" / "oracle.py"))
MODULUS = 1 << 32
MAX_AGE = 3258167296


def tick(value):
    return f"{value // MODULUS}:{value % MODULUS}"


def age(stamp, current):
    return min(current - stamp, MAX_AGE)


def column(values, initial_stamp, writes):
    slots = []
    for index in range(32):
        if index in values:
            token, value = values[index]
            payload = f"{token}:{value}@{value}"
            stamps = tick(initial_stamp) + "/" + tick(writes.get(index, initial_stamp))
        else:
            payload, stamps = "-", "-/-"
        slots.append(f"{index}={payload}@{stamps};")
    return "capacity=32[" + "".join(slots) + "]"


def world(outputs, initial_stamp, writes, current):
    return ("namespace=1;allocator={" + query["allocator"](18) + "};"
            "input=" + column(query["INPUTS"], initial_stamp, {}) + ";"
            "output=" + column(outputs, initial_stamp, writes) + ";"
            "resource=800;events=0;pending=0;registrations=[1:query:[input, output]];"
            "nextSystem=2;clock=" + tick(current) + ":[]")


def scenario(now, stamp, cursor, added=False, error_seed=False):
    outputs = dict(query["INITIAL_OUTPUTS"])
    if error_seed:
        outputs[1] = outputs[1][0], 13
    writes = {}
    statuses = []
    for current in range(now + 1, now + 4):
        errors = []
        for index in (1, 17):
            observed = stamp if added else writes.get(index, stamp)
            eligible = (age(observed, current) < MAX_AGE if cursor is None
                        else age(cursor, current) > age(observed, current))
            if eligible:
                token, value = outputs[index]
                value += query["INPUTS"][index][1]
                outputs[index] = token + 1, value
                writes[index] = current
                if value == 16:
                    errors.append(f"{index}:after-write")
        statuses.append("error/query-body/" + query["shown"](errors) if errors else "success/[]")
        cursor = current
    system = ("namespace=1,id=1,name=query,access=[input, output],cursor="
              + tick(now + 3) + ",local=903:3")
    foreign = query["world"](2, 0, query["INITIAL_OUTPUTS"], {}, False, 0)
    return ("statuses=[" + ",".join(statuses) + "];admission=refused;"
            f"system={{{system}}};original={{{world(outputs, stamp, writes, now + 3)}}};"
            f"foreign={{{foreign}}}")


if __name__ == "__main__":
    cases = (
        ("First/zero-cursor", 0, 0, 0, True, False),
        ("First/wrap", MODULUS - 1, MODULUS - 1, MODULUS - 2, False, False),
        ("Second/dormant-old", 3 * MODULUS, 0, 0, False, False),
        ("Second/dormant-recent", 3 * MODULUS, 3 * MODULUS, 0, False, False),
        ("First/error", 0, 0, None, False, True),
        ("Second/error-serial", 0, 0, None, True, True),
    )
    for label, *arguments in cases:
        print(label + "=" + scenario(*arguments))
