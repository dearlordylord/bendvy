"""Independent finite allocation model; no runtime output is consumed."""
import json
from pathlib import Path
MAX = 2**32 - 1

def allocate(next_id):
    return (next_id + 1, next_id) if next_id < MAX else (next_id, 0)

def expected():
    counter, first = allocate(MAX - 2)
    counter, second = allocate(counter)
    before = counter
    counter, sentinel = allocate(counter)
    assert (first, second, counter, sentinel) == (MAX-2, MAX-1, MAX, 0)
    # Both Route attempts check availability before creating a registration.
    assert not counter < MAX
    stream = {"domain":"boundary","batches":[{"tick":7,"values":[71]}],
              "positions":[{"id":9,"cursor":6,"registeredAt":5}],
              "nextReader":counter,"frameStart":4,"boundary":5,"capacity":8,"dropped":3}
    return {"acceptedReaderIds":[first,second],"nextReaderAfterAccepted":before,
            "directExhaustedId":sentinel,"streamUnchanged":counter==before,
            "streamAfter":stream,"registrationsAbsent":True}

if __name__ == "__main__":
    print(json.dumps(expected(),separators=(",",":")))
