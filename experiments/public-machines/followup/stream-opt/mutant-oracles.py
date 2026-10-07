"""Independent literal full-application expectations for the five finite defects.

The original complete model owns every unaffected field. Closed publication-index
ranges below describe the exact retained batches, deliveries and cursor/drop
observations at all seven checkpoints; this module does not execute queue code.
"""
import copy

LABELS = ['queue-capacity', 'cached-size', 'oldest-newest-order', 'dropped-through', 'successful-cursor']
STARTS = [0, 2, 196611, 196614, 196614, 196615, 196616]


def expected(label, model):
    assert label in LABELS
    rows = copy.deepcopy(model.expected())
    listing = model.listing

    def stream(values, index, dropped, cursor):
        batches = listing(f'{6 + value * 3}:[{value}>{value + 1}]' for value in values)
        positions = listing([f'2:{cursor}:2'] if index >= 1 else [])
        return f'batches={batches},positions={positions},dropped={dropped},frameStart={STARTS[index]}'

    def deliveries(values, lagged, count, empty_last=True):
        payload = listing(f'{value}>{value + 1}' for value in values)
        full = 'values=' + payload + ',lagged=' + model.boolean(lagged)
        empty = 'values=[],lagged=false'
        result = [empty] + [full] * count
        if empty_last:
            result.append(empty)
        return listing(result)

    for schema in ['A', 'B']:
        fields = [row['fields'] for row in rows[schema]]
        if label == 'queue-capacity':
            # Capacity65537 keeps publication0 too, so no lag before completion.
            for index in [3, 4, 5]:
                fields[index]['flowStream'] = stream(range(65537), index, 0, 196616 if index == 5 else 0)
            for index in [4, 5, 6]:
                fields[index]['deliveries'] = deliveries(range(65537), False, 1 if index == 4 else 2, index == 6)
        elif label == 'cached-size':
            # Each singleton adds2 to the cache but eviction subtracts1. Before
            # publication32770, excess2 starts removing two real oldest batches
            # per subsequent publication. The final pre-trim state retains only
            # publication65536; its cache is65538 and droppedThrough196611.
            fields[2]['flowStream'] = stream([65536], 2, 196611, 0)
            # The next frame removes that last batch. Its stale cache cannot
            # create additional real batches; all following payloads are empty.
            for index in [3, 4, 5, 6]:
                fields[index]['flowStream'] = stream([], index, 196614, 196616 if index == 5 else 196617 if index == 6 else 0)
            for index in [4, 5, 6]:
                fields[index]['deliveries'] = deliveries([], True, 1 if index == 4 else 2, index == 6)
        elif label == 'oldest-newest-order':
            # Publication0 already occupies front during the publishing loop.
            # Capacity evicts it, then normalizes back without reversal, making
            # retained publication indices65536..1 descending until completion.
            for index in [3, 4, 5]:
                fields[index]['flowStream'] = stream(range(65536, 0, -1), index, 6, 196616 if index == 5 else 0)
            for index in [4, 5, 6]:
                fields[index]['deliveries'] = deliveries(range(65536, 0, -1), True, 1 if index == 4 else 2, index == 6)
        elif label == 'dropped-through':
            # Eviction still removes the exact normal batches, but its watermark
            # stays0. Both nonempty reader observations therefore report no lag.
            for index in [3, 4, 5, 6]:
                values = range(1, 65537) if index < 6 else []
                fields[index]['flowStream'] = stream(values, index, 0, 196616 if index == 5 else 196617 if index == 6 else 0)
            for index in [4, 5, 6]:
                fields[index]['deliveries'] = deliveries(range(1, 65537), False, 1 if index == 4 else 2, index == 6)
        else:
            # Successful completion leaves cursor0, preserving all retained
            # batches and repeating every value on the final successful read.
            for index in [5, 6]:
                fields[index]['flowStream'] = stream(range(1, 65537), index, 6, 0)
            fields[6]['deliveries'] = deliveries(range(1, 65537), True, 3, False)
    return rows


def validate(label, raw, model, frozen_expected):
    actual = model.structure(raw)
    assert frozen_expected == expected(label, model), (label, 'frozen mutant oracle drift')
    for schema in ['A', 'B']:
        for got, wanted in zip(actual[schema], frozen_expected[schema]):
            assert got == wanted, (label, schema, got['label'], next((key for key in model.FIELD_NAMES if got['fields'][key] != wanted['fields'][key]), 'row'))
    return actual
