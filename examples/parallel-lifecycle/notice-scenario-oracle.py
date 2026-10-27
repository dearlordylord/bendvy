"""Independent finite model of command publication, reads and Finished retention.

No captured implementation output is read. Inputs are the declared initial owners,
real entity inventory and four-update program. One publication boundary follows
its admitted error; two generations are retained and each reader owns its cursor.
"""
from pathlib import Path
import runpy

query = runpy.run_path(str(Path(__file__).resolve().parents[1] / 'parallel-query/oracle.py'))
shown = query['shown']


def scenario(namespace, updates=4, return_state=False):
    inputs = dict(query['INPUTS'])
    outputs = dict(query['INITIAL_OUTPUTS'])
    live = set(range(1, 19))
    channels = {name: dict(next=1, floor=0, previous=[], current=[])
                for name in ('removed/output', 'removed/input', 'despawn')}
    cursors = dict(fast=0, slow=0, input=0, despawn=0)
    history = ''
    reports = []
    receipts = []
    now = 0

    def publish(family, entity, tick):
        channel = channels[family]
        channel['current'].append((channel['next'], entity, tick))
        channel['next'] += 1

    def read(reader, family):
        channel = channels[family]
        missed = max(channel['floor'] - cursors[reader], 0)
        cursors[reader] = max(cursors[reader], channel['floor'])
        for sequence, entity, tick in channel['previous'] + channel['current']:
            if sequence > cursors[reader]:
                cursors[reader] = sequence
                return f'item={sequence}:{namespace}:{entity}:0@0:{tick}/missed={missed}'
        return f'empty/missed={missed}'

    for update in range(updates):
        now += 1
        author_cursor = now
        errors = []
        for entity in sorted(live & inputs.keys() & outputs.keys()):
            token, value = outputs[entity]
            outputs[entity] = token + 1, value + inputs[entity][1]
            if entity == 1:
                errors.append('1:after-enqueue')
        if update == 0:
            # The captured real handles enqueue only once. The declared edge
            # publishes both accepted operations before the reader body.
            now += 1
            previous = outputs.pop(1)
            receipts.append(f'applied:{namespace}:1:0:{previous[0]}:{previous[1]}')
            publish('removed/output', 1, now)
            old_input, old_output = inputs.pop(17), outputs.pop(17)
            live.remove(17)
            receipts.append(f'despawned:{namespace}:17:0:input={old_input[0]}:{old_input[1]}'
                            + f'/output={old_output[0]}:{old_output[1]}')
            publish('removed/input', 17, now)
            publish('removed/output', 17, now)
            publish('despawn', 17, now)
        now += 1
        peer_cursor = now
        fast = read('fast', 'removed/output')
        slow = 'dormant' if update < 2 else read('slow', 'removed/output')
        other = read('input', 'removed/input')
        despawn = read('despawn', 'despawn')
        history += f'update={update}/fast={fast}/slow={slow}/input={other}/despawn={despawn};'
        author_event = ('error:1:query-body:' + shown(errors)) if errors else 'ran:1:[]'
        reader_event = ('error:2:after-reader-yield:' if update == 0 else 'ran:2:') + history
        reports.append(shown([author_event, reader_event]))
        # Exactly one normal public update completion rotates every family.
        for channel in channels.values():
            if channel['previous']:
                channel['floor'] = channel['previous'][-1][0]
            channel['previous'], channel['current'] = channel['current'], []

    slots = ['1:free' if i == 17 else '0:live' if i in live else '0:consumed'
             for i in range(32)]
    allocator = ('next=19,high=18,capacity=32,depth=5,slots=' + shown(slots)
                 + ',free=[17],order=' + shown(f'{i}:0' for i in sorted(live)))
    channel_texts = []
    for family, state in channels.items():
        render = lambda rows: shown(f'{seq}:{namespace}:{entity}:0@0:{tick}' for seq, entity, tick in rows)
        channel_texts.append('{' + family + f',next={state["next"]},floor={state["floor"]}'
                             + ',previous=' + render(state['previous']) + ',current=' + render(state['current']) + '}')
    journal = (f'namespace={namespace};next-reader=5;active='
               + '[1:removed/output, 2:removed/output, 3:removed/input, 4:despawn];channels='
               + shown(channel_texts))
    world = (f'journal={{{journal}}};namespace={namespace};allocator={{{allocator}}};'
             + f'input={query["column"](inputs, {})};output={query["column"](outputs, {})};'
             + 'resource=800;events=0;legacy-pending=0;registrations='
             + '[2:reader:[removed/output, removed/input, despawn], 1:author:[input, output]];'
             + f'next=3;clock=0:{now}:[]')
    reader = (f'token={700 + updates};runs={updates};fast=' + f'{namespace}:1:{cursors["fast"]}'
              + ';slow=' + f'{namespace}:2:{cursors["slow"]}'
              + ';input=' + f'{namespace}:3:{cursors["input"]}'
              + ';despawn=' + f'{namespace}:4:{cursors["despawn"]}'
              + ';history=' + history)
    handles = shown(f'{namespace}:{i}:0' for i in range(1, 19))
    if return_state:
        return dict(world=world, reader=reader, reports=reports, receipts=receipts, handles=handles,
                    author_cursor=author_cursor, peer_cursor=peer_cursor, history=history, cursors=cursors)
    return (';'.join(reports) + ';exact-pending=false|world=' + world
            + '|queue=[]|receipts=' + shown(receipts) + '|handles=' + handles
            + f'|user={900 + updates}:{updates}|cursor=0:{author_cursor}|peer={{{reader}}}:0:{peer_cursor}'
            + '|handler=901:2|unapplied=[]')


if __name__ == '__main__':
    print('First=' + scenario(1))
