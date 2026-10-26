"""Finite output-owner scenarios derived from declared rows and operations."""


def column(values, capacity, changed=()):
    slots = []
    for index in range(capacity):
        if index in values:
            value, stamps = str(values[index]), f"0:0/0:{7 if index in changed else 0}"
        else:
            value, stamps = "absent", "never/never"
        slots.append(f"{index}={value}@{stamps};")
    return f"capacity={capacity}[" + "".join(slots) + "]"


def expected():
    reads = {1: 3, 9: 5, 2: 7}
    for label in ("parallel", "serial", "empty", "missing", "refused"):
        writes = {1: 10, 9: 20, 3: 30}
        changed, outputs, errors, aligned, capacity = (), [900], [], "true", 16
        if label in ("parallel", "serial"):
            writes[1], writes[9] = 13, 25
            changed, outputs, errors = (1, 9), [1, 900, 9], ["1:after-write"]
        if label == "refused":
            writes, outputs, aligned, capacity = {}, [901], "false", 8
        print(label + "=read=" + column(reads, 16)
              + ";write=" + column(writes, capacity, changed)
              + ";output=[" + ", ".join(map(str, outputs)) + "]"
              + ";errors=[" + ", ".join(errors) + "];aligned=" + aligned)


if __name__ == "__main__":
    expected()
