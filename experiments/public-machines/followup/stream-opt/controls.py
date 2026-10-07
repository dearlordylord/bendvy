"""Source-current compiling operation candidates, with named two-schema witnesses.

These are finite execution controls, not laws or proof mutants. Detection requires
complete structurally valid output before examining the named changed field.
"""
MUTANTS = [
    ('queue-capacity', 'queue.bend', 'Nat.is_lt(capacity,size)',
     'Nat.is_lt(Nat.add(capacity,1n),size)', 'capacity-frame', 'flowStream'),
    ('cached-size', 'queue.bend', 'Nat.add(size,count)',
     'Nat.add(size,Nat.add(count,1n))', 'capacity-frame', 'flowStream'),
    ('oldest-newest-order', 'queue.bend', 'Queue{List.reverse(&2,Batch<E>,back),[],size,dropped}',
     'Queue{back,[],size,dropped}', 'overflow-failed-reader', 'deliveries'),
    ('dropped-through', 'queue.bend', 'Nat.max(dropped,tick)',
     'dropped', 'capacity-frame', 'flowStream'),
    ('successful-cursor', 'stream.bend',
     'case Stream{queue,positions,frameStart} True{}: Stream{queue,Ev.update(positions,id,tick,False{}),frameStart}',
     'case Stream{queue,positions,frameStart} True{}: Stream{queue,positions,frameStart}',
     'overflow-successful-retry', 'flowStream'),
]

NEGATIVES = [
    'negative-undeclared-transition.bend',
    'negative-reader-schema.bend',
    'negative-transition-write.bend',
    'negative-reader-instance-duplicate.bend',
]


def apply(label, text):
    entry = next(m for m in MUTANTS if m[0] == label)
    assert text.count(entry[2]) == 1, (label, 'nonunique mutation seam')
    return text.replace(entry[2], entry[3])


def witness(label, raw, model):
    entry = next(m for m in MUTANTS if m[0] == label)
    actual = model.structure(raw)
    expected = model.expected()
    result = []
    for schema in ['A', 'B']:
        observed = next(r for r in actual[schema] if r['label'] == entry[4])
        wanted = next(r for r in expected[schema] if r['label'] == entry[4])
        assert observed['fields'][entry[5]] != wanted['fields'][entry[5]], (label, schema, 'missing named witness')
        result.append({'schema': schema, 'checkpoint': entry[4], 'field': entry[5]})
    return result
