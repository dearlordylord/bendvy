"""Finite independent model of the frozen TS zero-entry shared fixture."""
import json

def run(label):
    sibling = [[31, 32], [41, 42]]
    draft = {'id': -1, 'proof': {}, 'components': [], 'relations': []}
    inserted = {'id': -1, 'proof': {}, 'components': [], 'relations': []}
    assert draft == inserted and draft is not inserted
    alive, pending, checkpoints, statuses = [], [], [], []

    def observe(name):
        checkpoints.append({'label': name, 'entities': list(alive), 'sibling': sibling, 'sameSibling': True})

    def flush():
        for operation in pending:
            if operation == 'spawn':
                alive.append(1)
            else:
                assert operation == 'empty-insert'
                # Command.insert iterates no entries, never calling writeComponent.
        pending.clear()

    observe('before')
    pending.append('spawn')
    observe('spawn-queued')
    flush()
    observe('spawn-barrier')
    flush()
    observe('spawn-second-barrier')
    statuses.append({'operation': 'tick', 'ok': True})
    statuses.append({'operation': 'insert-return', 'same': True, 'id': 1})
    pending.append('empty-insert')
    observe('insert-queued')
    flush()
    observe('insert-barrier')
    flush()
    observe('insert-second-barrier')
    statuses.append({'operation': 'tick', 'ok': True})
    statuses.append({'operation': 'missing-return', 'same': True, 'id': 999})
    pending.append('empty-insert')
    observe('missing-queued')
    flush()
    observe('missing-barrier')
    flush()
    observe('missing-second-barrier')
    statuses.append({'operation': 'tick', 'ok': True})
    assert len(checkpoints) == 10 and len(statuses) == 5
    assert checkpoints[0]['entities'] == checkpoints[1]['entities'] == []
    assert all(x['entities'] == [1] for x in checkpoints[2:])
    assert all(x['sibling'] is sibling for x in checkpoints)
    return {'schema': label, 'draft': draft, 'insertedDraft': inserted, 'draftDistinct': True,
            'handle': 1, 'statuses': statuses, 'checkpoints': checkpoints}

def expected():
    # Each Runtime.make allocates locally from 1; JSON.stringify emits compact JSON+LF.
    return (json.dumps([run('First'), run('Second')], separators=(',', ':'), ensure_ascii=False) + '\n').encode()

if __name__ == '__main__':
    import hashlib
    raw = expected()
    print(json.dumps({'status': 'PASS_FINITE_TS_SELFTEST', 'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}))
