"""Independently reproduce the existing TS Sparse logical/assertion hashes."""
import hashlib
import json


def compact(value):
    return json.dumps(value, separators=(',', ':'))


def digest(value):
    return hashlib.sha256(compact(value).encode()).hexdigest()


def rows(delta, count=64):
    return [{'rawId': j + 1, 'main': {'levels': [j + delta, j + 1, j + 2, j + 3], 'reserve': 9, 'class': 2},
             'aux': {'layers': [1, 2, 3, 4], 'grade': 3} if j % 3 == 0 else None,
             'flag': {'group': 8} if j % 3 == 1 else None} for j in range(0, count, 8)]


def checksum(values):
    total = 0
    for row in values:
        data = [row['rawId'], *row['main']['levels'], row['main']['reserve'], row['main']['class'], row['aux'] is not None]
        if row['aux'] is not None:
            data += [*row['aux']['layers'], row['aux']['grade']]
        data += [row['flag'] is not None]
        if row['flag'] is not None:
            data += [row['flag']['group']]
        for value in data:
            total = (total * 33 + int(value)) % 2147483647
    return total


def derived(count=64, iterations=64):
    audits = []
    for iteration in range(iterations):
        full = rows(iteration + 1, count)
        sets = {'optional': full, 'present': [r for r in full if r['aux'] is not None],
                'absent': [r for r in full if r['aux'] is None]}
        audits.append({'readSum': sum(4 * j + 6 + iteration for j in range(0, count, 8)),
                       'updated': len(full), 'selections': {key: {'length': len(value), 'checksum': checksum(value)}
                                                          for key, value in sets.items()}})
    final = {'rows': rows(iterations, count),
             'ledger': {'totals': [len(rows(0, count)) * iterations, 101, 102, 103], 'epoch': 4}}
    return final, audits
