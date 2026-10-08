"""Independent complete public oracle, authored before backend execution.

Inputs are the public operation sequence, not observed adapter output. Each
phase fixes membership and exact method outcomes for all four declarations.
"""
import json

PHASES = {
    'reserved': {
        'required': ([], 'MissingEntity:1'),
        'optional': ([], 'MissingEntity:1'),
        'added': ([], 'MissingEntity:1'),
        'changed': ([], 'MissingEntity:1'),
    },
    'absent': {
        'required': ([], 'QueryMismatch:1'),
        'optional': (['1:absent'], 'Found:1:absent'),
        'added': ([], 'QueryMismatch:1'),
        'changed': ([], 'QueryMismatch:1'),
    },
    'one': {
        'required': (['1:[11, 11, 11, 14]'], 'Found:1:[11, 11, 11, 14]'),
        'optional': (['1:[11, 11, 11, 14]'], 'Found:1:[11, 11, 11, 14]'),
        'added': (['1:[11, 11, 11, 14]'], 'Found:1:[11, 11, 11, 14]'),
        'changed': (['1:[11, 11, 11, 14]'], 'Found:1:[11, 11, 11, 14]'),
    },
    'one-repeat': {
        'required': (['1:[11, 11, 11, 14]'], 'Found:1:[11, 11, 11, 14]'),
        'optional': (['1:[11, 11, 11, 14]'], 'Found:1:[11, 11, 11, 14]'),
        'added': ([], 'QueryMismatch:1'),
        'changed': ([], 'QueryMismatch:1'),
    },
    'many': {
        'required': (['1:[11, 11, 11, 14]', '2:[31, 31, 31, 34]'], 'Found:1:[11, 11, 11, 14]'),
        'optional': (['1:[11, 11, 11, 14]', '2:[31, 31, 31, 34]'], 'Found:1:[11, 11, 11, 14]'),
        'added': (['2:[31, 31, 31, 34]'], 'QueryMismatch:1'),
        'changed': (['2:[31, 31, 31, 34]'], 'QueryMismatch:1'),
    },
    'many-repeat': {
        'required': (['1:[11, 11, 11, 14]', '2:[31, 31, 31, 34]'], 'Found:1:[11, 11, 11, 14]'),
        'optional': (['1:[11, 11, 11, 14]', '2:[31, 31, 31, 34]'], 'Found:1:[11, 11, 11, 14]'),
        'added': ([], 'QueryMismatch:1'),
        'changed': ([], 'QueryMismatch:1'),
    },
}

def complete_text():
    lines = []
    for schema in ['Workshop', 'Garden']:
        lines.append(schema)
        for phase, queries in PHASES.items():
            lines.append(phase)
            for name, (rows, lookup) in queries.items():
                if len(rows) == 0:
                    single, optional = 'NoEntities', 'None'
                elif len(rows) == 1:
                    single = optional = 'Found:' + rows[0]
                else:
                    single = optional = 'MultipleEntities:' + str(len(rows))
                lines.append(name + '|each=[' + ', '.join(rows) + ']|get=' + lookup
                             + '|single=' + single + '|optional=' + optional)
            lines.append('score=[21, 21, 21, 24]')
    return '\n'.join(lines) + '\n'

EXPECTED = complete_text()
if __name__ == '__main__':
    print(json.dumps(EXPECTED))
