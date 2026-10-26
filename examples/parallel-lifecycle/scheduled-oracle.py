"""Independent model of scheduled lifecycle filtering and deferred publication."""
from pathlib import Path
import runpy

query = runpy.run_path(str(Path(__file__).resolve().parents[1] / "parallel-query" / "oracle.py"))


def scenario(changed, final):
    values = dict(query["INITIAL_OUTPUTS"])
    stamps = {}
    queued, receipts, reports = [], [], []
    now, cursor, errors = 0, None, 0
    for _ in range(2):
        now += 1
        selected = []
        for index in (1, 17):
            stamp = stamps.get(index, 0) if changed else 0
            if cursor is None or stamp > cursor:
                selected.append(index)
                token, value = values[index]
                values[index] = token + 1, value + query["INPUTS"][index][1]
                stamps[index] = now
                queued.append((index, 1000 + index, 600 + index))
        cursor = now
        errors += 1 in selected
        reports.append('[error:1:query-body:[1:after-enqueue], ran:2:peer]'
                       if 1 in selected else '[ran:1:[], ran:2:peer]')
        now += 1
        peer_cursor = now
        if final and queued:
            now += 1
            for index, token, value in queued:
                previous_token, previous_value = values[index]
                receipts.append((index, previous_token, previous_value))
                values[index] = token, value
                stamps[index] = now
            queued.clear()
    queue = '[' + ', '.join(f'1:{i}:0:{t}:{v}' for i, t, v in sorted(queued)) + ']'
    applied = '[' + ', '.join(f'applied:1:{i}:0:{t}:{v}' for i, t, v in sorted(receipts)) + ']'
    world = (f'namespace=1;allocator={{{query["allocator"](18)}}};'
             + f'input={query["column"](query["INPUTS"], {})};output={query["column"](values, stamps)};'
             + 'resource=800;events=0;legacy-pending=0;'
             + 'registrations=[2:peer:[], 1:author:[input, output]];next=3;'
             + f'clock=0:{now}:[]')
    return (';'.join(reports) + ';exact-pending=' + ('true' if queued else 'false')
            + '|world=' + world + '|queue=' + queue + '|receipts=' + applied
            + f'|user=902:2|cursor=0:{cursor}|peer=801:0:{peer_cursor}'
            + f'|handler=901:{errors}|unapplied=' + ('[]' if final else '[2, 1]'))


if __name__ == '__main__':
    for label, changed, final in (
        ('First/added-native', False, True),
        ('First/changed-native', True, True),
        ('First/changed-retained', True, False),
        ('Second/added-serial', False, True),
        ('Second/changed-serial', True, True),
        ('Second/changed-retained', True, False),
    ):
        print(label + '=' + scenario(changed, final))
