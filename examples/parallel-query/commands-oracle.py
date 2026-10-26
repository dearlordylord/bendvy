"""Independent model of two query-author runs and selected deferred boundaries."""
from oracle import INPUTS, INITIAL_OUTPUTS, allocator, column


def scenario(final):
    values = dict(INITIAL_OUTPUTS)
    stamps = {}
    queued = []
    receipts = []
    now = 0
    for _ in range(2):
        now += 1
        author_cursor = now
        for index in (1, 17):
            token, value = values[index]
            values[index] = token + 1, value + INPUTS[index][1]
            stamps[index] = now
            queued.append((index, 1000 + index, 600 + index))
        now += 1
        peer_cursor = now
        if final:
            now += 1
            for index, token, value in queued:
                previous_token, previous_value = values[index]
                receipts.append((index, previous_token, previous_value))
                values[index] = token, value
                stamps[index] = now
            queued.clear()
    queue = '[' + ', '.join(f'1:{i}:0:{t}:{v}' for i, t, v in sorted(queued)) + ']'
    applied = '[' + ', '.join(f'applied:1:{i}:0:{t}:{v}' for i, t, v in sorted(receipts)) + ']'
    report = '[error:1:query-body:[1:after-enqueue], ran:2:peer]'
    world = (f'namespace=1;allocator={{{allocator(18)}}};'
             + f'input={column(INPUTS, {})};output={column(values, stamps)};'
             + 'resource=800;events=0;legacy-pending=0;'
             + 'registrations=[2:peer:[], 1:author:[input, output]];next=3;'
             + f'clock=0:{now}:[]')
    return (report + ';' + report + ';exact-pending=' + ('false' if final else 'true')
            + '|world=' + world + '|queue=' + queue + '|receipts=' + applied
            + f'|user=902:2|cursor=0:{author_cursor}|peer=801:0:{peer_cursor}'
            + '|handler=901:2|unapplied=' + ('[]' if final else '[2, 1]'))


if __name__ == '__main__':
    for schema in ('First', 'Second'):
        for name, final in [('native-final', True), ('native-retained', False), ('serial-final', True)]:
            print(schema + '/' + name + '=' + scenario(final))
